#!/usr/bin/env bash

install_nvm() {
    gum style --foreground 212 "Installing nvm (Node Version Manager)..."

    if gum spin --spinner globe --title "Installing nvm..." -- bash -c '
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/latest/install.sh | bash
    '; then
        gum style --foreground 212 "✓ nvm installed successfully"

        local shell_config=""
        case "$SHELL" in
            */bash) shell_config="$HOME/.bashrc" ;;
            */zsh) shell_config="$HOME/.zshrc" ;;
            */fish) shell_config="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
            if ! grep -q "NVM_DIR" "$shell_config"; then
                echo "" >> "$shell_config"
                echo '# NVM Configuration' >> "$shell_config"
                echo 'export NVM_DIR="$HOME/.nvm"' >> "$shell_config"
                echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$shell_config"
                echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$shell_config"
            fi
        fi

        if gum confirm "Install latest LTS Node.js?"; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
            gum style --foreground 212 "✓ Node.js LTS installed"
        fi
    else
        gum style --foreground 196 "✗ Failed to install nvm"
    fi
}

install_pyenv() {
    gum style --foreground 212 "Installing pyenv (Python Version Manager)..."

    gum spin --spinner globe --title "Installing pyenv dependencies..." -- \
        sudo apt install -y make build-essential libssl-dev zlib1g-dev \
        libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
        libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
        libffi-dev liblzma-dev

    if gum spin --spinner globe --title "Installing pyenv..." -- bash -c '
        curl https://pyenv.run | bash
    '; then
        gum style --foreground 212 "✓ pyenv installed successfully"

        local shell_config=""
        case "$SHELL" in
            */bash) shell_config="$HOME/.bashrc" ;;
            */zsh) shell_config="$HOME/.zshrc" ;;
            */fish) shell_config="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
            if ! grep -q "PYENV_ROOT" "$shell_config"; then
                echo "" >> "$shell_config"
                echo '# Pyenv Configuration' >> "$shell_config"
                echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$shell_config"
                echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$shell_config"
                echo 'eval "$(pyenv init -)"' >> "$shell_config"
                echo 'eval "$(pyenv virtualenv-init -)"' >> "$shell_config"
            fi
        fi

        if gum confirm "Install latest stable Python?"; then
            export PYENV_ROOT="$HOME/.pyenv"
            export PATH="$PYENV_ROOT/bin:$PATH"
            eval "$(pyenv init -)"

            local latest_python=$(pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | xargs)
            gum spin --spinner globe --title "Installing Python $latest_python..." -- \
                pyenv install "$latest_python"
            pyenv global "$latest_python"
            gum style --foreground 212 "✓ Python $latest_python installed and set as global"
        fi
    else
        gum style --foreground 196 "✗ Failed to install pyenv"
    fi
}

install_rbenv() {
    gum style --foreground 212 "Installing rbenv (Ruby Version Manager)..."

    if gum spin --spinner globe --title "Installing rbenv..." -- \
        sudo apt install -y rbenv ruby-build; then
        gum style --foreground 212 "✓ rbenv installed successfully"

        local shell_config=""
        case "$SHELL" in
            */bash) shell_config="$HOME/.bashrc" ;;
            */zsh) shell_config="$HOME/.zshrc" ;;
            */fish) shell_config="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
            if ! grep -q "rbenv init" "$shell_config"; then
                echo "" >> "$shell_config"
                echo '# rbenv Configuration' >> "$shell_config"
                echo 'eval "$(rbenv init -)"' >> "$shell_config"
            fi
        fi

        if gum confirm "Install latest stable Ruby?"; then
            eval "$(rbenv init -)"
            local latest_ruby=$(rbenv install -l | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | xargs)
            gum spin --spinner globe --title "Installing Ruby $latest_ruby..." -- \
                rbenv install "$latest_ruby"
            rbenv global "$latest_ruby"
            gum style --foreground 212 "✓ Ruby $latest_ruby installed and set as global"
        fi
    else
        gum style --foreground 196 "✗ Failed to install rbenv"
    fi
}

