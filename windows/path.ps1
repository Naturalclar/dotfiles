# Add direnv config path
Invoke-Expression "$(direnv hook pwsh)"

# Add pypoetry to path
$poetryPath = ';' + $env:APPDATA + '\pypoetry\venv\Scripts'

$env:Path += $poetryPath