# Add direnv config path
Invoke-Expression "$(direnv hook pwsh)"

$env:CLAUDE_CODE_GIT_BASH_PATH = "$env:USERPROFILE\scoop\shims\bash.exe"

$env:DIRENV_CONFIG = $env:APPDATA + '\direnv\config'
$env:XDG_CACHE_HOME = $env:APPDATA + '\direnv\cache'
$env:XDG_DATA_HOME = $env:APPDATA + '\direnv\data'

# Add pypoetry to path
$poetryPath = ';' + $env:APPDATA + '\pypoetry\venv\Scripts'

$env:Path += $poetryPath
