# .scripts/switch-worktree is bash and has to be sourced to cd, which fish
# cannot do, so this is the fish equivalent. Keep it in step with that script.
function switch-worktree --description 'cd to a git worktree picked with fzf'
    set -l lines (git worktree list 2>/dev/null | tail -n +2)
    if test (count $lines) -eq 0
        echo "No linked worktrees for this repository"
        return 1
    end

    set -l paths
    set -l labels
    for line in $lines
        set -l fields (string split -n ' ' -- $line)
        set -l path $fields[1]
        set -l branch (string trim -c '[]' -- $fields[3])
        set -l name (path basename $path)
        # The script shows "Nothing" when the branch matches the directory name,
        # i.e. when the branch adds no information beyond the worktree itself.
        test "$branch" = "$name"; and set branch Nothing

        set -a paths $path
        set -a labels (printf '%-30s %s' (path basename (path dirname $path))/$name $branch)
    end

    set -l picked (printf '%s\n' $labels | cat -n | fzf --layout=reverse --prompt="Select worktree: " \
        --preview 'echo -e "Currently working on: \n\n$(echo {} | cut -f2-)"')
    test -n "$picked"; or return 0

    set -l index (string trim -- (string split -m1 \t -- $picked)[1])
    cd $paths[$index]
end
