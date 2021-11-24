#!/usr/bin/env bash

# File based from Godot engine: https://github.com/godotengine

# This script runs autopep8 on all Python files in the repo.

set -uo pipefail

# Apply autopep8.
echo -e "Formatting Python files..."
PY_FILES=$(find \( -path "./.git" \
                -o -path "./thirdparty" \
                \) -prune \
                -o \( -name "SConstruct" \
                -o -name "SCsub" \
                -o -name "*.py" \
                \) -print)
autopep8 --max-line-length 100 $PY_FILES

git diff --color > patch.patch

# If no patch has been generated all is OK, clean up, and exit.
if [ ! -s patch.patch ] ; then
    printf "Files in this commit comply with the autopep8 style rules.\n"
    rm -f patch.patch
    exit 0
fi

# A patch has been created, notify the user, clean up, and exit.
printf "\n*** The following differences were found between the code "
printf "and the formatting rules:\n\n"
cat patch.patch
printf "\n*** Aborting, please fix your commit(s) with 'git commit --amend' or 'git rebase -i <hash>'\n"
rm -f patch.patch
exit 1
