#!/usr/bin/env bash

install_gum() {
    if ! command -v gum &> /dev/null; then
        echo -e "${YELLOW}Installing gum for beautiful CLI interactions...${NC}"
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
        echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list
        sudo apt update && sudo apt install -y gum
        echo -e "${GREEN}✓ Gum installed successfully${NC}"
    fi
}

install_base_packages() {
    local BASE_PACKAGES=(
        "curl"
        "wget"
        "git"
        "build-essential"
        "software-properties-common"
        "apt-transport-https"
        "ca-certificates"
        "gnupg"
        "lsb-release"
        "gnome-shell-extension-manager"
    )

    gum style --foreground 212 "Installing base system packages..."
    gum spin --spinner globe --title "Updating package lists..." -- sudo apt update
    gum spin --spinner globe --title "Installing base packages..." -- sudo apt install -y "${BASE_PACKAGES[@]}"
    gum style --foreground 212 "✓ Base packages installed successfully"
}

update_system() {
    gum style --foreground 212 "Updating system packages..."
    gum spin --spinner globe --title "Updating package lists..." -- sudo apt update
    gum spin --spinner globe --title "Upgrading packages..." -- sudo apt upgrade -y
    gum spin --spinner globe --title "Cleaning up..." -- sudo apt autoremove -y
    gum style --foreground 212 "✓ System updated successfully"
}

install_base_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Base System Setup"

    if gum confirm "Update system packages?"; then
        update_system
    fi

    if gum confirm "Install base packages?"; then
        install_base_packages
    fi
}
