#!/usr/bin/env bash

core_menu() {
    while true; do
        print_header
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --border rounded \
            --align center \
            --width 50 \
            --margin "1 2" \
            --padding "2 4" \
            "System Setup"

        local choice=$(gum choose --header "What would you like to do?" \
            "Update System" \
            "Install Base Packages" \
            "Remove Snap Packages" \
            "Install Pacstall" \
            "Configure APT Sources" \
            "Install Essential Build Tools" \
            "Setup Flatpak" \
            "Configure System Security" \
            "Back to Main Menu")

        case "$choice" in
            "Update System")
                source_script "core" "base.sh"
                update_system
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install Base Packages")
                source_script "core" "base.sh"
                install_base_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Remove Snap Packages")
                source_script "core" "snap-removal.sh"
                remove_snaps_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install Pacstall")
                source_script "core" "pacstall.sh"
                install_pacstall_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Configure APT Sources")
                source_script "core" "apt-sources.sh"
                configure_apt_sources
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install Essential Build Tools")
                source_script "core" "build-tools.sh"
                install_build_tools
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Setup Flatpak")
                source_script "core" "flatpak.sh"
                setup_flatpak
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Configure System Security")
                source_script "core" "security.sh"
                configure_security
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

core_menu
