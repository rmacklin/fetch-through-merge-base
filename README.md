# fetch-through-merge-base

A GitHub Action for fetching PR commits through the merge-base

## Usage

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
