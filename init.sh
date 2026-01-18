#!/bin/zsh

# --- CONFIGURACIÓN MAESTRA DE PROGRAMAS ---
MASTER_LIST=(
    "BASIC|Homebrew|manual|check_and_install_brew"
    "BASIC|GitHub CLI|brew|gh"
    "IDE|Visual Studio Code|cask|visual-studio-code"
    "PYTHON|Python 3.13|brew|python@3.13"
    "PYTHON|uv|brew|uv"
    "SYSTEM|Configuraciones de macOS|manual|apply_macos_settings"
)

# --- CONFIGURACIÓN DE PROYECTOS GIT ---
# Formato: "Nombre|URL"
PROJECT_LIST=(
    "api_signature_tester|git@github.com:VidoniJorge/api_signature_tester.git"
    "DesignPatterns|git@github.com:VidoniJorge/DesignPatterns.git"
    "config|git@github.com:VidoniJorge/config.git"
    "c-python|git@github.com:VidoniJorge/c-python.git"
    "agro-report|git@gitlab.com:jv-agro/desktop/agro-report.git"
)

# --- COLORES ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- FUNCIONES NÚCLEO ---

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

update_ssh_config() {
    local host=$1
    local key_path=$2
    local config_file="$HOME/.ssh/config"

    touch "$config_file"
    
    # Verificamos si ya existe la entrada para el host
    if ! grep -q "Host $host" "$config_file"; then
        echo "\nHost $host\n  HostName $host\n  User git\n  IdentityFile $key_path\n  AddKeysToAgent yes\n  UseKeychain yes" >> "$config_file"
        echo "${GREEN}✓ Configuración SSH añadida para $host en ~/.ssh/config${NC}"
    else
        echo "${YELLOW}! Ya existe una entrada para $host en ~/.ssh/config. Por favor, revísala manualmente si falla.${NC}"
    fi
}

generate_ssh_key() {
    local service=$1
    echo "${YELLOW}>>> Configuración de Clave SSH para $service${NC}"
    
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    
    local key_name="rsa_$service"
    local key_path="$HOME/.ssh/$key_name"
    local host=""
    [[ "$service" == "github" ]] && host="github.com"
    [[ "$service" == "gitlab" ]] && host="gitlab.com"

    if [[ -f "$key_path" ]]; then
        echo "${YELLOW}! Ya existe la clave $key_name en ~/.ssh/. Saltando generación...${NC}"
    else
        echo "Introduce tu email para $service: "
        read email
        
        echo "${BLUE}Generando clave SSH RSA 4096 para $service ($key_name)...${NC}"
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N ""
        
        eval "$(ssh-agent -s)"
        ssh-add --apple-use-keychain "$key_path"

        echo "${GREEN}✓ Clave para $service generada con éxito.${NC}"
        echo "${BLUE}Clave pública para copiar en $service:${NC}"
        cat "${key_path}.pub"
    fi

    # Actualizar el archivo config para asegurar que SSH sepa qué clave usar
    if [[ -n "$host" ]]; then
        update_ssh_config "$host" "$key_path"
    fi
}

test_ssh_connection() {
    echo "${BLUE}Probando conexión SSH con GitHub...${NC}"
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
    if [ $? -eq 0 ]; then
        echo "${GREEN}✓ Conexión con GitHub exitosa.${NC}"
    else
        echo "${RED}✗ Error en la conexión con GitHub. Asegúrate de haber subido la clave .pub a tu perfil.${NC}"
    fi
}

check_system_health() {
    echo "\n${BLUE}=========================================="
    echo "    DIAGNÓSTICO DE CONFIGURACIONES"
    echo "==========================================${NC}"
    
    [[ -f "$HOME/.ssh/rsa_github.pub" ]] && echo " [${GREEN}✓${NC}] Clave SSH GitHub: Detectada" || echo " [${RED}✗${NC}] Clave SSH GitHub: No encontrada"
    [[ -f "$HOME/.ssh/rsa_gitlab.pub" ]] && echo " [${GREEN}✓${NC}] Clave SSH GitLab: Detectada" || echo " [${RED}✗${NC}] Clave SSH GitLab: No encontrada"
    [[ -f "$HOME/.ssh/config" ]] && echo " [${GREEN}✓${NC}] Configuración SSH: Detectada" || echo " [${RED}✗${NC}] Configuración SSH: No encontrada"
    
    echo "\n${BLUE}==========================================${NC}"
}

apply_macos_settings() {
    while true; do
        clear
        echo "${BLUE}=========================================="
        echo "      CONFIGURACIONES DE SISTEMA"
        echo "==========================================${NC}"
        echo "1) Generar clave SSH para GitHub (rsa_github)"
        echo "2) Generar clave SSH para GitLab (rsa_gitlab)"
        echo "3) Probar conexión SSH (GitHub)"
        echo "4) Validar estado de configuraciones (Check)"
        echo "5) Volver al menú anterior"
        echo "Selección: "
        read sub_opt

        case $sub_opt in
            1) generate_ssh_key "github" ;;
            2) generate_ssh_key "gitlab" ;;
            3) test_ssh_connection ;;
            4) check_system_health ;;
            5) break ;;
            *) echo "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
        [[ $sub_opt != 5 ]] && { echo "\nPresiona Enter para continuar..."; read dummy; }
    done
}

