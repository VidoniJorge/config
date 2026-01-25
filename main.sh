#!/bin/zsh

# --- CARGA DINÁMICA DE MÓDULOS ---
BASE_DIR="."
echo $BASE_DIR
source "$BASE_DIR/data/master_list.sh"
source "$BASE_DIR/lib/ui.sh"
source "$BASE_DIR/lib/utils.sh"
source "$BASE_DIR/lib/git_ssh.sh"

apply_macos_settings() {
    while true; do
        show_section_header "CONFIGURACIONES DE SISTEMA"
        echo "1) Generar clave SSH GitHub"
        echo "2) Generar clave SSH GitLab"
        echo "3) Probar conexión GitHub"
        echo "4) Validar diagnósticos"
        echo "5) Volver"
        echo "Selección: "
        read sub_opt
        case $sub_opt in
            1) generate_ssh_key "github" ;;
            2) generate_ssh_key "gitlab" ;;
            3) test_ssh_connection ;;
            4) 
                show_section_header "DIAGNÓSTICO"
                [[ -f "$HOME/.ssh/rsa_github.pub" ]] && echo " [${GREEN}✓${NC}] SSH GitHub" || echo " [${RED}✗${NC}] SSH GitHub"
                [[ -f "$HOME/.ssh/rsa_gitlab.pub" ]] && echo " [${GREEN}✓${NC}] SSH GitLab" || echo " [${RED}✗${NC}] SSH GitLab"
                [[ -f "$HOME/.ssh/config" ]] && echo " [${GREEN}✓${NC}] Config File" || echo " [${RED}✗${NC}] Config File"
                ;;
            5) break ;;
        esac
        [[ $sub_opt != 5 ]] && { echo "\nPresiona Enter..."; read dummy; }
    done
}

manage_git_projects() {
    while true; do
        show_section_header "GESTIÓN DE PROYECTOS GIT"
        echo "1) Validar estado"
        echo "2) Clonar uno"
        echo "3) Clonar todos"
        echo "4) Volver"
        echo "Selección: "
        read git_opt
        case $git_opt in
            1) check_project_status ;;
            2) clone_single_project ;;
            3) clone_all_projects ;;
            4) break ;;
        esac
        [[ $git_opt != 4 ]] && { echo "\nPresiona Enter..."; read dummy; }
    done
}

# --- BUCLE PRINCIPAL ---
while true; do
    show_banner
    echo "1) Kit Inicial (BASIC)"
    echo "2) Kit IDEs (IDE)"
    echo "3) Kit Python (PYTHON)"
    echo "4) Configuración macOS (SYSTEM)"
    echo "5) Gestión Git (GIT)"
    echo "6) TODO (Completo)"
    echo "7) Ver estado (Check)"
    echo "8) Salir"
    echo "Selección: "
    read opt
    case $opt in
        1) process_category "BASIC" "Básico" ;;
        2) process_category "IDE" "IDEs" ;;
        3) process_category "PYTHON" "Python" ;;
        4) apply_macos_settings ;;
        5) manage_git_projects ;;
        6) process_category "ALL" "Completo" ;;
        7) show_status ;;
        8) exit 0 ;;
        *) echo "${RED}Inválido${NC}"; sleep 1 ;;
    esac
    [[ $opt != 4 && $opt != 5 && $opt != 7 && $opt != 8 ]] && { echo "\n${GREEN}Finalizado!${NC}"; read dummy; }
done