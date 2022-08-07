#!/usr/bin/env bash

ALL_COMMITS=$(git rev-list "HEAD" 2>&1) && exit_status=$? || exit_status=$?
LATEST_REMOTE_COMMIT=$(git rev-parse "@~" 2>&1) && exit_status=$? || exit_status=$?

echo "LOOP:"
for COMMIT in $ALL_COMMITS
do
    if [ $COMMIT != $LATEST_REMOTE_COMMIT ]; then
        #TODO: As git lock information fetching is really slow that should be minimized
        # For this please group files so every file will only be checked once.
        # Even better: only make one 'git lfs locks' call
        echo "Commit: $COMMIT"
        echo "$(git show $COMMIT | grep Author |head -1)"
        COMMIT_FILES=$(git diff-tree --no-commit-id --name-only -r $COMMIT)
        echo "Files:"
        for COMMIT_FILE in $COMMIT_FILES
        do
            echo "File: $COMMIT_FILE"
            COMMIT_FILE_LOCK=$(git lfs locks -p $COMMIT_FILE)
            if [ -n "${COMMIT_FILE_LOCK}" ]; then
                echo "  Is Locked"
                COMMIT_FILE_LOCK_OWNER=$(echo $COMMIT_FILE_LOCK | tr -s \" \" | cut -d ' ' -f2)
                # FIXME: MAP REMOTE SERVER USERNAME to AUTHOR
                # https://docs.github.com/en/rest/users/users#get-a-user
                # https://github.com/git-lfs/git-lfs/issues/3578
                # 
                # PS: Getting the commiter/pusher github username seems to be impossible
                echo "  Locked by: $COMMIT_FILE_LOCK_OWNER"
                #TODO: ADD flag to simply unlock all files regardless of commiter and current lock_owner (Default: Check if author == lock_owner)
            else
                echo "  Is not locked"
            fi
        done
    else
        break
    fi
done
