# Live Integration Tests

The onedevR package includes comprehensive live integration tests that
validate functionality against a real OneDev instance. These tests are
separate from unit tests and require network access to an OneDev server.

## Quick Start

### 1. Set up credentials for git.seymer.at

Create a `.Renviron` file in the project root (gitignored):

    ONEDEV_HOST=https://git.seymer.at
    ONEDEV_API_TOKEN=your-personal-access-token
    ONEDEV_PROJECT_PATH=your-group/your-project
    ONEDEV_PROJECT_ID=123
    ONEDEV_RUN_LIVE_TESTS=1

Or set environment variables directly:

``` bash
export ONEDEV_HOST=https://git.seymer.at
export ONEDEV_API_TOKEN=your-personal-access-token
export ONEDEV_PROJECT_PATH=your-group/your-project
export ONEDEV_PROJECT_ID=123
export ONEDEV_RUN_LIVE_TESTS=1
```

### 2. Generate an API token

1.  Log in to <https://git.seymer.at>
2.  Go to Settings → Personal → Access Tokens
3.  Generate a new token with appropriate scopes (e.g., “repo”, “build”,
    “issue”)
4.  Copy the token and set it as `ONEDEV_API_TOKEN`

### 3. Run live tests

Run all live tests:

``` r
Rscript -e 'devtools::test(filter = "live")'
```

Or run from R:

``` r

devtools::test(filter = "live")
```

Run a specific live test:

``` r

devtools::test(filter = "od_stream_query_results")
```

## What’s tested

Live tests cover:

### Core API

- Issue CRUD and queries
- Pull request queries and metadata
- Build queries and logs
- Project and user endpoints
- Repository branches and commits

### Performance Features (Phase 3)

- **Streaming** – `od_stream_query_results()`, `od_chunked_foreach()`,
  `od_stream_build_log()`
- **Caching** – `od_enable_cache()`, `od_disable_cache()`, cache
  statistics
- **Batch Operations** – `od_batch_create_issues()` (create-only, no
  mutations)

### Optional Features

- Build artifacts listing
- File text retrieval
- Query descriptions
- Build status keywords

## Test isolation

Live tests are isolated by:

1.  **Conditional execution** – All skip if
    `ONEDEV_RUN_LIVE_TESTS != "1"`
2.  **Credential checks** – Skip if credentials are missing
3.  **Graceful degradation** – Skip if an endpoint is unavailable (e.g.,
    no artifacts for a build)
4.  **Read-only by default** – Most tests only read; batch operations
    are create-only and can be cleaned up

## Debugging

To see detailed output:

``` r

devtools::test(filter = "live", reporter = "summary")
```

To run a single test with detailed output:

``` r

testthat::test_file("tests/testthat/test-live.R", reporter = "summary")
```

Check actual OneDev API responses:

``` r

# In R console with credentials set
od_set_connection(od_connection(
  host = Sys.getenv("ONEDEV_HOST"),
  token = Sys.getenv("ONEDEV_API_TOKEN")
))

# Query to verify setup
od_query_projects(count = 1L)
od_get_me()
```

## CI/CD Integration

Live tests are skipped in CI by default (no `ONEDEV_RUN_LIVE_TESTS` env
var set). To enable:

1.  Add `ONEDEV_RUN_LIVE_TESTS=1` to GitHub Actions secrets
2.  Add `ONEDEV_API_TOKEN` to GitHub Actions secrets (or use existing
    credential)
3.  Update `.github/workflows/R-CMD-check.yaml` to pass the env vars:

``` yaml
env:
  GITHUB_PAT: ${{ secrets.GITHUB_TOKEN }}
  ONEDEV_RUN_LIVE_TESTS: 1
  ONEDEV_API_TOKEN: ${{ secrets.ONEDEV_API_TOKEN }}
  ONEDEV_HOST: https://git.seymer.at
  ONEDEV_PROJECT_PATH: your-group/your-project
  ONEDEV_PROJECT_ID: 123
```

Then live tests will run as part of the check workflow.

## Troubleshooting

### Tests skip silently

- Check `ONEDEV_RUN_LIVE_TESTS=1` is set
- Verify `ONEDEV_API_TOKEN` is non-empty
- Verify `ONEDEV_HOST` is reachable: `curl https://git.seymer.at/api`

### Authentication fails

- Regenerate the API token
- Verify token has appropriate scopes
- Check token hasn’t expired

### Endpoint unavailable

- The test will skip gracefully
- Check OneDev version supports the endpoint
- Verify project/branch/build IDs exist

### Build log empty

- Some builds may not have logs available
- Test checks for this and skips appropriately

## Best Practices

1.  **Keep test credentials secure** – Never commit `.Renviron` or API
    tokens
2.  **Use a test project** – Create a dedicated test project if possible
3.  **Clean up after batch tests** – The batch creation tests create
    issues; clean them up manually or via test project reset
4.  **Monitor rate limits** – OneDev may have API rate limits; space out
    test runs
5.  **Test both success and edge cases** – Live tests intentionally fail
    gracefully when data is unavailable

## Adding new live tests

When adding new endpoints, add corresponding live tests to
`tests/testthat/test-live.R`:

``` r

test_that("od_new_function live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  skip_if_not(nzchar(Sys.getenv("ONEDEV_HOST")))

  result <- od_new_function(...)
  expect_true(condition_on_result)
})
```

Remember to skip gracefully if the endpoint might not be available or if
prerequisites (e.g., existing data) aren’t present.
