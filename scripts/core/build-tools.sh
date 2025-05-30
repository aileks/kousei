#!/usr/bin/env bash

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
    local VCS_TOOLS=(
        "git"
        "git-lfs"
        "subversion"
        "mercurial"
        "git-flow"
        "tig"
    )

    gum style --foreground 212 "Installing version control tools..."

    if gum spin --spinner globe --title "Installing version control tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${VCS_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Version control tools installed successfully"

        if command -v git-lfs &> /dev/null; then
            git lfs install --system
            gum style --foreground 212 "✓ Git LFS configured"
        fi
    else
        gum style --foreground 196 "✗ Failed to install version control tools"
    fi
}

install_container_tools() {
    gum style --foreground 212 "Installing container development tools..."

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
    esac
}

install_docker() {
    gum style --foreground 212 "Installing Docker..."

    if gum spin --spinner globe --title "Installing Docker..." -- bash -c '
        # Remove old versions
        sudo apt remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

        # Install prerequisites
        sudo apt update
        sudo apt install -y ca-certificates curl gnupg lsb-release

        # Add Docker GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Add Docker repository
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    '; then
        gum style --foreground 212 "✓ Docker installed successfully"

        if gum confirm "Add current user to docker group?"; then
            sudo usermod -aG docker $USER
            gum style --foreground 212 "✓ User added to docker group"
            gum style --foreground 214 "Note: Log out and back in for group changes to take effect"
        fi
    else
        gum style --foreground 196 "✗ Failed to install Docker"
    fi
}

install_podman() {
    gum style --foreground 212 "Installing Podman..."

    if gum spin --spinner globe --title "Installing Podman..." -- bash -c '
        sudo apt update
        sudo apt install -y podman podman-compose
    '; then
        gum style --foreground 212 "✓ Podman installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install Podman"
    fi
}

install_package_building_tools() {
    local PACKAGE_TOOLS=(
        "dpkg-dev"
        "debhelper"
        "devscripts"
        "equivs"
        "dh-make"
        "lintian"
        "pbuilder"
        "sbuild"
        "apt-file"
        "alien"
        "fakeroot"
        "checkinstall"
    )

    gum style --foreground 212 "Installing package building tools..."

    if gum spin --spinner globe --title "Installing package building tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${PACKAGE_TOOLS[*]}
    "; then
        gum style --foreground 212 "✓ Package building tools installed successfully"
    else
        gum style --foreground 196 "✗ Failed to install package building tools"
    fi
}

install_language_specific_tools() {
    gum style --foreground 212 "Installing language-specific build tools..."

    local languages=$(gum choose --no-limit --header "Select language-specific tools to install:" \
        "C/C++ Tools" \
        "Python Development" \
        "Ruby Development" \
        "Java Development" \
        "Node.js Development" \
        "Go Development" \
        "Rust Development")

    while IFS= read -r selection; do
        case "$selection" in
            "C/C++ Tools")
                install_cpp_tools
                ;;
            "Python Development")
                install_python_dev_tools
                ;;
            "Ruby Development")
                install_ruby_dev_tools
                ;;
            "Java Development")
                install_java_dev_tools
                ;;
            "Node.js Development")
                install_nodejs_dev_tools
                ;;
            "Go Development")
                install_go_dev_tools
                ;;
            "Rust Development")
                install_rust_dev_tools
                ;;
        esac
    done <<< "$languages"
}

install_cpp_tools() {
    local CPP_TOOLS=(
        "g++"
        "gcc"
        "clang"
        "clang-tools"
        "clang-format"
        "clang-tidy"
        "llvm"
        "lldb"
        "ccache"
        "cppcheck"
        "cpplint"
    )

    gum spin --spinner globe --title "Installing C/C++ tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${CPP_TOOLS[*]}
    "
    gum style --foreground 212 "✓ C/C++ tools installed"
}

install_python_dev_tools() {
    local PYTHON_TOOLS=(
        "python3-dev"
        "python3-pip"
        "python3-setuptools"
        "python3-wheel"
        "python3-venv"
        "python3-virtualenv"
        "pipx"
    )

    gum spin --spinner globe --title "Installing Python development tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${PYTHON_TOOLS[*]}
    "

    if command -v pipx &> /dev/null && gum confirm "Install Python development tools via pipx (poetry, black, mypy)?"; then
        pipx ensurepath
        gum spin --spinner globe --title "Installing Python tools via pipx..." -- bash -c "
            pipx install poetry
            pipx install black
            pipx install mypy
            pipx install ruff
            pipx install pre-commit
        "
    fi

    gum style --foreground 212 "✓ Python development tools installed"
}