check_project_status() {
    echo "\n${BLUE}=========================================="
    echo "    ESTADO DE PROYECTOS EN ~/repos"
    echo "==========================================${NC}"
    
    for item in "${PROJECT_LIST[@]}"; do
        local name=$(echo $item | cut -d'|' -f1)
        if [ -d "$HOME/repos/$name" ]; then
            echo " [${GREEN}✓${NC}] $name (Clonado)"
        else
            echo " [${RED}✗${NC}] $name (No descargado)"
        fi
    done
    echo "\n${BLUE}==========================================${NC}"
}

clone_single_project() {
    echo "\nSelecciona un proyecto para clonar:"
    local i=1
    for item in "${PROJECT_LIST[@]}"; do
        local name=$(echo $item | cut -d'|' -f1)
        echo "$i) $name"
        ((i++))
    done
    echo "Selección: "
    read input_idx

    # Ajuste de índice para Zsh (Arrays base 1)
    local real_idx=$((input_idx - 1)) 
    
    if [[ "$real_idx" -ge 0 && "$real_idx" -le "${#PROJECT_LIST[@]}" ]]; then
        local selected_item="${PROJECT_LIST[$real_idx]}"
        local name=$(echo "$selected_item" | cut -d'|' -f1)
        local url=$(echo "$selected_item" | cut -d'|' -f2)
        
        if [ -d "$HOME/repos/$name" ]; then
            echo "${YELLOW}! El proyecto $name ya existe en ~/repos.${NC}"
        else
            echo "${BLUE}Clonando $name...${NC}"
            mkdir -p "$HOME/repos"
            cd "$HOME/repos" && git clone "$url" "$name"
        fi
    else
        echo "${RED}Selección inválida.${NC}"
    fi
}

clone_all_projects() {
    echo "${BLUE}Iniciando clonación masiva en ~/repos...${NC}"
    mkdir -p "$HOME/repos"
    for item in "${PROJECT_LIST[@]}"; do
        local name=$(echo $item | cut -d'|' -f1)
        local url=$(echo $item | cut -d'|' -f2)
        
        if [ -d "$HOME/repos/$name" ]; then
            echo "${GREEN}✓ $name ya existe.${NC}"
        else
            echo "${BLUE}Clonando $name...${NC}"
            cd "$HOME/repos" && git clone "$url" "$name"
        fi
    done
}

manage_git_projects() {
    while true; do
        clear
        echo "${BLUE}=========================================="
        echo "        GESTIÓN DE PROYECTOS GIT"
        echo "==========================================${NC}"
        echo "1) Validar estado de proyectos (Check)"
        echo "2) Clonar un proyecto específico"
        echo "3) Clonar todos los proyectos de la lista"
        echo "4) Volver al menú anterior"
        echo "Selección: "
        read git_opt

        case $git_opt in
            1) check_project_status ;;
            2) clone_single_project ;;
            3) clone_all_projects ;;
            4) break ;;
            *) echo "${RED}Opción inválida${NC}"; sleep 1 ;;
        esac
        [[ $git_opt != 5 ]] && { echo "\nPresiona Enter para continuar..."; read dummy 
        }
    done
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
    echo "\n${BLUE}=========================================="
    echo "      ESTADO ACTUAL DEL SISTEMA"
    echo "==========================================${NC}"
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

# --- MENÚ PRINCIPAL ---
while true; do
    clear
    echo "${BLUE}=========================================="
    echo "   ESTACIÓN DE TRABAJO MAC (NIVEL PRO)"
    echo "==========================================${NC}"
    echo "\n1) Kit Inicial (BASIC)"
    echo "2) Kit IDEs (IDE)"
    echo "3) Kit Python (PYTHON)"
    echo "4) Configuraciones de macOS (SYSTEM)"
    echo "5) Gestión de Proyectos (GIT)"
    echo "6) TODO (Completo)"
    echo "7) Ver estado (Check)"
    echo "8) Salir"
    echo "Selección: "
    read opt
    case $opt in
        1) process_category "BASIC" "Básico" ;;
        2) process_category "IDE" "IDEs" ;;
        3) process_category "PYTHON" "Python" ;;
        4) process_category "SYSTEM" "Configuraciones" ;;
        5) manage_git_projects ;;
        6) process_category "ALL" "Completo" ;;
        7) show_status ;;
        8) exit 0 ;;
        *) echo "${RED}Opción inválida${NC}"; sleep 1 ;;
    esac
    [[ $opt != 7 && $opt != 8 ]] && { echo "\n${GREEN}¡Operación finalizada!${NC}"; read dummy; }
done