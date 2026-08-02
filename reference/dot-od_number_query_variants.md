# Build OneDev `"Number" is "..."` query variants for a UI number

Some OneDev versions accept `path#n`; others only accept bare `n` / `#n`
(path-prefixed values return HTTP 406 "Invalid number"). Try path form
first, then bare forms.

## Usage

``` r
.od_number_query_variants(project_path, number)
```
