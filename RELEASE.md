# Release checklist for onedevr

Use this when cutting a GitHub Release (Phase 4+).

1.  Ensure `main` is green on `R-CMD-check`, `pkgdown` and `security`,
    and that the release meets the Definition of Done in
    `project_plan.md` (section 11).
2.  Bump `Version` in `DESCRIPTION` (tag = `v` + version, e.g. `0.7.1` →
    `v0.7.1`) and make the first heading of `NEWS.md`
    `# onedevr <version>`. README, ROADMAP and `project_plan.md` must
    name the same version; the version-consistency test checks README
    and NEWS.
3.  Run the local gates:

``` r

devtools::document()
devtools::check(args = "--no-manual")
pkgdown::check_pkgdown()
```

``` bash
Rscript scripts/audit-deps.R   # dependency vulnerabilities (OSV), needs network
```

4.  Tag and publish:

``` bash
git checkout main
git pull
gh release create v0.7.1 --title "onedevr 0.7.1" --notes-file NEWS.md
```

5.  Confirm the `pkgdown` workflow deployed to
    <https://alexseymer.github.io/onedevR/>
6.  In GitHub repo **Settings → Pages**, set source to the `gh-pages`
    branch (first deploy creates it) if not already configured.

CRAN submission remains optional; the package name `onedevr` was
available on CRAN as of the Phase 4 check (2026-08-02).
