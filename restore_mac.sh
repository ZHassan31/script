#!/bin/bash

# Navigate to the folder where mac_backup is located
cd ~/Documents/Visual\ Studio\ Code/mac_backup

echo "Restoring Homebrew packages..."

# Install Homebrew if not already installed
if ! command -v brew &>/dev/null; then
    echo "Homebrew not found. Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi

brew update

# Install Homebrew formulae (CLI packages)
if [ -f brew_formulae.txt ]; then
    echo "Installing Homebrew formulae..."
    xargs brew install < brew_formulae.txt
else
    echo "No Homebrew formulae backup found."
fi

# Install Homebrew casks (Applications)
if [ -f brew_casks.txt ]; then
    echo "Installing Homebrew casks..."
    xargs brew install --cask < brew_casks.txt
else
    echo "No Homebrew casks backup found."
fi

# Install Python packages
if [ -f python_packages.txt ]; then
    echo "Installing Python packages..."
    pip install -r python_packages.txt
    pip3 install -r python3_packages.txt
else
    echo "No Python package backup found."
fi

# Install Node.js packages
if [ -f npm_packages.txt ]; then
    echo "Installing Node.js packages..."
    npm install -g $(cat npm_packages.txt | awk '{print $2}')
else
    echo "No Node.js package backup found."
fi

# Install Ruby gems
if [ -f ruby_gems.txt ]; then
    echo "Installing Ruby gems..."
    gem install $(cat ruby_gems.txt | awk '{print $1}')
else
    echo "No Ruby gem backup found."
fi

# Install Mac App Store apps (using 'mas' CLI)
if [ -f mas_apps.txt ]; then
    echo "Installing Mac App Store apps..."
    if ! command -v mas &>/dev/null; then
        echo "'mas' not found. Installing..."
        brew install mas
    fi
    awk '{print $1}' mas_apps.txt | xargs mas install
else
    echo "No Mac App Store apps backup found."
fi

# Restore Git configuration (including aliases)
if [ -f gitconfig_backup.txt ]; then
    echo "Restoring Git configuration..."
    cp gitconfig_backup.txt ~/.gitconfig
else
    echo "No Git configuration backup found."
fi

echo "Restore complete!"

