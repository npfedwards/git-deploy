# git-deploy-ng

Push-based deployment over SSH — a community continuation of [mislav/git-deploy](https://github.com/mislav/git-deploy), published on RubyGems as **git-deploy-ng**.

Deploy with a single git push:

```sh
git push production main
```

Only the person setting up deployment needs the gem on their machine. Production servers need **bash and git only** — no Ruby on the server.

- **CLI:** Same commands as upstream; **v0.9.0** introduces minor compatibility changes — see [Backwards compatibility](CONTRIBUTING.md#backwards-compatibility) and [ROADMAP.md](ROADMAP.md#v090-in-progress)
- **Ruby:** 2.7+ on the setup machine (including 4.x)
- **Auth:** SSH public keys (password auth not supported)

See also: [ROADMAP.md](ROADMAP.md) · [CONTRIBUTING.md](CONTRIBUTING.md) · [AGENTS.md](AGENTS.md)

---

## Table of contents

- [How it works](#how-it-works)
- [Installation](#installation)
- [Initial setup](#initial-setup)
- [Everyday deployments](#everyday-deployments)
- [Init templates](#init-templates)
- [Deploy callbacks](#deploy-callbacks)
- [CLI reference](#cli-reference)
- [Remote URL formats](#remote-url-formats)
- [Restart recipes](#restart-recipes)
- [Multiple environments](#multiple-environments)
- [Migrating from mislav/git-deploy](#migrating-from-mislavgit-deploy)
- [Which git-deploy?](#which-git-deploy)
- [Troubleshooting](#troubleshooting)
- [Development](#development)

---

## How it works

```
Developer machine                         Production server
─────────────────                         ─────────────────
git remote add production user@host:/app
git deploy setup -r production     ──SSH──►  mkdir /app, git init, install post-receive hook
git deploy init                    ──local►  generate deploy/* callbacks in your repo
git push production main           ──git──►  post-receive hook runs deploy/after_push
```

1. **`git deploy setup`** creates (or reuses) a git repository on the server and installs a `post-receive` hook.
2. **`git deploy init`** generates `deploy/` callback scripts in your application repo — commit these.
3. **`git push production <branch>`** updates the server working copy and runs callbacks.

The hook checks out the pushed branch, then executes scripts in `deploy/`. Output is appended to `log/deploy.log` on the server.

---

## Installation

```sh
gem install git-deploy-ng
```

Do **not** add it to your app's Gemfile. One developer runs setup once per project/host.

---

## Initial setup

### 1. Add a deploy remote

The remote name is arbitrary (`production`, `staging`, `online`, …):

```sh
git remote add production "user@example.com:/apps/mynewapp"
```

Use an **absolute** path (`/apps/...`) or a **home-relative** path (`apps/mynewapp` → `$HOME/apps/mynewapp`). See [Remote URL formats](#remote-url-formats).

### 2. Set up the server repository

```sh
git deploy setup -r production
```

This will:

- Create the deploy directory if missing
- Run `git init` (skipped if `.git` already exists)
- Install `post-receive` from `lib/hooks/post-receive.sh`
- Configure the remote HEAD to match your **current local branch** (`main` or `master`)

Options:

| Flag | Purpose |
|------|---------|
| `-r production` | **Required** — git remote name (no default) |
| `--force` / `-f` | Overwrite an existing `post-receive` hook |
| `--shared` / `-g` | Shared repository (`git init --shared`) |
| `--sudo` / `-s` | Create deploy dir with sudo |

### 3. Generate deploy callbacks

```sh
git deploy init --template rails-passenger
```

Commit the generated `deploy/` directory. Scripts run on the server during each deploy.

### 4. Push

```sh
git push production main
```

### 5. One-time server admin

On the server, configure your web server (nginx/Apache), database, environment variables, etc.

---

## Everyday deployments

```sh
git push production main
```

Push the branch that is checked out on the remote (configured during `setup`). Teammates deploy with plain `git push` — they do not need the gem installed.

### What the default Rails template does

On each deploy, `deploy/after_push` typically:

1. Syncs git submodules
2. Runs `deploy/before_restart` (bundle install, migrations, asset precompile)
3. Runs `deploy/restart` (app server restart)
4. Runs `deploy/after_restart` (if present)

Customize everything by editing `deploy/*` in your repo.

---

## Init templates

```sh
git deploy init --template <name>
```

| Template | Stack | Generated restart |
|----------|-------|-------------------|
| `rails-passenger` | Rails + Passenger | `touch tmp/restart.txt` |
| `rails-puma` | Rails + Puma | `pumactl restart` (with Passenger fallback) |
| `php-composer` | PHP + Composer | PHP-FPM reload via systemd |
| `generic` | Any | No-op — edit manually |

`rails-passenger` is the default. Templates only affect **new** `git deploy init` runs; existing `deploy/` scripts are never overwritten unless files are missing.

If `./deploy` exists as a **file** (not a directory), `init` aborts with an error. If `deploy/` is non-empty, existing files are preserved.

---

## Deploy callbacks

All scripts live in `deploy/` at the repo root. They are ordinary executables (shell, Ruby, anything). All are optional.

| Script | When it runs |
|--------|--------------|
| `deploy/setup` | First push to a new branch |
| `deploy/after_push` | Every subsequent push |
| `deploy/before_restart` | Called from `after_push` |
| `deploy/restart` | Called from `after_push` |
| `deploy/after_restart` | Called from `after_push` |
| `deploy/rollback` | `git deploy rollback` (instead of `after_push`) |

Hook entry point: `lib/hooks/post-receive.sh` (installed to `.git/hooks/post-receive` on the server).

---

## CLI reference

All commands that connect to a server **require** `-r <remote>`. There is no default remote.

Global options:

| Option | Description |
|--------|-------------|
| `-r`, `--remote` | Git remote name (**required** for remote commands) |
| `-n`, `--noop` | Print commands without executing |

| Command | Description |
|---------|-------------|
| `git deploy init [--template NAME]` | Generate `deploy/` callbacks locally |
| `git deploy setup -r REMOTE [--force]` | Create remote repo + install hook |
| `git deploy hooks -r REMOTE [--force]` | Refresh remote hook only |
| `git deploy log -r REMOTE [-l N] [-t]` | Tail deploy log (`-t` to follow) |
| `git deploy rerun -r REMOTE` | Re-run `after_push` on server |
| `git deploy restart -r REMOTE` | Run `deploy/restart` on server |
| `git deploy rollback -r REMOTE` | Reset to previous revision + callback |
| `git deploy upload -r REMOTE <files…>` | SCP local → server app dir |
| `git deploy download -r REMOTE <paths…>` | SCP server app dir → local |

---

## Remote URL formats

| Remote | Deploy path |
|--------|-------------|
| `user@host:/var/www/app` | `/var/www/app` (absolute) |
| `user@host:~/apps/app` | `~/apps/app` (home-relative) |
| `user@host:apps/app` | `$HOME/apps/app` (relative to remote `$HOME`) |
| `ssh://user@host:2222/path` | `/path` on port 2222 |

GitHub remotes are rejected — you cannot deploy to github.com.

---

## Restart recipes

Match `deploy/restart` to your app server:

**Passenger** (default template):

```sh
touch tmp/restart.txt
```

**Unicorn:**

```sh
kill -USR2 $(cat tmp/pids/unicorn.pid)
```

**Puma** — use `--template rails-puma`, or:

```sh
bundle exec pumactl -P tmp/pids/puma.pid restart
```

**PHP-FPM** — use `--template php-composer`, or:

```sh
sudo systemctl reload php-fpm
```

---

## Multiple environments

Use separate git remotes pointing at separate directories on the same (or different) host:

```sh
git remote add staging  user@server:~/apps/myapp-staging
git remote add production user@server:~/apps/myapp-production

git deploy setup -r staging
git deploy setup -r production

git push staging develop
git push production main
```

Same `deploy/` scripts usually work for both; set `RAILS_ENV` or equivalent in server environment or in the scripts.

---

## Migrating from mislav/git-deploy

1. `gem uninstall git-deploy` (optional)
2. `gem install git-deploy-ng`
3. `git deploy hooks -r production` on each host

Existing `deploy/` scripts in your apps do not need to change. After upgrading, refresh hooks on each host to pick up improvements.

**v0.9.0 compatibility changes:** Minor CLI changes (notably `-r` required on all remote commands). Full list: [CONTRIBUTING.md § Backwards compatibility](CONTRIBUTING.md#backwards-compatibility), [ROADMAP.md § v0.9.0](ROADMAP.md#v090-in-progress).

---

## Which git-deploy?

| Project | Model | Use when |
|---------|-------|----------|
| **git-deploy-ng** (this repo) | Push-based: `git push production main` | Heroku-style simplicity, modern Ruby |
| [mislav/git-deploy](https://github.com/mislav/git-deploy) | Original gem (archived ~0.7.0) | Legacy reference |
| [git-deploy/git-deploy](https://github.com/git-deploy/git-deploy) | Pull-based: `git deploy start/sync/finish` on a deploy host | Locking, deploy tags, multi-server sync from a staging machine |

---

## Troubleshooting

### `bundle` or `ruby` not found on push (but `git deploy rerun` works)

`git push` runs hooks in a non-interactive shell that may not load `.bashrc`. This is usually a **server environment** issue:

1. Initialize rbenv/rvm/nvm in `~/.profile` or `~/.bash_profile`, not only `.bashrc`.
2. Or add `deploy/env` on the server with PATH exports (sourced by the hook when present).

### SSH key authentication

Set up key auth with `ssh-copy-id` before running setup. Password auth is not supported.

### `unsupported key type ssh-ed25519`

```sh
gem install ed25519 bcrypt_pbkdf
```

git-deploy-ng prints this hint automatically when the gems are missing.

### Setup refuses to overwrite hooks

Use `--force` when re-running setup or hooks on an existing deployment:

```sh
git deploy setup -r production --force
```

---

## Development

```sh
git clone https://github.com/npfedwards/git-deploy.git
cd git-deploy
bundle install
bundle exec rspec
```

CI runs on Ubuntu and macOS against Ruby 2.7–4.0. Releases publish to RubyGems when a `v*` tag is pushed — see [CONTRIBUTING.md](CONTRIBUTING.md).

---

## License

MIT — see [LICENSE](LICENSE). Originally by [Mislav Marohnić](https://github.com/mislav); maintained by [Nathan Edwards](https://github.com/npfedwards).
