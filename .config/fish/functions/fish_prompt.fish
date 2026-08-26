# NOTE: mirrors the PROMPT in .zshrc, which is the source of truth. Keep the
# two in step -- see docs/shells.md.
#
#   PROMPT="${SSH_INDICATOR}%F{green}╭─ ${_prompt_path_msg} %f${vcs_info_msg_0_}
#   %F{green}╰─%B$%b %f"
function fish_prompt --description 'two-line prompt matching .zshrc'
    # SSH 接続時だけ先頭に目立つバッジを出す (zsh 側の SSH_INDICATOR と同じ)
    if set -q SSH_CONNECTION; or set -q SSH_TTY
        set_color --background magenta white
        printf ' SSH:%s ' (prompt_hostname)
        set_color normal
        echo
    end

    set_color green
    printf '╭─ %s ' (__prompt_path)
    set_color normal

    __prompt_git_state

    echo
    set_color green
    printf '╰─'
    set_color --bold green
    printf '$'
    set_color normal
    printf ' '
end
