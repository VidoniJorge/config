#!/bin/zsh

# --- COLORES ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- ELEMENTOS VISUALES ---
show_banner() {
    clear
    echo "${BLUE}=========================================="
    echo "   ESTACIÓN DE TRABAJO MAC (NIVEL PRO)"
    echo "==========================================${NC}"
}

show_section_header() {
    local title=$1
    echo "${BLUE}=========================================="
    echo "        $title"
    echo "==========================================${NC}"
}