#!/usr/bin/env bash

ALL_COMMITS=$(git rev-list "HEAD" 2>&1) && exit_status=$? || exit_status=$?
LATEST_REMOTE_COMMIT=$(git rev-parse "@~" 2>&1) && exit_status=$? || exit_status=$?


LATEST_REMOTE_COMMIT=f283721ba00aa5c804d826db26baa77930f0e9e5


echo $ALL_COMMITS
echo $LATEST_REMOTE_COMMIT

echo "LOOP:"
for COMMIT in $ALL_COMMITS
do
    if [ $COMMIT != $LATEST_REMOTE_COMMIT ]; then
        echo "COMMIT: $COMMIT"
        echo "AUTHOR: $(git show $COMMIT | grep Author)"
        echo "FILES: $(git diff-tree --no-commit-id --name-only -r $COMMIT)"
    else
        break
    fi
done
