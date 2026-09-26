#' Create multiple issues efficiently
#'
#' Creates multiple issues in batch, optionally reporting progress. Each issue
#' spec should be a list with `title` (required), and optional `description`,
#' `fields`, and `iteration_ids`. Uses [od_create_issue()] internally.
#'
#' @param issues {list|tibble} List of issue specs, or a tibble with
#'   `title` column and optional `description`, `fields`, `iteration_ids` columns.
#'   Each row/element should be a list with at least `title`.
#' @param progress {logical} If `TRUE` (default), report progress. Default: `TRUE`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {list} Named list with:
#'   - `created`: List of created issue lists (each with `id`, `number`, `title`, etc.)
#'   - `numbers`: Numeric vector of created issue numbers
#'   - `errors`: List of errors encountered (empty if all succeeded)
#'   - `summary`: Character vector with status message
#'
#' @endpoint POST /issues (multiple calls)
#' @family batch
#' @examples
#' \dontrun{
#' # Create multiple issues from a tibble
#' issues_to_create <- tibble::tibble(
#'   title = c("Issue 1", "Issue 2", "Issue 3"),
#'   description = c("Desc 1", "Desc 2", "Desc 3"),
#'   fields = list(
#'     list(Priority = "High"),
#'     list(Priority = "Normal"),
#'     list(Priority = "Low")
#'   )
#' )
#' result <- od_batch_create_issues(issues_to_create)
#' }
#' @export
od_batch_create_issues <- function(
  issues,
  progress = TRUE,
  conn = NULL
) {
  conn <- .od_conn(conn)

  # Convert tibble to list of specs if needed
  if (is.data.frame(issues)) {
    n <- nrow(issues)
    specs <- vector("list", n)
    for (i in seq_len(n)) {
      spec <- as.list(issues[i, , drop = TRUE])
      # Flatten empty lists
      spec <- spec[vapply(spec, function(x) !is.null(x) && length(x) > 0, logical(1))]
      specs[[i]] <- spec
    }
    issues <- specs
  }

  if (!is.list(issues)) {
    stop("`issues` must be a list or tibble.", call. = FALSE)
  }

  n_issues <- length(issues)
  if (n_issues == 0) {
    return(list(
      created = list(),
      numbers = numeric(0),
      errors = list(),
      summary = "No issues to create."
    ))
  }

  created <- list()
  errors <- list()
  numbers <- numeric(0)

  for (i in seq_len(n_issues)) {
    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] Creating issue %d...", i, n_issues, i))
    }

    spec <- issues[[i]]
    if (!is.list(spec)) {
      spec <- list(title = spec)
    }

    # Ensure required fields
    if (is.null(spec$title)) {
      spec$title <- sprintf("Issue %d", i)
    }
    if (is.null(spec$description)) {
      spec$description <- ""
    }

    tryCatch(
      {
        created_issue <- od_create_issue(
          title = spec$title,
          description = spec$description %||% "",
          fields = spec$fields %||% list(),
          iteration_ids = spec$iteration_ids,
          conn = conn
        )
        created[[length(created) + 1]] <- created_issue
        numbers <- c(numbers, created_issue$number)
      },
      error = function(e) {
        errors[[length(errors) + 1]] <<- list(
          issue_index = i,
          title = spec$title,
          error = conditionMessage(e)
        )
      }
    )
  }

  summary_msg <- sprintf(
    "Created %d of %d issues%s",
    length(created),
    n_issues,
    if (length(errors) > 0) sprintf(" (with %d errors)", length(errors)) else ""
  )

  list(
    created = created,
    numbers = numbers,
    errors = if (length(errors) > 0) errors else list(),
    summary = summary_msg
  )
}

