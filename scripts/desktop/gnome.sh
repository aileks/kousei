#!/usr/bin/env bash

AILEKS_GNOME_EXTENSIONS=(
    "Vitals@CoreCoding.com:Vitals"
    "blur-my-shell@aunetx:Blur My Shell"
    "forge@jmmaranan.com:Forge"
    "just-perfection-desktop@just-perfection:Just Perfection"
    "spotify-controls@Sonath21:Spotify Controls"
    "user-theme@gnome-shell-extensions.gcampax.github.com:User Theme"
    "weatherornot@somepaulo.github.io:Weather or Not"
    "ubuntu-appindicators@ubuntu.com:Ubuntu AppIndicators"
)

install_gnome_extension() {
    local extension_uuid="$1"
    local extension_name="$2"

    gum style --foreground 212 "Installing $extension_name..."

    if gnome-extensions list | grep -q "$extension_uuid"; then
        gum style --foreground 214 "✓ $extension_name is already installed"
        return 0
    fi

    if command -v gnome-extensions &> /dev/null; then
        if gum spin --spinner globe --title "Installing $extension_name..." -- \
            gnome-extensions install "$extension_uuid" 2>/dev/null; then
            gum style --foreground 212 "✓ $extension_name installed successfully"
            return 0
        fi
    fi

    if gum spin --spinner globe --title "Installing $extension_name..." -- bash -c "
        if ! command -v gnome-shell-extension-installer &> /dev/null; then
            wget -O /tmp/gnome-shell-extension-installer 'https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer'
            chmod +x /tmp/gnome-shell-extension-installer
            sudo mv /tmp/gnome-shell-extension-installer /usr/local/bin/
        fi

        # Install the extension
        gnome-shell-extension-installer --yes '$extension_uuid'
    "; then
        gum style --foreground 212 "✓ $extension_name installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install $extension_name"
        gum style --foreground 214 "  You can install it manually from https://extensions.gnome.org/"
        return 1
    fi
}

enable_gnome_extension() {
    local extension_uuid="$1"
    local extension_name="$2"

    if gnome-extensions list | grep -q "$extension_uuid"; then
        gnome-extensions enable "$extension_uuid" 2>/dev/null
        gum style --foreground 212 "✓ $extension_name enabled"
    else
        gum style --foreground 214 "⚠ $extension_name not found, skipping enable"
    fi
}

install_aileks_extensions() {
    gum style --foreground 212 "Installing Aileks' recommended GNOME extensions..."

    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ]; then
        gum style --foreground 196 "✗ GNOME desktop environment not detected"
        return 1
    fi

    gum spin --spinner globe --title "Installing GNOME Shell extensions support..." -- \
        sudo apt install -y gnome-shell-extensions

    for extension_info in "${AILEKS_GNOME_EXTENSIONS[@]}"; do
        local extension_uuid="${extension_info%%:*}"
        local extension_name="${extension_info#*:}"

        install_gnome_extension "$extension_uuid" "$extension_name"
        enable_gnome_extension "$extension_uuid" "$extension_name"
    done

    gum style --foreground 212 "✓ All extensions installed and enabled"
    gum style --foreground 214 "Note: You may need to log out and back in for all extensions to be active"
}

install_extensions_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "GNOME Extensions Installation" \
        "" \
        "Select extensions to install"

    echo ""

    if [ "$XDG_CURRENT_DESKTOP" != "GNOME" ] && [ "$XDG_CURRENT_DESKTOP" != "ubuntu:GNOME" ]; then
        gum style --foreground 196 "✗ GNOME desktop environment not detected"
        gum style --foreground 214 "Extensions can only be installed on GNOME"
        return 1
    fi

    if gum confirm "Install GNOME Shell extensions support?"; then
        gum spin --spinner globe --title "Installing GNOME Shell extensions..." -- \
            sudo apt install -y gnome-shell-extensions gnome-shell-extension-prefs
    fi

    local extension_choices=()
    for extension_info in "${AILEKS_GNOME_EXTENSIONS[@]}"; do
        extension_choices+=("$extension_info")
    done
    extension_choices+=("Install All:Install all extensions")

    local selected_extensions=$(gum choose --no-limit --header "Select GNOME extensions to install:" \
        "${extension_choices[@]}")

    if echo "$selected_extensions" | grep -q "Install All:Install all extensions"; then
        install_aileks_extensions
    else
        while IFS= read -r selection; do
            if [ -n "$selection" ] && [ "$selection" != "Install All:Install all extensions" ]; then
                local extension_uuid="${selection%%:*}"
                local extension_name="${selection#*:}"

                install_gnome_extension "$extension_uuid" "$extension_name"
                enable_gnome_extension "$extension_uuid" "$extension_name"
            fi
        done <<< "$selected_extensions"
    fi

    echo ""
    gum style --foreground 214 "Tip: You can manage extensions using 'gnome-extensions list' and 'gnome-extensions-prefs'"
}

configure_gnome_defaults() {
    gum style --foreground 212 "Configuring GNOME defaults..."

    # Enable minimize and maximize buttons
    gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"

    # Set dark theme
    gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
    gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"

    # Configure dock
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "BOTTOM"
    gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false

    # Enable hot corners
    gsettings set org.gnome.desktop.interface enable-hot-corners true

    # Set alt-tab to switch windows instead of applications
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"

    gum style --foreground 212 "✓ GNOME defaults configured"
}

configure_gnome_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "GNOME Configuration"

    echo ""

    local choice=$(gum choose --header "Select GNOME configuration option:" \
        "Install Extensions" \
        "Configure Settings" \
        "Both Extensions and Settings" \
        "Back")

    case "$choice" in
        "Install Extensions")
            install_extensions_interactive
            ;;
        "Configure Settings")
            configure_gnome_settings_interactive
            ;;
        "Both Extensions and Settings")
            install_extensions_interactive
            echo ""
            configure_gnome_settings_interactive
            ;;
        "Back")
            return
            ;;
    esac
}

configure_gnome_settings_interactive() {
    local configurations=$(gum choose --no-limit --header "Select GNOME configurations:" \
        "Enable window buttons (minimize/maximize)" \
        "Set dark theme" \
        "Configure dock position" \
        "Enable hot corners" \
        "Fix Alt+Tab behavior" \
        "All configurations")

    while IFS= read -r selection; do
        case "$selection" in
            "Enable window buttons"*)
                gsettings set org.gnome.desktop.wm.preferences button-layout "appmenu:minimize,maximize,close"
                gum style --foreground 212 "✓ Window buttons enabled"
                ;;
            "Set dark theme"*)
                gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
                gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
                gum style --foreground 212 "✓ Dark theme enabled"
                ;;
            "Configure dock position"*)
                local position=$(gum choose --header "Select dock position:" "BOTTOM" "TOP" "LEFT" "RIGHT")
                gsettings set org.gnome.shell.extensions.dash-to-dock dock-position "$position"
                gum style --foreground 212 "✓ Dock position set to $position"
                ;;
            "Enable hot corners"*)
                gsettings set org.gnome.desktop.interface enable-hot-corners true
                gum style --foreground 212 "✓ Hot corners enabled"
                ;;
            "Fix Alt+Tab behavior"*)
                gsettings set org.gnome.desktop.wm.keybindings switch-applications "[]"
                gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Alt>Tab']"
                gum style --foreground 212 "✓ Alt+Tab behavior fixed"
                ;;
            "All configurations"*)
                configure_gnome_defaults
                ;;
        esac
    done <<< "$configurations"
}
