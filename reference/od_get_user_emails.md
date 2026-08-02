# Get email addresses for a user

Get email addresses for a user

## Usage

``` r
od_get_user_emails(user = NULL, as_tibble = NULL, conn = NULL)
```

## Arguments

- user:

  Login name or numeric user id. Defaults to the authenticated user via
  [`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md)
  when `NULL`.

- as_tibble:

  If `TRUE` (default via `options(onedevr.as_tibble)`), return a tibble
  via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

A tibble of email addresses (default), or a list when
`as_tibble = FALSE`.

## See also

Other users:
[`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md),
[`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md),
[`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md),
[`od_resolve_user_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_user_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_user_emails()
} # }
```
