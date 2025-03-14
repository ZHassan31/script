#!/bin/bash
# Keep sudo active throughout the script
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Ensure Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo "❌ Homebrew is not installed. Please install it first: https://brew.sh/"
    exit 1
fi

# Authenticate with sudo to avoid multiple password prompts
echo "🔐 Authenticating... (you'll only need to enter your password once)"
sudo -v

# List installed applications
installed_apps=$(find /Applications /Applications/Utilities ~/Applications -maxdepth 1 -name "*.app" -exec basename {} .app \; 2>/dev/null)

# Track deleted/reinstalled apps and skipped apps
reinstalled_apps=()
skipped_apps=()

# Function to uninstall an existing app
uninstall_app() {
    local app_name="$1"
    local app_path

    # Uninstall via brew if managed by Homebrew
    if brew list --cask | grep -i -Fxq "$app_name"; then
        echo "🔹 Uninstalling via Homebrew: $app_name"
        brew uninstall --cask "$app_name"
        reinstalled_apps+=("$app_name")
        return
    fi

    # Uninstall manually if not managed by Homebrew
    app_path=$(mdfind "kMDItemFSName == '${app_name}.app'" | head -n 1)
    if [ -n "$app_path" ]; then
        echo "🔹 Uninstalling manually: $app_name"
        sudo rm -rf "$app_path"
        reinstalled_apps+=("$app_name")
    fi
}

# Function to check if an app is already managed by Homebrew
is_managed() {
    local app_name="$1"
    brew list --cask | grep -i -Fxq "$app_name"
}

# Function to find the correct brew cask name
find_brew_cask() {
    local app_name="$1"

    # Check exact name
    if brew search --cask "^${app_name}$" | grep -q "^${app_name}$"; then
        echo "$app_name"
        return
    fi

    # Try replacing spaces with hyphens
    local hyphen_name=$(echo "$app_name" | tr ' ' '-')
    if brew search --cask "^${hyphen_name}$" | grep -q "^${hyphen_name}$"; then
        echo "$hyphen_name"
        return
    fi

    # Try lowercase with hyphens
    local lowercase_name=$(echo "$app_name" | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
    if brew search --cask "^${lowercase_name}$" | grep -q "^${lowercase_name}$"; then
        echo "$lowercase_name"
        return
    fi

    # Fuzzy search as a last resort
    local fuzzy_match=$(brew search --cask "$app_name" | head -n 1)
    if [ -n "$fuzzy_match" ]; then
        echo "$fuzzy_match"
        return
    fi

    # No match found
    echo ""
}

# Check and migrate applications
echo "🔍 Checking installed applications against Homebrew..."

while IFS= read -r app; do
    if is_managed "$app"; then
        echo "✅ Already managed by Homebrew: $app — Skipping."
        skipped_apps+=("$app")
        continue
    fi

    # Find best match in Homebrew
    brew_cask=$(find_brew_cask "$app")
    if [ -n "$brew_cask" ]; then
        echo "✅ Found in Homebrew: $app (as '$brew_cask')"
        uninstall_app "$app"
        echo "🔄 Reinstalling $app via Homebrew..."
        brew install --cask "$brew_cask"
    else
        echo "❌ Not found in Homebrew: $app"
    fi
done <<< "$installed_apps"

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
