## Summary

<!-- What changes and why. One focused change per pull request. -->

## Linux principle

- [ ] One thing well: each new or changed function does one operation (purpose in one sentence, no "and")
- [ ] Compose: object first, `conn` and options last; plain data in and out
- [ ] No prompts, no stdout from library code (use `message()` / conditions)
- [ ] No new dependency (or the dependency budget test and its rationale are updated)

## Definition of Done

- [ ] Roxygen docs with example; entry in `_pkgdown.yml`
- [ ] At least one offline test; a field-log problem gets a regression test in `test-field-log.R`
- [ ] `NEWS.md` entry
- [ ] Anything not verified against a live OneDev server is marked as experimental

## Tests

<!-- Test counts, `R CMD check`, `pkgdown::check_pkgdown()`, `Rscript scripts/audit-deps.R`. -->
