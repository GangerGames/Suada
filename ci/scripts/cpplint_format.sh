#!/usr/bin/env bash

# File based from Godot engine: https://github.com/godotengine

# This script runs cpplint on all relevant files in the repo.
# This is the primary script responsible for fixing style violations.

set -uo pipefail
IFS=$'\n\t'

CLANG_FORMAT_FILE_EXTS=(".c" ".h" ".cpp" ".hpp" ".cc" ".hh" ".cxx")

# Loops through all text files tracked by Git.
git grep -zIl '' |
while IFS= read -rd '' f; do
    filters='+build/class,+build/c++11,+build/c++14,+build/c++tr1,+build/deprecated,+build/endif_comment,+build/explicit_make_pair,+build/forward_decl,-build/header_guard,-build/include,+build/include_alpha,+build/include_order,+build/include_what_you_use,+build/namespaces,+build/printf_format,+build/storage_class,+legal/copyright,+readability/alt_tokens,+readability/braces,+readability/casting,+readability/check,+readability/constructors,+readability/fn_size,+readability/inheritance,+readability/multiline_comment,+readability/multiline_string,+readability/namespace,+readability/nolint,+readability/nul,+readability/strings,+readability/todo,+readability/utf8,+runtime/arrays,+runtime/casting,+runtime/explicit,+runtime/int,+runtime/init,+runtime/invalid_increment,+runtime/member_string_references,+runtime/memset,+runtime/indentation_namespace,+runtime/operator,+runtime/printf,+runtime/printf_format,+runtime/references,+runtime/string,+runtime/threadsafe_fn,+runtime/vlog,+whitespace/blank_line,+whitespace/braces,+whitespace/comma,+whitespace/comments,+whitespace/empty_conditional_body,+whitespace/empty_if_body,+whitespace/empty_loop_body,+whitespace/end_of_line,+whitespace/ending_newline,+whitespace/forcolon,+whitespace/indent,+whitespace/line_length,+whitespace/newline,+whitespace/operators,+whitespace/parens,+whitespace/semicolon,+whitespace/tab,+whitespace/todo'

    for extension in ${CLANG_FORMAT_FILE_EXTS[@]}; do
        if [[ "$f" == *"$extension" ]]; then
            # Run cpplint.
            cpplint --filter=$filters "$f"
            continue 2
        fi
    done
done

git diff --color > patch.patch

# If no patch has been generated all is OK, clean up, and exit.
if [ ! -s patch.patch ] ; then
    printf "Files in this commit comply with the cpplint style rules.\n"
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