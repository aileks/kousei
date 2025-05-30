#!/usr/bin/env bash

install_signal() {
    gum style --foreground 212 "Installing Signal Desktop..."

    if gum spin --spinner globe --title "Installing Signal..." -- bash -c '
        wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
        cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
        sudo apt update
        sudo apt install -y signal-desktop
        rm -f signal-desktop-keyring.gpg
    '; then
        gum style --foreground 212 "✓ Signal Desktop installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Signal Desktop"
    fi
}

install_discord() {
    gum style --foreground 212 "Installing Discord..."

    local method=$(gum choose --header "Choose installation method:" \
        "Pacstall (Recommended)" \
        "Download .deb" \
        "Flatpak")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using .deb method instead."
                install_discord_deb
            else
                gum spin --spinner globe --title "Installing Discord via Pacstall..." -- \
                    pacstall -IP discord-deb
                gum style --foreground 212 "✓ Discord installed via Pacstall"
            fi
            ;;
        "Download .deb")
            install_discord_deb
            ;;
        "Flatpak")
            install_discord_flatpak
            ;;
    esac
}

install_discord_deb() {
    if gum spin --spinner globe --title "Installing Discord..." -- bash -c '
        cd /tmp
        wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
        sudo dpkg -i discord.deb
        sudo apt install -f -y
        rm -f discord.deb
    '; then
        gum style --foreground 212 "✓ Discord installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Discord"
    fi
}

install_discord_flatpak() {
    source_script "common" "flatpak.sh"
    setup_flatpak || return 1

    if gum spin --spinner globe --title "Installing Discord via Flatpak..." -- \
        flatpak install -y flathub com.discordapp.Discord; then
        gum style --foreground 212 "✓ Discord installed via Flatpak"
    else
        gum style --foreground 196 "✗ Failed to install Discord"
    fi
}

install_telegram() {
    gum style --foreground 212 "Installing Telegram..."

    local method=$(gum choose --header "Choose installation method:" \
        "Flatpak (Recommended)" \
        "Official tar.xz" \
        "APT repository")

    case "$method" in
        "Flatpak"*)
            install_telegram_flatpak
            ;;
        "Official tar.xz")
            install_telegram_official
            ;;
        "APT repository")
            gum spin --spinner globe --title "Installing Telegram..." -- \
                sudo apt install -y telegram-desktop
            ;;
    esac
}

install_telegram_flatpak() {
    source_script "common" "flatpak.sh"
    setup_flatpak || return 1

    if gum spin --spinner globe --title "Installing Telegram via Flatpak..." -- \
        flatpak install -y flathub org.telegram.desktop; then
        gum style --foreground 212 "✓ Telegram installed via Flatpak"
    else
        gum style --foreground 196 "✗ Failed to install Telegram"
    fi
}

install_telegram_official() {
    if gum spin --spinner globe --title "Installing Telegram..." -- bash -c '
        cd /tmp
        wget -O telegram.tar.xz "https://telegram.org/dl/desktop/linux"
        tar -xf telegram.tar.xz
        sudo mv Telegram /opt/
        sudo ln -sf /opt/Telegram/Telegram /usr/bin/telegram-desktop

        sudo tee /usr/share/applications/telegram.desktop > /dev/null << EOF
[Desktop Entry]
Version=1.0
Name=Telegram Desktop
Comment=Official desktop version of Telegram messaging app
TryExec=telegram-desktop
Exec=telegram-desktop -- %u
Icon=telegram
Terminal=false
StartupWMClass=TelegramDesktop
Type=Application
Categories=Chat;Network;InstantMessaging;Qt;
MimeType=x-scheme-handler/tg;
Keywords=tg;chat;im;messaging;messenger;sms;tdesktop;
X-GNOME-UsesNotifications=true
EOF

        sudo wget -O /usr/share/pixmaps/telegram.png "https://telegram.org/img/website_icon.svg"

        rm -f telegram.tar.xz
    '; then
        gum style --foreground 212 "✓ Telegram installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Telegram"
    fi
}

install_slack() {
    gum style --foreground 212 "Installing Slack..."

    local method=$(gum choose --header "Choose installation method:" \
        "Download .deb (Recommended)" \
        "Flatpak")

    case "$method" in
        "Download .deb"*)
            if gum spin --spinner globe --title "Installing Slack..." -- bash -c '
                cd /tmp
                wget -O slack.deb "https://downloads.slack-edge.com/releases/linux/4.29.149/prod/x64/slack-desktop-4.29.149-amd64.deb"
                sudo dpkg -i slack.deb
                sudo apt install -f -y
                rm -f slack.deb
            '; then
                gum style --foreground 212 "✓ Slack installed successfully"
            else
                gum style --foreground 196 "✗ Failed to install Slack"
            fi
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            if gum spin --spinner globe --title "Installing Slack via Flatpak..." -- \
                flatpak install -y flathub com.slack.Slack; then
                gum style --foreground 212 "✓ Slack installed via Flatpak"
            else
                gum style --foreground 196 "✗ Failed to install Slack"
            fi
            ;;
    esac
}

install_zoom() {
    gum style --foreground 212 "Installing Zoom..."

    if gum spin --spinner globe --title "Installing Zoom..." -- bash -c '
        cd /tmp
        wget -O zoom.deb "https://zoom.us/client/latest/zoom_amd64.deb"
        sudo dpkg -i zoom.deb
        sudo apt install -f -y
        rm -f zoom.deb
    '; then
        gum style --foreground 212 "✓ Zoom installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Zoom"
    fi
}

install_teams() {
    gum style --foreground 212 "Installing Microsoft Teams..."

    if gum spin --spinner globe --title "Installing Teams..." -- bash -c '
        cd /tmp
        wget -O teams.deb "https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.5.00.23861_amd64.deb"
        sudo dpkg -i teams.deb
        sudo apt install -f -y
        rm -f teams.deb
    '; then
        gum style --foreground 212 "✓ Microsoft Teams installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Microsoft Teams"
    fi
}

install_thunderbird() {
    gum style --foreground 212 "Installing Thunderbird..."

    local method=$(gum choose --header "Choose installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak" \
        "Mozilla PPA")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing Thunderbird..." -- \
                sudo apt install -y thunderbird
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing Thunderbird via Flatpak..." -- \
                flatpak install -y flathub org.mozilla.Thunderbird
            ;;
        "Mozilla PPA")
            gum spin --spinner globe --title "Installing Thunderbird from Mozilla PPA..." -- bash -c '
                sudo add-apt-repository -y ppa:mozillateam/ppa
                sudo apt update
                sudo apt install -y thunderbird
            '
            ;;
    esac

    gum style --foreground 212 "✓ Thunderbird installed successfully"
}

install_communication_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Communication Apps Installation"

    echo ""

    local apps=$(gum choose --no-limit --header "Select communication apps to install:" \
        "Signal Desktop" \
        "Discord" \
        "Telegram" \
        "Slack" \
        "Zoom" \
        "Microsoft Teams" \
        "Thunderbird")

    while IFS= read -r selection; do
        case "$selection" in
            "Signal Desktop"*)
                install_signal
                ;;
            "Discord"*)
                install_discord
                ;;
            "Telegram"*)
                install_telegram
                ;;
            "Slack"*)
                install_slack
                ;;
            "Zoom"*)
                install_zoom
                ;;
            "Microsoft Teams"*)
                install_teams
                ;;
            "Thunderbird"*)
                install_thunderbird
                ;;
        esac
    done <<< "$apps"
}