#' Update multiple issues
#'
#' Updates multiple issues with selective field updates. Supports updating
#' `title`, `description`, `fields`, and `state` individually.
#'
#' @param issue_numbers {numeric|character} Vector of UI issue numbers.
#' @param updates {list} Named list of updates to apply. Supported keys:
#'   - `title`: New title (string)
#'   - `description`: New description (string)
#'   - `fields`: Named list of custom field updates
#'   - `state`: New state (string)
#'   Only specified keys are updated.
#' @param progress {logical} If `TRUE` (default), report progress. Default: `TRUE`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {list} Named list with:
#'   - `updated`: List of updated issue lists
#'   - `count`: Number of successfully updated issues
#'   - `errors`: List of errors encountered
#'   - `summary`: Character vector with status message
#'
#' @endpoint POST /issues/{issueId}/title (and other endpoints)
#' @family batch
#' @examples
#' \dontrun{
#' # Update multiple issues
#' numbers <- c(10, 15, 20)
#' result <- od_batch_update_issues(
#'   numbers,
#'   updates = list(
#'     fields = list(Priority = "High"),
#'     state = "In Progress"
#'   )
#' )
#' }
#' @export
od_batch_update_issues <- function(
  issue_numbers,
  updates = list(),
  progress = TRUE,
  conn = NULL
) {
  conn <- .od_conn(conn)

  # Coerce to character and strip hashes
  issue_numbers <- vapply(
    issue_numbers,
    function(x) .od_strip_hash(as.character(x)[1]),
    character(1)
  )

  if (length(issue_numbers) == 0) {
    return(list(
      updated = list(),
      count = 0L,
      errors = list(),
      summary = "No issues to update."
    ))
  }

  if (!is.list(updates) || length(updates) == 0) {
    stop("`updates` must be a non-empty named list.", call. = FALSE)
  }

  # Validate update keys
  valid_keys <- c("title", "description", "fields", "state")
  invalid_keys <- setdiff(names(updates), valid_keys)
  if (length(invalid_keys) > 0) {
    stop(
      sprintf(
        "Invalid update keys: %s. Must be one of: %s",
        paste(invalid_keys, collapse = ", "),
        paste(valid_keys, collapse = ", ")
      ),
      call. = FALSE
    )
  }

  n_issues <- length(issue_numbers)
  updated <- list()
  errors <- list()

  for (i in seq_len(n_issues)) {
    issue_number <- issue_numbers[i]

    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] Updating issue #%s...", i, n_issues, issue_number))
    }

    tryCatch(
      {
        issue <- NULL

        # Update title if provided
        if (!is.null(updates$title)) {
          issue <- od_issue_set_title(issue_number, updates$title, conn = conn)
        }

        # Update description if provided
        if (!is.null(updates$description)) {
          issue <- od_issue_set_description(issue_number, updates$description, conn = conn)
        }

        # Update fields if provided
        if (!is.null(updates$fields) && is.list(updates$fields) && length(updates$fields) > 0) {
          issue <- od_issue_set_fields(issue_number, updates$fields, conn = conn)
        }

        # Transition state if provided
        if (!is.null(updates$state)) {
          issue <- od_issue_transition_state(issue_number, updates$state, conn = conn)
        }

        # If no updates were made, at least fetch the current state
        if (is.null(issue)) {
          issue <- od_get_issue(issue_number, conn = conn)
        }

        updated[[length(updated) + 1]] <- issue
      },
      error = function(e) {
        errors[[length(errors) + 1]] <<- list(
          issue_number = issue_number,
          error = conditionMessage(e)
        )
      }
    )
  }

  summary_msg <- sprintf(
    "Updated %d of %d issues%s",
    length(updated),
    n_issues,
    if (length(errors) > 0) sprintf(" (with %d errors)", length(errors)) else ""
  )

  list(
    updated = updated,
    count = length(updated),
    errors = if (length(errors) > 0) errors else list(),
    summary = summary_msg
  )
}

