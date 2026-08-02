# Resolve a UI pull request number to the internal REST id

Same `"Number" is "<projectPath>#<n>"` convention as
[`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md)
/ [tod](https://github.com/theonedev/tod).

## Usage

``` r
od_resolve_pull_request_id(pull_request_number, conn = NULL)
```

## Arguments

- pull_request_number:

  UI number (`42` or `"#42"`).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character internal pull request id.
