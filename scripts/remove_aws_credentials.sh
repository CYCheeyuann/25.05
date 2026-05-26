#!/usr/bin/env bash
# 脚本：在 Git Bash/WSL 下删除敏感文件并调用 git-filter-repo（示例）
set -euo pipefail

echo "1/4 - Removing files from index and committing"
git rm --cached dvc_tutorial/.aws/credentials || true
git rm --cached cycheeyuan_accessKeys.csv || true
git commit -m "remove sensitive credential files from working tree" || true

echo "2/4 - Running git-filter-repo to purge history (requires git-filter-repo installed)"
if ! command -v git-filter-repo >/dev/null 2>&1; then
  echo "git-filter-repo not found. Install with: pip install git-filter-repo" >&2
  exit 1
fi

git filter-repo --path dvc_tutorial/.aws/credentials --path cycheeyuan_accessKeys.csv --invert-paths

echo "3/4 - Cleaning reflog and running gc"
git reflog expire --expire=now --all
git gc --prune=now --aggressive

echo "4/4 - Force-pushing rewritten history to origin"
git push origin --force --all
git push origin --force --tags

echo "Done. Remember to rotate the exposed AWS keys immediately and inform collaborators."
