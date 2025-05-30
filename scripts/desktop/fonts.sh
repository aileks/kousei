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

    gum spin --spinner globe --title "Installing $font_name Nerd Font..." -- bash -c "
        mkdir -p ~/.local/share/fonts
        cd ~/.local/share/fonts

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

        fc-cache -fv >/dev/null 2>&1
    "

    if [ $? -eq 0 ]; then
        gum style --foreground 212 "✓ $font_name Nerd Font installed successfully"
        return 0
    else
        gum style --foreground 196 "✗ Failed to install $font_name Nerd Font"
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
    font_choices+=("Skip:Skip font installation")

    local selected_fonts=$(gum choose --no-limit --header "Select Nerd Fonts to install (space to select, enter to confirm):" \
        "${font_choices[@]}")

    while IFS= read -r selection; do
        if [ -n "$selection" ] && [ "$selection" != "Skip:Skip font installation" ]; then
            local font_name="${selection%%:*}"
            install_nerd_font "$font_name"
        fi
    done <<< "$selected_fonts"

    if gum confirm "Install additional system fonts (Ubuntu restricted extras)?"; then
        gum spin --spinner globe --title "Installing additional fonts..." -- \
            sudo apt install -y ubuntu-restricted-extras fonts-firacode fonts-cascadia-code
    fi
}

show_installed_fonts() {
    gum style --foreground 212 "Installed Nerd Fonts:"

    local nerd_fonts_dir="$HOME/.local/share/fonts"
    if [ -d "$nerd_fonts_dir" ]; then
        for font_dir in "${NERD_FONTS[@]}"; do
            font_name="${font_dir%%:*}"
            if find "$nerd_fonts_dir" -name "*${font_name}*" -type f | grep -q .; then
                echo "  ✓ $font_name"
            fi
        done
    else
        echo "  No Nerd Fonts found in user directory"
    fi
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

        fc-cache -fv

        gum style --foreground 212 "✓ Font rendering optimized"
    fi
}
