#!/usr/bin/env bash

utilities_menu() {
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
            "System Utilities"

        local choice=$(gum choose --header "What would you like to install?" \
            "System Tools & CLI Utilities" \
            "File Managers" \
            "Network Tools" \
            "System Monitoring" \
            "Compression Tools" \
            "All Utilities" \
            "Back to Main Menu")

        case "$choice" in
            "System Tools & CLI Utilities")
                source_script "utilities" "system-tools.sh"
                install_tools_interactive
                gum input --placeholder "Press Enter to continue..."
                ;;
            "File Managers")
                source_script "utilities" "system-tools.sh"
                install_file_managers
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Network Tools")
                source_script "utilities" "system-tools.sh"
                install_network_tools
                gum input --placeholder "Press Enter to continue..."
                ;;
            "System Monitoring")
                source_script "utilities" "system-tools.sh"
                install_system_monitoring
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Compression Tools")
                source_script "utilities" "system-tools.sh"
                install_compression_tools
                gum input --placeholder "Press Enter to continue..."
                ;;
            "All Utilities")
                source_script "utilities" "system-tools.sh"
                install_cli_tools
                install_system_monitoring
                install_compression_tools
                if gum confirm "Install network tools?"; then
                    install_network_tools
                fi
                if gum confirm "Install file managers?"; then
                    install_file_managers
                fi
                gum input --placeholder "Press Enter to continue..."
                ;;
            "Back to Main Menu")
                break
                ;;
        esac
    done
}

utilities_menu
