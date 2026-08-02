# Try several request body shapes until one succeeds

OneDev installations/versions accept different payload shapes for the
same endpoint (see `project_plan.md` §10). Tries each variant in order.

## Usage

``` r
.od_request_with_variants(method, endpoint, body_variants, conn = NULL)
```
