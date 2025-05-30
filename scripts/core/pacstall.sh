#!/usr/bin/env bash

install_pacstall() {
    if ! command -v pacstall &> /dev/null; then
        gum style --foreground 212 "Installing Pacstall package manager..."

        if gum spin --spinner globe --title "Installing Pacstall..." -- \
            sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"; then
            gum style --foreground 212 "✓ Pacstall installed successfully"
            return 0
        else
            gum style --foreground 196 "✗ Failed to install Pacstall"
            return 1
        fi
    else
        gum style --foreground 214 "Pacstall is already installed"
        return 0
    fi
}

update_pacstall() {
    gum style --foreground 212 "Updating Pacstall..."

    if gum spin --spinner globe --title "Updating Pacstall..." -- pacstall -Up; then
        gum style --foreground 212 "✓ Pacstall updated successfully"
    else
        gum style --foreground 196 "✗ Failed to update Pacstall"
    fi
}

search_pacstall_packages() {
    local query=$(gum input --placeholder "Enter package name to search:")

    if [ -n "$query" ]; then
        gum style --foreground 212 "Searching for '$query'..."
        pacstall -S "$query"
        echo ""
        gum input --placeholder "Press Enter to continue..."
    fi
}

install_pacstall_packages() {
    local packages=$(gum input --placeholder "Enter package names to install (space-separated):")

    if [ -n "$packages" ]; then
        for package in $packages; do
            gum style --foreground 212 "Installing $package..."
            if gum spin --spinner globe --title "Installing $package..." -- pacstall -IP "$package"; then
                gum style --foreground 212 "✓ $package installed successfully"
            else
                gum style --foreground 196 "✗ Failed to install $package"
            fi
        done
    fi
}

list_pacstall_packages() {
    gum style --foreground 212 "Installed Pacstall packages:"
    pacstall -L
    echo ""
    gum input --placeholder "Press Enter to continue..."
}

remove_pacstall_packages() {
    local installed_packages=$(pacstall -L 2>/dev/null | grep -E "^  " | sed 's/^  //' | sort)

    if [ -z "$installed_packages" ]; then
        gum style --foreground 214 "No Pacstall packages installed"
        return
    fi

    local package_array=()
    while IFS= read -r package; do
        package_array+=("$package")
    done <<< "$installed_packages"

    local packages_to_remove=$(gum choose --no-limit --header "Select packages to remove:" "${package_array[@]}")

    if [ -n "$packages_to_remove" ]; then
        while IFS= read -r package; do
            if gum confirm "Remove $package?"; then
                gum spin --spinner globe --title "Removing $package..." -- pacstall -R "$package"
                gum style --foreground 212 "✓ $package removed"
            fi
        done <<< "$packages_to_remove"
    fi
}

install_recommended_pacstall() {
    local RECOMMENDED_PACKAGES=(
        "neovim:Neovim"
        "brave-browser-deb:Brave Browser"
        "zen-browser-bin:Zen Browser"
        "bat-deb:Bat"
        "spotify-client-deb:Spotify"
        "discord-deb:Discord"
        "vscode-deb:VS Code"
        "zed-editor-stable-bin:Zed"
        "sublime-text-deb:Sublime Text"
        "obsidian-deb:Obsidian"
        "bitwarden-deb:Bitwarden"
    )

    local package_choices=()
    for package_info in "${RECOMMENDED_PACKAGES[@]}"; do
        package_choices+=("$package_info")
    done

    local selected=$(gum choose --no-limit --header "Select Pacstall packages to install:" "${package_choices[@]}")

    while IFS= read -r selection; do
        if [ -n "$selection" ]; then
            local package_name="${selection%%:*}"
            local package_desc="${selection#*:}"

            gum style --foreground 212 "Installing $package_name..."
            if gum spin --spinner globe --title "Installing $package_name..." -- pacstall -IP "$package_name"; then
                gum style --foreground 212 "✓ $package_name installed successfully"
            else
                gum style --foreground 196 "✗ Failed to install $package_name"
            fi
        fi
    done <<< "$selected"
}

install_pacstall_interactive() {
    if ! command -v pacstall &> /dev/null; then
        install_pacstall || return 1
    fi

    while true; do
        print_header
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --border rounded \
            --align center \
            --width 50 \
            --margin "1 2" \
            --padding "2 4" \
            "Pacstall Package Manager"

        local choice=$(gum choose --header "Select Pacstall operation:" \
            "Install Recommended Packages" \
            "Search Packages" \
            "Install Packages" \
            "List Installed Packages" \
            "Remove Packages" \
            "Update Pacstall" \
            "Back")

        case "$choice" in
            "Install Recommended Packages")
                install_recommended_pacstall
                ;;
            "Search Packages")
                search_pacstall_packages
                ;;
            "Install Packages")
                install_pacstall_packages
                ;;
            "List Installed Packages")
                list_pacstall_packages
                ;;
            "Remove Packages")
                remove_pacstall_packages
                ;;
            "Update Pacstall")
                update_pacstall
                ;;
            "Back")
                break
                ;;
        esac
    done
}
