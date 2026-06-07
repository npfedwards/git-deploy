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

Releases are tagged (`v0.8.0`, etc.) and published to RubyGems as `git-deploy-ng`. Maintainers cut releases from `master` after CI passes.

## Internal planning

Working notes may live in a local `plans/` directory (gitignored). [ROADMAP.md](ROADMAP.md) lists ideas under consideration — open an issue to discuss priorities.
