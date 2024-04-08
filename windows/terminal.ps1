# Set the shell to display current branch name
function prompt {
    # Get name of the current directory
    $directoryName = (Get-Location).Path.Split("\")[-1]
    $branch = $(get_current_branch)

    # Check if there are any changes in the current directory without showing them
    $has_diff = $null -ne $(git status --porcelain)
    if ($has_diff -eq "True") {
        $branchColor = "Red"
    }
    else {
        $branchColor = "Green"
    }
    Write-Host "$directoryName " -NoNewline -ForegroundColor "Magenta" 
    Write-Host "[$branch] " -NoNewline -ForegroundColor $branchColor
    return "PS> "
}

