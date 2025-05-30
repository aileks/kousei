#!/usr/bin/env bash

get_shell_config_file() {
    local shell_name
    shell_name=$(basename "$SHELL")
    if [[ "$shell_name" == "zsh" ]]; then
        echo "$HOME/.zshrc"
    elif [[ "$shell_name" == "bash" ]]; then
        if [[ -f "$HOME/.bashrc" ]]; then
            echo "$HOME/.bashrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            echo "$HOME/.bash_profile"
        elif [[ -f "$HOME/.profile" ]]; then
            echo "$HOME/.profile"
        else
            echo "$HOME/.bashrc"
        fi
    else
        echo "$HOME/.profile"
    fi
}


install_essential_build_tools() {
    local ESSENTIAL_TOOLS=(
        "build-essential"
        "cmake"
        "pkg-config"
        "autoconf"
        "automake"
        "libtool"
        "m4"
        "ninja-build"
        "meson"
        "bison"
        "flex"
        "gettext"
        "curl"
        "git"
    )

    refresh_sudo 
    gum style --foreground 212 "Installing essential build tools..."

    if gum spin --spinner globe --title "Installing essential build tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${ESSENTIAL_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Essential build tools installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install essential build tools"
    fi
}

install_debugging_tools() {
    local DEBUG_TOOLS=(
        "gdb"
        "valgrind"
        "strace"
        "ltrace"
        "lsof"
        "tcpdump"
        "gdbserver"
    )

    gum style --foreground 212 "Installing debugging tools..."

    if gum spin --spinner globe --title "Installing debugging tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${DEBUG_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Debugging tools installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install debugging tools"
    fi
}

install_version_control_tools() {
    local AVAILABLE_VCS_TOOLS=(
        "git"
        "git-lfs"
        "subversion"
        "mercurial"
        "git-flow"
        "tig"
    )

    gum style --foreground 212 "Version Control Tools Installation"
    refresh_sudo

    local selected_tools=$(gum choose --no-limit --header "Select Version Control tools to install (use space to select, enter to confirm):" "${AVAILABLE_VCS_TOOLS[@]}")

    if [[ -z "$selected_tools" ]]; then
        gum style --foreground 214 "No Version Control tools selected. Skipping."
        return
    fi

    local SELECTED_TOOLS=()
    while IFS= read -r tool; do
        SELECTED_TOOLS+=("$tool")
    done <<< "$selected_tools"

    if [ ${#SELECTED_TOOLS[@]} -eq 0 ]; then
        gum style --foreground 214 "No Version Control tools selected. Skipping."
        return
    fi

    gum style --foreground 212 "Installing selected Version Control tools: ${SELECTED_TOOLS[*]}"
    if gum spin --spinner globe --title "Installing Version Control tools: ${SELECTED_TOOLS[*]}" -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${SELECTED_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Selected Version Control tools installed successfully."

        local git_lfs_was_selected=false
        for tool_item in "${SELECTED_TOOLS[@]}"; do
            if [[ "$tool_item" == "git-lfs" ]]; then
                git_lfs_was_selected=true
                break
            fi
        done

        if $git_lfs_was_selected; then
            if command -v git-lfs &> /dev/null; then
                if gum confirm "Git LFS was installed. Configure it system-wide (sudo git lfs install --system)?"; then
                    if sudo git lfs install --system; then
                        gum style --foreground 212 "✓ Git LFS configured system-wide."
                    else
                        gum style --foreground 196 "✗ Failed to configure Git LFS system-wide."
                    fi
                else
                    gum style --foreground 214 "Git LFS system-wide configuration skipped."
                fi
            else
                gum style --foreground 196 "✗ git-lfs was selected, but command not found after install. System config skipped."
            fi
        fi
    else
        gum style --foreground 196 "✗ Failed to install some/all selected Version Control tools."
    fi
}

install_container_tools() {
    gum style --foreground 212 "Installing container development tools..."
    refresh_sudo

    local choice=$(gum choose --header "Select container tools to install:" \
        "Docker" \
        "Podman" \
        "Both" \
        "None")

    case "$choice" in
        "Docker"|"Both")
            install_docker
            ;;& 
        "Podman"|"Both")
            install_podman
            ;;
        "None")
            gum style --foreground 214 "Container tools installation skipped."
            ;;
        *) 
            gum style --foreground 214 "No container tool selection made. Skipping."
            ;;
    esac
}

