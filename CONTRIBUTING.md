# Contributing

Thank you for contributing to git-deploy-ng. This project continues [mislav/git-deploy](https://github.com/mislav/git-deploy) — v0.8.x preserved upstream compatibility; v0.9.0 introduces minor CLI changes (see [Backwards compatibility](#backwards-compatibility)).

## Getting started

```bash
git clone https://github.com/npfedwards/git-deploy.git
cd git-deploy
bundle install
bundle exec rspec
```

## Pull requests

1. Fork the repo and create a feature branch from `master`.
2. Add or update tests for any behaviour change. We use RSpec and prefer integration-style tests through public interfaces.
3. Keep the CLI, hook defaults, and deploy callback contract backwards-compatible unless explicitly discussed in an issue.
4. Open a PR with a clear description of the user-facing behaviour change.

## Backwards compatibility

### v0.8.x

Must not break existing users migrating from upstream 0.7.0:

- Same `git deploy` subcommands and flags
- Same default `post-receive` hook behaviour (improvements are opt-in via `git deploy hooks`)
- Existing `deploy/` callback scripts in deployed apps should keep working unchanged

### v0.9.0

Minor intentional compatibility changes — called out in release notes. **Existing `deploy/*` callbacks in deployed apps stay unchanged.**

| Change | Notes |
|--------|-------|
| Required `-r` on remote commands | No default remote (was `origin` in older docs) |
| Setup safety | `setup` requires explicit remote; `--force` to overwrite hooks |
| Init collision guard | Warn when `deploy/` non-empty; abort if `deploy` is a file |
| Relative remote paths | SCP-style paths without leading `/` resolve against remote `$HOME` |
| New commands / flags | `download`, `init --template` |

See [ROADMAP.md](ROADMAP.md#v090-in-progress) for scope.

## Releases

Releases are published to [RubyGems](https://rubygems.org/gems/git-deploy-ng) as `git-deploy-ng` via GitHub Actions when a version tag is pushed.

### Cutting a release

1. Bump `gem.version` in `git-deploy-ng.gemspec` on `master` and merge.
2. Update the changelog from conventional commits since the last tag:

    ```bash
    ruby bin/update-changelog
    git add CHANGELOG.md git-deploy-ng.gemspec
    git commit -m "chore: prepare release X.Y.Z"
    ```

3. Ensure CI is green on `master`.
4. Tag the release commit (tag must match the gemspec version):

    ```bash
    git tag v0.9.0
    git push origin master
    git push origin v0.9.0
    ```

5. The **Release** workflow verifies the changelog, creates a GitHub Release, and publishes to RubyGems.

## Internal planning

Working notes may live in a local `plans/` directory (gitignored). [ROADMAP.md](ROADMAP.md) lists ideas under consideration — open an issue to discuss priorities.
