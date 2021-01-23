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

## More details

The default behavior of [`actions/checkout`] v2 is to only fetch a single commit
because 1) often that commit is all that's needed and 2) fetching only one
commit is much faster than fetching everything, especially in large
repositories. If more history is needed, the `fetch-depth` input can be passed
to `actions/checkout` to fetch a number of commits up to the current commit (or
all history for all branches and tags via `fetch-depth: 0`). However, there's no
"fetch all commits within the current pull request" option (the depth of which
can vary greatly from one pull request to another). That's what this action
aims to provide!

The way this action works is by iteratively [deepening] the history of the
shallow clone until the common ancestor of the pull request source branch and
target branch (i.e. the [`merge-base`]) has been found. By default, the action
uses `--deepen=10`, but this can be tuned through the `deepen_length` action
input to optimize the `git fetch` calls for a given repository. The tradeoff of
setting a large `deepen_length` is that the action may fetch more unnecessary
commits when running on a pull request that only has a few commits. On the other
hand, setting a small `deepen_length` may lead to many `git fetch` calls in a
row in order to fetch all the commits of a large PR, with each call incurring
additional overhead.

Note: For small repositories, `actions/checkout` with `fetch-depth: 0` may
finish quickly, so feel free to just use that initially. This action can be
swapped in later when the repository has grown to the point where fetching the
full history is slow.

[`actions/checkout`]: https://github.com/actions/checkout
[deepening]: https://git-scm.com/docs/git-fetch#Documentation/git-fetch.txt---deepenltdepthgt
[`merge-base`]: https://git-scm.com/docs/git-merge-base
