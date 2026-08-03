# Cloud agent image for onedevr (R package).
# Do not COPY the project — Cursor checks out the workspace separately.
#
# Base: rocker/r-ver — Ubuntu LTS + pinned R + Posit Package Manager
# binaries (fast install.packages / install2.r on amd64).
# Cursor Cloud requires git (clone) and sudo (agent tooling).
FROM rocker/r-ver:4.6

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# git/sudo are mandatory for Cursor Cloud custom images; the rest are
# common system libs for compiling/checking R packages.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git \
      sudo \
      curl \
      ca-certificates \
      libcurl4-openssl-dev \
      libssl-dev \
      libxml2-dev \
      pandoc \
 && rm -rf /var/lib/apt/lists/*

# Dual repos: keep rocker's P3M binary mirror for installs, add CRAN for
# tools that probe packages.rds (e.g. R CMD check / pkgdown).
RUN echo 'options(repos = c(P3M = "https://p3m.dev/cran/__linux__/noble/latest", CRAN = "https://cloud.r-project.org"))' \
      >>"${R_HOME}/etc/Rprofile.site"

# Runtime + dev/test toolchain used by onedevr
RUN install2.r --error --skipinstalled --ncpus -1 \
      httr2 \
      jsonlite \
      rlang \
      tibble \
      vctrs \
      testthat \
      mockery \
      withr \
      remotes \
      devtools \
      roxygen2 \
      knitr \
      rmarkdown \
      pkgload \
      pkgdown \
 && rm -rf /tmp/downloaded_packages \
 && strip /usr/local/lib/R/site-library/*/libs/*.so 2>/dev/null || true

RUN Rscript -e 'stopifnot(getRversion() >= "4.2.0"); cat("R", as.character(getRversion()), "OK\n")'
