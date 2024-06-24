$CurrentLocation = Get-Location
Set-Location "HKCU:\Control Panel\Accessibility\Keyboard Response"


Set-ItemProperty -Path . -Name AutoRepeatDelay       -Value 100
Set-ItemProperty -Path . -Name AutoRepeatRate        -Value 30
Set-ItemProperty -Path . -Name DelayBeforeAcceptance -Value 0
Set-ItemProperty -Path . -Name BounceTime            -Value 0
Set-ItemProperty -Path . -Name Flags                 -Value 47

Set-Location $CurrentLocation
