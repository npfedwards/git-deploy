# AGENTS.md

Terse context for AI coding agents working in this repo.

## Project

**git-deploy-ng** — Ruby gem, CLI `git deploy`. Push-based deploy over SSH (Thor + net-ssh). Community fork of mislav/git-deploy. v0.8.x stayed compatible with upstream 0.7.0; **v0.9.0** has minor CLI changes (see `CONTRIBUTING.md`). Servers only need bash/git.

## Layout

```
bin/git-deploy              # CLI entry
lib/git_deploy.rb           # Thor commands
lib/git_deploy/             # configuration, SSH, generator
lib/hooks/post-receive.sh   # installed on server at setup
lib/git_deploy/templates/   # init callback templates (per stack)
spec/                       # RSpec — integration-style, public interfaces
```

## Conventions

- **Tests:** `bundle exec rspec`. Add/update specs for behaviour changes. Prefer integration tests through CLI/generator/public APIs, not implementation details.
- **Compat:** Don't break existing `deploy/` callbacks or CLI without explicit issue discussion. Hook behaviour changes are opt-in via `git deploy hooks`.
- **Scope:** Minimal diffs. Match existing style (Thor options, module mixins, shell hooks).
- **Commits:** Conventional commits (`feat:`, `fix:`, `docs:`, `ci:`). Don't commit unless asked.
- **Git:** No force push, no destructive git ops without explicit user request.

## Key behaviour

- Remote commands require `-r <remote>` (v0.9+).
- `deploy_to` parsed from git remote URL; relative scp paths resolve against remote `$HOME`.
- `Generator` (Thor::Group) writes `deploy/*` from template dir on `git deploy init`.
- SSH via `Net::SSH` / `Net::SCP`; ed25519 needs optional `ed25519` + `bcrypt_pbkdf` gems.

## Release

- Gem: `git-deploy-ng` (not `git-deploy`).
- Version in `git-deploy-ng.gemspec`. Tag `vX.Y.Z` triggers RubyGems publish (needs `RUBYGEMS_API_KEY` secret).
- CI: `.github/workflows/ci.yml` (matrix test + gem build), `release.yml` (tag publish).

## Docs

- User-facing: `README.md`
- Contributors: `CONTRIBUTING.md`
- Planning: `ROADMAP.md`, local `tmp/` (gitignored)
