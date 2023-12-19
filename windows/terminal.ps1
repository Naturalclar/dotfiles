# Set the shell to display current branch name
function prompt {
    # Get name of the current directory
    $directoryName = (Get-Location).Path.Split("\")[-1]
    $branch = $(get_current_branch)
    Write-Host "$directoryName [$branch] " -NoNewline -ForegroundColor Green
    return "PS> "
}