# Security policy

## Supported versions

Security fixes are released for the latest version on `main` (currently
0.7.x). Older versions are not patched; please update.

## Reporting a vulnerability

Please do **not** open a public issue for security problems.

1.  Use GitHub’s private reporting:
    <https://github.com/alexseymer/onedevR/security/advisories/new>
2.  Or email the maintainer (address in `DESCRIPTION`) with “onedevr
    security” in the subject.

Include the affected version, steps to reproduce, and the impact you
expect. You can expect an acknowledgement within a few days and a fix or
a mitigation plan as soon as the report is confirmed. Reporters are
credited in `NEWS.md` unless they prefer to stay anonymous.

## What counts as a vulnerability

Examples: credentials (token, password) that end up in output, logs,
cache keys or requests to a host other than the configured one; query or
request construction that lets input change what is sent to OneDev;
unsafe file writes in the download and log helpers; vulnerable
dependencies.

## Safe usage

- Keep tokens in `.Renviron` or CI secrets, never in code. `.Renviron`
  and `.env` are git-ignored; do not commit them.
- Use a token with the minimum permissions the script needs.
- Do not set `ONEDEV_CURL_INSECURE=1` (or `insecure_ssl = TRUE`) except
  on networks you trust. The package warns once per session when it is
  on.
- Treat `od_connection` objects as secrets;
  [`print()`](https://rdrr.io/r/base/print.html) and
  [`str()`](https://rdrr.io/r/utils/str.html) mask them, but
  [`unclass()`](https://rdrr.io/r/base/class.html) and
  [`saveRDS()`](https://rdrr.io/r/base/readRDS.html) do not.

## How the project is monitored

| Check | Where | When |
|----|----|----|
| Known vulnerabilities in R dependencies (installed and minimum versions, via [OSV](https://osv.dev)) | `scripts/audit-deps.R`, workflow `security` | weekly, pull requests, on demand |
| Secrets committed to the repository | gitleaks in workflow `security` | every push and pull request, weekly |
| Insecure patterns in GitHub Actions workflows | CodeQL (`actions`) in workflow `security` | pushes to `main`, pull requests, weekly |
| Outdated GitHub Actions | Dependabot (`.github/dependabot.yml`) | weekly |

Run the dependency audit locally with `Rscript scripts/audit-deps.R`.
