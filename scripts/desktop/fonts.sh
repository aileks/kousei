#!/usr/bin/env bash

NERD_FONTS=(
    "FiraCode:Fira Code"
    "Hack:Hack"
    "JetBrainsMono:JetBrains Mono"
    "Meslo:Meslo"
    "SourceCodePro:Source Code Pro"
    "UbuntuMono:Ubuntu Mono"
    "RobotoMono:Roboto Mono"
    "Iosevka:Iosevka"
    "CascadiaCode:Cascadia Code"
    "Inconsolata:Inconsolata"
    "DroidSansMono:Droid Sans Mono"
    "DejaVuSansMono:DejaVu Sans Mono"
)

install_nerd_font() {
    local font_name="$1"
    local font_dir="$HOME/.local/share/fonts/$font_name"

    gum spin --spinner globe --title "Installing $font_name Nerd Font..." -- bash -c "
        mkdir -p \"$font_dir\"
        cd \"$font_dir\"

        wget -q \"https://github.com/ryanoasis/nerd-fonts/releases/latest/download/${font_name}.zip\" || {
            echo 'Failed to download font'
            return 1
        }

        unzip -q \"${font_name}.zip\" || {
            echo 'Failed to extract font'
            rm -f \"${font_name}.zip\"
            return 1
        }

        rm -f \"${font_name}.zip\"

        find . -type f ! -name '*.ttf' ! -name '*.otf' ! -name '*.woff' ! -name '*.woff2' -delete 2>/dev/null || true

        fc-cache -fv \"$font_dir\" >/dev/null 2>&1
        fc-cache -f >/dev/null 2>&1
    "

    if [ $? -eq 0 ]; then
        gum style --foreground 212 "✓ $font_name Nerd Font installed successfully to ~/.local/share/fonts/$font_name"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install $font_name Nerd Font"
        rm -rf "$font_dir" 2>/dev/null || true
        return 1
    fi
}

install_fonts_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Nerd Fonts Installation" \
        "" \
        "Nerd Fonts include programming" \
        "ligatures and icon glyphs"

    echo ""

    local font_choices=()
    for font in "${NERD_FONTS[@]}"; do
        font_choices+=("$font")
    done
    font_choices+=("Back")

    local selected_fonts=$(gum choose --no-limit --header "Select Nerd Fonts to install (space to select, enter to confirm):" \
        "${font_choices[@]}")

    if echo "$selected_fonts" | grep -q "Back"; then
        return
    fi

    local fonts_installed=false
    while IFS= read -r selection; do
        if [ -n "$selection" ]; then
            local font_name="${selection%%:*}"
            install_nerd_font "$font_name" && fonts_installed=true
        fi
    done <<< "$selected_fonts"

    if [ -n "$selected_fonts" ]; then
        if gum confirm "Install additional system fonts (Ubuntu restricted extras)?"; then
            gum spin --spinner globe --title "Installing additional fonts..." -- \
                sudo apt install -y ubuntu-restricted-extras fonts-firacode fonts-cascadia-code
            fonts_installed=true
        fi
    fi

    if [ "$fonts_installed" = true ]; then
        gum style --foreground 212 "Updating system font cache..."
        fc-cache -f -v >/dev/null 2>&1
        gum style --foreground 212 "✓ Font cache updated successfully"
    fi
}

show_installed_fonts() {
    gum style --foreground 212 "Installed Nerd Fonts:"

    local nerd_fonts_dir="$HOME/.local/share/fonts"
    if [ -d "$nerd_fonts_dir" ]; then
        for font_dir in "${NERD_FONTS[@]}"; do
            font_name="${font_dir%%:*}"
            local font_path="$nerd_fonts_dir/$font_name"
            if [ -d "$font_path" ] && find "$font_path" -name "*.ttf" -o -name "*.otf" | grep -q .; then
                echo "  ✓ $font_name (in $font_path)"
            fi
        done
    else
        echo "  No Nerd Fonts found in user directory"
    fi
}

remove_font() {
    local font_name="$1"
    local font_dir="$HOME/.local/share/fonts/$font_name"

    if [ -d "$font_dir" ]; then
        gum style --foreground 212 "Removing $font_name Nerd Font..."
        rm -rf "$font_dir"
        fc-cache -f >/dev/null 2>&1
        gum style --foreground 212 "✓ $font_name Nerd Font removed successfully"
    else
        gum style --foreground 214 "⚠ $font_name Nerd Font not found"
    fi
}

manage_fonts_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Font Management"

    echo ""

    local choice=$(gum choose --header "Font management options:" \
        "Install Fonts" \
        "Show Installed Fonts" \
        "Remove Fonts" \
        "Optimize Font Rendering" \
        "Update Font Cache" \
        "Back")

    case "$choice" in
        "Install Fonts")
            install_fonts_interactive
            ;;
        "Show Installed Fonts")
            show_installed_fonts
            gum input --placeholder "Press Enter to continue..."
            ;;
        "Remove Fonts")
            remove_fonts_interactive
            ;;
        "Optimize Font Rendering")
            setup_font_rendering
            ;;
        "Update Font Cache")
            gum style --foreground 212 "Updating font cache..."
            fc-cache -f -v >/dev/null 2>&1
            gum style --foreground 212 "✓ Font cache updated"
            gum input --placeholder "Press Enter to continue..."
            ;;
        "Back")
            return
            ;;
    esac
}

remove_fonts_interactive() {
    local installed_fonts=()
    local nerd_fonts_dir="$HOME/.local/share/fonts"

    if [ -d "$nerd_fonts_dir" ]; then
        for font_dir in "${NERD_FONTS[@]}"; do
            font_name="${font_dir%%:*}"
            font_display="${font_dir#*:}"
            local font_path="$nerd_fonts_dir/$font_name"
            if [ -d "$font_path" ] && find "$font_path" -name "*.ttf" -o -name "*.otf" | grep -q .; then
                installed_fonts+=("$font_name:$font_display")
            fi
        done
    fi

    if [ ${#installed_fonts[@]} -eq 0 ]; then
        gum style --foreground 214 "No Nerd Fonts found to remove"
        gum input --placeholder "Press Enter to continue..."
        return
    fi

    local fonts_to_remove=$(gum choose --no-limit --header "Select fonts to remove:" \
        "${installed_fonts[@]}")

    while IFS= read -r selection; do
        if [ -n "$selection" ]; then
            local font_name="${selection%%:*}"
            remove_font "$font_name"
        fi
    done <<< "$fonts_to_remove"

    gum input --placeholder "Press Enter to continue..."
}

setup_font_rendering() {
    if gum confirm "Optimize font rendering for better appearance?"; then
        mkdir -p ~/.config/fontconfig
        cat > ~/.config/fontconfig/fonts.conf << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <match target="font">
    <edit mode="assign" name="antialias">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hinting">
      <bool>true</bool>
    </edit>
    <edit mode="assign" name="hintstyle">
      <const>hintslight</const>
    </edit>
    <edit mode="assign" name="rgba">
      <const>rgb</const>
    </edit>
    <edit mode="assign" name="lcdfilter">
      <const>lcddefault</const>
    </edit>
  </match>
</fontconfig>
EOF

        fc-cache -f -v >/dev/null 2>&1

        gum style --foreground 212 "✓ Font rendering optimized"
        gum input --placeholder "Press Enter to continue..."
    fi
}