install_docker() {
    gum style --foreground 212 "Installing Docker..."
    refresh_sudo

    if gum spin --spinner globe --title "Installing Docker..." -- bash -c '
        sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true
        sudo apt update -y 
        sudo apt install -y ca-certificates curl gnupg lsb-release
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt update -y 
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    '; then
        gum style --foreground 212 "✓ Docker installed successfully"
        if gum confirm "Add current user ($USER) to docker group? (Requires log out/log in)"; then
            if sudo usermod -aG docker "$USER"; then
                gum style --foreground 212 "✓ User $USER added to docker group."
                gum style --foreground 214 "Note: Log out and back in for changes to take effect."
            else
                gum style --foreground 196 "✗ Failed to add user $USER to docker group."
            fi
        fi
    else
        gum style --foreground 196 "✗ Failed to install Docker."
    fi
}

install_podman() {
    gum style --foreground 212 "Installing Podman..."
    refresh_sudo

    if gum spin --spinner globe --title "Installing Podman..." -- bash -c '
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y podman podman-compose
    '; then
        gum style --foreground 212 "✓ Podman installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Podman"
    fi
}

install_package_building_tools() {
    local PACKAGE_TOOLS=(
        "dpkg-dev" "debhelper" "devscripts" "equivs" "dh-make" "lintian"
        "pbuilder" "sbuild" "apt-file" "alien" "fakeroot" "checkinstall"
    )
    gum style --foreground 212 "Installing package building tools..."
    refresh_sudo

    if gum spin --spinner globe --title "Installing package building tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${PACKAGE_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Package building tools installed successfully"
        if gum confirm "Update apt-file database now? (Can take some time)"; then
            if sudo apt-file update; then gum style --foreground 212 "✓ apt-file database updated."; else gum style --foreground 196 "✗ Failed to update apt-file database."; fi
        fi
    else
        gum style --foreground 196 "✗ Failed to install package building tools"
    fi
}

install_language_specific_tools() {
    gum style --foreground 212 "Installing language-specific build tools..."
    local languages_str=$(gum choose --no-limit --header "Select language-specific tool categories:" \
        "C/C++ Tools" "Python Development" "Ruby Development" "Java Development" \
        "Node.js Development" "Go Development" "Rust Development")

    if [[ -z "$languages_str" ]]; then gum style --foreground 214 "No language categories selected. Skipping."; return; fi

    while IFS= read -r selection; do
        case "$selection" in
            "C/C++ Tools") install_cpp_tools ;;
            "Python Development") install_python_dev_tools ;;
            "Ruby Development") install_ruby_dev_tools ;;
            "Java Development") install_java_dev_tools ;;
            "Node.js Development") install_nodejs_dev_tools ;;
            "Go Development") install_go_dev_tools ;;
            "Rust Development") install_rust_dev_tools ;;
        esac
    done <<< "$languages_str"
}

