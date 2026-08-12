# NOTE: mirrors fzf-workspace in .zsh/73-workspace.zsh, which is the source of
# truth. The preview runs in fzf's own shell (sh), so that part is shared
# verbatim between the two.
function wf --description 'cd to a ghq repo picked with fzf, previewing its README'
    set -l preview 'REPO={}; README=$(find "$REPO" -maxdepth 1 -name "README*" -type f | head -n 1); if [ -z "$README" ]; then README=$(find "$REPO/main" "$REPO/master" "$REPO/develop" "$REPO/dev" -maxdepth 1 -name "README*" -type f 2>/dev/null | head -n 1); fi; if [ -n "$README" ]; then bat --color=always --style=header,grid --line-range :80 "$README"; else echo "No README found"; fi'

    set -l repo (ghq list --full-path | fzf --layout=reverse --preview $preview)
    test -n "$repo"; and cd $repo
end
