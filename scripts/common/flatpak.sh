#!/usr/bin/env bash

setup_flatpak() {
    if ! command -v flatpak &> /dev/null; then
        refresh_sudo
        gum style --foreground 212 "Setting up Flatpak..."
        gum spin --spinner globe --title "Installing Flatpak..." -- bash -c '
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update -y
            sudo apt install -y flatpak
            sudo apt install -y gnome-software-plugin-flatpak
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        '
        gum style --foreground 212 "✓ Flatpak setup completed"
        gum style --foreground 214 "Note: You may need to restart for full Flatpak integration"
        return 0
    else
        if ! flatpak remotes | grep -q flathub; then
            gum spin --spinner globe --title "Adding Flathub repository..." -- \
                flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        fi
        return 0
    fi
}

install_flatpak_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Flatpak Setup"

    echo ""

    if command -v flatpak &> /dev/null; then
        gum style --foreground 214 "Flatpak is already installed"

        if ! flatpak remotes | grep -q flathub; then
            if gum confirm "Add Flathub repository?"; then
                gum spin --spinner globe --title "Adding Flathub repository..." -- \
                    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
                gum style --foreground 212 "✓ Flathub repository added"
            fi
        else
            gum style --foreground 212 "✓ Flatpak is properly configured"
        fi
    else
        if gum confirm "Install and setup Flatpak?"; then
            setup_flatpak
        fi
    fi
}
