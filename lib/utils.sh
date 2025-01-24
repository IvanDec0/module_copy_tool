#!/usr/bin/env bash

SCRIPT_VERSION="1.1.0"
BASE_DIR="src/modules"
BACKUP_DIR="backups/modules"

declare -A CONFIG=(
    [dry_run]=false
    [interactive]=true
    [force]=false
)

init_environment() {
    detect_platform
    setup_paths
    check_dependencies
}

detect_platform() {
    case "$(uname -s)" in
        Darwin*)    PLATFORM="macOS";;
        Linux*)     PLATFORM="Linux";;
        *)          PLATFORM="Unknown"
    esac
}

setup_paths() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    export PATH="${SCRIPT_DIR}/bin:$PATH"
}

check_dependencies() {
    local missing=()
    for cmd in git sed awk; do
        if ! command -v $cmd &> /dev/null; then
            missing+=("$cmd")
        fi
    done
    
    [ ${#missing[@]} -gt 0 ] && 
        handle_error "Missing dependencies: ${missing[*]}"
}

array_contains() {
    local seeking=$1
    shift
    for element; do 
        [[ $element == "$seeking" ]] && return 0
    done
    return 1
}

show_help() {
    cat << EOF
🚀 Module Management Tool v${SCRIPT_VERSION}
Usage: module-copy [OPTIONS] --module MODULE --new NAME

Core Commands:
  -m, --module MODULE    Source module name (required)
  -n, --new NAME         New module name (required)
  -r, --restore MODULE   Restore module from backup
  -h, --help             Show this help message
  -v, --version          Display version information

Operation Modes:
  -d, --dry-run          Simulate changes without modifying files
  -f, --force            Skip confirmation prompts
  -y, --non-interactive  Disable interactive mode

Advanced Options:
  -b, --backup-dir DIR   Custom backup directory (default: ${BACKUP_DIR})
  -l, --log-file FILE    Specify log file path
  --list-backups         Show available backups for a module

Examples:
  Create new module:
  $ module-copy -m products -n services
  
  Restore module:
  $ module-copy --restore products
  
  Dry run with custom backup:
  $ module-copy -m user -n client -d -b /custom/backups

Documentation:
  See README.md for detailed usage guide and examples
EOF
}

parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                echo "Module Management Tool v${SCRIPT_VERSION}"
                exit 0
                ;;
            -m|--module)
                validate_argument "$1" "$2"
                module_name="$2"
                shift 2
                ;;
            -n|--new)
                validate_argument "$1" "$2"
                plural_new="$2"
                shift 2
                ;;
            -r|--restore)
                validate_argument "$1" "$2"
                restore_module="$2"
                shift 2
                ;;
            -d|--dry-run)
                CONFIG[dry_run]=true
                shift
                ;;
            -f|--force)
                CONFIG[interactive]=false
                shift
                ;;
            -y|--non-interactive)
                CONFIG[interactive]=false
                shift
                ;;
            -b|--backup-dir)
                validate_argument "$1" "$2"
                BACKUP_DIR="$2"
                shift 2
                ;;
            -l|--log-file)
                validate_argument "$1" "$2"
                LOG_FILE="$2"
                shift 2
                ;;
            --list-backups)
                list_backups=true
                shift
                ;;
            *)
                handle_error "Unknown option: $1"
                ;;
        esac
    done
}

validate_argument() {
    local opt="$1"
    local arg="$2"
    [ -z "$arg" ] && handle_error "Option $opt requires an argument"
    [[ "$arg" =~ ^- ]] && handle_error "Invalid argument for $opt: $arg"
}