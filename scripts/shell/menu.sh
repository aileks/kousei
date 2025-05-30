#!/usr/bin/env bash

shell_menu() {
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
            "Shell & Terminal Setup"

        local choice=$(gum choose --header "What would you like to configure?" \
            "Install Terminal Emulators" \
            "Configure Shell (Zsh, Fish, etc.)" \
            "Install Shell Utilities" \
            "Back to Main Menu")

        case "$choice" in
            "Install Terminal Emulators")
                source_script "shell" "terminals.sh"
                install_terminal_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Configure Shell (Zsh, Fish, etc.)")
                gum style --foreground 214 "Shell configuration coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install Shell Utilities")
                gum style --foreground 214 "Shell utilities installation coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

shell_menu
