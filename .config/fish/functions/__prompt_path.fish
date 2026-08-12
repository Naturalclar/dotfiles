# NOTE: this mirrors _prompt_path in .zshrc, which is the source of truth.
# See README.md -- keep the two in step; test/prompt.bats asserts they agree.
#
# git リポジトリの中では絶対パスではなく <repo>[/<worktree>] とリポジトリルート
# からの相対パスを出す。リポジトリ外では従来どおりフルパス表示。
#
# `string replace` はマッチしないと 1 を返すので、その終了ステータスがプロンプト
# 関数の外に漏れないよう、結果は必ず echo (...) でくるむ。
function __prompt_path --description 'repo[/worktree] and the path from the repo root'
    set -l gi (command git rev-parse --show-toplevel --git-common-dir 2>/dev/null)

    if test (count $gi) -ne 2
        # zsh の ${PWD/#$HOME/~} と同じく先頭のみ置換する
        echo (string replace -r -- '^'(string escape --style=regex -- $HOME) '~' $PWD)
        return 0
    end

    # --git-common-dir はサブディレクトリだと相対で返るので絶対化する
    set -l root $gi[1]
    set -l common (path resolve $gi[2])

    # common dir が .git / .bare ならそれはリポジトリ内の隠しディレクトリなので
    # 親がリポジトリ名 (通常の clone、および <repo>/.bare + <repo>/<branch> 運用)。
    # そうでなければ common dir 自体が bare リポジトリ (foo.git など) なので、
    # .git サフィックスを落としたものがリポジトリ名になる。
    set -l label
    switch (path basename $common)
        case .git .bare
            set label (path basename (path dirname $common))
        case '*'
            set label (string replace -r -- '\.git$' '' (path basename $common))
    end

    # linked worktree では <root>/.git がディレクトリではなくファイルになる
    if test -f $root/.git
        set label $label/(path basename $root)
    end

    # zsh 側は prompt_subst の再解釈対策で % を二重化するが、fish は
    # プロンプト文字列を再解釈しないのでそのまま出す
    echo $label(string replace -r -- '^'(string escape --style=regex -- $root) '' $PWD)
    return 0
end
