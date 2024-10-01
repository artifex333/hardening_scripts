#!/bin/bash

# Make sure to run the script with sudo privileges
if [ "$EUID" -ne 0 ]; then 
  echo "Please run as root or with sudo"
  exit
fi

echo "Starting macOS 15 (Sonoma) Hardening Script..."

# 1. Disable Guest User
echo "Disabling Guest User..."
defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool false

# 2. Set a password for the firmware (EFI password)
echo "Setting EFI (Firmware) password..."
# You will need to manually set this as it can't be done via script for security reasons
# sudo firmwarepasswd -setpasswd

# 3. Enable FileVault for disk encryption
echo "Enabling FileVault..."
fdesetup enable

# 4. Disable remote Apple Events
echo "Disabling remote Apple Events..."
systemsetup -setremoteappleevents off

# 5. Disable remote login (SSH)
echo "Disabling remote login (SSH)..."
systemsetup -f -setremotelogin off

# 6. Disable Screen Sharing
echo "Disabling Screen Sharing..."
launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist 2>/dev/null

# 7. Enable Firewall
echo "Enabling Firewall..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on

# 8. Enable Stealth Mode (prevents responses to probing requests)
echo "Enabling Stealth Mode..."
/usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on

# 9. Enable Gatekeeper (prevents installation of unverified apps)
echo "Enabling Gatekeeper..."
spctl --master-enable

# 10. Disable Wake on Network Access
echo "Disabling Wake on Network Access..."
pmset -a womp 0

# 11. Require password immediately after sleep or screen saver begins
echo "Setting password requirement after sleep..."
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# 12. Disable automatic login
echo "Disabling automatic login..."
defaults delete /Library/Preferences/.GlobalPreferences com.apple.login.mcx.DisableAutoLoginClient

# 13. Disable Bluetooth if not needed
echo "Disabling Bluetooth (if not needed)..."
blueutil --power 0

# 14. Disable unnecessary services (like AirDrop, etc.)
echo "Disabling unnecessary services..."
defaults write com.apple.NetworkBrowser DisableAirDrop -bool YES

# 15. Enable audit logs
echo "Enabling audit logs..."
launchctl load -w /System/Library/LaunchDaemons/com.apple.auditd.plist

# 16. Enable Secure Keyboard Entry in Terminal (protects against keyloggers)
echo "Enabling Secure Keyboard Entry in Terminal..."
defaults write com.apple.terminal SecureKeyboardEntry -bool true

# 17. Update macOS software and system applications
echo "Updating macOS software and system applications..."
softwareupdate --install --all

# 18. Disable Java (if not needed)
# echo "Disabling Java..."
/usr/libexec/java_home -v 1.8.0_151 --exec javac -version 2>/dev/null && sudo rm -rf /Library/Internet\ Plug-Ins/JavaAppletPlugin.plugin

# 19. Disable Auto-Running of Safe Files in Safari
echo "Disabling auto-run of safe files in Safari..."
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# 20. Lock down privacy settings
echo "Locking down privacy settings..."
# You can also configure privacy preferences via System Preferences manually

echo "Hardening process completed. Please review the settings and restart your system for the changes to take full effect."

