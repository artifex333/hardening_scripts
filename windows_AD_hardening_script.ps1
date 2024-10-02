# Ensure Script is Run as Administrator
If (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "You do not have Administrator rights to run this script.`Please re-run this script as an Administrator."
    Exit
}

# Error handling configuration
$ErrorActionPreference = "Continue"
$logfile = "$PSScriptRoot\\hardening_log.txt"
Function Log-Error {
    Param ([string]$message)
    Add-Content -Path $logfile -Value $message
}

# Function: Mitigations
Function Set-Mitigations {
    ##### SPECTRE MELTDOWN #####
    Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" -Name FeatureSettingsOverride -Type "DWORD" -Value 72 -Force
    Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\Memory Management" -Name FeatureSettingsOverrideMask -Type "DWORD" -Value 3 -Force
    Set-ItemProperty -Path "HKLM:\\Software\\Microsoft\\Windows NT\\CurrentVersion\\Virtualization" -Name MinVmVersionForCpuBasedMitigations -Type "String" -Value "1.0" -Force

    # Disable LLMNR
    If (-Not (Test-Path "HKLM:\\Software\\policies\\Microsoft\\Windows NT\\DNSClient")) {
        New-Item -Path "HKLM:\\Software\\policies\\Microsoft\\Windows NT\\" -Name "DNSClient" -Force
    }
    Set-ItemProperty -Path "HKLM:\\Software\\policies\\Microsoft\\Windows NT\\DNSClient" -Name "EnableMulticast" -Type "DWORD" -Value 0 -Force

    # Disable TCP Timestamps
    netsh int tcp set global timestamps=disabled

    # Enable DEP
    BCDEDIT /set "{current}" nx OptOut
    Set-Processmitigation -System -Enable DEP
    Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Policies\\Microsoft\\Windows\\Explorer" -Name "NoDataExecutionPrevention" -Type "DWORD" -Value 0 -Force

    # Enable SEHOP
    Set-ItemProperty -Path "HKLM:\\SYSTEM\\CurrentControlSet\\Control\\Session Manager\\kernel" -Name "DisableExceptionChainValidation" -Type "DWORD" -Value 0 -Force

    # Disable NetBIOS
    $key = "HKLM:SYSTEM\\CurrentControlSet\\services\\NetBT\\Parameters\\Interfaces"
    Get-ChildItem $key | ForEach-Object { 
        $NetbiosOptions_Value = (Get-ItemProperty "$key\\$($_.pschildname)").NetbiosOptions
    }

    # Disable WPAD
    New-Item -Path "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Wpad" -Force
    Set-ItemProperty -Path "HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings\\Wpad" -Name "WpadOverride" -Type "DWORD" -Value 1 -Force

    # Disable WDigest
    Set-ItemProperty -Path "HKLM:\\System\\CurrentControlSet\\Control\\SecurityProviders\\Wdigest" -Name "UseLogonCredential" -Type "DWORD" -Value 0 -Force
}

# Function: Adobe Reader DC Hardening
Function Configure-Adobe-Reader {
    # STIG settings for Adobe Reader
    $officeversions = '16.0', '15.0', '14.0', '12.0'
    ForEach ($officeversion in $officeversions) {
        Set-ItemProperty -Path "HKLM:\\SOFTWARE\\Microsoft\\Office\\$officeversion\\Outlook\\Security" -Name "ShowOLEPackageObj" -Type "DWORD" -Value "0" -Force
    }
}

# Modular Jobs
Start-Job -Name "Mitigations" -ScriptBlock { Set-Mitigations }
Start-Job -Name "Adobe Reader DC STIG" -ScriptBlock { Configure-Adobe-Reader }

# Ensure background jobs complete
Get-Job | Wait-Job

# Log success or failure of each step
Log-Error "Hardening script executed successfully."

# Prompt for reboot
$Reboot = Read-Host "Reboot now to apply changes? (Y/N)"
If ($Reboot -eq 'Y') {
    Restart-Computer -Force
}
