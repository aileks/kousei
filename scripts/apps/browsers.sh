#!/usr/bin/env bash

install_zen_browser() {
    gum style --foreground 212 "Installing Zen Browser via Pacstall..."

    if ! command -v pacstall &> /dev/null; then
        gum style --foreground 196 "✗ Pacstall not found. Please install Pacstall first."
        return 1
    fi

    if gum spin --spinner globe --title "Installing Zen Browser..." -- pacstall -IP zen-browser-bin; then
        gum style --foreground 212 "✓ Zen Browser installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Zen Browser"
    fi
}

install_brave_browser() {
    gum style --foreground 212 "Installing Brave Browser..."

    if gum spin --spinner globe --title "Installing Brave Browser..." -- bash -c '
        sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
        echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
        sudo apt update
        sudo apt install -y brave-browser
    '; then
        gum style --foreground 212 "✓ Brave Browser installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Brave Browser"
    fi
}

install_chrome() {
    gum style --foreground 212 "Installing Google Chrome..."

    if gum spin --spinner globe --title "Installing Google Chrome..." -- bash -c '
        wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
        echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list
        sudo apt update
        sudo apt install -y google-chrome-stable
    '; then
        gum style --foreground 212 "✓ Google Chrome installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Google Chrome"
    fi
}

install_firefox_flatpak() {
    gum style --foreground 212 "Installing Firefox via Flatpak..."

    source_script "core" "flatpak.sh"
    setup_flatpak || return 1

    if gum spin --spinner globe --title "Installing Firefox..." -- \
        flatpak install -y flathub org.mozilla.firefox; then
        gum style --foreground 212 "✓ Firefox installed via Flatpak"
    else
        gum style --foreground 196 "✗ Failed to install Firefox"
    fi
}

install_librewolf() {
    gum style --foreground 212 "Installing LibreWolf..."

    if gum spin --spinner globe --title "Installing LibreWolf..." -- bash -c '
        sudo apt update && sudo apt install -y wget gnupg lsb-release apt-transport-https ca-certificates

        distro=$(if echo " una bookworm vanessa focal jammy bullseye vera uma " | grep -q " $(lsb_release -sc) "; then lsb_release -sc; else echo focal; fi)

        wget -O- https://deb.librewolf.net/keyring.gpg | sudo gpg --dearmor -o /usr/share/keyrings/librewolf.gpg

        sudo tee /etc/apt/sources.list.d/librewolf.sources << EOF > /dev/null
Types: deb
URIs: https://deb.librewolf.net
Suites: $distro
Components: main
Architectures: amd64
Signed-By: /usr/share/keyrings/librewolf.gpg
EOF

        sudo apt update
        sudo apt install -y librewolf
    '; then
        gum style --foreground 212 "✓ LibreWolf installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install LibreWolf"
    fi
}

install_tor_browser() {
    gum style --foreground 212 "Installing Tor Browser..."

    if gum spin --spinner globe --title "Installing Tor Browser..." -- bash -c '
        sudo apt update
        sudo apt install -y torbrowser-launcher
    '; then
        gum style --foreground 212 "✓ Tor Browser Launcher installed successfully"
        gum style --foreground 214 "Note: Run 'torbrowser-launcher' to download and install Tor Browser"
    else
        gum style --foreground 196 "✗ Failed to install Tor Browser Launcher"
    fi
}

install_browsers_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Web Browser Installation"

    echo ""

    local browsers=$(gum choose --no-limit --header "Select browsers to install:" \
        "Zen Browser (Pacstall)" \
        "Brave Browser" \
        "Google Chrome" \
        "Microsoft Edge" \
        "Firefox (Flatpak)" \
        "LibreWolf" \
        "Tor Browser")

    while IFS= read -r selection; do
        case "$selection" in
            "Zen Browser"*)
                install_zen_browser
                ;;
            "Brave Browser"*)
                install_brave_browser
                ;;
            "Google Chrome"*)
                install_chrome
                ;;
            "Firefox"*)
                install_firefox_flatpak
                ;;
            "LibreWolf"*)
                install_librewolf
                ;;
            "Tor Browser"*)
                install_tor_browser
                ;;
        esac
    done <<< "$browsers"
}
