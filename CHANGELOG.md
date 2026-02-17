# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
[markdownlint](https://dlaa.me/markdownlint/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2026-02-17

### Breaking changes in 2.0.0

- Removed built-in `actions/checkout` step. The calling workflow must now
  checkout the repository before using this action (with `persist-credentials: false`
  and `fetch-depth: "0"`).

### Fixed in 2.0.0

- Fixed `artipacked` zizmor finding (redundant checkout without `persist-credentials: false`)
- Fixed `template-injection` zizmor findings (`${{ inputs.* }}` no longer used in `run:` lines)

### Added in 2.0.0

- `github_token` input for git push authentication via `gh auth setup-git`

## [1.0.3] - 2024-05-29

### Fixed in 1.0.3

- Fixed linting issue

## [1.0.2] - 2023-08-17

### Fixed in 1.0.2

- Fixed `gofmt` issue

## [1.0.1] - 2023-07-18

### Changed in 1.0.1

- Created a file that passes `gofmt` checking

## [1.0.0] - 2023-02-31

### Added to 1.0.0

- Initial release
