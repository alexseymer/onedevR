# Add a comment to an issue

Posts to `POST /issue-comments` with `issueId` + `content`.

## Usage

``` r
od_add_issue_comment(issue_number, content, conn = NULL)
```

## Arguments

- issue_number:

  UI number (`145` or `"#145"`).

- content:

  Comment body (Markdown).

- conn:

  Connection list.

## Value

Parsed API response.
