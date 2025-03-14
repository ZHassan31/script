#!/bin/bash

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew is not installed. Please install it first: https://brew.sh/"
    exit 1
fi

# Ensure `mas` is installed for App Store app management
if ! brew list mas &>/dev/null; then
    echo "🔹 Installing 'mas' for App Store management..."
    brew install mas
fi

# Authenticate with sudo to avoid multiple password prompts
echo "🔐 Authenticating... (you'll only need to enter your password once)"
sudo -v

# List installed applications
installed_apps=$(find /Applications /Applications/Utilities ~/Applications -maxdepth 1 -name "*.app" -exec basename {} .app \; 2>/dev/null)

# Track deleted/reinstalled apps and apps that were already managed
reinstalled_apps=()
skipped_apps=()

# Function to uninstall an existing app
uninstall_app() {
    local app_name="$1"
    local app_path

    app_path=$(mdfind "kMDItemFSName == '${app_name}.app'" | head -n 1)
    if [ -n "$app_path" ]; then
        echo "🔹 Uninstalling existing app: $app_name"
        sudo rm -rf "$app_path"
        reinstalled_apps+=("$app_name")
    fi
}

# Function to check if an app is already managed by Homebrew or mas
is_managed() {
    local app_name="$1"

    if brew list --cask | grep -Fxq "$app_name"; then
        return 0  # Managed by Homebrew
    fi

    if mas list | grep -q "${app_name}"; then
        return 0  # Managed by mas
    fi

    return 1  # Not managed
}

# Check and migrate applications
echo "🔍 Checking installed applications against Homebrew and the App Store..."

for app in $installed_apps; do
    if is_managed "$app"; then
        echo "✅ Already managed by Homebrew or App Store: $app — Skipping."
        skipped_apps+=("$app")
        continue
    fi

    # Check for Homebrew cask
    if brew search --cask "^${app}$" | grep -q "^${app}$"; then
        echo "✅ Found in Homebrew: $app"
        uninstall_app "$app"
        echo "🔄 Reinstalling $app via Homebrew..."
        brew install --cask "$app"

    # Check for App Store apps via `mas`
    elif app_id=$(mas search "$app" | grep -m 1 "$app" | awk '{print $1}'); then
        echo "✅ Found in App Store: $app (App ID: $app_id)"
        uninstall_app "$app"
        echo "🔄 Reinstalling $app via the App Store..."
        mas install "$app_id"

    else
        echo "❌ Not found in Homebrew or the App Store: $app"
    fi
done

# Display results
if [ ${#reinstalled_apps[@]} -gt 0 ]; then
    echo "✅ The following apps were deleted and re-downloaded:"
    for app in "${reinstalled_apps[@]}"; do
        echo " - $app"
    done
else
    echo "✅ No apps were deleted and reinstalled."
fi

if [ ${#skipped_apps[@]} -gt 0 ]; then
    echo "➖ The following apps were already managed and not deleted:"
    for app in "${skipped_apps[@]}"; do
        echo " - $app"
    done
else
    echo "✅ No apps were skipped."
fi

echo "✅ Migration complete!"
