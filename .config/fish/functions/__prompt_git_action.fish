# Approximates vcs_info's %a: the operation in progress, if any. The marker
# files live in the per-worktree git dir, so --git-dir is the right one here
# (not --git-common-dir).
function __prompt_git_action --description 'rebase/merge/etc in progress, empty when idle'
    set -l gitdir (command git rev-parse --git-dir 2>/dev/null)
    or return

    if test -d $gitdir/rebase-merge
        if test -f $gitdir/rebase-merge/interactive
            echo rebase-i
        else
            echo rebase-m
        end
    else if test -d $gitdir/rebase-apply
        if test -f $gitdir/rebase-apply/applying
            echo am
        else
            echo rebase
        end
    else if test -f $gitdir/MERGE_HEAD
        echo merge
    else if test -f $gitdir/CHERRY_PICK_HEAD
        echo cherry-pick
    else if test -f $gitdir/REVERT_HEAD
        echo revert
    else if test -f $gitdir/BISECT_LOG
        echo bisect
    end
end
