# Cloud agent base image for onedevr (R package).
# Do not COPY the project — Cursor checks out the workspace separately.
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl wget gnupg dirmngr \
      build-essential gfortran \
      software-properties-common \
 && rm -rf /var/lib/apt/lists/*

# CRAN apt repo (R >= 4.6) — Ubuntu noble's r-base-core 4.3.3 is too old for
# current r2u binaries.
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc \
      | tee /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc >/dev/null \
 && echo "deb [arch=amd64] https://cloud.r-project.org/bin/linux/ubuntu noble-cran40/" \
      > /etc/apt/sources.list.d/cran-r.list

# r2u — binary CRAN packages as .deb (fast, no compilation)
RUN wget -qO- https://eddelbuettel.github.io/r2u/assets/dirk_eddelbuettel_key.asc \
      | tee /etc/apt/trusted.gpg.d/cranapt_key.asc >/dev/null \
 && echo "deb [arch=amd64] https://r2u.stat.illinois.edu/ubuntu noble main" \
      > /etc/apt/sources.list.d/cranapt.list \
 && printf '%s\n' \
      'Package: *' \
      'Pin: release o=CRAN-Apt Project' \
      'Pin: release l=CRAN-Apt Packages' \
      'Pin-Priority: 700' \
      > /etc/apt/preferences.d/99cranapt

# R + runtime + test/dev toolchain used by onedevr (plan DESCRIPTION + usethis workflow)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      r-base-core r-base-dev \
      r-cran-httr2 r-cran-jsonlite r-cran-rlang \
      r-cran-testthat r-cran-devtools r-cran-roxygen2 \
      r-cran-knitr r-cran-rmarkdown r-cran-mockery r-cran-withr \
 && rm -rf /var/lib/apt/lists/*

# Sanity check at build time
RUN Rscript -e 'stopifnot(getRversion() >= "4.2.0"); cat("R", as.character(getRversion()), "OK\n")'
