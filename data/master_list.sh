#!/bin/zsh

# --- CONFIGURACIÓN MAESTRA DE PROGRAMAS ---
MASTER_LIST=(
    "BASIC|Homebrew|manual|check_and_install_brew"
    "BASIC|GitHub CLI|brew|gh"
    "IDE|Visual Studio Code|cask|visual-studio-code"
    "IDE|Google Cloud Antigravity|cask|antigravity"
    "PYTHON|Python 3.13|brew|python@3.13"
    "PYTHON|uv|brew|uv"
    "SYSTEM|Configuraciones de macOS|manual|apply_macos_settings"
)

# --- CONFIGURACIÓN DE PROYECTOS GIT ---
PROJECT_LIST=(
    "api_signature_tester|git@github.com:VidoniJorge/api_signature_tester.git"
    "DesignPatterns|git@github.com:VidoniJorge/DesignPatterns.git"
    "config|git@github.com:VidoniJorge/config.git"
    "c-python|git@github.com:VidoniJorge/c-python.git"
    "agro-report|git@gitlab.com:jv-agro/desktop/agro-report.git"
)