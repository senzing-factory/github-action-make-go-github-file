# github-action-make-go-github-file

Make a version.go file

## Usage

1. Example `.github/workflows/github-action-make-go-version-file.yaml` file:


    ```yaml
    name: make-go-version-file.yaml

    on:
      push:
        tags:
          - "[0-9]+.[0-9]+.[0-9]+"

    jobs:
      build:
        name: Update cmd/version.go
        runs-on: ubuntu-latest
        steps:
          - name: Checkout repository
            uses: actions/checkout@v3
            with:
              fetch-depth: '0'
          - name: Make github.go file
            uses: Senzing/github-action-make-go-github-file@main
    ```
