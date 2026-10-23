# Resolve iteration names to ids

Accepts numeric ids (returned as integers) and/or iteration names, which
are matched exactly against
[`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md).
Unknown names raise an error listing the available iterations.

## Usage

``` r
od_resolve_iteration_ids(iterations, project = NULL, conn = NULL)
```

## Arguments

- iterations:

  Character names and/or numeric ids.

- project:

  Optional project path or numeric id.

- conn:

  Connection list.

## Value

Integer vector of iteration ids.

## Examples

``` r
if (FALSE) { # \dontrun{
od_resolve_iteration_ids(c("Version 3.0.0", 17L))
} # }
```
