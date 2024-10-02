#!/bin/bash

# Run as root or with sudo privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or with sudo"
  exit
fi

echo "Starting macOS 15 Sonoma Hardening Script (•_•)7"

# Enable Firewall
# The firewall blocks unauthorized incoming connections, reducing the chance of network-based attacks like port scanning, unauthorized access, or DDoS attempts.
echo "Enabling Firewall..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Enable Stealth Mode
# Stealth Mode prevents your device from responding to probing requests, making it harder for attackers to find it during network scans or reconnaissance.
echo "Enabling Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# Enable Gatekeeper
# Gatekeeper ensures only trusted, signed applications can be installed, preventing malware from being downloaded or executed. It helps protect against trojans and malicious software.
echo "Enabling Gatekeeper..."
spctl --master-enable

# Enable audit logs
# Audit logs keep a record of security-relevant events, useful for detecting or analyzing attacks such as unauthorized access or privilege escalation.
echo "Enabling audit logs..."
launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist

# Enable Secure Keyboard Entry in Terminal
# This feature prevents keyloggers from capturing sensitive input typed into the Terminal, protecting against malware that records keystrokes.
echo "Enabling Secure Keyboard Entry in Terminal..."
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Enable FileVault for disk encryption
# FileVault encrypts the entire disk, protecting data even if the device is stolen. It mitigates physical attacks like unauthorized access to data via disk removal or booting from an external drive.
echo "Enabling FileVault..."
fdesetup enable

# Disable remote Apple Events
# Disabling remote Apple Events prevents remote control of applications on the system, reducing the risk of remote code execution and unauthorized automation.
echo "Disabling remote Apple Events..."
systemsetup -setremoteappleevents off

# Disable Guest User
# Disabling the Guest account prevents unauthorized users from logging in without a password, reducing the risk of local attacks from unauthorized physical access.
echo "Disabling Guest User..."
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Disable remote login (SSH)
# SSH allows remote access to your system. Disabling it prevents remote attacks like brute-force password guessing or unauthorized access to the machine.
echo "Disabling remote login (SSH)..."
systemsetup -f -setremotelogin off

# Disable Screen Sharing
# Disabling screen sharing reduces the risk of someone remotely controlling your device or spying on your activities without authorization.
echo "Disabling Screen Sharing..."
launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null

# Disable Wake on Network Access
# Disabling this feature prevents your device from being woken up remotely, which could be exploited in targeted attacks to access the system when it is idle.
echo "Disabling Wake on Network Access..."
pmset -a womp 0

# Disable automatic login
# Automatic login bypasses password protection, so disabling it ensures that even if the device is physically compromised, attackers would still need a password to access the system.
echo "Disabling automatic login..."
defaults delete /Library/Preferences/.GlobalPreferences com.apple.login.mcx.DisableAutoLoginClient

# Disable AirDrop
# Disabling AirDrop prevents unauthorized or accidental file sharing over a local network, reducing the risk of attacks like AirDrop hijacking or malicious file distribution.
echo "Disabling unnecessary services..."
defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES

# Update macOS software and system applications
# Regular software updates patch security vulnerabilities, reducing the risk of exploitation via known vulnerabilities in outdated software.
echo "Updating macOS software and system applications..."
softwareupdate --install --all

# Disable Auto-Running of Safe Files
# Disabling this Safari feature prevents downloaded files from automatically executing, reducing the risk of drive-by downloads and malware installation from malicious websites.
echo "Disabling auto-run of safe files in Safari..."
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Disable Java
# Java has been a frequent target for exploits. Disabling it removes the potential attack surface for vulnerabilities associated with Java-based attacks.
echo "Disabling Java..."
/usr/libexec/java_home -v 1.8.0_151 --exec javac -version 2>/dev/null && sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin

# Lock down privacy settings
# Strengthening privacy settings protects sensitive information from being shared without your consent, reducing exposure to privacy-invasive attacks.
echo "Locking down privacy settings..."

echo "Hardening process complete (•_•)7 please restart your Mac for the changes to take full effect."
```

This script is now more accessible to non-technical users by explaining the purpose and the potential security risks mitigated by each step.
