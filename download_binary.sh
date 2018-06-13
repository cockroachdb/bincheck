#!/usr/bin/env bash

set -euo pipefail

binary_suffix=$1
binary_source=""
cockroach_version=""
while read line; do
  case "$line" in
  \#*)
    continue ;;
  test:*)
    binary_source="https://binaries-test.cockroachdb.com"
    parts=(${line//:/ })
    cockroach_version="${parts[1]}"
    ;;
  "")
    continue
    ;;
  *)
    binary_source="https://binaries.cockroachdb.com"
    cockroach_version="${line}"
    ;;
  esac
done < VERSION

export COCKROACH_VERSION="${cockroach_version}"
binary_url="${binary_source}/cockroach-${cockroach_version}.${binary_suffix}"

mkdir -p mnt

# Check if this is a tarball or zip.
if [[ "${binary_suffix}" == *.tgz ]]; then
  curl -sSfL "${binary_url}" | tar zx -C mnt --strip-components=1
else
  curl -sSfL "${binary_url}" > cockroach.zip
  7z e -omnt cockroach.zip
fi

echo "Downloaded ${binary_url}"