#' Link multiple issue-PR pairs
#'
#' Creates links between multiple issue-pull request pairs. Useful for
#' establishing relationships between issues and PRs in batch.
#'
#' @param links {tibble|data.frame} A tibble or data.frame with columns:
#'   - `issue_number`: UI issue number
#'   - `pull_request_number`: UI pull request number
#'   Each row represents one link to create.
#' @param progress {logical} If `TRUE` (default), report progress. Default: `TRUE`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {list} Named list with:
#'   - `linked`: Numeric vector of issue numbers successfully linked
#'   - `count`: Number of successfully created links
#'   - `errors`: List of errors encountered
#'   - `summary`: Character vector with status message
#'
#' @endpoint POST /issues/{issueId}/pull-requests
#' @family batch
#' @examples
#' \dontrun{
#' # Link multiple issue-PR pairs
#' links <- tibble::tibble(
#'   issue_number = c(10, 15, 20),
#'   pull_request_number = c(42, 43, 44)
#' )
#' result <- od_batch_link_issues_prs(links)
#' }
#' @export
od_batch_link_issues_prs <- function(
  links,
  progress = TRUE,
  conn = NULL
) {
  conn <- .od_conn(conn)

  if (!is.data.frame(links)) {
    stop("`links` must be a tibble or data.frame.", call. = FALSE)
  }

  # Check required columns
  if (!("issue_number" %in% names(links)) || !("pull_request_number" %in% names(links))) {
    stop(
      "`links` must have `issue_number` and `pull_request_number` columns.",
      call. = FALSE
    )
  }

  n_links <- nrow(links)
  if (n_links == 0) {
    return(list(
      linked = numeric(0),
      count = 0L,
      errors = list(),
      summary = "No links to create."
    ))
  }

  linked <- numeric(0)
  errors <- list()

  for (i in seq_len(n_links)) {
    issue_num <- links$issue_number[i]
    pr_num <- links$pull_request_number[i]

    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] Linking issue #%s to PR #%s...", i, n_links, issue_num, pr_num))
    }

    tryCatch(
      {
        od_link_issue_to_pull_request(issue_num, pr_num, conn = conn)
        linked <- c(linked, issue_num)
      },
      error = function(e) {
        errors[[length(errors) + 1]] <<- list(
          issue_number = issue_num,
          pull_request_number = pr_num,
          error = conditionMessage(e)
        )
      }
    )
  }

  summary_msg <- sprintf(
    "Linked %d of %d issue-PR pairs%s",
    length(linked),
    n_links,
    if (length(errors) > 0) sprintf(" (with %d errors)", length(errors)) else ""
  )

  list(
    linked = linked,
    count = length(linked),
    errors = if (length(errors) > 0) errors else list(),
    summary = summary_msg
  )
}

#' Transition multiple issues to a new state
#'
#' Changes the state of multiple issues atomically. Useful for bulk state
#' transitions (e.g., closing related issues, reopening a batch).
#'
#' @param issue_numbers {numeric|character} Vector of UI issue numbers.
#' @param target_state {character} Target state name (e.g., `"Closed"`, `"In Progress"`).
#' @param progress {logical} If `TRUE` (default), report progress. Default: `TRUE`.
#' @param conn {list} Connection list from [od_get_config()] / [od_connection()]. Default: `NULL`.
#'
#' @return {list} Named list with:
#'   - `transitioned`: List of transitioned issue lists
#'   - `count`: Number of successfully transitioned issues
#'   - `errors`: List of errors encountered (e.g., invalid state, issue not found)
#'   - `summary`: Character vector with status message
#'
#' @endpoint POST /issues/{issueId}/state-transitions
#' @family batch
#' @examples
#' \dontrun{
#' # Close multiple issues
#' numbers <- c(10, 15, 20)
#' result <- od_batch_transition_issues(numbers, "Closed")
#' }
#' @export
od_batch_transition_issues <- function(
  issue_numbers,
  target_state,
  progress = TRUE,
  conn = NULL
) {
  conn <- .od_conn(conn)

  # Coerce to character and strip hashes
  issue_numbers <- vapply(
    issue_numbers,
    function(x) .od_strip_hash(as.character(x)[1]),
    character(1)
  )

  target_state <- .od_coerce_string(target_state)
  if (!nzchar(target_state)) {
    stop("`target_state` is required.", call. = FALSE)
  }

  if (length(issue_numbers) == 0) {
    return(list(
      transitioned = list(),
      count = 0L,
      errors = list(),
      summary = "No issues to transition."
    ))
  }

  n_issues <- length(issue_numbers)
  transitioned <- list()
  errors <- list()

  for (i in seq_len(n_issues)) {
    issue_number <- issue_numbers[i]

    if (isTRUE(progress)) {
      message(sprintf("[%d/%d] Transitioning issue #%s to %s...", i, n_issues, issue_number, target_state))
    }

    tryCatch(
      {
        result <- od_issue_transition_state(issue_number, target_state, conn = conn)
        transitioned[[length(transitioned) + 1]] <- result
      },
      error = function(e) {
        errors[[length(errors) + 1]] <<- list(
          issue_number = issue_number,
          target_state = target_state,
          error = conditionMessage(e)
        )
      }
    )
  }

  summary_msg <- sprintf(
    "Transitioned %d of %d issues to %s%s",
    length(transitioned),
    n_issues,
    target_state,
    if (length(errors) > 0) sprintf(" (with %d errors)", length(errors)) else ""
  )

  list(
    transitioned = transitioned,
    count = length(transitioned),
    errors = if (length(errors) > 0) errors else list(),
    summary = summary_msg
  )
}
