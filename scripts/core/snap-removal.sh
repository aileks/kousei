#!/usr/bin/env bash

remove_snaps_auto() {
    remove_snaps_core
}

remove_snaps_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Snap Removal" \
        "" \
        "This will completely remove snap" \
        "from your system and prevent" \
        "it from being reinstalled."

    echo ""
    if gum confirm "Do you want to remove snaps entirely from your system?"; then
        remove_snaps_core
    fi
}

remove_snaps_core() {
    gum style --foreground 214 "Removing snap packages..."

    local snaps=$(sudo snap list 2>/dev/null | awk 'NR>1 {print $1}')
    if [ -n "$snaps" ]; then
        echo "Current snap packages:"
        echo "$snaps"
        echo ""
    fi

    gum spin --spinner globe --title "Removing snap packages..." -- bash -c '
        # Remove all snap packages
        for snap in $(sudo snap list 2>/dev/null | awk "NR>1 {print \$1}"); do
            sudo snap remove --purge "$snap" 2>/dev/null || true
        done

        # Stop and disable snapd
        sudo systemctl stop snapd.service 2>/dev/null || true
        sudo systemctl stop snapd.socket 2>/dev/null || true
        sudo systemctl stop snapd.seeded.service 2>/dev/null || true
        sudo systemctl disable snapd.service 2>/dev/null || true
        sudo systemctl disable snapd.socket 2>/dev/null || true
        sudo systemctl disable snapd.seeded.service 2>/dev/null || true

        # Remove snapd
        sudo apt remove --purge -y snapd 2>/dev/null || true

        # Clean up directories
        sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd

        # Prevent snap from being installed
        echo "Package: snapd" | sudo tee /etc/apt/preferences.d/nosnap.pref
        echo "Pin: release a=*" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
        echo "Pin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref
    '

    gum style --foreground 212 "✓ Snaps have been removed from your system"
    gum style --foreground 214 "Note: Firefox will need to be installed via another method"

    if gum confirm "Install Firefox from Mozilla PPA?"; then
        install_firefox_ppa
    fi
}

install_firefox_ppa() {
    gum spin --spinner globe --title "Installing Firefox from Mozilla PPA..." -- bash -c '
        # Add Mozilla PPA
        sudo add-apt-repository -y ppa:mozillateam/ppa

        # Set PPA priority
        echo "Package: firefox*" | sudo tee /etc/apt/preferences.d/mozilla-firefox
        echo "Pin: release o=LP-PPA-mozillateam" | sudo tee -a /etc/apt/preferences.d/mozilla-firefox
        echo "Pin-Priority: 1001" | sudo tee -a /etc/apt/preferences.d/mozilla-firefox

        # Update and install
        sudo apt update
        sudo apt install -y firefox
    '

    gum style --foreground 212 "✓ Firefox installed from Mozilla PPA"
}
