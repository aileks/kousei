#!/usr/bin/env bash

install_ghostty() {
    gum style --foreground 212 "Installing Ghostty terminal..."

    if gum spin --spinner globe --title "Installing Ghostty..." -- \
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"; then

        gum style --foreground 212 "✓ Ghostty installed successfully"

        if command -v ghostty &> /dev/null && gum confirm "Set Ghostty as default terminal?"; then
            sudo update-alternatives --install /usr/bin/x-terminal-emulator x-terminal-emulator /usr/bin/ghostty 50
            sudo update-alternatives --set x-terminal-emulator /usr/bin/ghostty
            gum style --foreground 212 "✓ Ghostty set as default terminal"
        fi
    else
        gum style --foreground 196 "✗ Failed to install Ghostty"
    fi
}

install_alacritty() {
    gum style --foreground 212 "Installing Alacritty terminal..."

    if gum spin --spinner globe --title "Installing Alacritty..." -- bash -c '
        # Add Alacritty PPA
        sudo add-apt-repository -y ppa:aslatter/ppa
        sudo apt update
        sudo apt install -y alacritty
    '; then
        gum style --foreground 212 "✓ Alacritty installed successfully"

        if gum confirm "Create default Alacritty configuration?"; then
            create_alacritty_config
        fi
    else
        gum style --foreground 196 "✗ Failed to install Alacritty"
    fi
}

install_kitty() {
    gum style --foreground 212 "Installing Kitty terminal..."

    if gum spin --spinner globe --title "Installing Kitty..." -- bash -c '
        curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin

        # Create desktop entry
        mkdir -p ~/.local/share/applications
        cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/

        # Add to PATH
        echo "export PATH=\"\$HOME/.local/kitty.app/bin:\$PATH\"" >> ~/.bashrc
    '; then
        gum style --foreground 212 "✓ Kitty installed successfully"

        if gum confirm "Create default Kitty configuration?"; then
            create_kitty_config
        fi
    else
        gum style --foreground 196 "✗ Failed to install Kitty"
    fi
}

install_wezterm() {
    gum style --foreground 212 "Installing WezTerm..."

    if gum spin --spinner globe --title "Installing WezTerm..." -- bash -c '
        curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
        echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
        sudo apt update
        sudo apt install -y wezterm
    '; then
        gum style --foreground 212 "✓ WezTerm installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install WezTerm"
    fi
}

create_alacritty_config() {
    mkdir -p ~/.config/alacritty
    cat > ~/.config/alacritty/alacritty.toml << 'EOF'
[window]
padding = { x = 10, y = 10 }
decorations = "full"
opacity = 0.95

[font]
normal = { family = "JetBrainsMono Nerd Font", style = "Regular" }
bold = { family = "JetBrainsMono Nerd Font", style = "Bold" }
italic = { family = "JetBrainsMono Nerd Font", style = "Italic" }
bold_italic = { family = "JetBrainsMono Nerd Font", style = "Bold Italic" }
size = 12.0

[colors]
# Dracula theme
[colors.primary]
background = "#282a36"
foreground = "#f8f8f2"

[colors.cursor]
text = "#44475a"
cursor = "#f8f8f2"

[colors.selection]
text = "#f8f8f2"
background = "#44475a"

[colors.normal]
black = "#000000"
red = "#ff5555"
green = "#50fa7b"
yellow = "#f1fa8c"
blue = "#bd93f9"
magenta = "#ff79c6"
cyan = "#8be9fd"
white = "#bfbfbf"

[colors.bright]
black = "#4d4d4d"
red = "#ff6e67"
green = "#5af78e"
yellow = "#f4f99d"
blue = "#caa9fa"
magenta = "#ff92d0"
cyan = "#9aedfe"
white = "#e6e6e6"
EOF

    gum style --foreground 212 "✓ Alacritty configuration created"
}

create_kitty_config() {
    mkdir -p ~/.config/kitty
    cat > ~/.config/kitty/kitty.conf << 'EOF'
# Font configuration
font_family      JetBrainsMono Nerd Font
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        12.0

# Window configuration
window_padding_width 10
background_opacity 0.95

# Color scheme (Dracula)
foreground #f8f8f2
background #282a36
selection_foreground #ffffff
selection_background #44475a

# Black
color0 #000000
color8 #4d4d4d

# Red
color1 #ff5555
color9 #ff6e67

# Green
color2  #50fa7b
color10 #5af78e

# Yellow
color3  #f1fa8c
color11 #f4f99d

# Blue
color4  #bd93f9
color12 #caa9fa

# Magenta
color5  #ff79c6
color13 #ff92d0

# Cyan
color6  #8be9fd
color14 #9aedfe

# White
color7  #bfbfbf
color15 #e6e6e6

# Cursor colors
cursor #f8f8f2
cursor_text_color #44475a

# Tab bar
tab_bar_style powerline
tab_powerline_style slanted
EOF

    gum style --foreground 212 "✓ Kitty configuration created"
}

install_terminal_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Terminal Emulator Installation"

    echo ""

    local terminals=$(gum choose --no-limit --header "Select terminal emulators to install:" \
        "Ghostty" \
        "Alacritty" \
        "Kitty" \
        "WezTerm" \
        "Terminator" \
        "Tilix" \
        "GNOME Terminal")

    while IFS= read -r selection; do
        case "$selection" in
            "Ghostty"*)
                install_ghostty
                ;;
            "Alacritty"*)
                install_alacritty
                ;;
            "Kitty"*)
                install_kitty
                ;;
            "WezTerm"*)
                install_wezterm
                ;;
            "Terminator"*)
                gum spin --spinner globe --title "Installing Terminator..." -- \
                    sudo apt install -y terminator
                ;;
            "Tilix"*)
                gum spin --spinner globe --title "Installing Tilix..." -- \
                    sudo apt install -y tilix
                ;;
            "GNOME Terminal"*)
                gum spin --spinner globe --title "Installing GNOME Terminal..." -- \
                    sudo apt install -y gnome-terminal
                ;;
        esac
    done <<< "$terminals"
}
