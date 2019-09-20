#!/usr/bin/env bash

set -euox pipefail

binary_suffix=$1
binary_source=""
cockroach_version=""
while read line; do
  case "$line" in
  \#*|"") continue ;;
  test:*)
    binary_source="https://binaries-test.cockroachdb.com"
    parts=(${line//:/ })
    export COCKROACH_VERSION=${parts[1]}
    ;;
  v*)
    binary_source="https://binaries.cockroachdb.com"
    export COCKROACH_VERSION=$line
    ;;
  *)
    export COCKROACH_SHA=$line
  esac
done < VERSION

binary_url="${binary_source}/cockroach-$COCKROACH_VERSION.${binary_suffix}"

ls -la
ls -la mnt
rm -rf mnt
mkdir -p mnt

# Check if this is a tarball or zip.
if [[ "${binary_suffix}" == *.tgz ]]; then
  curl -sSfL "${binary_url}" | tar zx -C mnt --strip-components=1
else
  curl -sSL "${binary_url}" > cockroach.zip
  7z e -omnt -aoa cockroach.zip
fi

echo "Downloaded ${binary_url}"
