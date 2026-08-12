# Point $PROFILE at this repository.
#
# The profile becomes a small loader that dot-sources windows/*.ps1 from here,
# rather than a copy of them. That mirrors how `make` symlinks the Unix
# dotfiles: a `git pull` takes effect on the next shell, with no need to re-run
# this script. Edit windows/*.ps1 in the repository, not $PROFILE.

$ErrorActionPreference = 'Stop'

$marker = '# managed by Naturalclar/dotfiles bootstrap.ps1 -- edits here are overwritten'
$partsGlob = Join-Path (Join-Path $PSScriptRoot 'windows') '*.ps1'

# $PROFILE points into Documents\PowerShell, which does not exist until the
# first profile is created. Add-Content will not create it for us.
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -LiteralPath $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Never throw away a profile we did not write. Re-running this script is a
# no-op for the backup, since by then the marker is already in place.
if (Test-Path -LiteralPath $PROFILE) {
    $existing = Get-Content -LiteralPath $PROFILE -Raw
    if ($null -eq $existing -or -not $existing.Contains($marker)) {
        $backup = "$PROFILE.bak"
        Copy-Item -LiteralPath $PROFILE -Destination $backup -Force
        Write-Host "Backed up the existing profile to $backup"
    }
}

# Single-quoted in the generated file so nothing in the path is expanded at
# load time; '' is the escape for a literal quote.
$escapedGlob = $partsGlob.Replace("'", "''")

Set-Content -LiteralPath $PROFILE -Value @(
    $marker
    "# Sourced from $PSScriptRoot -- edit windows/*.ps1 there."
    ''
    "Get-ChildItem -Path '$escapedGlob' | Sort-Object Name | ForEach-Object { . `$_.FullName }"
)

Write-Host "Wrote $PROFILE"
Write-Host "It now sources $partsGlob on every start."
