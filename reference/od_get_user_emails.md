# Get email addresses for a user

Get email addresses for a user

## Usage

``` r
od_get_user_emails(user = NULL, as_tibble = NULL, conn = NULL)
```

## Arguments

- user:

  character\|numeric Login name or numeric user id. Defaults to the
  authenticated user via
  [`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md)
  when `NULL`. Default: `NULL`.

- as_tibble:

  logical If `TRUE` (default via `options(onedevr.as_tibble)`), return a
  tibble via
  [`od_as_tibble()`](https://alexseymer.github.io/onedevR/reference/od_as_tibble.md).
  Default: `NULL`.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

tibble\|list A tibble of email addresses (default), or a list when
`as_tibble = FALSE`.

## See also

Other users:
[`od_add_group_member()`](https://alexseymer.github.io/onedevR/reference/od_add_group_member.md),
[`od_add_user_ssh_key()`](https://alexseymer.github.io/onedevR/reference/od_add_user_ssh_key.md),
[`od_delete_user_ssh_key()`](https://alexseymer.github.io/onedevR/reference/od_delete_user_ssh_key.md),
[`od_get_group()`](https://alexseymer.github.io/onedevR/reference/od_get_group.md),
[`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md),
[`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md),
[`od_list_group_members()`](https://alexseymer.github.io/onedevR/reference/od_list_group_members.md),
[`od_list_user_ssh_keys()`](https://alexseymer.github.io/onedevR/reference/od_list_user_ssh_keys.md),
[`od_query_groups()`](https://alexseymer.github.io/onedevR/reference/od_query_groups.md),
[`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md),
[`od_remove_group_member()`](https://alexseymer.github.io/onedevR/reference/od_remove_group_member.md),
[`od_resolve_user_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_user_id.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_get_user_emails()
} # }
```
