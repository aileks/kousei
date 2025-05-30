#!/usr/bin/env bash

set -euo pipefail

SCRIPT_VERSION="1.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_DIR="${SCRIPT_DIR}/scripts"
REPO_URL="https://raw.githubusercontent.com/aileks/kousei/main"

export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export PURPLE='\033[0;35m'
export CYAN='\033[0;36m'
export NC='\033[0m' # No Color
export BOLD_ESC='\033[1m'

export SCRIPT_VERSION
export RUNNING_FROM_URL=false
export KOUSEI_DIR=""

# Detect if running from URL
if [[ "${BASH_SOURCE[0]}" == "/dev/fd/"* ]] || [[ "${BASH_SOURCE[0]}" == "/proc/self/fd/"* ]] || [[ "$0" == "bash" ]] || [[ "${BASH_SOURCE[0]}" == "" ]] || [[ "${BASH_SOURCE[0]}" == "bash" ]]; then
    RUNNING_FROM_URL=true
fi

setup_kousei_directory() {
    if [ "$RUNNING_FROM_URL" = true ]; then
        # Ensure git is available
        if ! command -v git &> /dev/null; then
            echo -e "${YELLOW}Installing git...${NC}"
            sudo apt update -qq >/dev/null 2>&1
            sudo apt install -qq -y git >/dev/null 2>&1
        fi

        KOUSEI_DIR="$HOME/.local/share/kousei"

        # Check if directory exists and is a git repo
        if [ -d "$KOUSEI_DIR/.git" ]; then
            echo -e "${CYAN}Updating existing Kōsei repository...${NC}"
            cd "$KOUSEI_DIR"
            git pull -q origin main >/dev/null 2>&1 || {
                echo -e "${YELLOW}Failed to update repository, re-cloning...${NC}"
                cd "$HOME/.local/share"
                rm -rf kousei
                git clone -q https://github.com/aileks/kousei.git >/dev/null 2>&1
            }
        else
            echo -e "${CYAN}Cloning Kōsei repository...${NC}"
            mkdir -p "$HOME/.local/share"
            cd "$HOME/.local/share"
            rm -rf kousei  # Remove if exists but not a git repo
            git clone -q https://github.com/aileks/kousei.git >/dev/null 2>&1 || {
                echo -e "${RED}Failed to clone repository. Please check your internet connection.${NC}"
                exit 1
            }
        fi

        SCRIPT_DIR="$KOUSEI_DIR"
        SCRIPTS_DIR="$KOUSEI_DIR/scripts"
        cd "$KOUSEI_DIR"
        echo -e "${GREEN}✓ Kōsei repository ready${NC}"
    fi
}

source_script() {
    local category="$1"
    local script="$2"
    local script_path="${SCRIPTS_DIR}/${category}/${script}"

    if [ -f "$script_path" ]; then
        source "$script_path"
    else
        echo -e "${RED}Script not found: ${script_path}${NC}"
        return 1
    fi
}

run_category() {
    local category="$1"
    local script="$2"
    local description="$3"

    if gum confirm "Setup ${description}?"; then
        source_script "$category" "$script"
    fi
}

show_main_menu() {
    while true; do
        print_header

        local choice=$(gum choose --header "Select setup category:" \
            "Aileks Recommended (Curated development setup)" \
            "Core System (Base packages, snap removal)" \
            "Desktop Environment (GNOME, fonts, themes)" \
            "Shell & Terminal (Shells, terminal emulators)" \
            "Development Tools (Editors, languages, version managers)" \
            "System Utilities (File managers, system tools)" \
            "Applications (Browsers, communication, productivity)" \
            "Custom Selection (Choose individual components)" \
            "Exit")

        case "$choice" in
            "Aileks Recommended (Curated development setup)")
                aileks_recommended
                ;;
            "Core System (Base packages, snap removal)")
                source_script "core" "menu.sh"
                ;;
            "Desktop Environment (GNOME, fonts, themes)")
                source_script "desktop" "menu.sh"
                ;;
            "Shell & Terminal (Shells, terminal emulators)")
                source_script "shell" "menu.sh"
                ;;
            "Development Tools (Editors, languages, version managers)")
                source_script "development" "menu.sh"
                ;;
            "System Utilities (File managers, system tools)")
                source_script "utilities" "menu.sh"
                ;;
            "Applications (Browsers, communication, productivity)")
                source_script "apps" "menu.sh"
                ;;
            "Custom Selection (Choose individual components)")
                custom_selection
                ;;
            "Exit")
                break
                ;;
        esac
    done
}

