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

# List installed applications (removing system paths like `/Applications:`)
installed_apps=$(find /Applications /Applications/Utilities ~/Applications -maxdepth 1 -name "*.app" -exec basename {} .app \; 2>/dev/null)

# Track app categories
reinstall_apps=()
skipped_apps=()
not_found_apps=()

# Function to check if an app is already managed by Homebrew or mas
is_managed() {
    local app_name="$1"

    # Check Homebrew for cask management
    if brew list --cask | grep -Fxq "$app_name"; then
        return 0  # Managed by Homebrew
    fi

    # Check mas for App Store management
    if mas list | grep -q "${app_name}"; then
        return 0  # Managed by mas
    fi

    return 1  # Not managed
}

# Check applications
echo "🔍 Checking installed applications for migration preview..."

for app in $installed_apps; do
    if is_managed "$app"; then
        skipped_apps+=("$app")
        continue
    fi

    # Check for Homebrew cask
    if brew search --cask "^${app}$" | grep -q "^${app}$"; then
        reinstall_apps+=("$app")

    # Check for App Store apps via `mas`
    elif mas search "$app" | grep -q "$app"; then
        reinstall_apps+=("$app")

    else
        not_found_apps+=("$app")
    fi
done

# Display results
echo ""
echo "📋 Migration Preview Results:"
echo "--------------------------------------"

if [ ${#reinstall_apps[@]} -gt 0 ]; then
    echo "✅ The following apps *would be deleted and reinstalled*:"
    for app in "${reinstall_apps[@]}"; do
        echo " - $app"
    done
else
    echo "✅ No apps need to be deleted and reinstalled."
fi

echo ""

if [ ${#skipped_apps[@]} -gt 0 ]; then
    echo "➖ The following apps are already managed and would *not* be touched:"
    for app in "${skipped_apps[@]}"; do
        echo " - $app"
    done
else
    echo "✅ No apps are currently managed by Homebrew or the App Store."
fi

echo ""

if [ ${#not_found_apps[@]} -gt 0 ]; then
    echo "❓ The following apps were *not found* in Homebrew or the App Store:"
    for app in "${not_found_apps[@]}"; do
        echo " - $app"
    done
else
    echo "✅ All apps were accounted for."
fi

echo "--------------------------------------"
echo "✅ Preview complete — no changes made."

