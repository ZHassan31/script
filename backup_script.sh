#!/bin/bash

# Backup Directory
BACKUP_DIR=~/Desktop/Backup
mkdir -p "$BACKUP_DIR"

echo "Starting backup..."

# Backup Zsh and Shell Configurations
cp -r ~/.zshrc ~/.oh-my-zsh ~/.p10k.zsh ~/.bash_profile ~/.profile "$BACKUP_DIR"

# Backup SSH Keys and Git Configuration
cp -r ~/.ssh ~/.gitconfig ~/.git-credentials "$BACKUP_DIR"

# Backup Homebrew Packages, Casks (GUI Apps), and Services
brew bundle dump --file="$BACKUP_DIR/Brewfile" --force

# Backup List of Non-Brew Installed Apps
ls /Applications > "$BACKUP_DIR/InstalledApps.txt"

# Backup NPM Global Packages
npm list -g --depth=0 > "$BACKUP_DIR/npm-packages.txt"

# Backup Python Packages
pip freeze > "$BACKUP_DIR/requirements.txt"

# Backup iTerm2 Preferences
if [ -d "~/Library/Preferences/com.googlecode.iterm2.plist" ]; then
    cp ~/Library/Preferences/com.googlecode.iterm2.plist "$BACKUP_DIR"
fi

# Backup .config directory for custom settings
cp -r ~/.config "$BACKUP_DIR"

# Backup System Preferences
defaults export -g "$BACKUP_DIR/global_prefs.plist"

echo "Backup completed successfully! Files are stored in $BACKUP_DIR"

# -------- Restore Instructions --------
cat << EOF

To restore on a new MacBook:
1. Install Xcode Command Line Tools:
   xcode-select --install

2. Install Homebrew:
   /bin/bash -c "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

3. Restore Homebrew Packages:
   brew bundle --file="$BACKUP_DIR/Brewfile"

4. Reinstall Oh My Zsh:
   sh -c "\$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

5. Copy Zsh and Shell Configurations:
   cp -r "$BACKUP_DIR/.*" ~/

6. Restore Node.js and NPM Packages:
   nvm install node
   cat "$BACKUP_DIR/npm-packages.txt" | xargs npm install -g

7. Restore Python Packages:
   pip install -r "$BACKUP_DIR/requirements.txt"

8. Restore iTerm2 Preferences:
   Open iTerm2 → Preferences → General → "Load preferences from a custom folder"
   Select "$BACKUP_DIR"

9. Restore System Preferences:
   defaults import -g "$BACKUP_DIR/global_prefs.plist"

10. Reload Configuration:
   source ~/.zshrc

EOF


