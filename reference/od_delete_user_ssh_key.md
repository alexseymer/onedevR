# Delete an SSH key

**Experimental:** not yet verified against a live OneDev server (it
deletes a credential); the interface and behaviour may change.

## Usage

``` r
od_delete_user_ssh_key(ssh_key_id, conn = NULL)
```

## Arguments

- ssh_key_id:

  character\|numeric Numeric SSH key ID.

- conn:

  list Connection list from
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
  /
  [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md).
  Default: `NULL`.

## Value

list Parsed API response (typically `NULL` on success).

## Details

Removes an SSH public key with `DELETE /ssh-keys/{id}`. SSH key ids are
global, so no user is needed; list a user's keys with
[`od_list_user_ssh_keys()`](https://alexseymer.github.io/onedevR/reference/od_list_user_ssh_keys.md)
to find the id.

## See also

Other users:
[`od_add_group_member()`](https://alexseymer.github.io/onedevR/reference/od_add_group_member.md),
[`od_add_user_ssh_key()`](https://alexseymer.github.io/onedevR/reference/od_add_user_ssh_key.md),
[`od_get_group()`](https://alexseymer.github.io/onedevR/reference/od_get_group.md),
[`od_get_me()`](https://alexseymer.github.io/onedevR/reference/od_get_me.md),
[`od_get_user()`](https://alexseymer.github.io/onedevR/reference/od_get_user.md),
[`od_get_user_emails()`](https://alexseymer.github.io/onedevR/reference/od_get_user_emails.md),
[`od_list_group_members()`](https://alexseymer.github.io/onedevR/reference/od_list_group_members.md),
[`od_list_user_ssh_keys()`](https://alexseymer.github.io/onedevR/reference/od_list_user_ssh_keys.md),
[`od_query_groups()`](https://alexseymer.github.io/onedevR/reference/od_query_groups.md),
[`od_query_users()`](https://alexseymer.github.io/onedevR/reference/od_query_users.md),
[`od_remove_group_member()`](https://alexseymer.github.io/onedevR/reference/od_remove_group_member.md),
[`od_resolve_user_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_user_id.md),
[`od_whoami()`](https://alexseymer.github.io/onedevR/reference/od_whoami.md)

## Examples

``` r
if (FALSE) { # \dontrun{
od_delete_user_ssh_key(1)
} # }
```
