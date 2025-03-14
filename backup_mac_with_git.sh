#!/bin/bash

# Create a backup directory
mkdir -p mac_backup

echo "Listing Homebrew packages..."
# Backup Homebrew formulae and casks
brew list --formula > mac_backup/brew_formulae.txt
brew list --cask > mac_backup/brew_casks.txt

echo "Listing Python packages..."
# Backup Python packages
pip list > mac_backup/python_packages.txt
pip3 list > mac_backup/python3_packages.txt

echo "Listing installed Applications..."
# Backup applications in system and user Applications folder
ls /Applications > mac_backup/applications.txt
ls ~/Applications >> mac_backup/applications.txt

echo "Listing Mac App Store apps..."
# Backup Mac App Store applications
if command -v mas &>/dev/null; then
    mas list > mac_backup/mas_apps.txt
else
    echo "Mac App Store CLI 'mas' is not installed." > mac_backup/mas_apps.txt
fi

echo "Listing Node.js packages..."
# Backup globally installed Node.js packages
npm list -g --depth=0 > mac_backup/npm_packages.txt

echo "Listing Ruby gems..."
# Backup installed Ruby gems
gem list > mac_backup/ruby_gems.txt

echo "Backing up Git configuration (including aliases)..."
# Backup Git global configuration file
if [ -f ~/.gitconfig ]; then
    cp ~/.gitconfig mac_backup/gitconfig_backup.txt
else
    echo "No global Git configuration file found." > mac_backup/gitconfig_backup.txt
fi

echo "Getting system summary..."
# Backup detailed system and software information
system_profiler SPSoftwareDataType SPApplicationsDataType SPFrameworksDataType > mac_backup/system_summary.txt

echo "Backup complete! All files are in the 'mac_backup' folder."

