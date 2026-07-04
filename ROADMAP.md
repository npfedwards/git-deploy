# Roadmap

Tracking for git-deploy-ng. **Nothing listed here is a commitment** — items may be reprioritised, dropped, or implemented differently. Any change that affects default behaviour will be called out explicitly in release notes.

## v0.8.0 (released)

| Fix | Upstream context |
|-----|------------------|
| Ruby 3.x compatibility | [#88](https://github.com/mislav/git-deploy/issues/88), [#67](https://github.com/mislav/git-deploy/issues/67) |
| Dynamic default branch (`main` / `master`) | Hardcoded `master` in setup |
| Dependency upgrades (Thor, net-ssh, net-scp) | OpenSSL / Ruby 3.2+ SSH failures |
| Modern CI (GitHub Actions, Ruby 2.7–4.0) | Travis CI retired |
| Publish as `git-deploy-ng` on RubyGems | Avoids namespace conflict with upstream gem |

## v0.9.0 (in progress)

Minor CLI compatibility changes from v0.8.x. **Deployed `deploy/*` callbacks are unchanged** — see [CONTRIBUTING.md § Backwards compatibility](CONTRIBUTING.md#backwards-compatibility).

| Change | Issue / PR |
|--------|------------|
| Required `-r` on remote commands | [#78](https://github.com/mislav/git-deploy/issues/78) |
| Setup safety (`--force` for hook overwrite) | [#78](https://github.com/mislav/git-deploy/issues/78) |
| Init collision warning | [#56](https://github.com/mislav/git-deploy/issues/56) |
| Relative remote path resolution | [#57](https://github.com/mislav/git-deploy/issues/57) |
| Framework init templates (`--template`) | [#4](https://github.com/npfedwards/git-deploy/issues/4), [#92](https://github.com/mislav/git-deploy/issues/92) |
| `git deploy download` | [#83](https://github.com/mislav/git-deploy/issues/83) |
| README + AGENTS docs | [#53](https://github.com/mislav/git-deploy/issues/53) |

## Ideas under consideration (post-v0.8.0)

Sourced from upstream open issues and community discussion. If something here interests you, open an issue — priorities are not fixed.

| Idea | Source | Notes |
|------|--------|-------|
| Multi-server deploy | [#89](https://github.com/mislav/git-deploy/issues/89) | Single push triggers deploy on N hosts |
| Multiple environments | [#71](https://github.com/mislav/git-deploy/issues/71) | `staging` / `production` config profiles |
| Custom deploy script directory | [#75](https://github.com/mislav/git-deploy/issues/75) | Not hardcoded to `deploy/` |
| Rails 6+ default templates | [#92](https://github.com/mislav/git-deploy/issues/92) | Zeitwerk, credentials, modern asset pipeline |
| Improved PATH in hooks | [#68](https://github.com/mislav/git-deploy/issues/68) | rbenv/nvm/pyenv in non-login hook context |
| Windows client support | [#80](https://github.com/mislav/git-deploy/issues/80) | May remain unsupported; needs discussion |
| Homebrew distribution | — | `brew install` for macOS setup machines |
| Download remote files | [#83](https://github.com/mislav/git-deploy/issues/83) | `git deploy download` — inverse of `upload` |
| Hook dry-run | — | `git deploy rerun --noop` on server |
