#!/usr/bin/env bash

apps_menu() {
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
            "Applications Installation"

        local choice=$(gum choose --header "What would you like to install?" \
            "Web Browsers" \
            "Communication Apps" \
            "Code Editors" \
            "Multimedia Apps" \
            "Productivity Apps" \
            "Back to Main Menu")

        case "$choice" in
            "Web Browsers")
                source_script "apps" "browsers.sh"
                install_browsers_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Communication Apps")
                source_script "apps" "communication.sh"
                install_communication_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Code Editors")
                source_script "development" "editors.sh"
                install_editors_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Multimedia Apps")
                source_script "apps" "multimedia.sh"
                install_multimedia_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Productivity Apps")
                source_script "apps" "productivity.sh"
                install_productivity_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

apps_menu
