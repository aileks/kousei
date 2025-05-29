#!/usr/bin/env bash

set -euo pipefail

SCRIPT_NAME="Kōsei"
SCRIPT_VERSION="1.0.0"
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
export BOLD='\033[1m'

export SCRIPT_NAME
export SCRIPT_VERSION
export RUNNING_FROM_URL=false

if [ "$0" = "bash" ]; then
    RUNNING_FROM_URL=true
fi

source_script() {
    local category="$1"
    local script="$2"
    local script_path="${SCRIPTS_DIR}/${category}/${script}"

    if [ "$RUNNING_FROM_URL" = true ]; then
        local url="${REPO_URL}/scripts/${category}/${script}"
        echo -e "${CYAN}Downloading ${category}/${script}...${NC}"
        source <(curl -fsSL "$url") || {
            echo -e "${RED}Failed to download ${category}/${script}${NC}"
            return 1
        }
    else
        if [ -f "$script_path" ]; then
            source "$script_path"
        else
            echo -e "${RED}Script not found: ${script_path}${NC}"
            return 1
        fi
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
            "Quick Setup (Recommended defaults)" \
            "Core System (Base packages, snap removal)" \
            "Desktop Environment (GNOME, fonts, themes)" \
            "Shell & Terminal (Shells, terminal emulators)" \
            "Development Tools (Editors, languages, version managers)" \
            "System Utilities (File managers, system tools)" \
            "Applications (Browsers, communication, productivity)" \
            "Custom Selection (Choose individual components)" \
            "Exit")

        case "$choice" in
            "Quick Setup (Recommended defaults)")
                quick_setup
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

quick_setup() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border double \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Quick Setup" \
        "" \
        "This will install recommended" \
        "packages and configurations"

    echo ""
    if ! gum confirm "Continue with quick setup?"; then
        return
    fi

    source_script "core" "base.sh"
    install_base_packages
    install_gum

    source_script "core" "snap-removal.sh"
    remove_snaps_auto

    source_script "core" "pacstall.sh"
    install_pacstall

    source_script "utilities" "system-tools.sh"
    install_default_tools

    source_script "shell" "terminals.sh"
    install_ghostty

    source_script "desktop" "fonts.sh"
    install_nerd_font "JetBrainsMono"

    source_script "development" "editors.sh"
    install_neovim

    source_script "apps" "browsers.sh"
    install_zen_browser

    source_script "apps" "communication.sh"
    install_signal

    if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ]; then
        source_script "desktop" "gnome.sh"
        configure_gnome_defaults
    fi

    show_summary "Quick setup completed!"
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
                source_script "shell" "terminal-emulators.sh" && install_terminal_interactive
                ;;
            "Development Editors")
                source_script "development" "editors.sh" && install_editors_interactive
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

print_header() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║               ${SCRIPT_NAME} v${SCRIPT_VERSION}                             ║"
    echo "║                                                           ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
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
        --margin "1 2" \
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
        --margin "1 2" \
        --padding "2 4" \
        "Welcome to Ubuntu Setup Script!" \
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

main() {
    check_ubuntu

    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Installing gum for beautiful CLI interactions...${NC}"
        sudo apt update
        sudo apt install -y curl wget
        source_script "core" "base.sh"
        install_gum
    fi

    show_welcome
    show_main_menu
    show_summary
}

main "$@"
