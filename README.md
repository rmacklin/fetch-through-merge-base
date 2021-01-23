# fetch-through-merge-base

A GitHub Action for fetching PR commits through the merge-base

## Usage

By default, the action will pull the "base ref" and "head ref" from the
[`github` context], i.e. `${{ github.base_ref }}` and `${{ github.head_ref }}`.

This means usage can be as simple adding
`- uses: rmacklin/fetch-through-merge-base@v0` to any `pull_request` workflow:

```yml
name: Example Workflow
on: pull_request

jobs:
  example_job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
        with:
          ref: ${{ github.head_ref }}
      - uses: rmacklin/fetch-through-merge-base@v0
      # now we've fetched commits through the merge-base of the source branch
      # and target branch of the pull request, so we can do things like:
      - run: git merge-base ${{ github.base_ref }} ${{ github.head_ref }}
      - run: git log --oneline ${{ github.base_ref }}..
      - run: git diff --name-only ${{ github.base_ref }}...
```

[`github` context]: https://docs.github.com/en/actions/reference/context-and-expression-syntax-for-github-actions#github-context

Note that the `${{ github.base_ref }}` and `${{ github.head_ref }}` properties
are only available when the event that triggers the workflow is `pull_request`.
So, in order to use this action in a workflow that is triggered by a different
event, like `push`, the refs must be passed as inputs to the action. The
following example fetches commits through the merge-base of the `main` branch
and the commit that triggered the workflow run:

```yml
name: Example Workflow
on: push

jobs:
  example_job:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: rmacklin/fetch-through-merge-base@v0
        with:
          base_ref: main
          head_ref: ${{ github.sha }}
```
