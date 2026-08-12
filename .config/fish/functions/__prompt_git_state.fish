# NOTE: mirrors the vcs_info zstyles in .zshrc, which are the source of truth:
#   stagedstr   "%F{yellow}!"
#   unstagedstr "%F{red}+"
#   formats     "%F{green}%c%u[%b]%f"
#   actionformats '[%b|%a]'
# The markers deliberately leak their color into the branch, exactly as the zsh
# formats do: green normally, yellow with staged changes, red with unstaged.
function __prompt_git_state --description 'git branch and dirty markers, matching vcs_info in .zshrc'
    command git rev-parse --is-inside-work-tree >/dev/null 2>&1; or return

    set -l branch (command git symbolic-ref --short HEAD 2>/dev/null)
    or set branch (command git rev-parse --short HEAD 2>/dev/null)
    test -n "$branch"; or return

    # rebase/merge などの最中は zsh の actionformats と同じく色なしの [branch|action]
    set -l action (__prompt_git_action)
    if test -n "$action"
        printf '[%s|%s]' $branch $action
        return
    end

    set_color green
    if not command git diff --cached --quiet 2>/dev/null
        set_color yellow
        printf '!'
    end
    if not command git diff --quiet 2>/dev/null
        set_color red
        printf '+'
    end
    printf '[%s]' $branch
    set_color normal
end
