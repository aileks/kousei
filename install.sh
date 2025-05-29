#!/usr/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

SCRIPT_NAME="Kōsei"
SCRIPT_VERSION="1.0.0"
SCRIPT_URL="https://github.com/aileks/kousei"

DEFAULT_APT_PACKAGES=(
    "curl"
    "ripgrep"
    "fzf"
    "trash-cli"
    "zoxide"
    "deja-dup"
    "eza"
    "tmux"
    "ubuntu-restricted-extras"
    "celluloid"
    "ffmpeg"
    "git"
    "build-essential"
    "btop"
    "cava"
    "wget"
    "gnupg"
    "lsb-release"
    "software-properties-common"
)

DEFAULT_PACSTALL_PACKAGES=(
    "neovim"
    "zen-browser-bin"
    "bat-deb"
    "spotify-client-deb"
)

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║               ${SCRIPT_NAME} v${SCRIPT_VERSION}               ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        echo -e "${RED}This script is designed for Ubuntu. Exiting...${NC}"
        exit 1
    fi
}

install_gum() {
    if ! command -v gum &> /dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y gum
    fi
}

show_welcome() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Welcome to Kōsei!" \
        "" \
        "This script will help you set up" \
        "your Ubuntu system with your" \
        "preferred tools and configurations."

    echo ""
    gum confirm "You will be prompted for your sudo password. Ready to begin?" || exit 0
}

# Function to remove snaps
remove_snaps() {
    if gum confirm "Do you want to remove snaps entirely from your system?"; then
        gum spin --spinner globe --title "Removing snap packages..." -- bash -c '
            sudo snap list | awk "NR>1 {print \$1}" | xargs -I {} sudo snap remove --purge {} 2>/dev/null || true
            sudo systemctl stop snapd
            sudo systemctl disable snapd
            sudo apt remove --purge -y snapd
            sudo rm -rf /snap /var/snap /var/lib/snapd
            echo "Package: snapd" | sudo tee /etc/apt/preferences.d/nosnap.pref
            echo "Pin: release a=*" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
            echo "Pin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
        '
        gum style --foreground 212 "✓ Snaps have been removed from your system"
    fi
}

# Function to select packages
select_packages() {
    local package_choice=$(gum choose --header "How would you like to install packages?" \
        "Use default package set" \
        "Select packages individually" \
        "Both (add to defaults)")

    case "$package_choice" in
        "Use default package set")
            SELECTED_APT_PACKAGES=("${DEFAULT_APT_PACKAGES[@]}")
            SELECTED_PACSTALL_PACKAGES=("${DEFAULT_PACSTALL_PACKAGES[@]}")
            ;;
        "Select packages individually")
            mapfile -t SELECTED_APT_PACKAGES < <(gum choose --no-limit --header "Select APT packages to install:" \
                "${DEFAULT_APT_PACKAGES[@]}" \
                "htop" "neofetch" "vim" "emacs" "docker.io" "docker-compose" \
                "nodejs" "npm" "python3-pip" "ruby" "golang" "rust" \
                "postgresql" "mysql-server" "redis" "mongodb" \
                "vlc" "gimp" "inkscape" "blender" "obs-studio" \
                "thunderbird" "libreoffice" "virt-manager" "virtualbox" "vagrant")

            mapfile -t SELECTED_PACSTALL_PACKAGES < <(gum choose --no-limit --header "Select Pacstall packages to install:" \
                "${DEFAULT_PACSTALL_PACKAGES[@]}" \
                "discord-deb" "slack-deb" "vscode-deb" "sublime-text-deb" \
                "brave-browser-deb" "librewolf-deb" "microsoft-edge-deb" \
                "opera-deb" "vivaldi-deb" "zoom-deb" "teams-deb" "anydesk-deb" \
                "teamviewer-deb")
            ;;
        "Both (add to defaults)")
            SELECTED_APT_PACKAGES=("${DEFAULT_APT_PACKAGES[@]}")
            SELECTED_PACSTALL_PACKAGES=("${DEFAULT_PACSTALL_PACKAGES[@]}")

            mapfile -t ADDITIONAL_APT < <(gum choose --no-limit --header "Select additional APT packages:" \
                "htop" "neofetch" "vim" "emacs" "docker.io" "docker-compose" \
                "nodejs" "npm" "python3-pip" "ruby" "golang" "rust" \
                "postgresql" "mysql-server" "redis" "mongodb" \
                "vlc" "gimp" "inkscape" "blender" "obs-studio" \
                "thunderbird" "libreoffice" "virtualbox" "vagrant")
            SELECTED_APT_PACKAGES+=("${ADDITIONAL_APT[@]}")

            mapfile -t ADDITIONAL_PACSTALL < <(gum choose --no-limit --header "Select additional Pacstall packages:" \
                "discord-deb" "slack-deb" "vscode-deb" "sublime-text-deb" \
                "brave-browser-deb" "librewolf-deb" "microsoft-edge-deb" \
                "opera-deb" "vivaldi-deb" "zoom-deb" "teams-deb" "anydesk-deb" \
                "teamviewer-deb")
            SELECTED_PACSTALL_PACKAGES+=("${ADDITIONAL_PACSTALL[@]}")
            ;;
    esac
}

