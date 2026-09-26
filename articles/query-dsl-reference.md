# OneDev Query DSL Reference

## Overview

The **OneDev Query DSL** (Domain-Specific Language) is a powerful
filtering syntax used across issues, pull requests, builds, and
projects. This vignette provides a comprehensive reference for
constructing queries programmatically, with special attention to
patterns useful for AI and LLM-based automation.

### Quick Start

All query functions accept a `query` parameter with OneDev’s DSL syntax:

``` r

library(onedevr)

# Simple query
issues <- od_query_issues(
  query = '"State" is "Open"'
)

# Complex query combining multiple conditions
high_priority_open <- od_query_issues(
  query = '("State" is "Open") and ("Priority" is "High")'
)
```

To see the full grammar for your OneDev instance, use:

``` r

# View available fields and operators for each resource type
cat(od_get_query_description("issue"))
cat(od_get_query_description("build"))
cat(od_get_query_description("pull_request"))
cat(od_get_query_description("project"))
```

------------------------------------------------------------------------

## Query Basics

### Field Syntax

OneDev queries use **quoted field names** and **quoted values**:

``` r

# Basic equality
query = '"State" is "Open"'

# Numeric comparison
query = '"Number" >= 100'

# Empty/null checks
query = '"Assignee" is empty'
```

### Operators

| Operator | Use Case | Example |
|----|----|----|
| `is` | Exact match | `"State" is "Open"` |
| `is not` | Negation | `"Type" is not "Documentation"` |
| `>=`, `<=`, `>`, `<` | Numeric/date comparison | `"Number" >= 100` |
| `~` | Text contains | `"Title" ~ "bug"` |
| `is empty` | Null/unset fields | `"Assignee" is empty` |
| `is not empty` | Non-null fields | `"Assignee" is not empty` |

### Quoting Rules

- **Field names** are always quoted: `"State"`, `"Number"`, `"Priority"`
- **String values** are quoted: `"Open"`, `"High"`, `"alice"`
- **Numeric values** can be unquoted: `>= 100` or `"100"`
- **Special values** (functions, operators) are unquoted:
  `currentUser()`, `true`, `false`

``` r

# ✓ Correct
query = '"Assignee" is currentUser()'
query = '"Number" is "145"'
query = '"Priority" >= 1'

# ✗ Incorrect
# query = 'State is Open'              # Missing quotes
# query = '"State" is Open'             # Value needs quotes
# query = 'Number is "145"'             # Field needs quotes
```

------------------------------------------------------------------------

## Common Patterns by Resource Type

### Issues

#### Field Reference

Common issue fields in OneDev:

