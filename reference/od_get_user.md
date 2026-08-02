# Get a single user

Get a single user

## Usage

``` r
od_get_user(user, conn = NULL, use_internal_id = FALSE)
```

## Arguments

- user:

  Login name or numeric user id.

- conn:

  Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).

- use_internal_id:

  If `TRUE`, treat `user` as the internal REST id.

## Value

Parsed user object (list).
