#!/usr/bin/env bash
set -Eeuo pipefail

command -v git >/dev/null 2>&1 || { echo 'git is required.' >&2; exit 1; }
command -v gh >/dev/null 2>&1 || { echo 'GitHub CLI (gh) is required.' >&2; exit 1; }
command -v sha256sum >/dev/null 2>&1 || { echo 'sha256sum is required.' >&2; exit 1; }

gh auth status >/dev/null 2>&1 || {
  echo 'GitHub CLI is not authenticated. Run: gh auth login' >&2
  exit 1
}

[[ -f mhm ]] || { echo 'Run this script from the repository root.' >&2; exit 1; }

version=$(sed -nE 's/^VERSION=([0-9]+\.[0-9]+\.[0-9]+)$/\1/p' mhm | head -n1)
[[ -n $version ]] || { echo 'Could not read VERSION from mhm.' >&2; exit 1; }
tag="v$version"

bash -n mhm
if command -v shellcheck >/dev/null 2>&1; then
  shellcheck --severity=error mhm
else
  echo '[warn] shellcheck is not installed; skipping.'
fi

if git status --porcelain --untracked-files=no | grep -q .; then
  echo 'Tracked files contain uncommitted changes. Commit them first.' >&2
  exit 1
fi

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  echo "Tag $tag already exists." >&2
  exit 1
fi

if gh release view "$tag" >/dev/null 2>&1; then
  echo "Release $tag already exists." >&2
  exit 1
fi

chmod +x mhm
sha256sum mhm > mhm.sha256

git tag -a "$tag" -m "mhm $tag"
git push origin "$tag"

gh release create "$tag" \
  mhm \
  mhm.sha256 \
  --title "mhm $tag" \
  --generate-notes \
  --latest

rm -f mhm.sha256
printf 'Published %s\n' "$tag"
