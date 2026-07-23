# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.9.1] - 2026-07-23

### Fixed
- Pass remote when setup invokes hooks


## [0.9.0] - 2026-07-04

### Added
- Add framework templates for init including PHP/composer
- Add git deploy download for pulling files from the server
- Auto-update CHANGELOG on release

### Changed
- Add README.md and AGENTS.md, retire README.markdown

### Fixed
- Require remote and guard setup against destructive overwrites
- Resolve relative scp-style remote paths against remote $HOME
- Warn on init when deploy path collides with existing files


## [0.8.0] - 2026-06-10

### Added

- Ruby 3.x and 4.x compatibility; dynamic default branch detection
- Publish as `git-deploy-ng` on RubyGems
- GitHub Actions CI (Ruby 2.7–4.0) and gem build verification
- Clear error when ed25519 SSH gems are missing

### Changed

- Dependency upgrades (Thor, net-ssh, net-scp)
