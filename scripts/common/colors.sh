#!/usr/bin/env bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD_ESC='\033[1m'

run_gum() {
    local saved_bold="${BOLD"

    unset BOLD
    unset FOREGROUND
    unset BACKGROUND
    unset BORDER
    unset ALIGN
    unset HEIGHT
    unset WIDTH
    unset MARGIN
    unset PADDING

    "$@"
    local result=$?

    if [ -n "$saved_bold" ]; then
        export BOLD="$saved_bold"
    fi

    return $result
}

export -f run_gum