refresh_sudo() {
    # Refresh sudo credentials to prevent password prompts during installation
    if ! sudo -n true 2>/dev/null; then
        gum style --foreground 214 "Administrator access required for system packages..."
        sudo -v
    fi
}

aileks_recommended() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 \
        --margin "1 10" \
        --padding "2 4" \
        "Aileks Recommended Setup" \
        "" \
        "This will install Aileks' curated" \
        "selection of development tools" \
        "and system utilities"

    echo ""
    if ! gum confirm "Continue with Aileks Recommended setup?"; then
        return
    fi

    # Cache sudo credentials
    refresh_sudo

    # Install base system packages
    gum style --foreground 212 "Installing base system packages..."
    source_script "core" "base.sh"
    install_base_packages

    # Remove snaps
    gum style --foreground 212 "Removing snap packages..."
    source_script "core" "snap-removal.sh"
    remove_snaps_auto

    # Install pacstall
    gum style --foreground 212 "Installing Pacstall package manager..."
    source_script "core" "pacstall.sh"
    install_pacstall

    # Install core CLI tools
    gum style --foreground 212 "Installing core CLI tools..."
    local AILEKS_CLI_TOOLS=(
        "curl"
        "ripgrep"
        "fzf"
        "trash-cli"
        "zoxide"
        "eza"
        "tmux"
        "btop"
        "cava"
        "ffmpeg"
        "git"
        "build-essential"
        "ubuntu-restricted-extras"
        "celluloid"
    )
    
    # Refresh sudo before long apt operation
    refresh_sudo
    gum spin --spinner globe --title "Installing CLI tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${AILEKS_CLI_TOOLS[*]}
    "

    # Install pacstall packages
    gum style --foreground 212 "Installing packages via Pacstall..."
    local AILEKS_PACSTALL_PACKAGES=(
        "neovim"
        "zen-browser-bin"
        "bat-deb"
        "spotify-client-deb"
    )
    
    for package in "${AILEKS_PACSTALL_PACKAGES[@]}"; do
        gum spin --spinner globe --title "Installing $package..." -- pacstall -PIP "$package"
    done

    # Install Ghostty terminal
    gum style --foreground 212 "Installing Ghostty terminal..."
    source_script "shell" "terminals.sh"
    install_ghostty

    # Install Signal Desktop
    gum style --foreground 212 "Installing Signal Desktop..."
    source_script "apps" "communication.sh"
    install_signal

    # Install JetBrains Mono Nerd Font
    gum style --foreground 212 "Installing JetBrains Mono Nerd Font..."
    source_script "desktop" "fonts.sh"
    install_nerd_font "JetBrainsMono"

    # Configure GNOME if running GNOME
    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
        gum style --foreground 212 "Configuring GNOME defaults..."
        source_script "desktop" "gnome.sh"
        configure_gnome_defaults
    fi

    show_summary "Aileks Recommended setup completed!"
}

custom_selection() {
    local selections=$(gum choose --no-limit --header "Select components to install:" \
        "Base System Packages" \
        "Remove Snaps" \
        "Pacstall Package Manager" \
        "GNOME Configuration" \
        "Nerd Fonts" \
        "Shell Configuration" \
        "Terminal Emulators" \
        "Development Editors" \
        "Programming Languages" \
        "Version Managers" \
        "System Utilities" \
        "Web Browsers" \
        "Communication Apps" \
        "Multimedia Apps" \
        "Productivity Apps")
 
    while IFS= read -r selection; do
        case "$selection" in
            "Base System Packages")
                source_script "core" "base.sh" && install_base_packages
                ;;
            "Remove Snaps")
                source_script "core" "snap-removal.sh" && remove_snaps_interactive
                ;;
            "Pacstall Package Manager")
                source_script "core" "pacstall.sh" && install_pacstall
                ;;
            "GNOME Configuration")
                source_script "desktop" "gnome.sh" && configure_gnome_interactive
                ;;
            "Nerd Fonts")
                source_script "desktop" "fonts.sh" && install_fonts_interactive
                ;;
            "Shell Configuration")
                source_script "shell" "shells.sh" && configure_shell_interactive
                ;;
            "Terminal Emulators")
                source_script "shell" "terminals.sh" && install_terminal_interactive
                ;;
            "Development Editors")
                source_script "apps" "editors.sh" && install_editors_interactive
                ;;
            "Programming Languages")
                source_script "development" "languages.sh" && install_languages_interactive
                ;;
            "Version Managers")
                source_script "development" "version-managers.sh" && install_version_managers_interactive
                ;;
            "System Utilities")
                source_script "utilities" "system-tools.sh" && install_tools_interactive
                ;;
            "Web Browsers")
                source_script "apps" "browsers.sh" && install_browsers_interactive
                ;;
            "Communication Apps")
                source_script "apps" "communication.sh" && install_communication_interactive
                ;;
            "Multimedia Apps")
                source_script "apps" "multimedia.sh" && install_multimedia_interactive
                ;;
            "Productivity Apps")
                source_script "apps" "productivity.sh" && install_productivity_interactive
                ;;
        esac
    done <<< "$selections"
}

