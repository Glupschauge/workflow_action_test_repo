#!/usr/bin/env bash

##Remember that it is nececarry to use following fetch-depth in github action:
# - name: Check out repository code
#        uses: actions/checkout@v3
#        with:
#          fetch-depth: 0

ALL_COMMITS=$(git rev-list "HEAD" 2>&1) && exit_status=$? || exit_status=$?
LATEST_REMOTE_COMMIT=$(git rev-parse "@~" 2>&1) && exit_status=$? || exit_status=$?
LATEST_REMOTE_COMMIT=f283721ba00aa5c804d826db26baa77930f0e9e5

# This sets all the Authors of file in a string delimited by " " in var AUTHORS_$escaped_filename
# exp.: Authors for file test/test.py are in va AUTHORS_test_test_py = foo.bar@asdfa.com fizzbuzz@foo.com
for COMMIT in $ALL_COMMITS
do
    if [ $COMMIT != $LATEST_REMOTE_COMMIT ]; then
        COMMIT_FILES=$(git diff-tree --no-commit-id --name-only -r $COMMIT)
        for COMMIT_FILE in $COMMIT_FILES
        do
            COMMIT_FILE_AUTHOR=$(git show $COMMIT | grep Author | cut -d ' ' -f4 | head -1 | sed 's/^<\(.*\)>$/\1/')
            escaped_filename=$(echo $COMMIT_FILE | tr ./ _)
            x=AUTHORS_$escaped_filename
            val=$(echo "${!x} $COMMIT_FILE_AUTHOR")
            if [ -z "${!x}" ]; then
                val=$(echo "$COMMIT_FILE_AUTHOR")
            else
                if [[ "$COMMIT_FILE_AUTHOR" == *"${!x}"* ]]; then
                    continue
                fi
            fi
            declare $x="$val"
        done
    else
        break
    fi
done

GIT_LFS_FILE_LOCKS=$(git lfs locks)
while IFS= read -r GIT_LFS_FILE_LOCK; do
    LOCKED_FILE=$(echo $GIT_LFS_FILE_LOCK | tr -s \" \" | cut -d ' ' -f1)
    LOCK_OWNER=$(echo $GIT_LFS_FILE_LOCK | tr -s \" \" | cut -d ' ' -f2)
    # FIXME: MAP REMOTE SERVER USERNAME to AUTHOR
    # https://docs.github.com/en/rest/users/users#get-a-user
    # https://github.com/git-lfs/git-lfs/issues/3578

    echo "Locked File: $LOCKED_FILE Owned by: $LOCK_OWNER"
done <<< "$GIT_LFS_FILE_LOCKS"
