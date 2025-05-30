#!/usr/bin/env bash

development_menu() {
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
            "Development Tools Setup"

        local choice=$(gum choose --header "What would you like to install?" \
            "Code Editors" \
            "Version Managers" \
            "Programming Languages" \
            "Development Tools" \
            "Back to Main Menu")

        case "$choice" in
            "Code Editors")
                source_script "development" "editors.sh"
                install_editors_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Version Managers")
                source_script "development" "version-managers.sh"
                install_version_managers_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Programming Languages")
                gum style --foreground 214 "Programming languages installation coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Development Tools")
                gum style --foreground 214 "Development tools installation coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

development_menu
