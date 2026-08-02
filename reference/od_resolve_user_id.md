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
