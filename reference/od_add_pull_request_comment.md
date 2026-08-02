# Add a comment to a pull request

Posts to `POST /pull-request-comments` with `requestId` + `content`.

## Usage

``` r
od_add_pull_request_comment(pull_request_number, content, conn = NULL)
```

## Arguments

- pull_request_number:

  UI number.

- content:

  Comment body (Markdown).

- conn:

  Connection list.

## Value

Parsed API response.
