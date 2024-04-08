setx PROMPT "%PROMPT%"
# Set the shell to display current branch name
function prompt {
  $loc = $executionContext.SessionState.Path.CurrentLocation;

  $out = ""
  if ($loc.Provider.Name -eq "FileSystem") {
    $out += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
  }
  $out += "PS> ";
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
  Write-Host "╭─ " -NoNewline -ForegroundColor "DarkGreen"
  Write-Host "$directoryName " -NoNewline -ForegroundColor "Magenta" 
  Write-Host "[$branch] " -ForegroundColor $branchColor
  Write-Host "╰─$ " -NoNewline -ForegroundColor "DarkGreen"

  return $out
}

