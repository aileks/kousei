#!/usr/bin/env bash

install_neovim() {
    local method=$(gum choose --header "Choose Neovim installation method:" \
        "Pacstall (Recommended)" \
        "APT (Ubuntu repository)" \
        "AppImage (Latest)" \
        "Build from source")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using APT instead."
                install_neovim_apt
            else
                gum spin --spinner globe --title "Installing Neovim via Pacstall..." -- \
                    pacstall -IP neovim
                gum style --foreground 212 "✓ Neovim installed via Pacstall"
            fi
            ;;
        "APT"*)
            install_neovim_apt
            ;;
        "AppImage"*)
            install_neovim_appimage
            ;;
        "Build from source")
            install_neovim_source
            ;;
    esac
}

install_neovim_apt() {
    gum spin --spinner globe --title "Installing Neovim..." -- \
        sudo apt install -y neovim
    gum style --foreground 212 "✓ Neovim installed via APT"
}

install_neovim_appimage() {
    gum spin --spinner globe --title "Installing Neovim AppImage..." -- bash -c '
        cd /tmp
        curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim.appimage
        chmod u+x nvim.appimage
        sudo mv nvim.appimage /usr/local/bin/nvim
        sudo ln -sf /usr/local/bin/nvim /usr/local/bin/neovim
    '
    gum style --foreground 212 "✓ Neovim AppImage installed"
}

install_neovim_source() {
    gum spin --spinner globe --title "Installing Neovim build dependencies..." -- \
        sudo apt install -y ninja-build gettext cmake unzip curl

    gum spin --spinner globe --title "Building Neovim from source..." -- bash -c '
        cd /tmp
        git clone https://github.com/neovim/neovim
        cd neovim
        make CMAKE_BUILD_TYPE=RelWithDebInfo
        sudo make install
        cd ..
        rm -rf neovim
    '
    gum style --foreground 212 "✓ Neovim built and installed from source"
}

install_vscode() {
    gum style --foreground 212 "Installing Visual Studio Code..."

    local method=$(gum choose --header "Choose VS Code installation method:" \
        "Pacstall (Recommended)" \
        "Official Microsoft repository" \
        "Download .deb")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using official repository."
                install_vscode_official
            else
                gum spin --spinner globe --title "Installing VS Code via Pacstall..." -- \
                    pacstall -IP vscode-deb
                gum style --foreground 212 "✓ VS Code installed via Pacstall"
            fi
            ;;
        "Official Microsoft repository")
            install_vscode_official
            ;;
        "Download .deb")
            install_vscode_deb
            ;;
    esac
}

install_vscode_official() {
    gum spin --spinner globe --title "Installing VS Code..." -- bash -c '
        wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
        sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
        sudo sh -c "echo \"deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main\" > /etc/apt/sources.list.d/vscode.list"
        sudo apt update
        sudo apt install -y code
        rm packages.microsoft.gpg
    '
    gum style --foreground 212 "✓ VS Code installed from official repository"
}

install_vscode_deb() {
    gum spin --spinner globe --title "Installing VS Code..." -- bash -c '
        cd /tmp
        wget -O vscode.deb "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64"
        sudo dpkg -i vscode.deb
        sudo apt install -f -y
        rm -f vscode.deb
    '
    gum style --foreground 212 "✓ VS Code installed via .deb package"
}

install_zed() {
    gum style --foreground 212 "Installing Zed Editor..."

    local method=$(gum choose --header "Choose Zed installation method:" \
        "Pacstall (Recommended)" \
        "Official script")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using official script."
                install_zed_official
            else
                gum spin --spinner globe --title "Installing Zed via Pacstall..." -- \
                    pacstall -IP zed-editor-stable-bin
                gum style --foreground 212 "✓ Zed installed via Pacstall"
            fi
            ;;
        "Official script")
            install_zed_official
            ;;
    esac
}

install_zed_official() {
    gum spin --spinner globe --title "Installing Zed..." -- bash -c '
        curl -f https://zed.dev/install.sh | sh
    '
    gum style --foreground 212 "✓ Zed installed via official script"
}

install_sublime_text() {
    gum style --foreground 212 "Installing Sublime Text..."

    local method=$(gum choose --header "Choose Sublime Text installation method:" \
        "Pacstall (Recommended)" \
        "Official repository")

    case "$method" in
        "Pacstall"*)
            if ! command -v pacstall &> /dev/null; then
                gum style --foreground 196 "✗ Pacstall not found. Using official repository."
                install_sublime_official
            else
                gum spin --spinner globe --title "Installing Sublime Text via Pacstall..." -- \
                    pacstall -IP sublime-text-deb
                gum style --foreground 212 "✓ Sublime Text installed via Pacstall"
            fi
            ;;
        "Official repository")
            install_sublime_official
            ;;
    esac
}

install_sublime_official() {
    gum spin --spinner globe --title "Installing Sublime Text..." -- bash -c '
        wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
        echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
        sudo apt update
        sudo apt install -y sublime-text
    '
    gum style --foreground 212 "✓ Sublime Text installed from official repository"
}

install_vim() {
    gum style --foreground 212 "Installing Vim..."

    if gum spin --spinner globe --title "Installing Vim..." -- \
        sudo apt install -y vim; then
        gum style --foreground 212 "✓ Vim installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Vim"
    fi
}

install_emacs() {
    gum style --foreground 212 "Installing Emacs..."

    local method=$(gum choose --header "Choose Emacs installation method:" \
        "APT (Ubuntu repository)" \
        "Flatpak")

    case "$method" in
        "APT"*)
            gum spin --spinner globe --title "Installing Emacs..." -- \
                sudo apt install -y emacs
            ;;
        "Flatpak")
            source_script "core" "flatpak.sh"
            setup_flatpak || return 1

            gum spin --spinner globe --title "Installing Emacs via Flatpak..." -- \
                flatpak install -y flathub org.gnu.emacs
            ;;
    esac

    gum style --foreground 212 "✓ Emacs installed successfully"
}

install_editors_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Code Editor Installation"

    echo ""

    local editors=$(gum choose --no-limit --header "Select editors to install:" \
        "Neovim" \
        "Visual Studio Code" \
        "Zed Editor" \
        "Sublime Text" \
        "Vim" \
        "Emacs")

    while IFS= read -r selection; do
        case "$selection" in
            "Neovim"*)
                install_neovim
                ;;
            "Visual Studio Code"*)
                install_vscode
                ;;
            "Zed Editor"*)
                install_zed
                ;;
            "Sublime Text"*)
                install_sublime_text
                ;;
            "Vim"*)
                install_vim
                ;;
            "Emacs"*)
                install_emacs
                ;;
        esac
    done <<< "$editors"
}
