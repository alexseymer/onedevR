# onedevr — Plan für ein R-Paket (OneDev REST API Client)

**Stand:** 2026-07-10  
**Ziel:** Eigenständiges R-Paket `onedevr` (Display-Name: **onedevR**),
analog zu [gitlabr](https://thinkr-open.github.io/gitlabr/), das die
OneDev-REST-API kapselt.

------------------------------------------------------------------------

## Inhaltsverzeichnis

1.  [Executive Summary](#id_1-executive-summary)
2.  [Motivation & Referenzmodell
    (gitlabr)](#id_2-motivation--referenzmodell-gitlabr)
3.  [Funktionsumfang MVP](#id_3-funktionsumfang-mvp)
4.  [Abhängigkeiten & öffentliche
    API](#id_4-abh%C3%A4ngigkeiten--%C3%B6ffentliche-api)
5.  [Architektur](#id_5-architektur)
6.  [API-Design](#id_6-api-design)
7.  [Referenz-Implementierung
    (Code-Snippets)](#id_7-referenz-implementierung-code-snippets)
8.  [Umgebungsvariablen &
    Konfiguration](#id_8-umgebungsvariablen--konfiguration)
9.  [UI-Nummern vs. interne
    API-IDs](#id_9-ui-nummern-vs-interne-api-ids)
10. [Bekannte API-Quirks](#id_10-bekannte-api-quirks)
11. [Phasen, Meilensteine &
    Akzeptanzkriterien](#id_11-phasen-meilensteine--akzeptanzkriterien)
12. [Consumer-Integration](#id_12-consumer-integration)
13. [Paket-Skeleton](#id_13-paket-skeleton)
14. [Test-Strategie](#id_14-test-strategie)
15. [Zukünftige API-Abdeckung](#id_15-zuk%C3%BCnftige-api-abdeckung)
16. [Referenzen & Links](#id_16-referenzen--links)
17. [Risiken & offene Fragen](#id_17-risiken--offene-fragen)
18. [Umsetzungs-Checkliste](#id_18-umsetzungs-checkliste)

------------------------------------------------------------------------

## 1. Executive Summary

| Aspekt | Entscheidung |
|----|----|
| **Paketname (CRAN)** | `onedevr` (lowercase, R-Konvention) |
| **Display-Name** | onedevR |
| **Funktionspräfix** | `od_*` |
| **HTTP-Stack** | `httr2` + `jsonlite` |
| **Auth** | Bearer Token (primär); Basic Auth optional ergänzen |
| **Lizenz** | MIT oder GPL-3 (Abstimmung; gitlabr nutzt GPL-3) |
| **Erstes Ziel** | Issue-CRUD + Projekt-Auflösung + Query |
| **Nicht im Paket** | App-spezifische Web-URL-Builder, Shiny-UI, domänenspezifische Issue-Titel |

**Kernidee:** Zwei Ebenen wie bei gitlabr:

- **Low-level:**
  [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md)
  — beliebiger REST-Aufruf gegen `https://<host>/~api/...`
- **High-level:**
  [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md),
  [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md),
  [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md),
  …

------------------------------------------------------------------------

## 2. Motivation & Referenzmodell (gitlabr)

### Was gitlabr liefert

| Ebene | gitlabr | geplantes onedevr-Äquivalent |
|----|----|----|
| Connection | `gl_connection()`, `set_gitlab_connection()` | [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md), [`od_set_connection()`](https://alexseymer.github.io/onedevR/reference/od_set_connection.md) |
| Low-level | `gitlab(req, verb, ...)` | `od_request(method, endpoint, ...)` |
| Issues | `gl_list_issues()`, `gl_create_issue()`, … | [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md), [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md), … |
| Projekte | `gl_list_projects()`, … | [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md), `od_list_projects()` |
| CI/Builds | `use_gitlab_ci()`, Pipeline-Wrapper | Phase 3: [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md), … |
| Vignetten | `vignette("a-gitlabr")` | [`vignette("getting-started")`](https://alexseymer.github.io/onedevR/articles/getting-started.md), `vignette("custom-endpoints")` |

### Warum ein separates Paket?

1.  **Wiederverwendung** — R-Projekte, CI-Skripte und Agents nutzen
    dieselbe API-Logik
2.  **Zentrale Pflege** — Payload-Varianten, UI-Nummern-Auflösung,
    Versionstoleranz an einem Ort
3.  **REST-first** — programmatischer Zugriff ohne CLI-Wrapper
4.  **Lücke im Ökosystem** — es gibt kein etabliertes R-Paket für OneDev
    (Stand 2026)

### OneDev vs. GitLab (designrelevant)

| Thema | GitLab | OneDev |
|----|----|----|
| Issue-IDs | global eindeutig | **projektbezogene UI-Nummer** `#NNN` |
| Interne ID | oft identisch mit IID | separates Feld `id` (z. B. `#145` → `id=283`) |
| Query-Syntax | GitLab-spezifisch | `"Number" is "ProjectPath#145"` |
| API-Doku | docs.gitlab.com | **pro Installation:** `https://<host>/~help/api` |
| Auth (Doku) | Private Token | Basic Auth **oder** Bearer Token |
| Self-hosted | üblich | **Standard-Use-Case** |

------------------------------------------------------------------------

## 3. Funktionsumfang MVP

### Phase 1 — Issue-Core (MVP)

| Modul | Funktionen |
|----|----|
| Config | [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md), später [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md) |
| HTTP | [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md) |
| Projekte | [`od_resolve_project_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_id.md), [`od_resolve_project_path()`](https://alexseymer.github.io/onedevR/reference/od_resolve_project_path.md) |
| Issues | [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md), [`od_resolve_issue_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_issue_id.md), [`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md) |
| Issues (write) | [`od_create_issue()`](https://alexseymer.github.io/onedevR/reference/od_create_issue.md), [`od_issue_set_title()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_title.md), [`od_issue_set_description()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_description.md), [`od_issue_set_fields()`](https://alexseymer.github.io/onedevR/reference/od_issue_set_fields.md), [`od_issue_transition_state()`](https://alexseymer.github.io/onedevR/reference/od_issue_transition_state.md) |

### Phase 2 — Issues+

| Modul | Funktionen |
|----|----|
| Fields | [`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md) |
| Iterations | [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md), [`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md) |
| Create erweitert | `od_create_issue(..., iteration_ids =)` |

### Phase 3 — Builds & Pull Requests

| Modul | Funktionen |
|----|----|
| Builds | [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md), [`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md), [`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md) |
| PRs | `od_list_pull_requests()`, … (je nach `~help/api`) |

### Bewusst außerhalb des Pakets

| Thema | Begründung |
|----|----|
| Web-URLs für „Neues Issue“-Formulare | Consumer-spezifisch (Shiny, HTML, JS) |
| Domänen-Titel/Beschreibungen | Gehört in die Anwendung, nicht in den API-Client |
| Issue-Schließen per Commit-Message | OneDev/Git-Workflow der jeweiligen Installation |

------------------------------------------------------------------------

## 4. Abhängigkeiten & öffentliche API

### DESCRIPTION (Entwurf)

``` r
Package: onedevr
Title: Access to the OneDev REST API
Version: 0.1.0
Description: R client for the OneDev project management REST API. Provides
    low-level request helpers and high-level convenience functions for
    issues, projects, and (future) builds. Designed for self-hosted OneDev
    instances.
Depends: R (>= 4.2.0)
Imports:
    httr2 (>= 1.0.0),
    jsonlite (>= 1.8.0),
    rlang (>= 1.0.0)
Suggests:
    testthat (>= 3.1.0),
    mockery,
    withr,
    knitr,
    rmarkdown
VignetteBuilder: knitr
Roxygen: list(markdown = TRUE)
Encoding: UTF-8
```

### Interne Helfer (nicht exportiert)

    .od_trim_env
    .od_first_non_empty
    .od_parse_flag
    .od_derive_project_path
    .od_normalize_collection
    .od_parse_response_body
    .od_http_error
    .od_prepare_request
    .od_resolve_api_url
    .od_request_with_variants

### Öffentliche Exports (Ziel v0.1.0)

    export(od_get_config)
    export(od_request)
    export(od_resolve_project_id)
    export(od_resolve_project_path)
    export(od_query_issues)
    export(od_resolve_issue_id)
    export(od_get_issue)
    export(od_create_issue)
    export(od_issue_set_title)
    export(od_issue_set_description)
    export(od_issue_set_fields)
    export(od_issue_transition_state)

Phase 2 ergänzt: `od_get_issue_fields`, `od_list_iterations`,
`od_add_issue_iterations`, `od_connection`.

------------------------------------------------------------------------

## 5. Architektur

### Ziel-Dateistruktur

    onedevr/
    ├── DESCRIPTION
    ├── NAMESPACE
    ├── LICENSE
    ├── README.md
    ├── R/
    │   ├── onedevr-package.R       # globalVariables, on_attach message
    │   ├── connection.R            # od_connection(), od_get_config(), od_set_connection()
    │   ├── request.R               # od_request(), .od_prepare_request(), Fehlerbehandlung
    │   ├── normalize.R             # .od_normalize_collection(), Response-Parsing
    │   ├── resolve.R               # od_resolve_issue_id(), od_resolve_build_id() [Phase 3]
    │   ├── projects.R              # od_resolve_project_id/path(), od_list_projects()
    │   ├── issues.R                # od_query_issues(), od_get_issue(), od_create_issue(), …
    │   ├── iterations.R            # od_list_iterations(), od_add_issue_iterations() [Phase 2]
    │   ├── variants.R              # .od_request_with_variants()
    │   └── utils.R                 # Env-Parsing, URL-Helfer
    ├── tests/testthat/
    │   ├── helper-onedevr.R
    │   ├── test-config.R
    │   ├── test-request.R
    │   ├── test-resolve.R
    │   ├── test-issues.R
    │   └── test-variants.R
    ├── vignettes/
    │   ├── getting-started.Rmd
    │   └── custom-endpoints.Rmd
    └── inst/
        └── WORDLIST

### Connection-Modell (gitlabr-ähnlich)

``` r

conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "MyProject",
  project_id = NULL,
  insecure_ssl = FALSE
)

od_set_connection(conn)  # optional: globale Default-Connection

issue <- od_get_issue(145, conn = conn)
```

**Env-Fallback:**
[`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
liest `ONEDEV_*` aus der Umgebung, wenn keine explizite `conn` übergeben
wird.

### Schichten-Diagramm

``` mermaid
flowchart TB
  subgraph consumers [Consumer Applications]
    Apps[R / Shiny Apps]
    Scripts[Automation Scripts]
    CI[CI / Agents]
  end

  subgraph onedevr_pkg [onedevr Package]
  HL[High-level od_* wrappers]
  LL[od_request low-level]
  RES[Resolve UI numbers to internal ids]
  CFG[Connection / Config]
  end

  subgraph onedev_srv [OneDev Server]
  API["/~api REST"]
  WEB["Web UI /~issues"]
  end

  Apps --> HL
  Scripts --> HL
  CI --> HL
  HL --> RES
  HL --> LL
  RES --> LL
  CFG --> LL
  LL --> API
  consumers -.->|browser links only| WEB
```

------------------------------------------------------------------------

## 6. API-Design

### Namenskonvention

| Präfix          | Bedeutung                              |
|-----------------|----------------------------------------|
| `od_*`          | Öffentliche API                        |
| `.od_*`         | Interne Helfer                         |
| `od_connection` | Explizites Verbindungsobjekt (Phase 2) |

### Parameter-Konvention

- `conn` — optionales Connection-Objekt; Default aus Env via
  [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md)
- `issue_number` — **immer** UI-Nummer (`145` oder `"#145"`), nie
  interne `id`
- `project` — Pfad (`"group/project"`) oder numerische ID, je nach
  Funktion

### High-level vs. Low-level

``` r

# High-level (empfohlen)
issue <- od_get_issue(145)

# Low-level (Escape Hatch)
issue_id <- od_resolve_issue_id(145)
raw <- od_request("GET", paste0("/issues/", issue_id))
```

### Phase-2-Erweiterungen

| Funktion | Endpunkt |
|----|----|
| `od_get_issue_fields(issue_number)` | `GET /issues/{id}/fields` |
| `od_list_iterations(project)` | `GET /projects/{id}/iterations` |
| `od_add_issue_iterations(issue_number, ids)` | `POST /issues/{id}/iterations` |
| `od_create_issue(..., iteration_ids =)` | `iterationIds` im Create-Body |

------------------------------------------------------------------------

## 7. Referenz-Implementierung (Code-Snippets)

> Ziel-API mit `od_*`-Präfix. Snippets sind Implementierungsvorlagen für
> das neue Paket.

### 7.1 HTTP-Request-Vorbereitung

``` r

.od_prepare_request <- function(method, url, token, insecure_ssl = FALSE) {
  req <- httr2::request(url)
  req <- httr2::req_method(req, method)
  req <- httr2::req_headers(
    req,
    Authorization = paste("Bearer", token),
    Accept = "application/json"
  )
  req <- httr2::req_timeout(req, 30)
  req <- httr2::req_error(req, is_error = function(resp) FALSE)

  if (isTRUE(insecure_ssl)) {
    req <- httr2::req_options(req, ssl_verifypeer = 0L, ssl_verifyhost = 0L)
  }

  req
}
```

### 7.2 Low-level Request (Kern)

``` r

od_request <- function(method = "GET", endpoint, query = NULL, body = NULL, conn = NULL) {
  conn <- conn %||% od_get_config()
  method <- toupper(trimws(as.character(method)[1]))
  url <- .od_resolve_api_url(endpoint, conn)
  req <- .od_prepare_request(method, url, conn$token, conn$insecure_ssl)

  if (length(query) > 0) {
    query <- query[!vapply(query, is.null, logical(1))]
    if (length(query) > 0) {
      req <- do.call(httr2::req_url_query, c(list(req), query))
    }
  }

  if (!is.null(body)) {
    json_body <- jsonlite::toJSON(body, auto_unbox = TRUE, null = "null")
    req <- httr2::req_headers(req, "Content-Type" = "application/json")
    req <- httr2::req_body_raw(req, as.character(json_body))
  }

  response <- httr2::req_perform(req)
  payload <- .od_parse_response_body(response)
  if (httr2::resp_status(response) >= 400L) {
    .od_http_error(response, payload)
  }

  payload
}
```

### 7.3 Config aus Umgebungsvariablen

``` r

od_get_config <- function(validate = TRUE) {
  host <- .od_trim_env("ONEDEV_HOST")
  token <- .od_first_non_empty(
    .od_trim_env("ONEDEV_API_TOKEN"),
    .od_trim_env("ONEDEV_TOKEN"),
    .od_trim_env("ONEDEV_ISSUE_REPORTER_API_KEY")
  )
  repo_url <- .od_trim_env("ONEDEV_REPO_URL")
  project_path <- .od_first_non_empty(
    .od_trim_env("ONEDEV_PROJECT_PATH"),
    .od_derive_project_path(repo_url)
  )
  project_id <- .od_trim_env("ONEDEV_PROJECT_ID")
  issue_state <- .od_trim_env("ONEDEV_ISSUE_STATE")
  insecure_ssl <- .od_parse_flag(.od_trim_env("ONEDEV_CURL_INSECURE"))

  host <- sub("/+$", "", host)
  conn <- list(
    host = host,
    api_base_url = if (nzchar(host)) paste0(host, "/~api") else "",
    token = token,
    repo_url = repo_url,
    project_id = project_id,
    project_path = project_path,
    default_issue_state = issue_state,
    insecure_ssl = insecure_ssl
  )

  if (isTRUE(validate)) {
    if (!nzchar(conn$host)) {
      stop("ONEDEV_HOST is missing or empty.", call. = FALSE)
    }
    if (!nzchar(conn$token)) {
      stop(
        "No OneDev token found. Expected: ONEDEV_API_TOKEN, ONEDEV_TOKEN, or ONEDEV_ISSUE_REPORTER_API_KEY.",
        call. = FALSE
      )
    }
  }

  conn
}
```

### 7.4 Response-Normalisierung

``` r

.od_normalize_collection <- function(response) {
  if (is.null(response)) return(list())
  if (is.list(response) && !is.null(response$items) && is.list(response$items)) {
    return(response$items)
  }
  if (is.list(response) && !is.null(response$data) && is.list(response$data)) {
    return(response$data)
  }
  if (is.list(response) && !is.null(names(response)) && "id" %in% names(response)) {
    return(list(response))
  }
  if (is.list(response)) return(response)
  list(response)
}
```

### 7.5 UI-Nummer → interne ID (kritisch)

``` r

od_resolve_issue_id <- function(issue_number, conn = NULL) {
  conn <- conn %||% od_get_config()
  project_path <- od_resolve_project_path(conn = conn)
  numeric_part <- gsub("^#", "", trimws(as.character(issue_number)[1]), perl = TRUE)
  ref <- paste0(project_path, "#", numeric_part)
  issues <- .od_normalize_collection(
    od_query_issues(
      query = paste0('"Number" is "', ref, '"'),
      count = 1L,
      offset = 0L,
      conn = conn
    )
  )

  if (length(issues) < 1L || is.null(issues[[1]]$id)) {
    stop(paste0("OneDev issue #", numeric_part, " was not found."), call. = FALSE)
  }

  as.character(issues[[1]]$id)
}
```

### 7.6 Payload-Varianten (API-Inkonsistenz)

``` r

.od_request_with_variants <- function(method, endpoint, body_variants, conn = NULL) {
  last_error <- NULL
  for (body in body_variants) {
    outcome <- tryCatch(
      list(ok = TRUE, value = od_request(method, endpoint, body = body, conn = conn)),
      error = function(e) { last_error <<- e; list(ok = FALSE, value = NULL) }
    )
    if (isTRUE(outcome$ok)) return(outcome$value)
  }
  stop(conditionMessage(last_error), call. = FALSE)
}

# Create Issue — zwei gängige Body-Formen:
.od_request_with_variants(
  method = "POST",
  endpoint = "/issues",
  body_variants = list(
    list(projectId = project_id, title = title, description = description),
    list(project = list(id = project_id), title = title, description = description)
  ),
  conn = conn
)

# State Transition — drei gängige Body-Formen:
.od_request_with_variants(
  method = "POST",
  endpoint = paste0("/issues/", issue_id, "/state-transitions"),
  body_variants = list(
    list(state = state),
    list(transition = state),
    state
  ),
  conn = conn
)
```

### 7.7 Issue Create mit Custom Fields und Iterations

``` r

od_create_issue(
  title = "API integration test",
  description = "Created programmatically from R",
  fields = list(
    Assignee = "developer",
    Type = "Task",
    Priority = "Normal"
  ),
  iteration_ids = c(17L),  # Phase 2: internal iteration id from od_list_iterations()
  conn = conn
)

# Equivalent low-level body:
od_request(
  method = "POST",
  endpoint = "/issues",
  body = list(
    projectId = as.integer(conn$project_id),
    title = "API integration test",
    description = "Created programmatically from R",
    fields = list(Assignee = "developer", Type = "Task", Priority = "Normal"),
    iterationIds = list(17L)
  ),
  conn = conn
)
```

### 7.8 Iterations nachträglich setzen (Phase 2)

``` r

od_add_issue_iterations <- function(issue_number, iteration_ids, conn = NULL) {
  conn <- conn %||% od_get_config()
  issue_id <- od_resolve_issue_id(issue_number, conn = conn)

  .od_request_with_variants(
    method = "POST",
    endpoint = paste0("/issues/", issue_id, "/iterations"),
    body_variants = list(
      as.list(as.integer(iteration_ids)),
      list(iterationIds = as.list(as.integer(iteration_ids)))
    ),
    conn = conn
  )
}
```

### 7.9 Issue Query mit State-Filter

``` r

od_query_issues <- function(query = NULL, state = NULL, count = 100L, offset = 0L, conn = NULL) {
  conn <- conn %||% od_get_config()
  query <- trimws(as.character(query %||% "")[1])
  state <- trimws(as.character(state %||% "")[1])

  if (!nzchar(query) && !nzchar(state)) {
    state <- conn$default_issue_state %||% ""
  }
  if (nzchar(state)) {
    state_clause <- paste0('State is "', state, '"')
    query <- if (nzchar(query)) {
      paste0("(", query, ") and ", state_clause)
    } else {
      state_clause
    }
  }

  od_request(
    method = "GET",
    endpoint = "/issues",
    query = list(
      query = if (nzchar(query)) query else NULL,
      count = as.integer(count),
      offset = as.integer(offset)
    ),
    conn = conn
  )
}
```

### 7.10 Beispiel-Workflow (End-to-End)

``` r

library(onedevr)

# Configure via environment
Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = Sys.getenv("ONEDEV_API_TOKEN"),
  ONEDEV_PROJECT_PATH = "group/my-project"
)

issue <- od_get_issue(145)

created <- od_create_issue(
  title = "REST client test",
  description = "Created from onedevr",
  fields = list(Priority = "High")
)

od_issue_set_title(created$number, "REST client verified")
od_issue_transition_state(created$number, "Closed")
```

### 7.11 Web-URL für „Neues Issue“ (Consumer-Hinweis, nicht Paket-API)

Anwendungen, die Nutzer im Browser zu einem vorausgefüllten
Issue-Formular leiten, bauen URLs selbst:

``` r

# Consumer code (outside onedevr)
new_issue_url <- function(host, project_path, params = list()) {
  base <- paste0(sub("/+$", "", host), "/", project_path, "/~issues/new")
  if (length(params) == 0) return(base)
  query <- paste(
    vapply(names(params), function(n) {
      paste0(URLencode(n, reserved = TRUE), "=", URLencode(params[[n]], reserved = FALSE))
    }, character(1)),
    collapse = "&"
  )
  paste0(base, "?", query)
}

new_issue_url(
  host = "https://git.example.test",
  project_path = "group/my-project",
  params = list(
    `request.type` = "Bug",
    `request.title` = "Something broke",
    `request.description` = "Steps to reproduce…"
  )
)
```

------------------------------------------------------------------------

## 8. Umgebungsvariablen & Konfiguration

### `.env.example` (Vorlage für Consumer und Tests)

``` bash
# --- OneDev REST API ---
ONEDEV_HOST=https://git.example.test
ONEDEV_API_TOKEN=your-personal-access-token
ONEDEV_PROJECT_PATH=group/my-project
ONEDEV_PROJECT_ID=42
ONEDEV_REPO_URL=https://git.example.test/group/my-project.git
ONEDEV_ISSUE_STATE=Open
# ONEDEV_CURL_INSECURE=1   # only for controlled internal setups with self-signed TLS
```

### Variablen-Matrix

| Variable | MVP | Beschreibung |
|----|----|----|
| `ONEDEV_HOST` | ✅ | Basis-URL des OneDev-Servers |
| `ONEDEV_API_TOKEN` | ✅ | Bevorzugtes API-Token |
| `ONEDEV_TOKEN` | ✅ | Fallback-Token |
| `ONEDEV_ISSUE_REPORTER_API_KEY` | ✅ | Legacy-Fallback |
| `ONEDEV_PROJECT_ID` | ✅ | Numerische Projekt-ID |
| `ONEDEV_PROJECT_PATH` | ✅ | Projektpfad für UI-Nummern-Queries |
| `ONEDEV_REPO_URL` | ✅ | Optional: Ableitung von `project_path` |
| `ONEDEV_ISSUE_STATE` | ✅ | Default-State für [`od_query_issues()`](https://alexseymer.github.io/onedevR/reference/od_query_issues.md) |
| `ONEDEV_CURL_INSECURE` | ✅ | TLS-Verifikation deaktivieren (`1`/`true`) |
| `ONEDEV_RUN_LIVE_TESTS` | — | `1` aktiviert Integrationstests in CI |

### Projekt-Pfad aus Repo-URL ableiten

``` r

.od_derive_project_path <- function(repo_url) {
  repo_url <- trimws(as.character(repo_url)[1])
  if (!nzchar(repo_url)) return("")
  path <- sub("^https?://[^/]+/", "", repo_url, perl = TRUE)
  path <- sub("\\.git/?$", "", path, perl = TRUE)
  path <- sub("^/+", "", path, perl = TRUE)
  trimws(path)
}
```

------------------------------------------------------------------------

## 9. UI-Nummern vs. interne API-IDs

### Golden Rule

Wenn Nutzer oder Workflows eine Issue-Nummer nennen (z. B. „Issue 129“,
`#129`), ist damit die **sichtbare UI-Nummer** gemeint — JSON-Feld
`number`, formatiert als `#129`.

Das ist **nicht** das interne REST-Feld `id` (z. B. `283` für UI
`#129`). Diese Werte unterscheiden sich und dürfen nicht vertauscht
werden.

### API-Design-Regeln für onedevr

| Kontext | Verwenden |
|----|----|
| High-level API (`od_get_issue(145)`) | UI-Nummer `#145` / `145` |
| User-Kommunikation, Commits, Branches | `#145` |
| Low-level (`od_request("GET", "/issues/283")`) | interne `id` — nur dokumentiert |
| Fehlermeldungen | UI-Nummer bevorzugen |

**Empfehlung:**
[`od_get_issue()`](https://alexseymer.github.io/onedevR/reference/od_get_issue.md)
akzeptiert standardmäßig keine interne ID. Optionaler Parameter
`use_internal_id = TRUE` nur für Debugging.

### Query-Muster für Auflösung

``` text
"Number" is "group/my-project#145"
```

Analog für Builds (Phase 3):

``` text
"Number" is "group/my-project#100"
```

------------------------------------------------------------------------

## 10. Bekannte API-Quirks

### Create Issue: zwei Body-Formen

| Variante | Schlüssel                  |
|----------|----------------------------|
| A        | `projectId` (scalar)       |
| B        | `project = list(id = ...)` |

→
[`.od_request_with_variants()`](https://alexseymer.github.io/onedevR/reference/dot-od_request_with_variants.md)
probiert beide.

### State Transition: drei Body-Formen

| \#  | Body                          |
|-----|-------------------------------|
| 1   | `list(state = "Closed")`      |
| 2   | `list(transition = "Closed")` |
| 3   | `"Closed"` (raw string)       |

### Iterations POST: mehrere Body-Formen (zu verifizieren)

``` r

# Probe verschiedener Payloads gegen die Ziel-Installation:
for (body in list(c(17L), list(17L), list(iterationIds = list(17L)))) {
  od_request("POST", "/issues/{issue_id}/iterations", body = body, conn = conn)
}
```

→ In Phase 2: Varianten-Helper + Integrationstest gegen echte Instanz.

### Custom Fields sind installationsabhängig

Beispiel-Response `GET /issues/{id}/fields`:

``` json
{
  "Assignee": "developer",
  "Type": "Task",
  "Priority": "Normal"
}
```

Feldnamen und erlaubte Werte variieren pro OneDev-Installation und
Issue-Schema. onedevr dokumentiert `fields` als named list ohne festes
Schema.

### Iteration-IDs

Iterationen haben interne numerische IDs. Namen (z. B. „Version 2.x“)
werden über `GET /projects/{id}/iterations` aufgelöst. IDs sind
installations- und projektspezifisch.

------------------------------------------------------------------------

## 11. Phasen, Meilensteine & Akzeptanzkriterien

### Phase 0 — Planung

Plan-Dokument (`onedevr-plan.md`)

GitHub-Repo anlegen

Lizenz-Entscheid (MIT vs GPL-3)

Maintainer & Org festlegen

### Phase 1 — MVP (Issue-Core)

**Ziel:** Paket installierbar, Tests grün, Issue-CRUD funktional.

| Task | Akzeptanzkriterium |
|----|----|
| Paket-Skeleton mit usethis | `R CMD check` ohne ERROR |
| [`od_request()`](https://alexseymer.github.io/onedevR/reference/od_request.md), [`od_get_config()`](https://alexseymer.github.io/onedevR/reference/od_get_config.md) | Vignette-Beispiel dokumentiert |
| Issue-CRUD + Auflösung | `testthat` failed=0 |
| UI-Nummern-Auflösung | Mock-Test: `#145` → Query `"Number" is "..."` |
| README Quick Start | 5-Minuten-Einstieg |

**Zeitschätzung:** 1–2 Arbeitstage

### Phase 2 — Issues+ (Iterations, Fields)

| Task | Akzeptanzkriterium |
|----|----|
| [`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md) | GET fields für UI-Nummer |
| [`od_list_iterations()`](https://alexseymer.github.io/onedevR/reference/od_list_iterations.md) | Liste für Projekt |
| [`od_add_issue_iterations()`](https://alexseymer.github.io/onedevR/reference/od_add_issue_iterations.md) | Varianten-Helper + Integrationstest |
| `od_create_issue(iteration_ids=)` | Create mit `iterationIds` |
| [`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md) | Explizite Connection statt nur Env |

**Zeitschätzung:** 2–3 Arbeitstage

### Phase 3 — Builds & Pull Requests

| Task | Endpunkt |
|----|----|
| [`od_query_builds()`](https://alexseymer.github.io/onedevR/reference/od_query_builds.md) | `GET /builds` |
| [`od_get_build()`](https://alexseymer.github.io/onedevR/reference/od_get_build.md) | `GET /builds/{id}` |
| [`od_resolve_build_id()`](https://alexseymer.github.io/onedevR/reference/od_resolve_build_id.md) | Query `"Number" is "path#N"` |
| PR-Liste / Review-Kommentare | je nach `~help/api` |

**Zeitschätzung:** 1 Woche+

### Phase 4 — Veröffentlichung

GitHub Release v0.1.0

pkgdown-Site

CRAN-Submission oder R-universe (optional)

------------------------------------------------------------------------

## 12. Consumer-Integration

### Installation

``` r

# GitHub (bis CRAN)
remotes::install_github("your-org/onedevr")

# Später
install.packages("onedevr")
```

### Minimales Setup

``` r

library(onedevr)

Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = Sys.getenv("ONEDEV_API_TOKEN"),
  ONEDEV_PROJECT_PATH = "group/my-project"
)

od_query_issues(state = "Open")
```

### Explizite Connection (empfohlen für Skripte)

``` r

conn <- od_connection(
  host = "https://git.example.test",
  token = Sys.getenv("ONEDEV_API_TOKEN"),
  project_path = "group/my-project"
)

od_get_issue(42, conn = conn)
```

### Roxygen-Re-Export (optional, für Shiny-Pakete)

``` r

#' @importFrom onedevr od_get_issue od_create_issue
NULL
```

### Was Consumer selbst implementieren

| Bedarf                            | Empfehlung                       |
|-----------------------------------|----------------------------------|
| Browser-Links zu Issue-Formularen | Eigene URL-Builder (siehe §7.11) |
| App-spezifische Issue-Titel       | Domänenlogik im Consumer         |
| Webhook-Handling                  | Separates Paket oder App-Code    |

------------------------------------------------------------------------

## 13. Paket-Skeleton

### Repo anlegen (usethis)

``` r

usethis::create_package("path/to/onedevr")
usethis::use_mit_license()   # oder use_gpl3_license()
usethis::use_testthat()
usethis::use_package("httr2", "Imports")
usethis::use_package("jsonlite", "Imports")
usethis::use_package("rlang", "Imports")
usethis::use_package("mockery", "Suggests")
usethis::use_package("withr", "Suggests")
usethis::use_vignette("getting-started")
usethis::use_git()
usethis::use_github()
```

### Quick Start (Ziel-README)

``` r

install.packages("onedevr")  # oder remotes::install_github("your-org/onedevr")

Sys.setenv(
  ONEDEV_HOST = "https://git.example.test",
  ONEDEV_API_TOKEN = "your-token",
  ONEDEV_PROJECT_PATH = "group/my-project"
)

library(onedevr)

od_query_issues(state = "Open")
issue <- od_get_issue(145)

created <- od_create_issue(
  title = "API test",
  description = "Created from R",
  fields = list(Priority = "Normal")
)

od_issue_transition_state(created$number, "Closed")
```

------------------------------------------------------------------------

## 14. Test-Strategie

### Unit-Tests (ohne Netzwerk)

| Test | Was geprüft wird |
|----|----|
| `od_get_config reads env vars` | Env-Parsing, `project_path`-Ableitung |
| `od_resolve_issue_id uses UI number query` | Query-String mit Projekt-Pfad |
| `od_get_issue resolves internal id` | GET `/issues/{id}` |
| `od_create_issue uses project id` | POST Body-Struktur |
| `od_issue_transition_state tries variants` | Drei Payload-Formen |
| `od_request handles HTTP errors` | Klare Fehlermeldungen bei 4xx/5xx |

### Beispiel: Config-Test

``` r

test_that("od_get_config reads ONEDEV env vars and derives project path", {
  withr::local_envvar(
    ONEDEV_HOST = "https://git.example.test/",
    ONEDEV_API_TOKEN = "api-token",
    ONEDEV_REPO_URL = "https://git.example.test/group/subgroup/project.git",
    ONEDEV_PROJECT_ID = "20",
    ONEDEV_PROJECT_PATH = "",
    ONEDEV_ISSUE_STATE = "Open",
    ONEDEV_CURL_INSECURE = "1"
  )

  cfg <- od_get_config()

  expect_equal(cfg$host, "https://git.example.test")
  expect_equal(cfg$api_base_url, "https://git.example.test/~api")
  expect_equal(cfg$token, "api-token")
  expect_equal(cfg$project_id, "20")
  expect_equal(cfg$project_path, "group/subgroup/project")
  expect_equal(cfg$default_issue_state, "Open")
  expect_true(isTRUE(cfg$insecure_ssl))
})
```

### Beispiel: UI-Nummer-Auflösung (mockery)

``` r

test_that("od_resolve_issue_id uses UI number query with project path", {
  skip_if_not_installed("mockery")
  mockery::stub(od_resolve_issue_id, "od_resolve_project_path", function(conn = NULL) {
    "my-project"
  })
  mockery::stub(od_resolve_issue_id, "od_query_issues", function(query, count, offset, conn = NULL) {
    expect_equal(query, '"Number" is "my-project#145"')
    list(list(id = 283, number = 145))
  })

  issue_id <- od_resolve_issue_id("#145", conn = list(host = "https://git.example.test"))
  expect_equal(issue_id, "283")
})
```

### Integrationstests (gated)

``` r

test_that("od_get_issue live", {
  skip_if(Sys.getenv("ONEDEV_RUN_LIVE_TESTS") != "1")
  skip_if_not(nzchar(Sys.getenv("ONEDEV_API_TOKEN")))
  issue <- od_get_issue(1)
  expect_true(!is.null(issue$title))
})
```

### CI (GitHub Actions Entwurf)

``` yaml
# .github/workflows/R-CMD-check.yaml
on: [push, pull_request]
jobs:
  R-CMD-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: r-lib/actions/setup-r@v2
      - run: R CMD check .
```

Optional: separater Job `live-tests` mit Repository-Secrets
(`ONEDEV_HOST`, `ONEDEV_API_TOKEN`, `ONEDEV_PROJECT_PATH`).

------------------------------------------------------------------------

## 15. Zukünftige API-Abdeckung

Priorisiert nach OneDev `~help/api` Ressourcen:

| Ressource          | Priorität | geplante Funktionen   |
|--------------------|-----------|-----------------------|
| **Issues**         | P0        | MVP                   |
| **Projects**       | P0        | resolve id/path, list |
| **Iterations**     | P1        | list, add to issue    |
| **Issue Fields**   | P1        | get, set              |
| **Issue Comments** | P2        | list, create          |
| **Builds**         | P2        | query, get, promote   |
| **Pull Requests**  | P3        | list, merge, comments |
| **Users / Groups** | P3        | lookup                |
| **Attachments**    | P3        | upload/download       |

### Low-level Escape Hatch

``` r

od_request(
  method = "GET",
  endpoint = "/projects/42/iterations",
  conn = conn
)
```

### OneDev API-Ressourcen (Referenz)

Typische Endpunkte laut Installations-Doku:

| Operation        | Methode | Endpunkt                              |
|------------------|---------|---------------------------------------|
| Query Issues     | GET     | `/issues`                             |
| Get Issue        | GET     | `/issues/{issueId}`                   |
| Create Issue     | POST    | `/issues`                             |
| Set Title        | POST    | `/issues/{issueId}/title`             |
| Set Description  | POST    | `/issues/{issueId}/description`       |
| Set Fields       | POST    | `/issues/{issueId}/fields`            |
| State Transition | POST    | `/issues/{issueId}/state-transitions` |
| Get Project      | GET     | `/projects/{projectId}`               |
| Get Project Id   | GET     | `/projects/ids/{path}`                |
| Query Projects   | GET     | `/projects`                           |
| Query Iterations | GET     | `/projects/{projectId}/iterations`    |
| Query Builds     | GET     | `/builds`                             |
| Get Build        | GET     | `/builds/{buildId}`                   |

Vollständige Liste: `https://<ONEDEV_HOST>/~help/api`

------------------------------------------------------------------------

## 16. Referenzen & Links

### Extern

| Ressource                     | URL                                      |
|-------------------------------|------------------------------------------|
| OneDev REST API (allgemein)   | <https://docs.onedev.io/restful-api>     |
| OneDev Concepts               | <https://docs.onedev.io/concepts>        |
| API-Hilfe (pro Instanz)       | `https://<ONEDEV_HOST>/~help/api`        |
| gitlabr (Referenzarchitektur) | <https://thinkr-open.github.io/gitlabr/> |
| gitlabr GitHub                | <https://github.com/ThinkR-open/gitlabr> |
| httr2                         | <https://httr2.r-lib.org/>               |
| usethis                       | <https://usethis.r-lib.org/>             |
| testthat                      | <https://testthat.r-lib.org/>            |

### Projekt-Artefakte (dieses Repo)

| Artefakt        | Pfad                  |
|-----------------|-----------------------|
| Dieser Plan     | `onedevr-plan.md`     |
| Paket-Quellcode | `R/*.R` (nach Anlage) |
| Tests           | `tests/testthat/*.R`  |
| Vignetten       | `vignettes/*.Rmd`     |
| Env-Vorlage     | `.env.example`        |

------------------------------------------------------------------------

## 17. Risiken & offene Fragen

| Risiko | Mitigation |
|----|----|
| OneDev API ändert Payload-Formate zwischen Versionen | [`.od_request_with_variants()`](https://alexseymer.github.io/onedevR/reference/dot-od_request_with_variants.md); Versionshinweis in README |
| Custom Fields installationsabhängig | Kein festes Schema; `fields` als named list |
| Bearer vs Basic Auth | Beide unterstützen; Bearer als Default, Basic als Option |
| Paketname `onedevr` auf CRAN verfügbar? | Vor Submission prüfen; Alternative: `onedevapi` |
| Kleine Community | Gute Doku, pkgdown, klare Vignetten |
| Self-signed TLS in internen Setups | `ONEDEV_CURL_INSECURE` dokumentieren, nicht empfehlen |

### Offene Entscheidungen

1.  **GitHub-Org:** `your-org/onedevr` — welche Organisation?
2.  **Funktionspräfix:** `od_*` (kurz) vs. `onedev_*` (explizit)?
3.  **CRAN ja/nein** oder nur GitHub + R-universe?
4.  **Lizenz:** MIT (breite Nutzung) vs GPL-3 (wie gitlabr)?
5.  **Basic Auth:** Phase 1 oder Phase 2?
6.  **Rückgabeformat:** native `list` vs. `tibble` (gitlabr-Stil)?

------------------------------------------------------------------------

## 18. Umsetzungs-Checkliste

### Sofort

Plan-Dokument erstellen

GitHub-Repo anlegen

Lizenz wählen

README-Skeleton

### Phase 1 MVP

`usethis::create_package("onedevr")`

`R/request.R`, `R/config.R`, `R/issues.R`, `R/projects.R`,
`R/variants.R`

`%||%` via `rlang::%||%`

Unit-Tests (config, resolve, issues, variants)

Vignette `getting-started`

`R CMD check` grün

Tag `v0.1.0`

### Phase 2

[`od_connection()`](https://alexseymer.github.io/onedevR/reference/od_connection.md)
implementieren

Iterations-API kapseln

[`od_get_issue_fields()`](https://alexseymer.github.io/onedevR/reference/od_get_issue_fields.md)

Live-Integrationstests (gated)

### Phase 3+

Builds-Modul

Pull-Request-Wrapper

pkgdown-Site

CRAN / R-universe

------------------------------------------------------------------------
