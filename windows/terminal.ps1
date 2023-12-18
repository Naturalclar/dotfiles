# Set the shell to display current branch name
function prompt {
    $branch = $(get_current_branch)
    Write-Host "[$branch] " -NoNewline -ForegroundColor Green
    return "PS> "
}