| Field | Type | Example |
|----|----|----|
| `Number` | Numeric (UI \#) | `"Number" is "145"` or `"Number" >= 100` |
| `State` | String enum | `"State" is "Open"` |
| `Type` | String enum | `"Type" is "Bug"` |
| `Priority` | String enum | `"Priority" is "High"` |
| `Assignee` | User name | `"Assignee" is "alice"` |
| `Title` | Text | `"Title" ~ "authentication"` |
| `Description` | Text | `"Description" ~ "critical"` |
| `Created` | Date/time | `"Created" > "2024-01-01"` |
| `Updated` | Date/time | `"Updated" > "2024-01-01"` |
| `Iteration` | Sprint/iteration name | `"Iteration" is "Sprint 5"` |

#### Issue Examples

``` r

# Open issues
open_issues <- od_query_issues(
  query = '"State" is "Open"'
)

# Issues assigned to me
my_issues <- od_query_issues(
  query = '"Assignee" is currentUser()'
)

# Unassigned high-priority bugs
urgent_unassigned <- od_query_issues(
  query = '("Assignee" is empty) and ("Priority" is "High") and ("Type" is "Bug")'
)

# Issues with specific assignee
alice_work <- od_query_issues(
  query = '"Assignee" is "alice"'
)

# Issues modified in last 7 days
recent_activity <- od_query_issues(
  query = '"Updated" > "2026-09-19"'
)

# Issues from number 100-200
specific_range <- od_query_issues(
  query = '("Number" >= 100) and ("Number" <= 200)'
)

# In specific iteration
sprint_work <- od_query_issues(
  query = '"Iteration" is "Sprint 5"'
)
```

### Pull Requests

#### Field Reference

Common PR fields in OneDev:

| Field           | Type            | Example                             |
|-----------------|-----------------|-------------------------------------|
| `Number`        | Numeric (UI \#) | `"Number" >= 10`                    |
| `Status`        | Keyword         | `open`, `merged`, `discarded`       |
| `Source Branch` | String          | `"Source Branch" is "feature/auth"` |
| `Target Branch` | String          | `"Target Branch" is "main"`         |
| `Author`        | User name       | `"Author" is "bob"`                 |
| `Reviewer`      | User name       | `"Reviewer" is "charlie"`           |
| `Title`         | Text            | `"Title" ~ "authentication"`        |

#### PR Examples

``` r

# Open pull requests
open_prs <- od_query_pull_requests(
  query = 'open'
)

# Recently merged PRs
merged_prs <- od_query_pull_requests(
  query = 'merged'
)

# PR from specific branch
feature_prs <- od_query_pull_requests(
  query = '"Source Branch" is "feature/auth"'
)

# PRs to main branch
main_prs <- od_query_pull_requests(
  query = '(open) and ("Target Branch" is "main")'
)

# PRs by author
bob_prs <- od_query_pull_requests(
  query = '("Author" is "bob")'
)

# Discarded PRs
discarded_prs <- od_query_pull_requests(
  query = 'discarded'
)
```

### Builds

#### Field Reference

Common build fields in OneDev:

| Field | Type | Example |
|----|----|----|
| `Number` | Numeric (UI \#) | `"Number" >= 100` |
| `Status` | Keyword | `successful`, `failed`, `cancelled`, `running`, `waiting` |
| `Branch` | String | `"Branch" is "main"` |
| `Commit` | Commit hash | `"Commit" is "abc1234567..."` |
| `Job` | Job name | `"Job" is "CI"` |

#### Build Examples

``` r

# Successful builds
success <- od_query_builds(
  query = 'successful'
)

# Failed builds
failures <- od_query_builds(
  query = 'failed'
)

# Successful builds on main
main_success <- od_query_builds(
  query = '(successful) and ("Branch" is "main")'
)

# Builds by job name
ci_builds <- od_query_builds(
  query = '"Job" is "CI"'
)

# Running builds
in_progress <- od_query_builds(
  query = 'running'
)

# Builds from specific commit
commit_builds <- od_query_builds(
  query = '"Commit" is "abc1234567..."'
)
```

### Projects

#### Field Reference

Common project fields in OneDev:

| Field         | Type              | Example                     |
|---------------|-------------------|-----------------------------|
| `Name`        | Text              | `"Name" ~ "auth"`           |
| `Path`        | Hierarchical path | `"Path" is "group/project"` |
| `Description` | Text              | `"Description" ~ "API"`     |

#### Project Examples

``` r

# Projects with "api" in name
api_projects <- od_query_projects(
  query = '"Name" ~ "api"'
)

# Projects in specific group
group_projects <- od_query_projects(
  query = '"Path" is "mygroup/*"'
)

# Projects with "active" in description
active_projects <- od_query_projects(
  query = '"Description" ~ "active"'
)
```

------------------------------------------------------------------------

## Combining Conditions

### AND Logic

Use parentheses and the `and` operator to require **all** conditions:

``` r

# Issues that are BOTH Open AND High Priority
both_conditions <- od_query_issues(
  query = '("State" is "Open") and ("Priority" is "High")'
)

# Assigned to alice AND State is Open
alice_open <- od_query_issues(
  query = '("Assignee" is "alice") and ("State" is "Open")'
)

# Three conditions
complex_and <- od_query_issues(
  query = '("State" is "Open") and ("Priority" is "High") and ("Type" is "Bug")'
)
```

### OR Logic

Use the `or` operator to match **any** of the conditions:

``` r

# Issues assigned to alice OR bob
two_assignees <- od_query_issues(
  query = '("Assignee" is "alice") or ("Assignee" is "bob")'
)

# High Priority OR Critical state
important_issues <- od_query_issues(
  query = '("Priority" is "High") or ("State" is "Critical")'
)

# Multiple status options
pr_statuses <- od_query_pull_requests(
  query = '(open) or (merged)'
)
```

### Complex Combinations

Combine `and` and `or` with clear parenthesization:

``` r

# (alice or bob) AND (open or in-progress)
team_work <- od_query_issues(
  query = '(("Assignee" is "alice") or ("Assignee" is "bob")) and (("State" is "Open") or ("State" is "In Progress"))'
)

# (High or Critical) AND (Bug or Regression) AND (Unassigned or alice)
priority_bugs <- od_query_issues(
  query = '(("Priority" is "High") or ("Priority" is "Critical")) and (("Type" is "Bug") or ("Type" is "Regression")) and (("Assignee" is empty) or ("Assignee" is "alice"))'
)
```

------------------------------------------------------------------------

## Special Syntax

### Path References

Issue and build numbers can be qualified with project paths:

``` r

# Issue #145 in group/project
full_ref <- od_query_issues(
  query = '"Number" is "group/project#145"'
)

# Multiple builds from different projects
cross_project <- od_query_builds(
  query = '("Number" is "project1#100") or ("Number" is "project2#200")'
)
```

### Special Values and Functions

OneDev supports special values in queries:

| Syntax          | Meaning          | Example                       |
|-----------------|------------------|-------------------------------|
| `currentUser()` | Logged-in user   | `"Assignee" is currentUser()` |
| `empty`         | Null/unset field | `"Assignee" is empty`         |
| `true`, `false` | Boolean literals | `"IsResolved" is true`        |

``` r

# Issues assigned to current user
my_work <- od_query_issues(
  query = '"Assignee" is currentUser()'
)

# Unresolved issues
open_work <- od_query_issues(
  query = '"IsResolved" is false'
)

# Issues without iteration
no_sprint <- od_query_issues(
  query = '"Iteration" is empty'
)
```

### Text Search

Use the `~` operator for substring/keyword search:

``` r

# Issues with "authentication" in title or description
auth_issues <- od_query_issues(
  query = '("Title" ~ "authentication") or ("Description" ~ "authentication")'
)

# Projects containing "tools"
tooling <- od_query_projects(
  query = '"Name" ~ "tools"'
)

# Case-sensitive note: behavior is OneDev-server-specific
```

------------------------------------------------------------------------

## Function-by-Function Examples

### od_query_issues()

The core function for querying issues:

``` r

library(onedevr)

# Example 1: Simple state filter
open <- od_query_issues(
  state = "Open"  # Using convenience parameter
)

# Example 2: Query string (more powerful)
high_priority <- od_query_issues(
  query = '"Priority" is "High"'
)

# Example 3: Combining query with state parameter
# Note: state is automatically AND'd with query
assigned_open <- od_query_issues(
  query = '"Assignee" is "alice"',
  state = "Open"
  # Generates: ("Assignee" is "alice") and ("State" is "Open")
)

# Example 4: Complex query with pagination
all_urgent <- od_paginate(
  od_query_issues,
  query = '("Priority" is "High") and ("Type" is "Bug")',
  page_size = 50L,
  max_pages = Inf
)

# Example 5: Numeric field with range
mid_range <- od_query_issues(
  query = '("Number" >= 100) and ("Number" <= 200)',
  count = 100L
)

# Example 6: Text search
bugs_title <- od_query_issues(
  query = '"Title" ~ "crash" and ("Type" is "Bug")'
)

# Example 7: Datetime filtering
recent <- od_query_issues(
  query = '"Updated" > "2026-01-01"',
  state = "Open"
)
```

### od_query_builds()

Query builds with status-specific helpers:

``` r

# Example 1: Status keyword (simplest)
successful <- od_query_builds(status = "successful", count = 20L)

# Example 2: Raw query string
branch_filter <- od_query_builds(
  query = '"Branch" is "develop"'
)

# Example 3: Combining status with query
develop_success <- od_query_builds(
  query = '"Branch" is "develop"',
  status = "successful"
  # Generates: ("Branch" is "develop") and successful
)

# Example 4: Job-specific builds
ci_job <- od_query_builds(
  query = '"Job" is "CI"'
)

# Example 5: Pagination for all failed builds
all_failures <- od_paginate(
  od_query_builds,
  status = "failed",
  page_size = 100L
)

# Example 6: Number range
recent_builds <- od_query_builds(
  query = '("Number" >= 500) and ("Number" <= 600)',
  status = "successful"
)

# Example 7: Complex multi-condition
important_runs <- od_query_builds(
  query = '(("Branch" is "main") or ("Branch" is "release/*")) and ("Job" is "CI")',
  status = "successful"
)
```

### od_query_pull_requests()

Query pull requests with status filters:

``` r

# Example 1: Status keyword
open_pr <- od_query_pull_requests(status = "open", count = 20L)

# Example 2: Merged PRs
merged <- od_query_pull_requests(status = "merged")

# Example 3: Raw query for branch filtering
feature_prs <- od_query_pull_requests(
  query = '"Source Branch" is "feature/*"'
)

# Example 4: Combining status with query
main_open <- od_query_pull_requests(
  query = '"Target Branch" is "main"',
  status = "open"
)

# Example 5: Author filtering
bob_prs <- od_query_pull_requests(
  query = '"Author" is "bob"'
)

# Example 6: Pagination for all discarded
all_discarded <- od_paginate(
  od_query_pull_requests,
  query = 'discarded',
  page_size = 50L
)

# Example 7: Multi-condition
reviewer_focus <- od_query_pull_requests(
  query = '(open) and ("Target Branch" is "main") and ("Title" ~ "auth")'
)
```

### od_query_projects()

Query projects in your OneDev instance:

``` r

# Example 1: Name search
api_projects <- od_query_projects(
  query = '"Name" ~ "api"'
)

# Example 2: Path-based grouping
group_projects <- od_query_projects(
  query = '"Path" ~ "backend/*"'
)

# Example 3: Description search
documented <- od_query_projects(
  query = '"Description" ~ "production"'
)

# Example 4: Pagination
all_projects <- od_paginate(
  od_query_projects,
  page_size = 100L
)

# Example 5: Multiple name patterns
tools_projects <- od_query_projects(
  query = '("Name" ~ "tool") or ("Name" ~ "util")'
)
```

------------------------------------------------------------------------

## For AI and LLM Users

This section addresses the unique challenges of **programmatic query
construction** using LLMs and automated systems.

### Constructing Queries Programmatically

When building queries dynamically (e.g., in an LLM agent or automation
script), follow these patterns:

#### Pattern 1: Simple Field Match

``` r

# Building a single condition
build_field_match <- function(field, value) {
  sprintf('"%s" is "%s"', field, value)
}

# Usage
state_query <- build_field_match("State", "Open")
# Result: "State" is "Open"
```

#### Pattern 2: Numeric Comparison

``` r

build_numeric_comparison <- function(field, operator, value) {
  sprintf('"%s" %s %s', field, operator, value)
}

# Usage
number_query <- build_numeric_comparison("Number", ">=", "100")
# Result: "Number" >= 100
```

#### Pattern 3: Combining Conditions

``` r

build_and_query <- function(...) {
  conditions <- list(...)
  paste0("(", paste(conditions, collapse = ") and ("), ")")
}

# Usage
complex <- build_and_query(
  '"State" is "Open"',
  '"Priority" is "High"',
  '"Assignee" is "alice"'
)
# Result: ("State" is "Open") and ("Priority" is "High") and ("Assignee" is "alice")
```

#### Pattern 4: OR Variations

``` r

build_or_query <- function(...) {
  conditions <- list(...)
  paste0("(", paste(conditions, collapse = ") or ("), ")")
}

# Usage
status_options <- build_or_query(
  '"State" is "Open"',
  '"State" is "In Progress"'
)
# Result: ("State" is "Open") or ("State" is "In Progress")
```

#### Pattern 5: Safe User Input

When accepting user input (especially from LLMs), escape special
characters:

``` r

safe_string_value <- function(value) {
  # Escape quotes in the value
  escaped <- gsub('"', '\\"', value, fixed = TRUE)
  sprintf('"%s"', escaped)
}

# Usage
user_input <- 'Test "quoted" value'
safe_query <- sprintf('"Assignee" is %s', safe_string_value(user_input))
# Result: "Assignee" is "Test \"quoted\" value"
```

### Common Mistakes to Avoid

#### Mistake 1: Missing Quotes on Field Names

``` r

# ✗ WRONG
query = 'State is "Open"'

# ✓ CORRECT
query = '"State" is "Open"'
```

#### Mistake 2: Forgetting Quotes on String Values

``` r

# ✗ WRONG
query = '"State" is Open'

# ✓ CORRECT
query = '"State" is "Open"'
```

#### Mistake 3: Unbalanced Parentheses

``` r

# ✗ WRONG (missing closing paren)
query = '("State" is "Open" and ("Priority" is "High")'

# ✓ CORRECT
query = '("State" is "Open") and ("Priority" is "High")'
```

#### Mistake 4: Incorrect Case for Keywords

``` r

# ✗ WRONG (AND should be lowercase)
query = '("State" is "Open") AND ("Priority" is "High")'

# ✓ CORRECT
query = '("State" is "Open") and ("Priority" is "High")'
```

#### Mistake 5: Status Keywords vs. Field Names (Builds/PRs)

Builds and PRs use **keywords** directly, not field queries:

``` r

# ✗ WRONG (for builds)
query = '"Status" is "successful"'

# ✓ CORRECT (for builds)
query = 'successful'

# ✓ ALSO CORRECT (combining)
query = '(successful) and ("Branch" is "main")'
```

#### Mistake 6: Confusing UI Numbers with Internal IDs

``` r

# UI number in query (shown in web UI)
query = '"Number" is "145"'

# NOT the internal id, though onedevr handles the conversion
# when you call od_get_issue(145)
```

### When to Use Query vs. Filter Parameters

OnedevR functions offer two ways to filter:

#### Approach 1: Simple Parameters (When Available)

``` r

# For issues: use state parameter
issues <- od_query_issues(state = "Open")

# For builds: use status parameter
builds <- od_query_builds(status = "successful")

# For PRs: use status parameter
prs <- od_query_pull_requests(status = "open")

# Benefits:
# - Simpler syntax
# - Less error-prone
# - Function handles escaping
```

#### Approach 2: Raw Query Strings (When You Need More Control)

``` r

# Complex multi-field query
issues <- od_query_issues(
  query = '("State" is "Open") and ("Priority" is "High") and ("Assignee" is "alice")'
)

# Text search
projects <- od_query_projects(
  query = '"Name" ~ "api"'
)

# Benefits:
# - Access all fields
# - Full boolean logic
# - More powerful filtering
```

#### When to Combine Both

``` r

# state parameter is automatically AND'd with query
issues <- od_query_issues(
  query = '"Priority" is "High"',
  state = "Open"
  # Becomes: ("Priority" is "High") and ("State" is "Open")
)

# Useful for:
# - Enforcing a base filter (state) + custom logic
# - Reducing query complexity
```

### Tips for LLM-Based Query Generation

#### Tip 1: Start Simple

``` r

# Instead of generating complex queries immediately,
# build incrementally and test at each step:

# Step 1: Test basic state
issues <- od_query_issues(state = "Open")

# Step 2: Add priority
issues <- od_query_issues(
  query = '"Priority" is "High"',
  state = "Open"
)

# Step 3: Add assignee
issues <- od_query_issues(
  query = '("Priority" is "High") and ("Assignee" is "alice")',
  state = "Open"
)
```

#### Tip 2: Validate Query Grammar

``` r

# Use od_get_query_description() to understand your server's dialect
description <- od_get_query_description("issue")
cat(description)

# The output shows:
# - Available field names for your OneDev instance
# - Supported operators
# - Example syntax
# - Enum values for custom fields
```

#### Tip 3: Test on Small Result Sets First

``` r

# Add count limit while developing
test_query <- od_query_issues(
  query = '("State" is "Open") and ("Assignee" is "alice")',
  count = 5L  # Test with small batch
)

# Once working, remove limit or increase for production
```

#### Tip 4: Use Pagination for Large Datasets

``` r

# For potentially large result sets, use pagination:
all_issues <- od_paginate(
  od_query_issues,
  query = '("State" is "Open")',
  page_size = 50L,    # Items per request
  max_pages = Inf     # Fetch all
)

# Without pagination, you're limited to 100 items per call
```

#### Tip 5: Handle Special Fields and Functions

``` r

# Some fields have special behaviors:

# Current user reference (no quotes around function)
mine <- od_query_issues(query = '"Assignee" is currentUser()')

# Empty/null checks
unassigned <- od_query_issues(query = '"Assignee" is empty')

# Boolean values
resolved <- od_query_issues(query = '"IsResolved" is true')

# These cannot be quoted like regular values
```

### Debugging Failed Queries

When a query returns an error:

``` r

# 1. Check for unbalanced parentheses
query1 <- '("State" is "Open") and ("Priority" is "High")'  # ✓
query2 <- '("State" is "Open" and ("Priority" is "High")'   # ✗

# 2. Verify field names exist on your server
description <- od_get_query_description("issue")
# Check that your field name appears in the output

# 3. Test a simpler version first
simple <- od_query_issues(query = '"State" is "Open"')
# If this works, gradually add complexity

# 4. Check operator compatibility
# - Use "is" for enums and user fields
# - Use >= / <= for numeric fields
# - Use ~ for text search
# - Some fields may have their own operators

# 5. Verify enum values match your OneDev instance
# State values might be: Open, In Progress, Closed
# Priority values might be: Low, Medium, High, Critical
```

------------------------------------------------------------------------

## Summary of Query Syntax

### Quick Reference Table

| Concept | Syntax | Example |
|----|----|----|
| Simple match | `"Field" is "value"` | `"State" is "Open"` |
| Not equal | `"Field" is not "value"` | `"Type" is not "Doc"` |
| Greater than | `"Field" > value` | `"Number" > 100` |
| Less than | `"Field" < value` | `"Updated" < "2026-01-01"` |
| Text contains | `"Field" ~ "text"` | `"Title" ~ "bug"` |
| Empty check | `"Field" is empty` | `"Assignee" is empty` |
| Not empty | `"Field" is not empty` | `"Assignee" is not empty` |
| AND logic | `(cond1) and (cond2)` | `("State" is "Open") and ("Priority" is "High")` |
| OR logic | `(cond1) or (cond2)` | `("State" is "Open") or ("State" is "In Progress")` |
| Current user | (function, no quotes) | `"Assignee" is currentUser()` |
| Keyword status | (unquoted keyword) | `successful`, `open`, `merged` |

------------------------------------------------------------------------

## Resources

- **API Reference**: `https://your-onedev-host/~help/api`
- **TheOneDev CLI**: <https://github.com/theonedev/tod>
- **gitlabr (design reference)**:
  <https://thinkr-open.github.io/gitlabr/>
- **onedevr Issues**: <https://github.com/alexseymer/onedevR/issues>

For more on using queries with onedevr functions:

- [`vignette("getting-started", package = "onedevr")`](https://alexseymer.github.io/onedevR/articles/getting-started.md)
  — Basic setup
- [`vignette("issues-workflow", package = "onedevr")`](https://alexseymer.github.io/onedevR/articles/issues-workflow.md)
  — Issue patterns
- [`vignette("builds-workflow", package = "onedevr")`](https://alexseymer.github.io/onedevR/articles/builds-workflow.md)
  — Build patterns
- [`vignette("pull-requests-workflow", package = "onedevr")`](https://alexseymer.github.io/onedevR/articles/pull-requests-workflow.md)
  — PR patterns
