#!/usr/bin/env bash

install_cli_tools() {
    local CLI_TOOLS=(
        "curl"
        "git"
        "build-essential"
        "ripgrep"
        "fzf"
        "trash-cli"
        "zoxide"
        "eza"
        "tmux"
        "btop"
        "wl-clipboard"
        "cava"
        "ffmpeg"
        "tree"
        "htop"
        "neofetch"
        "unzip"
        "zip"
        "jq"
    )

    refresh_sudo
    gum style --foreground 212 "Installing CLI tools..."
    gum spin --spinner globe --title "Installing CLI tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${CLI_TOOLS[*]}
    "
    gum style --foreground 212 "✓ CLI tools installed successfully"
}

install_default_tools() {
    local DEFAULT_TOOLS=(
        "curl"
        "ripgrep"
        "fzf"
        "fastfetch"
        "trash-cli"
        "zoxide"
        "eza"
        "tmux"
        "btop"
        "cava"
        "ffmpeg"
        "git"
        "jq"
        "wl-clipboard"
        "build-essential"
    )

    refresh_sudo
    gum style --foreground 212 "Installing default system tools..."
    gum spin --spinner globe --title "Installing default tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${DEFAULT_TOOLS[*]}
    "
    gum style --foreground 212 "✓ Default tools installed successfully"
}

install_system_monitoring() {
    local MONITORING_TOOLS=(
        "htop"
        "btop"
        "iotop"
        "nload"
    )

    refresh_sudo
    gum style --foreground 212 "Installing system monitoring tools..."

    gum spin --spinner globe --title "Installing monitoring tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${MONITORING_TOOLS[*]}
    "

    if command -v cargo &> /dev/null; then
        if gum confirm "Install additional monitoring tools via cargo (bandwhich, dust, duf)?"; then
            gum spin --spinner globe --title "Installing cargo tools..." -- \
                cargo install bandwhich dust duf
        fi
    fi

    gum style --foreground 212 "✓ System monitoring tools installed"
}

install_file_managers() {
    local managers=$(gum choose --no-limit --header "Select file managers to install:" \
        "ranger - Terminal file manager" \
        "nnn - Fast terminal file manager" \
        "mc - Midnight Commander" \
        "thunar - GUI file manager" \
        "pcmanfm - Lightweight GUI file manager")

    if [ -n "$managers" ]; then
        refresh_sudo
    fi

    while IFS= read -r selection; do
        case "$selection" in
            "ranger"*)
                gum spin --spinner globe --title "Installing ranger..." -- bash -c "
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt update -y
                    sudo apt install -y ranger
                "
                ;;
            "nnn"*)
                gum spin --spinner globe --title "Installing nnn..." -- bash -c "
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt update -y
                    sudo apt install -y nnn
                "
                ;;
            "mc"*)
                gum spin --spinner globe --title "Installing Midnight Commander..." -- bash -c "
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt update -y
                    sudo apt install -y mc
                "
                ;;
            "thunar"*)
                gum spin --spinner globe --title "Installing Thunar..." -- bash -c "
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt update -y
                    sudo apt install -y thunar
                "
                ;;
            "pcmanfm"*)
                gum spin --spinner globe --title "Installing PCManFM..." -- bash -c "
                    export DEBIAN_FRONTEND=noninteractive
                    sudo apt update -y
                    sudo apt install -y pcmanfm
                "
                ;;
        esac
    done <<< "$managers"
}

install_network_tools() {
    local NETWORK_TOOLS=(
        "curl"
        "net-tools"
        "dnsutils"
        "traceroute"
        "nmap"
        "wireshark"
        "tcpdump"
        "iftop"
        "nethogs"
    )

    gum style --foreground 212 "Installing network tools..."

    if gum confirm "Install network analysis tools (some require sudo)?"; then
        refresh_sudo
        gum spin --spinner globe --title "Installing network tools..." -- bash -c "
            export DEBIAN_FRONTEND=noninteractive
            sudo apt update -y
            sudo apt install -y ${NETWORK_TOOLS[*]}
        "
        gum style --foreground 212 "✓ Network tools installed"
    fi
}

install_compression_tools() {
    local COMPRESSION_TOOLS=(
        "zip"
        "unzip"
        "p7zip-full"
        "p7zip-rar"
        "rar"
        "unrar"
        "tar"
        "gzip"
        "bzip2"
        "xz-utils"
    )

    refresh_sudo
    gum style --foreground 212 "Installing compression tools..."
    gum spin --spinner globe --title "Installing compression tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${COMPRESSION_TOOLS[*]}
    "
    gum style --foreground 212 "✓ Compression tools installed"
}

install_tools_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "System Utilities Installation"

    echo ""

    local choice=$(gum choose --header "What would you like to install?" \
        "CLI Tools (ripgrep, fzf, eza, etc.)" \
        "System Monitoring Tools" \
        "File Managers" \
        "Network Tools" \
        "Compression Tools" \
        "All System Tools" \
        "Back")

    case "$choice" in
        "CLI Tools"*)
            install_cli_tools
            ;;
        "System Monitoring Tools")
            install_system_monitoring
            ;;
        "File Managers")
            install_file_managers
            ;;
        "Network Tools")
            install_network_tools
            ;;
        "Compression Tools")
            install_compression_tools
            ;;
        "All System Tools")
            install_cli_tools
            install_system_monitoring
            install_compression_tools
            if gum confirm "Install network tools?"; then
                install_network_tools
            fi
            ;;
        "Back")
            return
            ;;
    esac

    echo ""
    gum input --placeholder "Press Enter to continue..."
}
