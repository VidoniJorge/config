#!/bin/zsh

check_and_install_brew() {
    if ! command -v brew &> /dev/null; then
        echo "${BLUE}Homebrew no encontrado. Iniciando instalación...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ $(uname -m) == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        echo "${GREEN}✓ Homebrew ya está instalado y configurado.${NC}"
    fi
}

is_installed() {
    local name=$1; local type=$2; local id=$3
    case $type in
        brew) brew list --formula $id &> /dev/null; return $? ;;
        cask) brew list --cask $id &> /dev/null || [ -d "/Applications/$name.app" ] && return 0 || return 1 ;;
        manual)
            [[ "$id" == "check_and_install_brew" ]] && { command -v brew &> /dev/null && return 0 || return 1; }
            [[ "$id" == "apply_macos_settings" ]] && { [[ -f "$HOME/.ssh/rsa_github.pub" && -f "$HOME/.ssh/rsa_gitlab.pub" ]] && return 0 || return 1; }
            return 1 ;;
    esac
}

process_category() {
    local filter=$1; local title=$2
    echo "\n${YELLOW}>>> PROCESANDO: $title${NC}"
    for item in "${MASTER_LIST[@]}"; do
        local cat=$(echo $item | cut -d'|' -f1); local name=$(echo $item | cut -d'|' -f2)
        local type=$(echo $item | cut -d'|' -f3); local id=$(echo $item | cut -d'|' -f4)
        if [[ "$filter" == "ALL" || "$cat" == "$filter" ]]; then
            if is_installed "$name" "$type" "$id"; then
                echo "${GREEN}✓ $name ya está presente.${NC}"
            else
                echo "${BLUE}Procesando $name...${NC}"
                case $type in
                    brew) brew install $id ;;
                    cask) brew install --cask $id ;;
                    manual) $id ;; 
                esac
            fi
        fi
    done
}

show_status() {
    show_section_header "ESTADO ACTUAL DEL SISTEMA"
    local current_cat=""
    for item in "${MASTER_LIST[@]}"; do
        local cat=$(echo $item | cut -d'|' -f1); local name=$(echo $item | cut -d'|' -f2)
        local type=$(echo $item | cut -d'|' -f3); local id=$(echo $item | cut -d'|' -f4)
        [[ "$cat" != "$current_cat" ]] && { echo "\n${YELLOW}Categoría: $cat${NC}"; current_cat=$cat; }
        is_installed "$name" "$type" "$id" && echo " [${GREEN}✓${NC}] $name" || echo " [${RED}✗${NC}] $name"
    done
    echo "\n${BLUE}==========================================${NC}"
    echo "Presiona Enter para volver al menú..."
    read dummy
}