#!/usr/bin/env bash

desktop_menu() {
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
            "Desktop Environment Setup"

        local choice=$(gum choose --header "What would you like to configure?" \
            "Install Nerd Fonts" \
            "Configure GNOME" \
            "Install GNOME Extensions" \
            "Install Themes" \
            "Configure Display Settings" \
            "Back to Main Menu")

        case "$choice" in
            "Install Nerd Fonts")
                source_script "desktop" "fonts.sh"
                install_fonts_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Configure GNOME")
                source_script "desktop" "gnome.sh"
                configure_gnome_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install GNOME Extensions")
                source_script "desktop" "gnome.sh"
                install_extensions_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Install Themes")
                gum style --foreground 214 "Theme installation coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Configure Display Settings")
                gum style --foreground 214 "Display configuration coming soon..."
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

desktop_menu
