# Function Relationship Map & API Navigation Guide

## Overview

The onedevR package provides **86 functions** organized across multiple
OneDev resource types. This guide maps those functions to their
relationships, workflows, and parameter patterns—helping you discover
the right function for your task and understand how functions work
together.

**Who is this for?** - **LLMs and AI systems** generating onedevR code
or explaining API patterns - **API users** exploring what functions are
available - **Package contributors** understanding the function
organization

### Navigation Quick Start

**If you know your resource type:** - Issues? → See [Issues
Functions](#issues-functions) - Pull Requests? → See [Pull Requests
Functions](#pull-requests-functions) - Builds? → See [Builds
Functions](#builds-functions) - Projects? → See [Projects
Functions](#projects-functions) - Users/Groups? → See [User & Group
Functions](#user--group-functions) - Repository? → See [Repository
Functions](#repository-functions)

**If you know your task:** - “Report an issue” → See [Report an
Issue](#report-an-issue) - “Merge a PR” → See [Merge a Pull
Request](#merge-a-pull-request) - “Find builds” → See [Query
Builds](#query-builds) - “Manage permissions” → See [Manage Group
Permissions](#manage-group-permissions)

------------------------------------------------------------------------

## Conceptual Overview: Resource Hierarchy

### ASCII Diagram: OneDev API Structure

                                    OneDev Server
                                         |
                        _________________|_______________
                       |                 |               |
                  PROJECTS         USERS & GROUPS    WEBHOOKS
                       |                 |
            ___________|___________      |______
           |          |          |             |
        ISSUES   PULL-REQS   BUILDS      REPOSITORY
           |          |          |
       _____|____  ___|___    ___|___
      |   |   |  | |   |  | |   |   |
     Comments Reviews Jobs Logs Artifacts
      Fields  Links     Params  Statuses


    Resource Access Patterns:
      Query/List → (optional filtering)
      Get        → (get details for ID)
      Create     → (if supported)
      Update     → (if supported)
      Transition → (state changes)
      Link       → (connect resources)

### Typical Workflow Patterns

All onedevR functions follow these patterns:

    1. QUERY/LIST pattern:
       od_query_*(query, state, count, offset, as_tibble, conn)
       └─→ Returns list of matching items (as tibble by default)

    2. GET pattern:
       od_get_*(id_or_number, conn, use_internal_id)
       └─→ Returns single item details

    3. CREATE pattern:
       od_create_*(title/name, description, fields, conn)
       └─→ Returns created item

    4. UPDATE/TRANSITION pattern:
       od_*_set_*(id_or_number, new_value, conn)
       └─→ Returns updated item

    5. LINK/RELATE pattern:
       od_link_*_to_*(source_id, target_id, conn)
       └─→ Connects two resources

------------------------------------------------------------------------

## Issues Functions

Issues are the core task/bug tracking resource in OneDev.

### Query/List Functions

- **od_query_issues()** — Find issues with query DSL
  - `query`: Raw OneDev query string (e.g., `'"Priority" is "High"'`)
  - `state`: Filter by state (e.g., `"Open"`, `"Closed"`)
  - `count`: Max results (default 100)
  - `offset`: For pagination
  - `as_tibble`: Return tibble (default) or list
  - Returns: tibble/list of issues
- **od_list_iterations()** — List available iterations/sprints
  - Returns: tibble/list of iterations

### Get/Retrieve Functions

- **od_get_issue()** — Get single issue by UI number
  - `issue_number`: UI number like `145` or `"#145"`
  - `use_internal_id`: If TRUE, treat as internal ID (debugging)
  - Returns: Full issue object
- **od_get_issue_fields()** — Get custom fields for an issue
  - `issue_number`: UI number
  - Returns: Named list of field name → value
- **od_get_issue_comments()** — Get all comments on an issue
  - `issue_number`: UI number
  - `as_tibble`: Return format (default tibble)
  - Returns: tibble/list of comments
- **od_get_issue_pull_requests()** — Get PRs linked to an issue
  - `issue_number`: UI number
  - `as_tibble`: Return format
  - Returns: tibble/list of linked PRs

### Create Functions

- **od_create_issue()** — Create a new issue
  - `title`: Issue title (required)
  - `description`: Markdown description (default `""`)
  - `fields`: Named list of custom fields
  - `iteration_ids`: Optional iteration IDs
  - Returns: Created issue object

### Update Functions

- **od_issue_set_title()** — Change issue title
  - `issue_number`: UI number
  - `title`: New title
  - Returns: Updated issue
- **od_issue_set_description()** — Change issue description
  - `issue_number`: UI number
  - `description`: New description
  - Returns: Updated issue
- **od_issue_set_fields()** — Set custom fields
  - `issue_number`: UI number
  - `fields`: Named list of field values
  - Returns: Updated issue
- **od_issue_transition_state()** — Change issue state
  - `issue_number`: UI number
  - `state`: New state (e.g., `"Closed"`, `"In Progress"`)
  - Returns: Updated issue

### Add/Comment Functions

- **od_add_issue_comment()** — Add a comment to an issue
  - `issue_number`: UI number
  - `content`: Comment text (Markdown)
  - Returns: Created comment object
- **od_add_issue_iterations()** — Add iterations to an issue
  - `issue_number`: UI number
  - `iteration_ids`: Numeric iteration IDs
  - Returns: Updated issue

### Link/Connect Functions

- **od_link_issue_to_pull_request()** — Link issue to PR
  - `issue_number`: UI number
  - `pull_request_number`: PR UI number
  - Returns: Link confirmation
- **od_unlink_issue_from_pull_request()** — Remove issue-PR link
  - `issue_number`: UI number
  - `pull_request_number`: PR UI number
  - Returns: Unlink confirmation

------------------------------------------------------------------------

## Pull Requests Functions

Pull Requests (PRs) are code review and merge requests.

### Query/List Functions

- **od_query_pull_requests()** — Find PRs with query DSL
  - `query`: Raw query string
  - `state`: Filter by state (e.g., `"Open"`, `"Merged"`)
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of PRs

### Get/Retrieve Functions

- **od_get_pull_request()** — Get single PR by UI number
  - `pull_request_number`: UI number
  - `use_internal_id`: Debugging flag
  - Returns: Full PR object
- **od_get_pull_request_comments()** — Get all PR comments
  - `pull_request_number`: UI number
  - `as_tibble`: Return format
  - Returns: tibble/list of comments
- **od_get_pull_request_reviews()** — Get PR reviews
  - `pull_request_number`: UI number
  - `as_tibble`: Return format
  - Returns: tibble/list of reviews
- **od_get_pull_request_issues()** — Get issues linked to PR
  - `pull_request_number`: UI number
  - `as_tibble`: Return format
  - Returns: tibble/list of linked issues

### Create Functions

- **od_create_pull_request()** — Create a new PR
  - `target_branch`: Target branch (e.g., `"main"`)
  - `source_branch`: Source branch
  - `title`: PR title
  - `description`: PR description
  - Returns: Created PR object

### Update/State Functions

- **od_approve_pull_request()** — Approve a PR
  - `pull_request_number`: UI number
  - Returns: Updated PR
- **od_request_pull_request_changes()** — Request changes on PR
  - `pull_request_number`: UI number
  - Returns: Updated PR
- **od_merge_pull_request()** — Merge a PR
  - `pull_request_number`: UI number
  - Returns: Merged PR object
- **od_discard_pull_request()** — Close/discard a PR
  - `pull_request_number`: UI number
  - Returns: Discarded PR object

### Add/Comment Functions

- **od_add_pull_request_comment()** — Add comment to PR
  - `pull_request_number`: UI number
  - `content`: Comment text
  - Returns: Created comment object

------------------------------------------------------------------------

## Builds Functions

Builds are CI/CD pipeline executions.

### Query/List Functions

- **od_query_builds()** — Find builds with query DSL
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of builds

### Get/Retrieve Functions

- **od_get_build()** — Get single build by number
  - `build_number`: Build number
  - `use_internal_id`: Debugging flag
  - Returns: Full build object
- **od_get_build_params()** — Get build parameters
  - `build_number`: Build number
  - `use_internal_id`: Debugging flag
  - Returns: Named list of parameters
- **od_get_build_log()** — Get build log
  - `build_number`: Build number
  - `job_name`: Optional job name filter
  - `tail`: Show last N lines
  - `use_internal_id`: Debugging flag
  - Returns: Log content (character)

### Job Management

- **od_run_job()** — Trigger a build job
  - `build_number`: Build number
  - `job_name`: Job name to run
  - `use_internal_id`: Debugging flag
  - Returns: Job execution result
- **od_rebuild_job()** — Rebuild a failed job
  - `build_number`: Build number
  - `job_name`: Job to rebuild
  - `use_internal_id`: Debugging flag
  - Returns: Rebuild result
- **od_cancel_job()** — Cancel a running job
  - `build_number`: Build number
  - `use_internal_id`: Debugging flag
  - Returns: Cancellation result

### Artifacts

- **od_list_build_artifacts()** — List build artifacts
  - `build_number`: Build number
  - `as_tibble`: Return format
  - `use_internal_id`: Debugging flag
  - Returns: tibble/list of artifacts
- **od_download_build_artifact()** — Download artifact
  - `build_number`: Build number
  - `artifact_path`: Path within artifact
  - `path`: Local save path
  - `use_internal_id`: Debugging flag
  - Returns: Downloaded file path

### Promotion

- **od_promote_build()** — Promote build (release/deploy)
  - `build_number`: Build number
  - `promotion_name`: Promotion type
  - `use_internal_id`: Debugging flag
  - Returns: Promotion result

------------------------------------------------------------------------

## Projects Functions

Projects are the top-level organizational unit.

### Query/List Functions

- **od_query_projects()** — Find projects by criteria
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of projects
- **od_list_projects()** — List all projects
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of projects

### Get/Retrieve Functions

- **od_get_project()** — Get single project details
  - `project`: Project path or ID
  - Returns: Full project object
- **od_get_project_clone_url()** — Get git clone URL
  - `project`: Project path or ID
  - Returns: Clone URL (character)

### Webhooks

- **od_list_webhooks()** — List project webhooks
  - `project`: Project path or ID
  - `as_tibble`: Return format
  - Returns: tibble/list of webhooks
- **od_get_webhook()** — Get single webhook
  - `webhook_id`: Webhook ID
  - `project`: Project path or ID
  - Returns: Webhook object
- **od_create_webhook()** — Create new webhook
  - `url`: Webhook URL (where OneDev posts events)
  - `events`: List of event types (e.g., `c("issues", "pr")`)
  - `project`: Project path or ID
  - Returns: Created webhook object
- **od_delete_webhook()** — Delete a webhook
  - `webhook_id`: Webhook ID
  - `project`: Project path or ID
  - Returns: Deletion confirmation

------------------------------------------------------------------------

## Repository Functions

Repository functions access git information: branches, tags, commits,
files.

### Branches

- **od_list_branches()** — List all branches
  - `project`: Project path or ID
  - Returns: Character vector of branch names
- **od_get_default_branch()** — Get default branch
  - `project`: Project path or ID
  - Returns: Branch name (character)
- **od_get_branch()** — Get branch details
  - `branch`: Branch name
  - `project`: Project path or ID
  - Returns: Branch object

### Tags

- **od_list_tags()** — List all tags
  - `project`: Project path or ID
  - Returns: Character vector of tag names
- **od_get_tag()** — Get tag details
  - `tag`: Tag name
  - `project`: Project path or ID
  - Returns: Tag object

### Commits

- **od_query_commits()** — Find commits by criteria
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - `project`: Project path or ID
  - Returns: tibble/list of commits
- **od_get_commit()** — Get commit details
  - `revision`: Commit SHA or reference
  - `project`: Project path or ID
  - Returns: Commit object
- **od_set_commit_status()** — Set commit build status
  - `revision`: Commit SHA
  - `status`: Status (e.g., `"success"`, `"failure"`, `"pending"`)
  - `description`: Optional status description
  - `target_url`: Optional link
  - `project`: Project path or ID
  - Returns: Status object
- **od_get_commit_statuses()** — Get commit statuses
  - `revision`: Commit SHA
  - `project`: Project path or ID
  - Returns: List of statuses

### Files

- **od_get_file()** — Get file metadata
  - `revision`: Branch/tag/commit
  - `path`: File path in repo
  - `project`: Project path or ID
  - Returns: File object
- **od_get_file_text()** — Get file content as text
  - `revision`: Branch/tag/commit
  - `path`: File path in repo
  - `project`: Project path or ID
  - Returns: File content (character)

------------------------------------------------------------------------

## User & Group Functions

User and group functions manage authentication, permissions, and
identities.

### User Management

- **od_get_me()** — Get current authenticated user
  - Returns: Current user object
- **od_get_user()** — Get user details by login
  - `user`: Login name or ID
  - `use_internal_id`: Debugging flag
  - Returns: User object
- **od_query_users()** — Find users by criteria
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of users

### User Authentication

- **od_get_user_emails()** — List user emails
  - `user`: Optional user (default: current user)
  - `as_tibble`: Return format
  - Returns: tibble/list of emails
- **od_list_user_ssh_keys()** — List SSH keys
  - `user`: Optional user (default: current user)
  - `as_tibble`: Return format
  - Returns: tibble/list of SSH keys
- **od_add_user_ssh_key()** — Add SSH key to user
  - `content`: SSH public key content
  - `name`: Optional key label
  - `user`: Optional user (default: current user)
  - Returns: Created key object
- **od_delete_user_ssh_key()** — Remove SSH key
  - `ssh_key_id`: Key ID
  - `user`: Optional user (default: current user)
  - Returns: Deletion confirmation

### Group Management

- **od_query_groups()** — Find groups by criteria
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of groups
- **od_get_group()** — Get group details
  - `name`: Group name
  - Returns: Group object
- **od_list_group_members()** — List group members
  - `group_name`: Group name
  - `as_tibble`: Return format
  - Returns: tibble/list of members
- **od_add_group_member()** — Add user to group
  - `group_name`: Group name
  - `user`: User login or ID
  - Returns: Updated group
- **od_remove_group_member()** — Remove user from group
  - `group_name`: Group name
  - `user`: User login or ID
  - Returns: Updated group

------------------------------------------------------------------------

## Packages Functions

Package functions access package/release artifacts.

### Query/List Functions

- **od_query_packages()** — Find packages by criteria
  - `query`: Raw query string
  - `count`: Max results
  - `offset`: Pagination
  - `as_tibble`: Return format
  - Returns: tibble/list of packages

### Get/Retrieve Functions

- **od_get_pack()** — Get package details
  - `pack_id`: Package ID
  - Returns: Package object
- **od_get_pack_blobs()** — List package files
  - `pack_id`: Package ID
  - `as_tibble`: Return format
  - Returns: tibble/list of blobs/files
- **od_get_pack_labels()** — List package labels
  - `pack_id`: Package ID
  - `as_tibble`: Return format
  - Returns: tibble/list of labels

------------------------------------------------------------------------

## Resolution Functions (ID Converters)

OneDev has two ID systems: **UI numbers** (what you see in web UI) and
**internal REST IDs**. Resolution functions convert between them.

### Why Resolution Matters

    UI Numbers → User-friendly but context-specific
      Issue #145 (in project context)
      PR !42 (in project context)
      Build 789 (in project context)

    Internal IDs → Unique across API
      Issue ID 1234 (globally unique)
      PR ID 5678
      Build ID 9012

Most functions automatically handle this conversion. Use these when you
have an ID and need the other form.

### Resolution Functions

- **od_resolve_issue_id()** — Convert UI number to internal ID
  - `issue_number`: UI number like `145` or `"#145"`
  - Returns: Internal ID (integer)
- **od_resolve_pull_request_id()** — Convert PR number to internal ID
  - `pull_request_number`: UI number like `42` or `"!42"`
  - Returns: Internal ID (integer)
- **od_resolve_build_id()** — Convert build number to internal ID
  - `build_number`: Build number
  - Returns: Internal ID (integer)
- **od_resolve_user_id()** — Convert username to internal ID
  - `user`: Login name
  - Returns: Internal ID (integer)
- **od_resolve_project_id()** — Convert project path to ID
  - `project`: Project path like `"group/project"`
  - Returns: Internal ID (integer)
- **od_resolve_project_path()** — Get current project path
  - Returns: Project path from connection

### When to Use `use_internal_id = TRUE`

Most `od_get_*()` and similar functions have a `use_internal_id`
parameter. Use `TRUE` only when: - You’re debugging API responses - You
have an internal ID and want to skip resolution - You’re working with
raw API responses

Default is `FALSE`—always use UI numbers.

------------------------------------------------------------------------

## Common Workflow Patterns

### Report an Issue

``` r

# 1. Create the issue
issue <- od_create_issue(
  title = "Bug in API client",
  description = "## Steps\n1. Call function\n2. See error",
  fields = list(priority = "High")
)

# 2. Get the issue number
issue_num <- issue$number

# 3. Add comment if needed
od_add_issue_comment(issue_num, "Assigning to @alice")

# 4. Set fields
od_issue_set_fields(issue_num, list(assignee = "alice"))

# 5. Add to iteration
od_add_issue_iterations(issue_num, c(123, 456))
```

### Merge a Pull Request

``` r

# 1. Get PR details
pr <- od_get_pull_request(42)

# 2. Check PR state
if (pr$state == "Open") {
  # 3. Approve it
  od_approve_pull_request(42)

  # 4. Merge it
  od_merge_pull_request(42)
}
```

### Query Issues & Link to PR

``` r

# 1. Find issues needing PR
issues <- od_query_issues(
  query = '"Fix Version" is empty',
  state = "Closed"
)

# 2. Link each to the PR
for (issue_num in issues$number) {
  od_link_issue_to_pull_request(issue_num, 42)
}
```

### Build & Promote

``` r

# 1. Query recent builds
builds <- od_query_builds(
  query = '"Branch" is "main"',
  count = 10
)

# 2. Get latest build
latest <- builds[1, ]$number

# 3. Check its log
log <- od_get_build_log(latest)
cat(log)

# 4. Promote if good
if (grepl("SUCCESS", log)) {
  od_promote_build(latest, promotion_name = "release")
}
```

### Manage Group Permissions

``` r

# 1. Create group
group_info <- od_get_group("developers")

# 2. Add members
od_add_group_member("developers", "alice")
od_add_group_member("developers", "bob")

# 3. List members
members <- od_list_group_members("developers")
print(members)

# 4. Remove if needed
od_remove_group_member("developers", "charlie")
```

### Download Build Artifacts

``` r

# 1. Query builds
builds <- od_query_builds(count = 5)

# 2. Get latest
build_num <- builds[1, ]$number

# 3. List artifacts
artifacts <- od_list_build_artifacts(build_num)
print(artifacts)

# 4. Download specific artifact
od_download_build_artifact(
  build_num,
  artifact_path = "app/dist.tar.gz",
  path = "/tmp/app.tar.gz"
)
```

------------------------------------------------------------------------

## Parameter Patterns Table

Common parameters across onedevR functions:

| Pattern | Meaning | Used In | Example |
|----|----|----|----|
| `conn = NULL` | Connection object or NULL to auto-resolve | All functions | `conn = od_connection(...)` |
| `as_tibble = NULL` | Return tibble (TRUE) or list (FALSE); NULL uses default | Query/list functions | `od_query_issues(as_tibble = FALSE)` |
| `project = NULL` | Project path/ID or NULL for default | Project-scoped functions | `project = "group/my-project"` |
| `use_internal_id = FALSE` | Treat input as internal ID (debugging) | Getter functions | `od_get_issue(999, use_internal_id = TRUE)` |
| `issue_number` | UI number like `145` or `"#145"` | Issue functions | `od_get_issue(145)` |
| `pull_request_number` | UI number like `42` or `"!42"` | PR functions | `od_get_pull_request(42)` |
| `build_number` | Build number | Build functions | `od_get_build(123)` |
| `query` | Raw OneDev query DSL string | Query functions | `query = '"Priority" is "High"'` |
| `state` | State filter (e.g., “Open”, “Closed”) | Query functions | `state = "Open"` |
| `count` | Maximum results to return | Pagination | `count = 50` |
| `offset` | Starting position for results | Pagination | `offset = 100` |
| `content` | Text content (Markdown) | Comments, webhooks | `content = "Great work!"` |
| `title` | Item title | Create/update | `title = "New Issue"` |
| `description` | Item description (Markdown) | Create/update | `description = "Full details"` |
| `fields` | Named list of custom fields | Issues, create | `fields = list(priority = "High")` |
| `url` | Web URL (for webhooks, file paths) | Webhooks, download | `url = "https://example.com/webhook"` |

------------------------------------------------------------------------

## Low-Level Escape Hatch: od_request()

When no high-level function fits your use case, use the low-level
**od_request()** function to make custom API calls.

### Basic Syntax

``` r

od_request(
  method = "GET",
  endpoint = "/issues",
  query = list(count = 10),
  body = NULL,
  conn = NULL
)
```

### Parameters

- **method** — HTTP method: `"GET"`, `"POST"`, `"PUT"`, `"DELETE"`
- **endpoint** — API path (e.g., `"/issues"`, `"/issues/123"`)
- **query** — List of query parameters (converted to URL query string)
- **body** — Request body (list, auto-JSON encoded)
- **conn** — Connection object

### When to Use od_request()

- Creating resources not in high-level functions
- Custom query filters not in high-level functions
- Bulk operations
- API endpoints added after package release

### Examples

``` r

# GET request
issues <- od_request(
  "GET",
  "/issues",
  query = list(query = '"Priority" is "High"', count = 20),
  conn = conn
)

# POST request (create resource)
new_hook <- od_request(
  "POST",
  "/projects/1/webhooks",
  body = list(
    url = "https://example.com/webhook",
    events = list("issues", "pr")
  ),
  conn = conn
)

# PUT request (update resource)
od_request(
  "PUT",
  "/issues/123",
  body = list(title = "New title"),
  conn = conn
)

# DELETE request
od_request(
  "DELETE",
  "/webhooks/456",
  conn = conn
)
```

### Response Handling

[`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
returns the parsed JSON response as an R list. For list/array endpoints,
results are automatically wrapped:

``` r

# Query endpoints return wrapped response
response <- od_request("GET", "/issues", ...)
issues <- response$data  # or response$items (endpoint-specific)

# Single-item endpoints return the item directly
issue <- od_request("GET", "/issues/123", ...)
```

Check OneDev’s API documentation (or `od_request("GET", "/doc")`) for
exact response shapes.

------------------------------------------------------------------------

## For LLMs: Navigation Guide

This section helps language models and AI systems understand how to
recommend and use onedevR functions.

### How to Discover Functions by Resource

**Given a user task mentioning a resource:**

1.  **Issue** → Use functions in [Issues Functions](#issues-functions)
    - Keywords: “issue”, “bug”, “task”, “ticket”
    - Common operations: query, get, create, update, comment, link
2.  **Pull Request** → Use functions in [Pull Requests
    Functions](#pull-requests-functions)
    - Keywords: “PR”, “pull request”, “merge request”, “code review”
    - Common operations: query, get, create, approve, merge, comment
3.  **Build** → Use functions in [Builds Functions](#builds-functions)
    - Keywords: “build”, “CI”, “pipeline”, “job”, “artifact”
    - Common operations: query, get, run, log, promote, artifact
4.  **Project** → Use functions in [Projects
    Functions](#projects-functions)
    - Keywords: “project”, “repository”, “repo”, “webhook”
    - Common operations: get, list, webhook, clone-url
5.  **Repository** → Use functions in [Repository
    Functions](#repository-functions)
    - Keywords: “branch”, “tag”, “commit”, “file”, “git”
    - Common operations: list, get, query commits, read file
6.  **User/Group** → Use functions in [User & Group
    Functions](#user--group-functions)
    - Keywords: “user”, “group”, “permission”, “member”, “SSH”, “auth”
    - Common operations: get, query, add member, SSH key

### How to Match Functions to Operations

**Given an operation, find the right function:**

| Operation | Pattern | Examples |
|----|----|----|
| Search/filter | `od_query_*()` | [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md), [`od_query_pull_requests()`](https://alexseymer.github.io/onedevR/reference/od_query_pull_requests.md) |
| Retrieve one | `od_get_*()` | [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md), [`od_get_project()`](https://alexseymer.github.io/onedevR/reference/od_get_project.md) |
| Retrieve many | `od_list_*()` | [`od_list_branches()`](https://alexseymer.github.io/onedevR/reference/od_list_branches.md), `od_list_webhooks()` |
| Create | `od_create_*()` | [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md), [`od_create_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_create_pull_request.md) |
| Update field | `od_*_set_*()` | [`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md), [`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md) |
| State change | `od_*_transition_*()` | [`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md) |
| Add/attach | `od_add_*()` | [`od_add_issue_comment()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_comment.md), `od_add_group_member()` |
| Link/connect | `od_link_*_to_*()` | `od_link_issue_to_pull_request()` |
| Approve | `od_approve_*()` | [`od_approve_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_approve_pull_request.md) |
| Merge | `od_merge_*()` | [`od_merge_pull_request()`](https://alexseymer.github.io/onedevR/reference/od_merge_pull_request.md) |
| Remove | `od_remove_*()` or `od_delete_*()` or `od_unlink_*()` | `od_remove_group_member()`, `od_delete_webhook()` |
| Download | `od_download_*()` | [`od_download_build_artifact()`](https://alexseymer.github.io/onedevR/reference/od_download_build_artifact.md) |

### Pattern Matching: Finding Similar Functions

**To find related functions:**

1.  Look for shared prefixes:
    - `od_issue_*` → all issue-specific operations
    - `od_*_comment*` → commenting across resources
    - `od_query_*` → all query functions
    - `od_*_pull_request*` → PR-related operations
2.  Think about workflows:
    - Create → Get → Update → Transition
    - Query → Get → Link → Comment
3.  Use function metadata:
    - Look at `@family` in roxygen docs
    - Check parameter patterns (table above)
    - Review common workflows (section above)

### When to Use ?od\_\* vs This Map

| Situation | Use This Map | Use ?od\_\* |
|----|----|----|
| Understanding API structure | Yes | No |
| Discovering which function to use | Yes | No (after choosing function) |
| Learning typical workflows | Yes | No |
| Parameter details for one function | No | Yes |
| Full function documentation | No | Yes |
| Which functions fit together | Yes | No |

### Common Patterns for LLMs Generating Code

When generating code, follow these patterns:

1.  **Always include connection setup:**

    ``` r

    # If no conn provided, add this first
    conn <- od_get_config()
    # or
    conn <- od_connection(host = ..., token = ...)
    ```

2.  **Prefer UI numbers, not internal IDs:**

    ``` r

    # Good
    od_get_issue(145)

    # Only for debugging
    od_get_issue(999, use_internal_id = TRUE)
    ```

3.  **Use as_tibble = TRUE (default) for easier data handling:**

    ``` r

    issues <- od_query_issues(count = 50)  # Returns tibble
    issues %>% dplyr::filter(priority == "High")
    ```

4.  **Chain operations in workflows:**

    ``` r

    # Better: create then immediately get details
    new_issue <- od_create_issue(title = "Test")
    details <- od_get_issue(new_issue$number)
    ```

5.  **Use resolution functions only when necessary:**

    ``` r

    # Almost never needed - high-level functions handle this
    # Only use if you have both UI number and internal ID:
    id <- od_resolve_issue_id(145)
    ```

------------------------------------------------------------------------

## The 80/20 Functions: You’ll Use These Most

These 20 functions handle 80% of typical onedevR workflows:

### Core Functions (Must Know)

| Function                        | Purpose                | Return             |
|---------------------------------|------------------------|--------------------|
| **od_query_issues()**           | Find issues            | tibble of issues   |
| **od_get_issue()**              | Get issue details      | issue object       |
| **od_create_issue()**           | Create new issue       | created issue      |
| **od_issue_set_fields()**       | Update issue fields    | updated issue      |
| **od_issue_transition_state()** | Change issue state     | updated issue      |
| **od_add_issue_comment()**      | Add issue comment      | comment object     |
| **od_query_pull_requests()**    | Find PRs               | tibble of PRs      |
| **od_get_pull_request()**       | Get PR details         | PR object          |
| **od_approve_pull_request()**   | Approve PR             | updated PR         |
| **od_merge_pull_request()**     | Merge PR               | merged PR object   |
| **od_query_builds()**           | Find builds            | tibble of builds   |
| **od_get_build()**              | Get build details      | build object       |
| **od_get_build_log()**          | Get build log          | log text           |
| **od_promote_build()**          | Release/deploy build   | promotion result   |
| **od_query_projects()**         | Find projects          | tibble of projects |
| **od_get_project()**            | Get project details    | project object     |
| **od_query_users()**            | Find users             | tibble of users    |
| **od_get_connection()**         | Get current connection | connection object  |
| **od_set_connection()**         | Set default connection | (invisibly)        |
| **od_request()**                | Low-level API call     | raw API response   |

### Setup (First Thing)

``` r

# Option 1: Use environment variables
library(onedevr)
od_get_config()  # Validates ONEDEV_* env vars

# Option 2: Explicit connection
library(onedevr)
conn <- od_connection(
  host = "https://git.example.com",
  token = "token_here",
  project_path = "group/project"
)
od_set_connection(conn)
```

### Typical Workflow

``` r

# 1. Query to find items
issues <- od_query_issues(state = "Open", count = 20)

# 2. Get details on specific item
details <- od_get_issue(issues$number[1])

# 3. Update/transition
od_issue_transition_state(issues$number[1], "In Progress")

# 4. Add comments/links
od_add_issue_comment(issues$number[1], "Working on this")

# 5. Similar for PRs, builds, etc.
```

------------------------------------------------------------------------

## Summary & Quick Reference

    THREE WAYS TO GET HELP:

    1. Know the resource? → See §2-8 (Issues, PRs, Builds, etc.)
       Example: "I need to work with issues" → Section 2

    2. Know the operation? → See Parameter Patterns Table
       Example: "How do I search?" → Use od_query_*()

    3. Know nothing? → See Common Workflow Patterns or 80/20 Functions
       Example: "How do I merge a PR?" → Workflow section

    REMEMBER:
    - All functions use UI numbers (#145, !42, not internal IDs)
    - Query/list functions return tibbles by default
    - Workflows typically: Query → Get → Update → Transition
    - Use od_request() only when no high-level function exists
    - Connection is auto-resolved from environment or explicit object

------------------------------------------------------------------------

## See Also

For detailed workflows and examples:

- [`vignette("getting-started")`](https://alexseymer.github.io/onedevR/articles/getting-started.md)
  — Basic setup and first steps
- [`vignette("issues-workflow")`](https://alexseymer.github.io/onedevR/articles/issues-workflow.md)
  — Issue management workflows
- [`vignette("pull-requests-workflow")`](https://alexseymer.github.io/onedevR/articles/pull-requests-workflow.md)
  — PR review and merge workflows
- [`vignette("builds-workflow")`](https://alexseymer.github.io/onedevR/articles/builds-workflow.md)
  — Build querying and promotion workflows

For API reference: - `?od_query_issues()` and related function docs -
OneDev server documentation: <https://onedev.io/api>
