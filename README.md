# github-action-make-go-github-file

## Synopsis

Make a github.go file.

## Overview

The GitHub Action creates a pull request with updated values in `github.go`.

## Inputs

| Input          | Description                                                                                       | Required | Default               |
| -------------- | ------------------------------------------------------------------------------------------------- | -------- | --------------------- |
| `file`         | The file to create.                                                                               | No       | `cmd/github.go`       |
| `package`      | The package name for the package statement.                                                       | No       | `cmd`                 |
| `actor`        | GitHub actor for signed commits. Must correspond to the noreply email used to create the GPG key. | No       |                       |
| `github_token` | GitHub token for Git push authentication.                                                         | No       | `${{ github.token }}` |

## Prerequisites

The calling workflow **must** checkout the repository before using this action.
The checkout step should use `persist-credentials: false` and `fetch-depth: "0"`.

## Usage

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `cmd/github.go` file for "package cmd".
   Example:

   ```yaml
   name: make-go-github-file.yaml

   on:
     push:
       tags:
         - "[0-9]+.[0-9]+.[0-9]+"

   jobs:
     build:
       name: Update cmd/github.go
       runs-on: ubuntu-latest
       steps:
         - name: Checkout repository
           uses: actions/checkout@v4
           with:
             fetch-depth: "0"
             persist-credentials: false
         - name: Make github.go file
           uses: Senzing/github-action-make-go-github-file@v2
   ```

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `example/example.go` file for "package myexample".
   Example:

   ```yaml
   name: make-go-github-file.yaml

   on:
     push:
       tags:
         - "[0-9]+.[0-9]+.[0-9]+"

   jobs:
     build:
       name: Update cmd/github.go
       runs-on: ubuntu-latest
       steps:
         - name: Checkout repository
           uses: actions/checkout@v4
           with:
             fetch-depth: "0"
             persist-credentials: false
         - name: Make github.go file
           uses: Senzing/github-action-make-go-github-file@v2
           with:
             file: example/example.go
             package: myexample
   ```

1. A `.github/workflows/make-go-github-file.yaml` file
   that creates a `cmd/github.go` file for "package cmd"
   using a signed commit.
   Example:

   ```yaml
   name: make-go-github-file.yaml

   on:
     push:
       tags:
         - "[0-9]+.[0-9]+.[0-9]+"

   jobs:
     build:
       name: Update cmd/github.go
       runs-on: ubuntu-latest
       steps:
         - name: Checkout repository
           uses: actions/checkout@v4
           with:
             fetch-depth: "0"
             persist-credentials: false
         - name: Import GPG key
           uses: crazy-max/ghaction-import-gpg@v6
           with:
             gpg_private_key: ${{ secrets.GPG_PRIVATE_KEY }}
             passphrase: ${{ secrets.PASSPHRASE }}
             git_user_signingkey: true
             git_commit_gpgsign: true
         - name: Make github.go file
           uses: Senzing/github-action-make-go-github-file@v2
           with:
             actor: ${{ secrets.ACTOR }}
   ```
