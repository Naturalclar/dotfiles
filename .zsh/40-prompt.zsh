## prompt
### vcs_info 表示内容をカスタマイズ
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "%F{yellow}!"
zstyle ':vcs_info:git:*' unstagedstr "%F{red}+"
zstyle ':vcs_info:*' formats "%F{green}%c%u[%b]%f"
zstyle ':vcs_info:*' actionformats '[%b|%a]'

setopt prompt_subst

### プロンプトのパス表示
# git リポジトリの中では絶対パスではなく <repo>[/<worktree>] とリポジトリルート
# からの相対パスを出す。~/.ghq/github.com/owner/... のようなパスは頭が長いだけで
# 実際に知りたいのはリポジトリ名・worktree 名・ルートからの位置なので。
# ブランチ名は vcs_info 側が出す。リポジトリ外では従来どおりフルパス表示。
_prompt_path() {
  local -a gi
  gi=(${(f)"$(command git rev-parse --show-toplevel --git-common-dir 2>/dev/null)"})

  local out
  if (( ${#gi} != 2 )); then
    out=${PWD/#$HOME/\~}
  else
    # --git-common-dir はサブディレクトリだと相対で返るので :a で絶対化する
    local root=${gi[1]} common=${gi[2]:a}

    # common dir が .git / .bare ならそれはリポジトリ内の隠しディレクトリなので
    # 親がリポジトリ名 (通常の clone、および <repo>/.bare + <repo>/<branch> 運用)。
    # そうでなければ common dir 自体が bare リポジトリ (foo.git など) なので、
    # .git サフィックスを落としたものがリポジトリ名になる。
    local label
    case ${common:t} in
      .git | .bare) label=${common:h:t} ;;
      *)            label=${${common:t}%.git} ;;
    esac
    # linked worktree では <root>/.git がディレクトリではなくファイルになる
    [[ -f $root/.git ]] && label+="/${root:t}"
    out="${label}${PWD#$root}"
  fi

  # prompt_subst で展開した中身は % がプロンプトエスケープとして再解釈されるため、
  # ディレクトリ名に % が含まれていてもプロンプトが壊れないようにエスケープする
  _prompt_path_msg="${out//\%/%%}"
}

### SSH接続時はプロンプト先頭に目立つバッジを表示する
if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" ]]; then
  SSH_INDICATOR=$'%K{magenta}%F{white} SSH:%m %f%k\n'
else
  SSH_INDICATOR=""
fi

PROMPT="${SSH_INDICATOR}%F{green}╭─ "'${_prompt_path_msg}'" %f"'${vcs_info_msg_0_}'"
%F{green}╰─%B$%b %f"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# User configuration