install_g() {
    gum style --foreground 212 "Installing g (Go Version Manager)..."

    if gum spin --spinner globe --title "Installing g..." -- bash -c '
        curl -sSL https://git.io/g-install | sh -s
    '; then
        gum style --foreground 212 "✓ g installed successfully"

        local shell_config=""
        case "$SHELL" in
            */bash) shell_config="$HOME/.bashrc" ;;
            */zsh) shell_config="$HOME/.zshrc" ;;
            */fish) shell_config="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
            if ! grep -q "GOPATH" "$shell_config"; then
                echo "" >> "$shell_config"
                echo '# Go Configuration' >> "$shell_config"
                echo 'export GOPATH="$HOME/go"' >> "$shell_config"
                echo 'export PATH="$HOME/go/bin:$PATH"' >> "$shell_config"
            fi
        fi

        if gum confirm "Install latest Go version?"; then
            export PATH="$HOME/go/bin:$PATH"
            g install latest
            gum style --foreground 212 "✓ Latest Go version installed"
        fi
    else
        gum style --foreground 196 "✗ Failed to install g"
    fi
}

install_rustup() {
    gum style --foreground 212 "Installing rustup (Rust Version Manager)..."

    if gum spin --spinner globe --title "Installing rustup..." -- bash -c '
        curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    '; then
        gum style --foreground 212 "✓ rustup installed successfully"

        local shell_config=""
        case "$SHELL" in
            */bash) shell_config="$HOME/.bashrc" ;;
            */zsh) shell_config="$HOME/.zshrc" ;;
            */fish) shell_config="$HOME/.config/fish/config.fish" ;;
        esac

        if [ -n "$shell_config" ] && [ -f "$shell_config" ]; then
            if ! grep -q ".cargo/bin" "$shell_config"; then
                echo "" >> "$shell_config"
                echo '# Rust Configuration' >> "$shell_config"
                echo '. "$HOME/.cargo/env"' >> "$shell_config"
            fi
        fi

        source "$HOME/.cargo/env"

        if gum confirm "Install additional Rust components (rust-analyzer, clippy)?"; then
            rustup component add rust-analyzer clippy rustfmt
            gum style --foreground 212 "✓ Additional Rust components installed"
        fi
    else
        gum style --foreground 196 "✗ Failed to install rustup"
    fi
}

install_sdkman() {
    gum style --foreground 212 "Installing SDKMAN (Java/JVM Version Manager)..."

    if gum spin --spinner globe --title "Installing SDKMAN..." -- bash -c '
        curl -s "https://get.sdkman.io" | bash
    '; then
        gum style --foreground 212 "✓ SDKMAN installed successfully"

        source "$HOME/.sdkman/bin/sdkman-init.sh"

        if gum confirm "Install Java (OpenJDK)?"; then
            local java_versions=$(gum choose --no-limit --header "Select Java versions to install:" \
                "Latest LTS (21)" \
                "Previous LTS (17)" \
                "Java 11 LTS" \
                "Latest (22)" \
                "GraalVM")

            while IFS= read -r version; do
                case "$version" in
                    "Latest LTS (21)")
                        sdk install java 21-open
                        ;;
                    "Previous LTS (17)")
                        sdk install java 17-open
                        ;;
                    "Java 11 LTS")
                        sdk install java 11-open
                        ;;
                    "Latest (22)")
                        sdk install java 22-open
                        ;;
                    "GraalVM")
                        sdk install java 21-graal
                        ;;
                esac
            done <<< "$java_versions"
        fi
    else
        gum style --foreground 196 "✗ Failed to install SDKMAN"
    fi
}

install_version_managers_interactive() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Version Manager Installation" \
        "" \
        "Install version managers for" \
        "different programming languages"

    echo ""

    local managers=$(gum choose --no-limit --header "Select version managers to install:" \
        "nvm - Node.js Version Manager" \
        "pyenv - Python Version Manager" \
        "rbenv - Ruby Version Manager" \
        "g - Go Version Manager" \
        "rustup - Rust Version Manager" \
        "SDKMAN - Java/JVM Version Manager")

    while IFS= read -r selection; do
        case "$selection" in
            "nvm"*)
                install_nvm
                ;;
            "pyenv"*)
                install_pyenv
                ;;
            "rbenv"*)
                install_rbenv
                ;;
            "g"*)
                install_g
                ;;
            "rustup"*)
                install_rustup
                ;;
            "SDKMAN"*)
                install_sdkman
                ;;
        esac
    done <<< "$managers"

    echo ""
    gum style --foreground 214 "Note: Please restart your terminal or source your shell config for changes to take effect"
}