install_apt_packages() {
    if [ ${#SELECTED_APT_PACKAGES[@]} -gt 0 ]; then
        gum style --foreground 212 "Installing APT packages..."
        echo "Packages to install: ${SELECTED_APT_PACKAGES[*]}"

        gum spin --spinner globe --title "Updating package lists..." -- sudo apt update
        gum spin --spinner globe --title "Installing APT packages..." -- sudo apt install -y "${SELECTED_APT_PACKAGES[@]}"

        gum style --foreground 212 "✓ APT packages installed successfully"
    fi
}

install_pacstall() {
    if ! command -v pacstall &> /dev/null; then
        gum spin --spinner globe --title "Installing Pacstall..." -- sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
        gum style --foreground 212 "✓ Pacstall installed successfully"
    fi
}

install_pacstall_packages() {
    if [ ${#SELECTED_PACSTALL_PACKAGES[@]} -gt 0 ]; then
        gum style --foreground 212 "Installing Pacstall packages..."
        for package in "${SELECTED_PACSTALL_PACKAGES[@]}"; do
            gum spin --spinner globe --title "Installing $package..." -- pacstall -I "$package"
        done
        gum style --foreground 212 "✓ Pacstall packages installed successfully"
    fi
}

install_special_packages() {
    gum style --foreground 212 "Installing special packages..."
 
    if gum confirm "Install Ghostty terminal?"; then
        gum spin --spinner globe --title "Installing Ghostty..." -- /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi

    if gum confirm "Install Signal Desktop?"; then
        gum spin --spinner globe --title "Installing Signal Desktop..." -- bash -c '
            wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg;
            cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null
            echo "deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main" | sudo tee /etc/apt/sources.list.d/signal-xenial.list
            sudo apt update && sudo apt install -y signal-desktop
        '
    fi

    if gum confirm "Install Proton Mail?"; then
        gum style --foreground 214 "Please download Proton Mail .deb from:"
        gum style --foreground 214 "https://proton.me/mail/download"
        gum input --placeholder "Enter path to downloaded .deb file (or press Enter to skip):" > /tmp/proton_path
        PROTON_PATH=$(cat /tmp/proton_path)
        if [ -n "$PROTON_PATH" ] && [ -f "$PROTON_PATH" ]; then
            gum spin --spinner globe --title "Installing Proton Mail..." -- sudo dpkg -i "$PROTON_PATH"
            sudo apt install -f -y
        fi
    fi
}

install_nerd_fonts() {
    if gum confirm "Do you want to install a Nerd Font?"; then
        NERD_FONTS=(
            "FiraCode"
            "Hack"
            "JetBrainsMono"
            "Meslo"
            "SourceCodePro"
            "UbuntuMono"
            "RobotoMono"
            "Iosevka"
            "CascadiaCode"
            "Skip"
        )
        
        SELECTED_FONT=$(gum choose --header "Select a Nerd Font to install:" "${NERD_FONTS[@]}")
        
        if [ "$SELECTED_FONT" != "Skip" ]; then
            gum spin --spinner globe --title "Installing $SELECTED_FONT Nerd Font..." -- bash -c "
                mkdir -p ~/.local/share/fonts
                cd ~/.local/share/fonts
                wget -q https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${SELECTED_FONT}.zip
                unzip -q ${SELECTED_FONT}.zip
                rm ${SELECTED_FONT}.zip
                fc-cache -fv
            "
            gum style --foreground 212 "✓ $SELECTED_FONT Nerd Font installed successfully"
        fi
    fi
}

install_language_managers() {
    LANGUAGES=$(gum choose --no-limit --header "Select language version managers to install:" \
        "Node.js (nvm)" \
        "Python (pyenv)" \
        "Ruby (rbenv)" \
        "Go (g)" \
        "Rust (rustup)" \
        "Java (sdkman)")

    if echo "$LANGUAGES" | grep -q "Node.js (nvm)"; then
        gum spin --spinner globe --title "Installing nvm..." -- bash -c '
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/latest/install.sh | bash
        '
        gum style --foreground 212 "✓ nvm installed successfully"
    fi

    if echo "$LANGUAGES" | grep -q "Python (pyenv)"; then
        gum spin --spinner globe --title "Installing pyenv..." -- bash -c '
            curl https://pyenv.run | bash
        '
        gum style --foreground 212 "✓ pyenv installed successfully"
    fi

    if echo "$LANGUAGES" | grep -q "Ruby (rbenv)"; then
        gum spin --spinner globe --title "Installing rbenv..." -- bash -c '
            sudo apt install -y rbenv ruby-build
        '
        gum style --foreground 212 "✓ rbenv installed successfully"
    fi

    if echo "$LANGUAGES" | grep -q "Go (g)"; then
        gum spin --spinner globe --title "Installing g (Go version manager)..." -- bash -c '
            curl -sSL https://git.io/g-install | sh -s
        '
        gum style --foreground 212 "✓ g installed successfully"
    fi

    if echo "$LANGUAGES" | grep -q "Rust (rustup)"; then
        gum spin --spinner globe --title "Installing rustup..." -- bash -c '
            curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        '
        gum style --foreground 212 "✓ rustup installed successfully"
    fi

    if echo "$LANGUAGES" | grep -q "Java (sdkman)"; then
        gum spin --spinner globe --title "Installing SDKMAN..." -- bash -c '
            curl -s "https://get.sdkman.io" | bash
        '
        gum style --foreground 212 "✓ SDKMAN installed successfully"
    fi
}

configure_shell() {
    CURRENT_SHELL=$(basename "$SHELL")
    SELECTED_SHELL=$(gum choose --header "Select your preferred shell (current: $CURRENT_SHELL):" \
        "bash" \
        "zsh" \
        "fish" \
        "Keep current")

    if [ "$SELECTED_SHELL" != "Keep current" ] && [ "$SELECTED_SHELL" != "$CURRENT_SHELL" ]; then
        case "$SELECTED_SHELL" in
            "zsh")
                gum spin --spinner globe --title "Installing zsh..." -- sudo apt install -y zsh

                if gum confirm "Install Oh My Zsh?"; then
                    gum spin --spinner globe --title "Installing Oh My Zsh..." -- sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

                    if gum confirm "Install popular zsh plugins (autosuggestions, fast-syntax-highlighting)?"; then
                        git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
                        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
                    fi
                fi

                chsh -s $(which zsh)
                ;;
            "fish")
                gum spin --spinner globe --title "Installing fish..." -- sudo apt install -y fish
                chsh -s $(which fish)
                ;;
            "bash")
                chsh -s $(which bash)
                ;;
        esac
        gum style --foreground 212 "✓ Shell changed to $SELECTED_SHELL"
    fi
}

configure_gnome() {
    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
        if gum confirm "Configure GNOME settings and default apps?"; then
            if gum confirm "Enable dark mode?"; then
                gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
                gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
            fi

            if gum confirm "Disable the Ubuntu dock?"; then
                gsettings set org.gnome.shell.extensions.dash-to-dock autohide false
                gsettings set org.gnome.shell.extensions.dash-to-dock dock-fixed false
                gsettings set org.gnome.shell.extensions.dash-to-dock intellihide false
                gnome-extensions disable ubuntu-dock@ubuntu.com
                gum style --foreground 212 "✓ Ubuntu dock disabled"

                if gum confirm "Disable desktop icons?"; then
                    gsettings set org.gnome.shell.extensions.ding show-home false
                    gsettings set org.gnome.shell.extensions.ding show-trash false
                    gnome-extensions disable ding@rastersoft.com
                fi
            fi

            gsettings set org.gnome.mutter dynamic-workspaces false
            gsettings set org.gnome.desktop.wm.preferences num-workspaces 7

            if gum confirm "Enable night light?"; then
                gsettings set org.gnome.settings-daemon.plugins.color night-light-enabled true
            fi

            if command -v ghostty &> /dev/null; then
                if gum confirm "Set Ghostty as default terminal?"; then
                    sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50
                    sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
                fi
            fi

            gum style --foreground 212 "✓ GNOME settings configured"
        fi
    fi
}

show_summary() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Setup Complete!" \
        "" \
        "Your Ubuntu system has been configured" \
        "with your selected preferences." \
        "" \
        "Please restart your terminal or" \
        "log out and back in for all" \
        "changes to take effect."

    echo ""
    gum style --foreground 214 "Installed packages:"
    if [ ${#SELECTED_APT_PACKAGES[@]} -gt 0 ]; then
        echo "APT: ${SELECTED_APT_PACKAGES[*]}"
    fi
    if [ ${#SELECTED_PACSTALL_PACKAGES[@]} -gt 0 ]; then
        echo "Pacstall: ${SELECTED_PACSTALL_PACKAGES[*]}"
    fi
}

main() {
    check_ubuntu

    sudo apt update
    sudo apt install -y curl wget

    install_gum
    show_welcome

    remove_snaps
    select_packages
    install_apt_packages
    install_pacstall
    install_pacstall_packages
    install_special_packages
    install_nerd_fonts
    install_language_managers
    configure_shell
    configure_gnome
 
    show_summary
}

if [ "$0" = "bash" ]; then
    # Script is being piped from curl/wget
    main "$@"
else
    # Script is being run normally
    main "$@"
fi
