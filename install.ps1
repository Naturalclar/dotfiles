# install.ps1 -- one-command setup for a new Windows machine.
#
#   git clone https://github.com/Naturalclar/dotfiles.git; cd dotfiles; .\install.ps1
#
# The counterpart of install.sh. Idempotent: every step either replaces a link
# it made before or leaves what it finds alone, so re-running is safe.
#
# Creating symlinks needs an elevated shell or Developer Mode
# (Settings > Privacy & security > For developers). Without one, the link steps
# warn and carry on rather than stopping the run.
#
# setup-ahk.ps1 is not called from here -- see the note in that file.

$ErrorActionPreference = 'Stop'

function Invoke-Step {
    param([Parameter(Mandatory)][string]$Script)

    Write-Host ''
    Write-Host "==> $Script" -ForegroundColor Cyan
    & (Join-Path $PSScriptRoot $Script)
}

# The profile first, so a new shell picks everything else up.
Invoke-Step 'bootstrap.ps1'

foreach ($script in 'setup-nvim.ps1', 'setup-wezterm.ps1', 'setup-komorebi.ps1',
                    'setup-whkdrc.ps1', 'setup-yasb.ps1') {
    Invoke-Step $script
}

Invoke-Step 'setup-defaults.ps1'

Write-Host ''
Write-Host 'Done. Start a new PowerShell to pick up the profile.'
