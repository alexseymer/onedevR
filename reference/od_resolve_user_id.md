# Resolve a OneDev login name to its numeric user id

Calls `GET /users/ids/{name}`. Numeric `user` values are returned as-is.

## Usage

``` r
od_resolve_user_id(user, conn = NULL)
```

## Arguments

- user:

  Login name or numeric user id.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

## Value

Character user id.

## See also

Other users:
[`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md),
[`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md),
[`od_get_user_emails()`](https://alexseymer.github.io/onedevR/reference/od_get_user_emails.md),
[`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_resolve_user_id("alice")
} # }
```
