#!/bin/bash

# run this script with sudo privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or with sudo"
  exit
fi

echo "Starting macOS 15 (Sonoma) Hardening Script..."

# Disable Guest User
echo "Disabling Guest User..."
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# Enable FileVault for disk encryption
echo "Enabling FileVault..."
fdesetup enable

# Disable remote Apple Events
echo "Disabling remote Apple Events..."
systemsetup -setremoteappleevents off

# Disable remote login (SSH)
echo "Disabling remote login (SSH)..."
systemsetup -f -setremotelogin off

# Disable Screen Sharing
echo "Disabling Screen Sharing..."
launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null

# Enable Firewall
echo "Enabling Firewall..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# Enable Stealth Mode (prevents responses to probing requests)
echo "Enabling Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# Enable Gatekeeper (prevents installation of unverified apps)
echo "Enabling Gatekeeper..."
spctl --master-enable

# Disable Wake on Network Access
echo "Disabling Wake on Network Access..."
pmset -a womp 0

# Disable automatic login
echo "Disabling automatic login..."
defaults delete /Library/Preferences/.GlobalPreferences com.apple.login.mcx.DisableAutoLoginClient

# Disable unnecessary services (like AirDrop, etc.)
echo "Disabling unnecessary services..."
defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES

# Enable audit logs
echo "Enabling audit logs..."
launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist

# Enable Secure Keyboard Entry in Terminal (protects against keyloggers)
echo "Enabling Secure Keyboard Entry in Terminal..."
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# Update macOS software and system applications
echo "Updating macOS software and system applications..."
softwareupdate --install --all

# Disable Auto-Running of Safe Files in Safari
echo "Disabling auto-run of safe files in Safari..."
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Disable Java
echo "Disabling Java..."
/usr/libexec/java_home -v 1.8.0_151 --exec javac -version 2>/dev/null && sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin

# Lock down privacy settings
echo "Locking down privacy settings..."

echo "Hardening process completed. Please review the settings and restart your system for the changes to take full effect."