install_cpp_tools() {
    local AVAILABLE_CPP_TOOLS=(
        "g++" "gcc" "clang" "clangd" "clang-tools" "clang-format" "clang-tidy"
        "llvm" "lldb" "ccache" "cppcheck"
    )
    gum style --foreground 212 "C/C++ Tools Installation"
    local selected_tools=$(gum choose --no-limit --header "Select C/C++ tools (apt):" "${AVAILABLE_CPP_TOOLS[@]}")
    if [[ -z "$selected_tools" ]]; then gum style --foreground 214 "No C/C++ apt tools selected."; else
        local SELECTED_TOOLS=(); while IFS= read -r tool; do SELECTED_TOOLS+=("$tool"); done <<< "$selected_tools"
        if [ ${#SELECTED_TOOLS[@]} -gt 0 ]; then
            gum style --foreground 212 "Installing C/C++ tools: ${SELECTED_TOOLS[*]}"
            if gum spin --spinner globe --title "Installing C/C++ tools..." -- bash -c "
                export DEBIAN_FRONTEND=noninteractive; sudo apt update -y; sudo apt install -y ${SELECTED_TOOLS[*]}"; then
                gum style --foreground 212 "✓ Selected C/C++ apt tools installed."
            else gum style --foreground 196 "✗ Failed to install C/C++ apt tools."; fi
        fi
    fi
    if command -v pip &> /dev/null || command -v pip3 &> /dev/null; then
        if gum confirm "Install cpplint (C++ linter) using pip/pip3?"; then
            local pip_cmd=$(command -v pip3 || command -v pip)
            if gum spin --spinner globe --title "Installing cpplint (pip)..." -- "$pip_cmd" install cpplint; then
                gum style --foreground 212 "✓ cpplint installed via $pip_cmd."
            else gum style --foreground 196 "✗ Failed to install cpplint via $pip_cmd."; fi
        fi
    fi
}

install_python_dev_tools() {
    gum style --foreground 212 "Python Development Environment Setup (pyenv)"
    local SHELL_CONFIG_FILE
    SHELL_CONFIG_FILE=$(get_shell_config_file)

    # Prerequisites for pyenv and building Python versions
    local PYENV_PREREQUISITES=(
        "git" "curl" "build-essential" "libssl-dev" "zlib1g-dev" "libbz2-dev"
        "libreadline-dev" "libsqlite3-dev" "llvm" "libncurses5-dev" "libncursesw5-dev"
        "xz-utils" "tk-dev" "libffi-dev" "liblzma-dev" "python3-openssl" # python3-openssl might be specific
    )

    gum style --foreground 212 "Checking/Installing prerequisites for pyenv..."

    if gum spin --spinner globe --title "Installing pyenv prerequisites..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive; sudo apt update -y; sudo apt install -y ${PYENV_PREREQUISITES[*]}"; then
        gum style --foreground 212 "✓ pyenv prerequisites installed."
    else
        gum style --foreground 196 "✗ Failed to install pyenv prerequisites. pyenv installation might fail."
    fi

    if ! command -v pyenv &> /dev/null; then
        if gum confirm "pyenv not found. Install pyenv?"; then
            gum style --foreground 212 "Installing pyenv..."
            if curl https://pyenv.run | bash; then
                gum style --foreground 212 "✓ pyenv installed."
                # Add pyenv to PATH for current session and shell config
                export PYENV_ROOT="$HOME/.pyenv"
                export PATH="$PYENV_ROOT/bin:$PATH"

                if ! grep -q 'PYENV_ROOT' "$SHELL_CONFIG_FILE"; then
                    gum style --foreground 212 "Adding pyenv to $SHELL_CONFIG_FILE..."
                    echo '' >> "$SHELL_CONFIG_FILE"
                    echo '# pyenv configuration' >> "$SHELL_CONFIG_FILE"
                    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$SHELL_CONFIG_FILE"
                    echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> "$SHELL_CONFIG_FILE"
                    echo 'eval "$(pyenv init -)"' >> "$SHELL_CONFIG_FILE"
                fi

                eval "$(pyenv init -)" # Initialize for current script session

                gum style --foreground 214 "pyenv configured. Please run 'exec \"\$SHELL\"' or restart your terminal after this script finishes."
            else
                gum style --foreground 196 "✗ Failed to install pyenv. Aborting Python setup."
                return 1
            fi
        else
            gum style --foreground 214 "pyenv installation skipped. Cannot manage Python versions."
            return 1
        fi
    else
        gum style --foreground 212 "pyenv is already installed."
        # Ensure pyenv is initialized for the current script session
        export PYENV_ROOT="$HOME/.pyenv"

        if [[ -d "$PYENV_ROOT/bin" && ":$PATH:" != *":$PYENV_ROOT/bin:"* ]]; then
             export PATH="$PYENV_ROOT/bin:$PATH" 
        fi

        eval "$(pyenv init -)"
    fi

    local python_versions_to_install
    python_versions_to_install=$(gum input --placeholder "Enter Python versions to install (e.g., 3.13.1 3.11 3.10.9), leave blank to skip:")

    if [[ -n "$python_versions_to_install" ]]; then
        local versions_array=($python_versions_to_install)

        for version in "${versions_array[@]}"; do
            gum style --foreground 212 "Installing Python $version with pyenv..."
            if gum spin --spinner globe --title "pyenv install $version" -- pyenv install "$version"; then
                gum style --foreground 212 "✓ Python $version installed."
            else
                gum style --foreground 196 "✗ Failed to install Python $version."
            fi
        done
    fi

    local installed_py_versions
    installed_py_versions=$(pyenv versions --bare)
    if [[ -n "$installed_py_versions" ]]; then
        local global_py_version
        global_py_version=$(echo "$installed_py_versions" | gum choose --header "Select a global Python version (optional):")
        if [[ -n "$global_py_version" ]]; then
            if pyenv global "$global_py_version"; then
                gum style --foreground 212 "✓ Global Python version set to $global_py_version."
            else
                gum style --foreground 196 "✗ Failed to set global Python version."
            fi
        fi
    else
        gum style --foreground 214 "No Python versions managed by pyenv found to set as global."
    fi

    local PYTHON_PIPX_TOOLS=("pipx" "poetry" "black" "ruff" "mypy" "pre-commit") # Add pipx itself to ensure it's there
    gum style --foreground 212 "Python CLI Tools (pipx)"

    # Ensure pipx is installed (via active Python's pip)
    if ! command -v pipx &> /dev/null; then
        if gum confirm "pipx not found. Install pipx using pip?"; then
            if python3 -m pip install --user pipx; then
                 gum style --foreground 212 "✓ pipx installed via pip."
                 python3 -m pipx ensurepath
                 gum style --foreground 214 "pipx PATH configured. You might need to restart your shell or source config."
            else
                 gum style --foreground 196 "✗ Failed to install pipx via pip."
            fi
        fi
    fi

    if command -v pipx &> /dev/null; then
        local selected_pipx_tools_str
        selected_pipx_tools_str=$(gum choose --no-limit --header "Select Python tools to install via pipx:" "${PYTHON_PIPX_TOOLS[@]}")

        if [[ -n "$selected_pipx_tools_str" ]]; then
            local SELECTED_PIPX_TOOLS=()

            while IFS= read -r tool; do SELECTED_PIPX_TOOLS+=("$tool"); done <<< "$selected_pipx_tools_str"

            if [ ${#SELECTED_PIPX_TOOLS[@]} -gt 0 ]; then
                for tool in "${SELECTED_PIPX_TOOLS[@]}"; do
                    if [[ "$tool" == "pipx" && $(command -v pipx) ]]; then # Skip pipx if already installed
                        gum style --foreground 214 "pipx is already installed."
                        continue
                    fi

                    if gum spin --spinner globe --title "pipx install $tool" -- pipx install "$tool"; then
                        gum style --foreground 212 "✓ $tool installed via pipx."
                    else
                        gum style --foreground 196 "✗ Failed to install $tool via pipx."
                    fi
                done
            fi
        fi
    else
        gum style --foreground 196 "pipx command not found. Skipping pipx tools."
    fi

    gum style --foreground 212 "✓ Python development tools setup finished."
}

install_ruby_dev_tools() {
    gum style --foreground 212 "Ruby Development Environment Setup (rbenv)"
    local SHELL_CONFIG_FILE

    SHELL_CONFIG_FILE=$(get_shell_config_file)

    local RBENV_PREREQUISITES=(
        "git" "curl" "autoconf" "bison" "build-essential" "libssl-dev" "libyaml-dev"
        "libreadline6-dev" "zlib1g-dev" "libncurses5-dev" "libffi-dev" "libgdbm-dev" "libdb-dev" # or libgdbm6-dev, libdb5.3-dev
    )

    gum style --foreground 212 "Checking/Installing prerequisites for rbenv..."

    if gum spin --spinner globe --title "Installing rbenv prerequisites..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive; sudo apt update -y; sudo apt install -y ${RBENV_PREREQUISITES[*]}"; then
        gum style --foreground 212 "✓ rbenv prerequisites installed."
    else
        gum style --foreground 196 "✗ Failed to install rbenv prerequisites. rbenv installation might fail."
    fi

    if ! command -v rbenv &> /dev/null; then
        if gum confirm "rbenv not found. Install rbenv and ruby-build?"; then
            gum style --foreground 212 "Installing rbenv..."
            if git clone https://github.com/rbenv/rbenv.git ~/.rbenv; then
                gum style --foreground 212 "✓ rbenv cloned."
                export PATH="$HOME/.rbenv/bin:$PATH" # Add to current session PATH
                if ! grep -q '$HOME/.rbenv/bin' "$SHELL_CONFIG_FILE"; then
                    gum style --foreground 212 "Adding rbenv to $SHELL_CONFIG_FILE..."
                    echo '' >> "$SHELL_CONFIG_FILE"
                    echo '# rbenv configuration' >> "$SHELL_CONFIG_FILE"
                    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> "$SHELL_CONFIG_FILE"
                    echo 'eval "$(rbenv init -)"' >> "$SHELL_CONFIG_FILE"
                fi

                eval "$(rbenv init -)" # Initialize for current script session

                gum style --foreground 212 "Installing ruby-build (rbenv plugin)..."
                mkdir -p "$(rbenv root)"/plugins

                if git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build; then
                    gum style --foreground 212 "✓ ruby-build installed."
                else
                    gum style --foreground 196 "✗ Failed to install ruby-build."
                fi

                gum style --foreground 214 "rbenv & ruby-build configured. Please run 'exec \"\$SHELL\"' or restart terminal after script."
            else
                gum style --foreground 196 "✗ Failed to clone rbenv. Aborting Ruby setup."
                return 1
            fi
        else
            gum style --foreground 214 "rbenv installation skipped. Cannot manage Ruby versions."
            return 1
        fi
    else
        gum style --foreground 212 "rbenv is already installed."

        # Ensure rbenv is initialized for the current script session
        if [[ -d "$HOME/.rbenv/bin" && ":$PATH:" != *":$HOME/.rbenv/bin:"* ]]; then
            export PATH="$HOME/.rbenv/bin:$PATH"
        fi

        eval "$(rbenv init -)"
    fi

    local ruby_versions_to_install_str
    ruby_versions_to_install_str=$(gum input --placeholder "Enter Ruby versions to install (e.g., 3.1.2 2.7.6), blank to skip:")

    if [[ -n "$ruby_versions_to_install_str" ]]; then
        local versions_array=($ruby_versions_to_install_str)
        for version in "${versions_array[@]}"; do
            gum style --foreground 212 "Installing Ruby $version with rbenv..."
            if gum spin --spinner globe --title "rbenv install $version" -- rbenv install "$version"; then
                gum style --foreground 212 "✓ Ruby $version installed."
            else
                gum style --foreground 196 "✗ Failed to install Ruby $version."
            fi
        done
    fi

    local installed_rb_versions
    installed_rb_versions=$(rbenv versions --bare)

    if [[ -n "$installed_rb_versions" ]]; then
        local global_rb_version
        global_rb_version=$(echo "$installed_rb_versions" | gum choose --header "Select a global Ruby version (optional):")
        if [[ -n "$global_rb_version" ]]; then
            if rbenv global "$global_rb_version"; then
                gum style --foreground 212 "✓ Global Ruby version set to $global_rb_version."
                # Install bundler for the new global ruby if not present
                if ! rbenv exec gem query --name-matches '^bundler$' --installed > /dev/null; then
                    gum style --foreground 212 "Installing bundler for Ruby $global_rb_version..."
                    if rbenv exec gem install bundler; then
                        gum style --foreground 212 "✓ bundler installed for current Ruby."
                        rbenv rehash
                    else
                        gum style --foreground 196 "✗ Failed to install bundler for current Ruby."
                    fi
                fi
            else
                gum style --foreground 196 "✗ Failed to set global Ruby version."
            fi
        fi
    else
        gum style --foreground 214 "No Ruby versions managed by rbenv found to set as global."
    fi

    # Gems installation
    if command -v gem &> /dev/null && command -v ruby &> /dev/null; then # Check if a ruby version is active
        local RUBY_GEMS=("bundler" "rubocop" "solargraph") # Bundler added here to ensure it's offered if not auto-installed
        local selected_gems_str
        selected_gems_str=$(gum choose --no-limit --header "Select Ruby gems to install:" "${RUBY_GEMS[@]}")

        if [[ -n "$selected_gems_str" ]]; then
            local SELECTED_GEMS=()
            while IFS= read -r gem_name; do SELECTED_GEMS+=("$gem_name"); done <<< "$selected_gems_str"
            if [ ${#SELECTED_GEMS[@]} -gt 0 ]; then
                for gem_name in "${SELECTED_GEMS[@]}"; do
                    # Check if gem is already installed for the current ruby
                    if rbenv exec gem query --name-matches "^${gem_name}$" --installed > /dev/null; then
                         gum style --foreground 214 "Gem '$gem_name' is already installed for current Ruby. Skipping."
                         continue
                    fi

                    gum style --foreground 212 "Installing gem: $gem_name..."

                    if gum spin --spinner globe --title "gem install $gem_name" -- rbenv exec gem install "$gem_name"; then
                        gum style --foreground 212 "✓ Gem $gem_name installed."
                    else
                        gum style --foreground 196 "✗ Failed to install gem $gem_name."
                    fi
                done
                rbenv rehash # Rehash shims after installing gems with executables
            fi
        fi
    else
        gum style --foreground 196 "Ruby/gem command not found. Skipping gem installations. (Is a Ruby version set via rbenv?)"
    fi
    gum style --foreground 212 "✓ Ruby development tools setup finished."
}

install_java_dev_tools() {
    local JAVA_TOOLS=( "default-jdk" "maven" "gradle" "ant" )
    gum style --foreground 212 "Java Development Tools Installation"

    local selected_tools=$(gum choose --no-limit --header "Select Java tools to install:" "${JAVA_TOOLS[@]}")
    if [[ -z "$selected_tools" ]]; then gum style --foreground 214 "No Java tools selected. Skipping."; return; fi

    local SELECTED_JAVA_TOOLS=(); while IFS= read -r tool; do SELECTED_JAVA_TOOLS+=("$tool"); done <<< "$selected_tools"
    if [ ${#SELECTED_JAVA_TOOLS[@]} -eq 0 ]; then gum style --foreground 214 "No Java tools selected. Skipping."; return; fi

    gum style --foreground 212 "Installing selected Java tools: ${SELECTED_JAVA_TOOLS[*]}"

    if gum spin --spinner globe --title "Installing Java tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive; sudo apt update -y; sudo apt install -y ${SELECTED_JAVA_TOOLS[*]}"; then
        gum style --foreground 212 "✓ Selected Java development tools installed."
    else gum style --foreground 196 "✗ Failed to install selected Java development tools."; fi
}

install_nodejs_dev_tools() {
    if ! command -v npm &> /dev/null; then
        gum style --foreground 196 "npm (Node Package Manager) not found."
        if gum confirm "Attempt to install Node.js (LTS) and npm via NodeSource?"; then
            if gum spin --spinner globe --title "Installing Node.js LTS and npm..." -- bash -c '
                curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash - && sudo apt-get install -y nodejs'; then
                gum style --foreground 212 "✓ Node.js LTS and npm installed via NodeSource."
            else gum style --foreground 196 "✗ Failed to install Node.js. Please install manually."; return 1; fi
        else return 1; fi
    fi

    gum style --foreground 212 "Node.js Global Development Tools Installation (npm)"

    local NODE_GLOBAL_TOOLS=( "typescript" "eslint" "prettier" "nodemon" "pm2" "yarn" "pnpm" )
    local selected_tools=$(gum choose --no-limit --header "Select global Node.js tools (npm install -g):" "${NODE_GLOBAL_TOOLS[@]}")

    if [[ -z "$selected_tools" ]]; then gum style --foreground 214 "No global Node.js tools selected."; else
        local SELECTED_NODE_TOOLS=(); while IFS= read -r tool; do SELECTED_NODE_TOOLS+=("$tool"); done <<< "$selected_tools"
        if [ ${#SELECTED_NODE_TOOLS[@]} -gt 0 ]; then
            for tool in "${SELECTED_NODE_TOOLS[@]}"; do
                if gum spin --spinner globe --title "npm install -g $tool" -- npm install -g "$tool"; then
                    gum style --foreground 212 "✓ $tool installed globally."
                else
                    gum style --foreground 196 "✗ Failed to install $tool globally (npm)."
                    if gum confirm "Attempt to install $tool globally using sudo npm?"; then
                        if gum spin --spinner globe --title "sudo npm install -g $tool" -- sudo npm install -g "$tool"; then
                             gum style --foreground 212 "✓ $tool installed globally (sudo npm)."
                        else gum style --foreground 196 "✗ Failed to install $tool globally (sudo npm)."; fi
                    fi
                fi
            done
        fi
    fi

    if command -v corepack &> /dev/null && gum confirm "Enable corepack (for yarn/pnpm management)?"; then
        if sudo corepack enable; then gum style --foreground 212 "✓ Corepack enabled."; else gum style --foreground 196 "✗ Failed to enable corepack."; fi
    fi

    gum style --foreground 212 "✓ Node.js global tools setup finished."
}

install_go_dev_tools() {
    if ! command -v go &> /dev/null; then
        gum style --foreground 196 "Go compiler (go) not found."

        if gum confirm "Attempt to install Go using apt (might be older)?"; then
            if gum spin --spinner globe --title "Installing golang-go (apt)..." -- sudo apt install -y golang-go; then
                gum style --foreground 212 "✓ golang-go installed. Consider newer version from golang.org."
            else gum style --foreground 196 "✗ Failed to install golang-go. Please install Go manually."; return 1; fi
        else return 1; fi
    fi

    if [[ -z "$GOBIN" ]]; then export GOBIN="$HOME/go/bin"; gum style --foreground 214 "GOBIN set to $GOBIN."; fi

    if [[ ":$PATH:" != *":$GOBIN:"* ]]; then gum style --foreground 214 "$GOBIN not in PATH. Add 'export PATH=\$PATH:\$GOBIN' to shell profile."; fi

    mkdir -p "$GOBIN"
    gum style --foreground 212 "Go Development Tools Installation (go install)"

    local GO_TOOLS=(
        "golang.org/x/tools/gopls@latest" "github.com/go-delve/delve/cmd/dlv@latest"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest" "golang.org/x/tools/cmd/goimports@latest"
        "mvdan.cc/gofumpt@latest"
    )

    local selected_tools=$(gum choose --no-limit --header "Select Go tools (go install):" "${GO_TOOLS[@]}")

    if [[ -z "$selected_tools" ]]; then gum style --foreground 214 "No Go tools selected."; else
        local SELECTED_GO_TOOLS=(); while IFS= read -r tool; do SELECTED_GO_TOOLS+=("$tool"); done <<< "$selected_tools"
        if [ ${#SELECTED_GO_TOOLS[@]} -gt 0 ]; then
            for tool_path in "${SELECTED_GO_TOOLS[@]}"; do
                if gum spin --spinner globe --title "go install $tool_path" -- go install "$tool_path"; then
                    gum style --foreground 212 "✓ $tool_path installed."
                else gum style --foreground 196 "✗ Failed to install $tool_path."; fi
            done
        fi
    fi

    gum style --foreground 212 "✓ Go development tools setup finished."
}

install_rust_dev_tools() {
    if ! command -v cargo &> /dev/null; then
        gum style --foreground 196 "Cargo (Rust pkg manager) not found."

        if gum confirm "Install Rust via rustup now?"; then
            if gum spin --spinner globe --title "Installing rustup..." -- bash -c 'curl --proto "=https" --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path'; then
                # Source cargo env for current script
                # shellcheck source=/dev/null
                source "$HOME/.cargo/env"

                # Add to shell config if not already present
                local SHELL_CONFIG_FILE; SHELL_CONFIG_FILE=$(get_shell_config_file)

                if ! grep -q "$HOME/.cargo/env" "$SHELL_CONFIG_FILE"; then
                    echo "source \"\$HOME/.cargo/env\"" >> "$SHELL_CONFIG_FILE"
                fi

                gum style --foreground 212 "✓ Rustup installed. Sourced \$HOME/.cargo/env for current session."

                gum style --foreground 214 "Please restart terminal or run 'source \$HOME/.cargo/env' after script."
            else gum style --foreground 196 "✗ Failed to install rustup. Install manually from rustup.rs."; return 1; fi
        else return 1; fi
    fi
    if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
         # shellcheck source=/dev/null
         source "$HOME/.cargo/env" 

         if [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
            gum style --foreground 214 "\$HOME/.cargo/bin not in PATH. Ensure rustup configured shell or add manually."
         fi
    fi
    gum style --foreground 212 "Additional Rust Tools (cargo install)"
    local RUST_CARGO_TOOLS=(
        "cargo-watch" "cargo-edit" "cargo-outdated" "cargo-audit" "cargo-expand"
        "sccache" "flamegraph" "cargo-bloat"
    )

    local selected_tools=$(gum choose --no-limit --header "Select Rust tools (cargo install):" "${RUST_CARGO_TOOLS[@]}")

    if [[ -z "$selected_tools" ]]; then gum style --foreground 214 "No additional Rust tools selected."; else
        local SELECTED_RUST_TOOLS=(); while IFS= read -r tool; do SELECTED_RUST_TOOLS+=("$tool"); done <<< "$selected_tools"
        if [ ${#SELECTED_RUST_TOOLS[@]} -gt 0 ]; then
            for tool_name in "${SELECTED_RUST_TOOLS[@]}"; do
                if gum spin --spinner globe --title "cargo install $tool_name" -- cargo install "$tool_name"; then
                    gum style --foreground 212 "✓ $tool_name installed."
                else gum style --foreground 196 "✗ Failed to install $tool_name."; fi
            done
        fi
    fi

    gum style --foreground 212 "✓ Rust additional tools setup finished."
}

install_build_tools() {
    print_header

    gum style --foreground 212 --border-foreground 212 --border rounded \
        --align center --width 50 --margin "1 2" --padding "2 4" \
        "Build Tools Installation Menu"
    echo ""

    local main_categories_str=$(gum choose --no-limit --header "Select categories to install/configure:" \
        "Essential System Build Tools" "Debugging Tools" "Version Control Tools" \
        "Container Tools" "Package Building Tools" "Language-Specific Tools" \
        "---" "Install ALL from above (prompts for sub-choices)")

    if [[ -z "$main_categories_str" ]]; then gum style --foreground 214 "No categories selected. Exiting."; return; fi

    local install_all=false
    echo "$main_categories_str" | grep -q "Install ALL" && install_all=true

    if $install_all; then
        gum style --foreground 212 "Attempting to install ALL tool categories..."
        install_essential_build_tools; install_debugging_tools; install_version_control_tools
        install_container_tools; install_package_building_tools; install_language_specific_tools
    else
        while IFS= read -r selection; do
            case "$selection" in
                "Essential System Build Tools"*) install_essential_build_tools ;;
                "Debugging Tools"*) install_debugging_tools ;;
                "Version Control Tools"*) install_version_control_tools ;;
                "Container Tools"*) install_container_tools ;;
                "Package Building Tools"*) install_package_building_tools ;;
                "Language-Specific Tools"*) install_language_specific_tools ;;
                "---") ;; 
            esac
        done <<< "$main_categories_str"
    fi
    echo ""; gum style --foreground 212 "✓ Build tools installation process completed."
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    if ! command -v gum &> /dev/null; then
        echo "Error: 'gum' not installed. This script requires gum." >&2

        echo "Install from: https://github.com/charmbracelet/gum" >&2
        read -r -p "Attempt to install gum (requires sudo)? [y/N] " response

        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            echo "Installing gum..."
            if sudo mkdir -p /etc/apt/keyrings && \
               curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg && \

               echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list && \

               sudo apt update && sudo apt install -y gum; then
                echo "'gum' installed. Please re-run script."
                exit 0
            else echo "Failed to install 'gum'. Install manually."; exit 1; fi
        else echo "Please install 'gum' and try again."; exit 1; fi
    fi

    refresh_sudo() {
      gum log --level info "Checking sudo status..."

      if sudo -n true 2>/dev/null; then
        gum log --level info "Sudo privileges active."
        sudo -v 
      else
        gum log --level warn "Sudo privileges not active or require password."
        gum confirm "Script needs sudo access. Authenticate now?" && sudo -v
        if [ $? -ne 0 ]; then gum log --level error "Sudo auth failed/cancelled. Exiting."; exit 1; fi
      fi
    }

    print_header() {
      gum style --padding "1 5" --border double --border-foreground 57 \
        "🚀 Development Environment Setup Script 🚀"; echo
    }

    refresh_sudo

    case "${1:-}" in
        "essential") install_essential_build_tools ;;
        "debug") install_debugging_tools ;;
        "vcs") install_version_control_tools ;;
        "containers") install_container_tools ;;
        "package") install_package_building_tools ;;
        "languages") install_language_specific_tools ;;
        "python") install_python_dev_tools ;;
        "ruby") install_ruby_dev_tools ;;
        "cpp") install_cpp_tools ;;
        *) 
            if command -v print_header &> /dev/null; then print_header; fi
            install_build_tools ;;
    esac
fi

