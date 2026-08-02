# Release checklist for onedevr

Use this when cutting a GitHub Release (Phase 4+).

1. Ensure `main` is green on `R-CMD-check`.
2. Confirm `DESCRIPTION` `Version` matches the tag (e.g. `0.1.0` → `v0.1.0`).
3. Update `NEWS.md` for the release.
4. Tag and publish:

```bash
git checkout main
git pull
gh release create v0.1.0 --title "onedevr 0.1.0" --notes-file NEWS.md
```

5. Confirm the `pkgdown` workflow deployed to
   https://alexseymer.github.io/onedevR/
6. In GitHub repo **Settings → Pages**, set source to the `gh-pages` branch
   (first deploy creates it) if not already configured.

CRAN submission remains optional; the package name `onedevr` was available on
CRAN as of the Phase 4 check (2026-08-02).
