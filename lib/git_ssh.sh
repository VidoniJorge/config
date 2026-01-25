#!/bin/zsh

update_ssh_config() {
    local host=$1; local key_path=$2
    local config_file="$HOME/.ssh/config"
    touch "$config_file"
    
    if ! grep -q "Host $host" "$config_file"; then
        echo "\nHost $host\n  HostName $host\n  User git\n  IdentityFile $key_path\n  AddKeysToAgent yes\n  UseKeychain yes" >> "$config_file"
        echo "${GREEN}✓ Configuración SSH añadida para $host en ~/.ssh/config${NC}"
    else
        echo "${YELLOW}! Ya existe una entrada para $host en ~/.ssh/config.${NC}"
    fi
}

generate_ssh_key() {
    local service=$1
    echo "${YELLOW}>>> Configuración de Clave SSH para $service${NC}"
    mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
    
    local key_name="rsa_$service"
    local key_path="$HOME/.ssh/$key_name"
    local host=""
    [[ "$service" == "github" ]] && host="github.com"
    [[ "$service" == "gitlab" ]] && host="gitlab.com"

    if [[ -f "$key_path" ]]; then
        echo "${YELLOW}! Ya existe la clave $key_name. Saltando generación...${NC}"
    else
        echo "Introduce tu email para $service: "
        read email
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_path" -N ""
        eval "$(ssh-agent -s)"
        ssh-add --apple-use-keychain "$key_path"
        echo "${GREEN}✓ Clave generada. Cópiala en $service:${NC}"
        cat "${key_path}.pub"
    fi
    [[ -n "$host" ]] && update_ssh_config "$host" "$key_path"
}

test_ssh_connection() {
    echo "${BLUE}Probando conexión SSH con GitHub...${NC}"
    ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"
    if [ $? -eq 0 ]; then
        echo "${GREEN}✓ Conexión con GitHub exitosa.${NC}"
    else
        echo "${RED}✗ Error de conexión con GitHub.${NC}"
    fi

    echo "${BLUE}Probando conexión SSH con GitLab...${NC}"
    ssh -T git@gitlab.com 2>&1 | grep -q "Welcome to GitLab"
    if [ $? -eq 0 ]; then
        echo "${GREEN}✓ Conexión con GitLab exitosa.${NC}"
    else
        echo "${RED}✗ Error de conexión con GitLab.${NC}"
    fi
}

check_project_status() {
    show_section_header "ESTADO DE PROYECTOS EN ~/repos"
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
    local real_idx=$((input_idx - 1)) 
    
    if [[ "$real_idx" -ge 0 && "$real_idx" -le "${#PROJECT_LIST[@]}" ]]; then
        local selected_item="${PROJECT_LIST[$real_idx]}"
        local name=$(echo "$selected_item" | cut -d'|' -f1)
        local url=$(echo "$selected_item" | cut -d'|' -f2)
        
        if [ -d "$HOME/repos/$name" ]; then
            echo "${YELLOW}! El proyecto $name ya existe.${NC}"
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
    echo "${BLUE}Iniciando clonación masiva...${NC}"
    mkdir -p "$HOME/repos"
    for item in "${PROJECT_LIST[@]}"; do
        local name=$(echo $item | cut -d'|' -f1); local url=$(echo $item | cut -d'|' -f2)
        if [ -d "$HOME/repos/$name" ]; then
            echo "${GREEN}✓ $name ya existe.${NC}"
        else
            echo "${BLUE}Clonando $name...${NC}"
            cd "$HOME/repos" && git clone "$url" "$name"
        fi
    done
}