# Dependabot Validator

[![Test](https://github.com/get-bridge/dependabot-validator/actions/workflows/test.yml/badge.svg)](https://github.com/get-bridge/dependabot-validator/actions/workflows/test.yml)

## Local Execution

    ./main.rb spec/fixtures/test_app spec/fixtures/test_app/.github/dependabot.yml

## GitHub Action

Add the following to your workflow (e.g. `.github/actions/test.yml`):

    jobs:
      test:
        runs-on: ubuntu-latest
        steps:
          - uses: actions/checkout@v3.0.1
          - uses: get-bridge/dependabot-validator@v1.0.0

## Testing the GitHub Action

[Act](https://github.com/nektos/act) is used to simulate a GitHub action run.
It can be invoked via `act`.
