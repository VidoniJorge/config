# macOS Pro Setup - Estación de Trabajo Modular

Este proyecto consiste en un conjunto de scripts de automatización para macOS diseñados para configurar un entorno de desarrollo profesional de forma rápida y consistente. El sistema está modularizado para facilitar el mantenimiento y la escalabilidad.

## 📁 Estructura del Proyecto

El proyecto se divide en una carpeta raíz y dos subdirectorios lógicos:

```
setup/
├── main.sh            # Punto de entrada y gestión de menús.
├── data/
│   └── master_list.sh # Listas de software (Brew) y repositorios Git.
└── lib/
    ├── ui.sh          # Definiciones de colores y componentes de interfaz.
    ├── utils.sh       # Lógica de instalación de software y diagnóstico.
    └── git_ssh.sh     # Gestión de llaves SSH, config y clonación de repositorios.
```

## 🛠️ Descripción de los Módulos

### 1. main.sh

Es el script principal que el usuario debe ejecutar. Se encarga de cargar todos los módulos necesarios (`source`) y desplegar el menú interactivo. Coordina las llamadas a las funciones de instalación y configuración.

### 2. data/master_list.sh

Contiene la "fuente de verdad" del proyecto:

**MASTER_LIST**: Define qué programas instalar (VS Code, Python, uv, etc.) y mediante qué método (Brew, Cask o Manual).

**PROJECT_LIST**: Lista de repositorios Git que el desarrollador utiliza habitualmente.

### 3. lib/ui.sh

Gestiona la experiencia de usuario (UX):

Define constantes de colores ANSI para la terminal.

Funciones para mostrar banners y encabezados de sección uniformes.

### 4. lib/utils.sh

Contiene las funciones de bajo nivel:

Instalación automática de Homebrew.

Verificación de si un software ya está instalado para evitar redundancias.

Procesamiento de categorías de instalación masiva.

### 5. lib/git_ssh.sh

Gestiona la infraestructura de Git:

SSH Config: Crea y actualiza automáticamente `~/.ssh/config `para que las llaves se usen de forma transparente.

Key Generation: Genera llaves RSA de 4096 bits para GitHub y GitLab, añadiéndolas al Keychain de macOS.

Connection Test: Valida la comunicación con los servidores de GitHub y GitLab.

Clonación: Permite clonar proyectos individualmente o de forma masiva en la carpeta `~/repos`.

## 🚀 Uso

Clona este repositorio o descarga la carpeta setup.

Asegúrate de estar en la carpeta raíz del proyecto.

Otorga permisos de ejecución al script principal:

```bash
chmod +x main.sh
```

Ejecuta el instalador:

``` bash
./main.sh
```

## 📋 Requisitos

Sistema Operativo: macOS (probado en procesadores Intel y Apple Silicon).

Conexión a internet.

Shell: Zsh (por defecto en macOS moderno).

Documentación generada para la gestión automatizada de entornos de desarrollo.