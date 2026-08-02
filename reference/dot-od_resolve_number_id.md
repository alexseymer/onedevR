# Resolve a UI number via query variants until one succeeds

Resolve a UI number via query variants until one succeeds

## Usage

``` r
.od_resolve_number_id(kind, number, conn, label)
```

## Arguments

- kind:

  One of `"issue"`, `"build"`, `"pull"`.

- number:

  UI number.

- conn:

  Connection list.

- label:

  Human label for errors (`"issue"`, `"build"`, …).

## Value

Character internal id.
