# Set the shell to display current branch name
function prompt {
    # Get name of the current directory
    $directoryName = (Get-Location).Path.Split("\")[-1]
    $branch = $(get_current_branch)

    # Check if there are any changes in the current directory without showing them
    $has_diff = $(git status --porcelain > $null; Write-Output $?)

    $ForegroundColor = "Green"
    if ($has_diff -eq "True") {
        $ForegroundColor = "Red"
    }
    Write-Host "$directoryName [$branch] " -NoNewline -ForegroundColor $ForegroundColor
    return "PS> "
}