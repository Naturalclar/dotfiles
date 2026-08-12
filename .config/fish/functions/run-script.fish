# NOTE: mirrors run-script in .zsh/81-run-script.zsh, which is the source of
# truth. Same selector, same package-manager detection, same lockfile order.
function run-script --description 'pick a package.json script with fzf and run it'
    if not test -f package.json
        echo "No package.json found in current directory"
        return 1
    end

    # ::: as the delimiter, so script names containing a colon still split
    set -l entries (jq -r '.scripts | to_entries | .[] | .key + ":::" + .value' package.json)
    if test (count $entries) -eq 0
        echo "No scripts found in package.json"
        return 1
    end

    set -l selected (printf '%s\n' $entries | fzf --layout=reverse --prompt="Run script: " \
        --preview 'echo -e "Command:\n\n$(echo {} | cut -d: -f3-)"')
    test -n "$selected"; or return 0

    set -l script_name (string replace -r ':::.*' '' -- $selected)

    set -l cmd npm run
    if test -f yarn.lock
        set cmd yarn
    else if test -f pnpm-lock.yaml
        set cmd pnpm
    else if test -f bun.lockb
        set cmd bun run
    end

    echo "Running: $cmd $script_name"
    command $cmd $script_name
end
