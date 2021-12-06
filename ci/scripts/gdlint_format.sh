#!/usr/bin/env bash

# File based from Godot engine: https://github.com/godotengine

# This script runs gdlint on all relevant files in the repo.
# This is the primary script responsible for fixing style violations.

set -uo pipefail
IFS=$'\n\t'

GD_FORMAT_FILE_EXTS=(".gd")

# Loops through all text files tracked by Git.
git grep -zIl '' |
while IFS= read -rd '' f; do
    for extension in ${GD_FORMAT_FILE_EXTS[@]}; do
        if [[ "$f" == *"$extension" ]]; then
            # Run gdlint.
            gdlint "$f"
            gdparse "$f"
            continue 2
        fi
    done
done

git diff --color > patch.patch

# If no patch has been generated all is OK, clean up, and exit.
if [ ! -s patch.patch ] ; then
    printf "Files in this commit comply with the gdlint style rules.\n"
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
