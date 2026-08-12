# One-time Windows settings. Run once per machine.
#
# These used to live in windows/keyboard.ps1 and windows/terminal.ps1, which
# bootstrap.ps1 wires into $PROFILE -- so they ran on every shell start, writing
# the same registry values over and over. The Unix side keeps the equivalent
# (`defaults write -g InitialKeyRepeat`) in install.sh rather than in .zshrc;
# this is the same split.

$ErrorActionPreference = 'Stop'

# Key repeat: start repeating sooner and repeat faster than the stock minimum.
$keyboard = 'HKCU:\Control Panel\Accessibility\Keyboard Response'
$settings = [ordered]@{
    AutoRepeatDelay       = 100
    AutoRepeatRate        = 30
    DelayBeforeAcceptance = 0
    BounceTime            = 0
    Flags                 = 47
}

foreach ($name in $settings.Keys) {
    Set-ItemProperty -Path $keyboard -Name $name -Value $settings[$name]
}
Write-Host "Set key repeat under $keyboard"

# Persist PROMPT so it survives into new sessions. setx writes to the registry
# and is slow, which is exactly why it does not belong in a shell profile.
setx PROMPT "%PROMPT%" | Out-Null
Write-Host 'Set the persistent PROMPT environment variable'

Write-Host 'Done. These are machine settings -- no need to run this again.'
