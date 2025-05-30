#!/usr/bin/env bash

install_obsidian() {
    gum style --foreground 212 "Installing Obsidian..."

    local method=$(gum choose --header "Choose Obsidian installation method:" \
        "Pacstall (Recommended)" \
        "Download .deb" \
        "Flatpak")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using .deb method instead."
                install_obsidian_deb
            else
                gum spin --spinner globe --title "Installing Obsidian via Pacstall..." -- \
                    pacstall -IP obsidian-deb
                gum style --foreground 212 "✓ Obsidian installed via Pacstall"
            fi
            ;;
        "Download .deb")
            install_obsidian_deb
            ;;
        "Flatpak")
            install_obsidian_flatpak
            ;;
    esac
}

install_obsidian_deb() {
    gum spin --spinner globe --title "Installing Obsidian..." -- bash -c '
        cd /tmp
        LATEST_URL=$(curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest | grep "browser_download_url.*amd64.deb" | cut -d "\"" -f 4)
        wget -O obsidian.deb "$LATEST_URL"
        sudo dpkg -i obsidian.deb
        sudo apt install -f -y
        rm -f obsidian.deb
    '
    gum style --foreground 212 "✓ Obsidian installed successfully"
}

install_obsidian_flatpak() {
    source_script "common" "flatpak.sh"
    setup_flatpak || return 1

    gum spin --spinner globe --title "Installing Obsidian via Flatpak..." -- \
        flatpak install -y flathub md.obsidian.Obsidian
    gum style --foreground 212 "✓ Obsidian installed via Flatpak"
}

install_bitwarden() {
    gum style --foreground 212 "Installing Bitwarden..."

    local method=$(gum choose --header "Choose Bitwarden installation method:" \
        "Pacstall (Recommended)" \
        "Download .deb" \
        "Flatpak")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using .deb method instead."
                install_bitwarden_deb
            else
                gum spin --spinner globe --title "Installing Bitwarden via Pacstall..." -- \
                    pacstall -IP bitwarden-deb
                gum style --foreground 212 "✓ Bitwarden installed via Pacstall"
            fi
            ;;
        "Download .deb")
            install_bitwarden_deb
            ;;
        "Flatpak")
            install_bitwarden_flatpak
            ;;
    esac
}

install_bitwarden_deb() {
    gum spin --spinner globe --title "Installing Bitwarden..." -- bash -c '
        cd /tmp
        wget -O bitwarden.deb "https://vault.bitwarden.com/download/?app=desktop&platform=linux&variant=deb"
        sudo dpkg -i bitwarden.deb
        sudo apt install -f -y
        rm -f bitwarden.deb
    '
    gum style --foreground 212 "✓ Bitwarden installed successfully"
}

install_bitwarden_flatpak() {
    source_script "common" "flatpak.sh"
    setup_flatpak || return 1

    gum spin --spinner globe --title "Installing Bitwarden via Flatpak..." -- \
        flatpak install -y flathub com.bitwarden.desktop
    gum style --foreground 212 "✓ Bitwarden installed via Flatpak"
}

install_libreoffice() {
    gum style --foreground 212 "Installing LibreOffice..."

    local method=$(gum choose --header "Choose LibreOffice installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing LibreOffice..." -- \
                sudo apt install -y libreoffice
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing LibreOffice via Flatpak..." -- \
                flatpak install -y flathub org.libreoffice.LibreOffice
            ;;
    esac

    gum style --foreground 212 "✓ LibreOffice installed successfully"
}

install_notion() {
    gum style --foreground 212 "Installing Notion..."

    local method=$(gum choose --header "Choose Notion installation method:" \
        "Download .deb (Unofficial)" \
        "Web app wrapper")

    case "$method" in
        "Download .deb"*)
            gum spin --spinner globe --title "Installing Notion..." -- bash -c '
                cd /tmp
                wget -O notion.deb "https://github.com/davidbailey00/notion-linux/releases/latest/download/notion-app_amd64.deb"
                sudo dpkg -i notion.deb
                sudo apt install -f -y
                rm -f notion.deb
            '
            gum style --foreground 212 "✓ Notion installed (unofficial package)"
            ;;
        "Web app wrapper")
            gum style --foreground 214 "Creating Notion web app..."
            create_notion_webapp
            ;;
    esac
}

create_notion_webapp() {
    mkdir -p ~/.local/share/applications
    cat > ~/.local/share/applications/notion.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Notion
Icon=notion
Exec=google-chrome --app=https://www.notion.so
NoDisplay=false
Categories=Office;
StartupWMClass=notion.so
EOF

    gum style --foreground 212 "✓ Notion web app created"
}

install_calibre() {
    gum style --foreground 212 "Installing Calibre..."

    local method=$(gum choose --header "Choose Calibre installation method:" \
        "APT (Ubuntu repository)" \
        "Official installer" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing Calibre..." -- \
                sudo apt install -y calibre
            ;;
        "Official installer")
            gum spin --spinner globe --title "Installing Calibre..." -- bash -c '
                sudo -v && wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sudo sh /dev/stdin
            '
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing Calibre via Flatpak..." -- \
                flatpak install -y flathub com.calibre_ebook.calibre
            ;;
    esac

    gum style --foreground 212 "✓ Calibre installed successfully"
}

install_productivity_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Productivity Apps Installation"

    echo ""

    local apps=$(gum choose --no-limit --header "Select productivity apps to install:" \
        "Obsidian" \
        "Bitwarden" \
        "LibreOffice" \
        "Notion" \
        "Calibre")

    while IFS= read -r selection; do
        case "$selection" in
            "Obsidian"*)
                install_obsidian
                ;;
            "Bitwarden"*)
                install_bitwarden
                ;;
            "LibreOffice"*)
                install_libreoffice
                ;;
            "Notion"*)
                install_notion
                ;;
            "Calibre"*)
                install_calibre
                ;;
        esac
    done <<< "$apps"
}
