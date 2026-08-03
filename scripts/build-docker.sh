#!/usr/bin/env bash
# Build onedevr source tarball inside rocker/r2u, then remove the container.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="${OUT_DIR:-${ROOT}/dist}"
IMAGE="${IMAGE:-rocker/r2u:noble}"
HOST_UID="$(id -u)"
HOST_GID="$(id -g)"

mkdir -p "${OUT_DIR}"

echo "Building onedevr with ${IMAGE} (container removed on exit)…"

# Root inside the container so r2u/bspm can apt-install knitr (VignetteBuilder).
# Output is chown'd to the host user before the container exits (--rm).
docker run --rm \
  -e HOST_UID="${HOST_UID}" \
  -e HOST_GID="${HOST_GID}" \
  -v "${ROOT}:/pkg:ro" \
  -v "${OUT_DIR}:/out" \
  -w /tmp \
  "${IMAGE}" \
  bash -c '
    set -euo pipefail
    # Imports + vignette builders (R CMD build installs the package to weave vignettes)
    install.r httr2 jsonlite rlang tibble vctrs knitr rmarkdown
    cp -a /pkg /tmp/onedevr
    cd /tmp/onedevr
    rm -rf .git .cursor dist
    R CMD build .
    mv -v onedevr_*.tar.gz /out/
    chown "${HOST_UID}:${HOST_GID}" /out/onedevr_*.tar.gz
  '

echo "Done. Artifact(s):"
ls -lh "${OUT_DIR}"/onedevr_*.tar.gz