install_ruby_dev_tools() {
    local RUBY_TOOLS=(
        "ruby-full"
        "ruby-dev"
        "rubygems"
        "bundler"
    )

    gum spin --spinner globe --title "Installing Ruby development tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${RUBY_TOOLS[*]}
    "
    gum style --foreground 212 "✓ Ruby development tools installed"
}

install_java_dev_tools() {
    local JAVA_TOOLS=(
        "default-jdk"
        "maven"
        "gradle"
        "ant"
    )

    gum spin --spinner globe --title "Installing Java development tools..." -- bash -c "
        export DEBIAN_FRONTEND=noninteractive
        sudo apt update -y
        sudo apt install -y ${JAVA_TOOLS[*]}
    "
    gum style --foreground 212 "✓ Java development tools installed"
}

install_nodejs_dev_tools() {
    if ! command -v node &> /dev/null; then
        gum style --foreground 214 "Node.js not installed. Install via nvm first."
        return
    fi

    gum style --foreground 212 "Installing Node.js development tools..."

    local NODE_TOOLS=(
        "typescript"
        "eslint"
        "prettier"
        "nodemon"
        "pm2"
        "yarn"
        "pnpm"
    )

    if gum confirm "Install global Node.js development tools?"; then
        for tool in "${NODE_TOOLS[@]}"; do
            gum spin --spinner globe --title "Installing $tool..." -- npm install -g "$tool"
        done
        gum style --foreground 212 "✓ Node.js development tools installed"
    fi
}

install_go_dev_tools() {
    if ! command -v go &> /dev/null; then
        gum style --foreground 214 "Go not installed. Install Go first."
        return
    fi

    gum style --foreground 212 "Installing Go development tools..."

    local GO_TOOLS=(
        "golang.org/x/tools/gopls@latest"
        "github.com/go-delve/delve/cmd/dlv@latest"
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest"
        "golang.org/x/tools/cmd/goimports@latest"
    )

    for tool in "${GO_TOOLS[@]}"; do
        gum spin --spinner globe --title "Installing $tool..." -- go install "$tool"
    done

    gum style --foreground 212 "✓ Go development tools installed"
}

install_rust_dev_tools() {
    if ! command -v cargo &> /dev/null; then
        gum style --foreground 214 "Rust not installed. Install rustup first."
        return
    fi

    gum style --foreground 212 "Installing additional Rust tools..."

    local RUST_TOOLS=(
        "cargo-watch"
        "cargo-edit"
        "cargo-outdated"
        "cargo-audit"
        "cargo-expand"
        "sccache"
    )

    for tool in "${RUST_TOOLS[@]}"; do
        gum spin --spinner globe --title "Installing $tool..." -- cargo install "$tool"
    done

    gum style --foreground 212 "✓ Rust development tools installed"
}

install_build_tools() {
    print_header
    gum style \
        --foreground 212 \
        --border-foreground 212 \
        --border rounded \
        --align center \
        --width 50 \
        --margin "1 2" \
        --padding "2 4" \
        "Build Tools Installation"

    echo ""

    local tools=$(gum choose --no-limit --header "Select build tools to install:" \
        "Essential Build Tools (build-essential, cmake, etc.)" \
        "Debugging Tools" \
        "Version Control Tools" \
        "Container Tools (Docker/Podman)" \
        "Package Building Tools" \
        "Language-Specific Tools" \
        "All Build Tools")

    refresh_sudo

    while IFS= read -r selection; do
        case "$selection" in
            "Essential Build Tools"*)
                install_essential_build_tools
                ;;
            "Debugging Tools"*)
                install_debugging_tools
                ;;
            "Version Control Tools"*)
                install_version_control_tools
                ;;
            "Container Tools"*)
                install_container_tools
                ;;
            "Package Building Tools"*)
                install_package_building_tools
                ;;
            "Language-Specific Tools"*)
                install_language_specific_tools
                ;;
            "All Build Tools"*)
                install_essential_build_tools
                install_debugging_tools
                install_version_control_tools
                if gum confirm "Install container tools?"; then
                    install_container_tools
                fi
                if gum confirm "Install package building tools?"; then
                    install_package_building_tools
                fi
                if gum confirm "Install language-specific tools?"; then
                    install_language_specific_tools
                fi
                ;;
        esac
    done <<< "$tools"

    echo ""
    gum style --foreground 212 "✓ Build tools installation completed"
}

if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    case "${1:-}" in
        "essential")
            install_essential_build_tools
            ;;
        "debug")
            install_debugging_tools
            ;;
        "vcs")
            install_version_control_tools
            ;;
        "containers")
            install_container_tools
            ;;
        "package")
            install_package_building_tools
            ;;
        "languages")
            install_language_specific_tools
            ;;
        *)
            install_build_tools
            ;;
    esac
fi
