# Shared helper for the setup-*.ps1 scripts.
#
# Deliberately not under windows/, since bootstrap.ps1 wires everything there
# into $PROFILE and this has no business running on every shell start.

Set-StrictMode -Version Latest

function Test-IsSymbolicLink {
    param([Parameter(Mandatory)][string]$Path)

    $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
    if ($null -eq $item) { return $false }
    return $item.Attributes.HasFlag([IO.FileAttributes]::ReparsePoint)
}

<#
.SYNOPSIS
Link $Path to $Target, the way `ln -sfn` does on the Unix side.

.DESCRIPTION
Creates the parent directory if it is missing, replaces a link we previously
made, and refuses to touch anything else that is already there -- the same rule
`make dotfiles` follows since #264. Returns $true when the link is in place.
#>
function New-DotfilesLink {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Target
    )

    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Warning "skip $Path`: $Target does not exist in the repository"
        return $false
    }

    # New-Item does not create intermediate directories for a symlink, and
    # %USERPROFILE%\.config does not exist on a stock Windows install.
    $parent = Split-Path -Parent $Path
    if ($parent -and -not (Test-Path -LiteralPath $parent)) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
    }

    if ((Test-Path -LiteralPath $Path) -and -not (Test-IsSymbolicLink $Path)) {
        Write-Warning "skip $Path`: already exists and is not a link -- move it aside first"
        return $false
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Path -Value $Target -Force | Out-Null
    } catch {
        Write-Warning "failed to link $Path -> $Target"
        Write-Warning 'Creating symlinks needs an elevated shell, or Developer Mode:'
        Write-Warning '  Settings > Privacy & security > For developers > Developer Mode'
        Write-Warning $_.Exception.Message
        return $false
    }

    Write-Host "linked $Path -> $Target"
    return $true
}
