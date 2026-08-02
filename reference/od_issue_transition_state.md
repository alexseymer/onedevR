# Transition an issue to a new state

Tries the known body shapes (`list(state=)`, `list(transition=)`, raw
string) — see `project_plan.md` §10 and `tod issue change-state`.

## Usage

``` r
od_issue_transition_state(issue_number, state, conn = NULL)
```

## Arguments

- issue_number:

  UI number.

- state:

  Target state name (e.g. `"Closed"`).

- conn:

  Connection list.

## Value

Parsed API response.