check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        echo -e "${RED}This script is designed for Ubuntu. Exiting...${NC}"
        exit 1
    fi
}

check_and_update_existing_repo() {
    local kousei_dir="$HOME/.local/share/kousei"

    if ! command -v git &> /dev/null; then
        return 0
    fi

    if [ -d "$kousei_dir/.git" ]; then
        echo -e "${CYAN}Found existing Kōsei repository, updating...${NC}"
        cd "$kousei_dir"

        if git pull -q origin main >/dev/null 2>&1; then
            echo -e "${GREEN}✓ Repository updated successfully${NC}"

            SCRIPT_DIR="$kousei_dir"
            SCRIPTS_DIR="$kousei_dir/scripts"
            cd "$kousei_dir"
        else
            echo -e "${YELLOW}Failed to update repository, will re-clone if needed...${NC}"
        fi
    fi
}

check_and_setup_repository() {
    if [ ! -f "${SCRIPTS_DIR}/core/base.sh" ]; then
        RUNNING_FROM_URL=true
        setup_kousei_directory
    fi
}

print_header() {
    clear
    echo -e "${CYAN}${BOLD_ESC}"
    echo ""
    echo ""
    echo "       ▄█   ▄█▄  ▄██████▄  ███    █▄     ▄████████    ▄████████  ▄█  "
    echo "      ███ ▄███▀ ███    ███ ███    ███   ███    ███   ███    ███ ███  "
    echo "      ███▐██▀   ███    ███ ███    ███   ███    █▀    ███    █▀  ███▌ "
    echo "     ▄█████▀    ███    ███ ███    ███   ███         ▄███▄▄▄     ███▌ "
    echo "    ▀▀█████▄    ███    ███ ███    ███ ▀███████████ ▀▀███▀▀▀     ███▌ "
    echo "      ███▐██▄   ███    ███ ███    ███          ███   ███    █▄  ███  "
    echo "      ███ ▀███▄ ███    ███ ███    ███    ▄█    ███   ███    ███ ███  "
    echo "      ███   ▀█▀  ▀██████▀  ████████▀   ▄████████▀    ██████████ █▀   "
    echo "      ▀                                                              "
    echo "                                v${SCRIPT_VERSION}"
    echo -e "${NC}"
}

show_summary() {
    local message="${1:-Setup completed!}"

    print_header

    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 10" \
        --padding "2 4" \
        "$message" \
        "" \
        "Please restart your terminal or" \
        "log out and back in for all" \
        "changes to take effect."
}

show_welcome() {
    print_header

    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 \
        --margin "1 10" \
        --padding "2 4" \
        "Welcome to Kōsei!" \
        "" \
        "This modular script will help you" \
        "set up your Ubuntu system with" \
        "your preferred tools and configs."

    echo ""
    gum confirm "Ready to begin?" || exit 0
}

export -f print_header
export -f show_summary
export -f source_script
export -f refresh_sudo
export -f setup_kousei_directory
export -f check_and_setup_repository
export -f check_and_update_existing_repo

main() {
    check_ubuntu
    check_and_update_existing_repo
    check_and_setup_repository

    if [ "$RUNNING_FROM_URL" = true ] || [ ! -d "$SCRIPTS_DIR" ]; then
        setup_kousei_directory
    fi

    if command -v gum &> /dev/null; then
        refresh_sudo
    fi

    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Installing gum for beautiful CLI interactions...${NC}"
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -qq >/dev/null 2>&1
        sudo apt install -qq -y curl wget git >/dev/null 2>&1
        source_script "core" "base.sh"
        install_gum
        refresh_sudo
    fi

    show_welcome
    show_main_menu
    show_summary
}

main "$@"
