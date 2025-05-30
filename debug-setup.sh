#!/usr/bin/env bash

set -euo pipefail

# Force URL mode for testing
RUNNING_FROM_URL=true

echo "=== DEBUG INFORMATION ==="
echo "BASH_SOURCE[0]: ${BASH_SOURCE[0]}"
echo "\$0: $0"
echo "pwd: $(pwd)"
echo "RUNNING_FROM_URL: $RUNNING_FROM_URL"
echo "========================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

setup_kousei_directory() {
    echo "=== STARTING REPOSITORY SETUP ==="
    
    # Ensure git is available
    if ! command -v git &> /dev/null; then
        echo -e "${YELLOW}Installing git...${NC}"
        sudo apt update -y
        sudo apt install -y git
    fi
    
    KOUSEI_DIR="$HOME/.local/share/kousei"
    echo "Target directory: $KOUSEI_DIR"
    
    # Create parent directory
    mkdir -p "$HOME/.local/share"
    echo "Created parent directory: $HOME/.local/share"
    
    # Remove existing directory if it exists
    if [ -d "$KOUSEI_DIR" ]; then
        echo "Removing existing directory..."
        rm -rf "$KOUSEI_DIR"
    fi
    
    # Clone the repository
    echo -e "${CYAN}Cloning Kōsei repository...${NC}"
    cd "$HOME/.local/share"
    echo "Current directory: $(pwd)"
    
    git clone https://github.com/aileks/kousei.git
    
    if [ -d "$KOUSEI_DIR" ]; then
        echo -e "${GREEN}✓ Repository cloned successfully${NC}"
        echo "Contents of $KOUSEI_DIR:"
        ls -la "$KOUSEI_DIR"
    else
        echo -e "${RED}✗ Repository clone failed${NC}"
        exit 1
    fi
    
    cd "$KOUSEI_DIR"
    echo "Changed to repository directory: $(pwd)"
    
    echo "=== REPOSITORY SETUP COMPLETE ==="
}

# Test the function
setup_kousei_directory

echo ""
echo "=== FINAL VERIFICATION ==="
if [ -d "$HOME/.local/share/kousei" ]; then
    echo -e "${GREEN}✓ Repository exists at $HOME/.local/share/kousei${NC}"
    echo "Contents:"
    ls -la "$HOME/.local/share/kousei"
else
    echo -e "${RED}✗ Repository does not exist${NC}"
fi
