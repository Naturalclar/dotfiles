# Check each .ps1 files in windows directory and set up so that it runs when shell starts up

# Get the current directory
$dir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Remove the existing profile
Remove-Item -Path $profile -Force

# Get all .ps1 files in windows directory
$files = Get-ChildItem -Path $dir\windows\*.ps1

# For each file, add the contents to the profile
foreach ($file in $files) {
    $content = Get-Content $file
    Add-Content -Path $profile -Value $content
}
