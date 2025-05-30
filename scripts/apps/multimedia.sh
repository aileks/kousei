#!/usr/bin/env bash

install_multimedia_codecs() {
    gum style --foreground 212 "Installing multimedia codecs and restricted extras..."

    if gum spin --spinner globe --title "Installing ubuntu-restricted-extras..." -- \
        sudo apt install -y ubuntu-restricted-extras; then
        gum style --foreground 212 "✓ Ubuntu restricted extras installed"
    else
        gum style --foreground 196 "✗ Failed to install ubuntu-restricted-extras"
    fi

    if gum spin --spinner globe --title "Installing additional codecs..." -- \
        sudo apt install -y ffmpeg gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav; then
        gum style --foreground 212 "✓ Additional codecs installed"
    else
        gum style --foreground 196 "✗ Failed to install additional codecs"
    fi
}

install_celluloid() {
    gum style --foreground 212 "Installing Celluloid (MPV frontend)..."

    if gum spin --spinner globe --title "Installing Celluloid..." -- \
        sudo apt install -y celluloid; then
        gum style --foreground 212 "✓ Celluloid installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Celluloid"
    fi
}

install_vlc() {
    gum style --foreground 212 "Installing VLC Media Player..."

    local method=$(gum choose --header "Choose installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing VLC..." -- \
                sudo apt install -y vlc
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing VLC via Flatpak..." -- \
                flatpak install -y flathub org.videolan.VLC
            ;;
    esac

    gum style --foreground 212 "✓ VLC installed successfully"
}

install_mpv() {
    gum style --foreground 212 "Installing MPV Media Player..."

    if gum spin --spinner globe --title "Installing MPV..." -- \
        sudo apt install -y mpv; then
        gum style --foreground 212 "✓ MPV installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install MPV"
    fi
}

install_spotify() {
    gum style --foreground 212 "Installing Spotify..."

    local method=$(gum choose --header "Choose installation method:" \
        "Pacstall (Recommended)" \
        "Official repository" \
        "Flatpak")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using official repository instead."
                install_spotify_official
            else
                gum spin --spinner globe --title "Installing Spotify via Pacstall..." -- \
                    pacstall -IP spotify-client-deb
                gum style --foreground 212 "✓ Spotify installed via Pacstall"
            fi
            ;;
        "Official repository")
            install_spotify_official
            ;;
        "Flatpak")
            install_spotify_flatpak
            ;;
    esac
}

install_spotify_official() {
    if gum spin --spinner globe --title "Installing Spotify..." -- bash -c '
        curl -sS https://download.spotify.com/debian/pubkey_7A3A762FAFD4A51F.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt update
        sudo apt install -y spotify-client
    '; then
        gum style --foreground 212 "✓ Spotify installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Spotify"
    fi
}

install_spotify_flatpak() {
    source_script "common" "flatpak.sh"
    setup_flatpak || return 1

    if gum spin --spinner globe --title "Installing Spotify via Flatpak..." -- \
        flatpak install -y flathub com.spotify.Client; then
        gum style --foreground 212 "✓ Spotify installed via Flatpak"
    else
        gum style --foreground 196 "✗ Failed to install Spotify"
    fi
}

install_audacity() {
    gum style --foreground 212 "Installing Audacity..."

    local method=$(gum choose --header "Choose installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing Audacity..." -- \
                sudo apt install -y audacity
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing Audacity via Flatpak..." -- \
                flatpak install -y flathub org.audacityteam.Audacity
            ;;
    esac

    gum style --foreground 212 "✓ Audacity installed successfully"
}

install_obs() {
    gum style --foreground 212 "Installing OBS Studio..."

    local method=$(gum choose --header "Choose installation method:" \
        "Official PPA (Recommended)" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "Official PPA"*)
            gum spin --spinner globe --title "Installing OBS Studio..." -- bash -c '
                sudo add-apt-repository -y ppa:obsproject/obs-studio
                sudo apt update
                sudo apt install -y obs-studio
            '
            ;;
        "APT"*)
            gum spin --spinner globe --title "Installing OBS Studio..." -- \
                sudo apt install -y obs-studio
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing OBS Studio via Flatpak..." -- \
                flatpak install -y flathub com.obsproject.Studio
            ;;
    esac

    gum style --foreground 212 "✓ OBS Studio installed successfully"
}

install_gimp() {
    gum style --foreground 212 "Installing GIMP..."

    local method=$(gum choose --header "Choose installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing GIMP..." -- \
                sudo apt install -y gimp
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing GIMP via Flatpak..." -- \
                flatpak install -y flathub org.gimp.GIMP
            ;;
    esac

    gum style --foreground 212 "✓ GIMP installed successfully"
}

install_blender() {
    gum style --foreground 212 "Installing Blender..."

    local method=$(gum choose --header "Choose installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak" \
        "Official website")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing Blender..." -- \
                sudo apt install -y blender
            ;;
        "Flatpak")
            source_script "common" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing Blender via Flatpak..." -- \
                flatpak install -y flathub org.blender.Blender
            ;;
        "Official website")
            gum style --foreground 214 "Please download Blender from https://www.blender.org/download/"
            ;;
    esac

    gum style --foreground 212 "✓ Blender installed successfully"
}

install_multimedia_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Multimedia Apps Installation"

    echo ""

    local apps=$(gum choose --no-limit --header "Select multimedia apps to install:" \
        "Multimedia Codecs & Restricted Extras" \
        "Celluloid (MPV frontend)" \
        "VLC Media Player" \
        "MPV" \
        "Spotify" \
        "Audacity" \
        "OBS Studio" \
        "GIMP" \
        "Blender")

    while IFS= read -r selection; do
        case "$selection" in
            "Multimedia Codecs"*)
                install_multimedia_codecs
                ;;
            "Celluloid"*)
                install_celluloid
                ;;
            "VLC Media Player"*)
                install_vlc
                ;;
            "MPV"*)
                install_mpv
                ;;
            "Spotify"*)
                install_spotify
                ;;
            "Audacity"*)
                install_audacity
                ;;
            "OBS Studio"*)
                install_obs
                ;;
            "GIMP"*)
                install_gimp
                ;;
            "Blender"*)
                install_blender
                ;;
        esac
    done <<< "$apps"
}
