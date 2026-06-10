# Contributing

Thank you for contributing to git-deploy-ng. This project is a backwards-compatible continuation of [mislav/git-deploy](https://github.com/mislav/git-deploy).

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

v0.8.x must not break existing users migrating from upstream 0.7.0:

- Same `git deploy` subcommands and flags
- Same default `post-receive` hook behaviour (improvements are opt-in via `git deploy hooks`)
- Existing `deploy/` callback scripts in deployed apps should keep working unchanged

## Releases

Releases are published to [RubyGems](https://rubygems.org/gems/git-deploy-ng) as `git-deploy-ng` via GitHub Actions when a version tag is pushed.

### Cutting a release

1. Bump `gem.version` in `git-deploy-ng.gemspec` on `master` and merge.
2. Ensure CI is green on `master`.
3. Tag the release commit (tag must match the gemspec version):

    ```bash
    git tag v0.9.0
    git push origin v0.9.0
    ```

4. The **Release** workflow runs tests and publishes to RubyGems.

### One-time setup (maintainers)

Add a [RubyGems API key](https://guides.rubygems.org/api-key-scopes/) to the repository:

- GitHub → Settings → Secrets and variables → Actions
- Secret name: `RUBYGEMS_API_KEY`
- Value: your RubyGems API key with **push** scope for `git-deploy-ng`

The workflow will fail until this secret is configured.

## Internal planning

Working notes may live in a local `plans/` directory (gitignored). [ROADMAP.md](ROADMAP.md) lists ideas under consideration — open an issue to discuss priorities.
