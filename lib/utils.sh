#!/usr/bin/env bash
# @title Utilities Library
# @description Core functions and configuration for module management

# Core configuration variables
export SCRIPT_VERSION="1.2.0"
export BASE_DIR="src/modules"
export BACKUP_DIR="backups/modules"
export backup_dir_final=""
export module_name=""
export plural_new=""
export singular_new=""
export restore_module=""
export LOG_FILE=""

# Configuration array must be exported for child processes
declare -xA CONFIG=(
    [dry_run]="false"
    [interactive]="true"
    [force]="false"
    [list_backups]="false"
)
export CONFIG

# @function Initialize environment
init_environment() {
    detect_platform
    setup_paths
    check_dependencies
    return 0
}

# @function Detect operating system
detect_platform() {
    case "$(uname -s)" in
        Darwin*)    PLATFORM="macOS";;
        Linux*)     PLATFORM="Linux";;
        *)          handle_error "Unsupported platform: $(uname -s)"
    esac
    return 0
}

# @function Set script directory path
setup_paths() {
    # SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    BASE_DIR="${SCRIPT_DIR}/${BASE_DIR}"
    BACKUP_DIR="${SCRIPT_DIR}/${BACKUP_DIR}"
    export BASE_DIR
    if [ -n "$module_name" ]; then
        src_dir="${BASE_DIR}/${module_name}"
        export src_dir
    fi
    if [ -n "$plural_new" ]; then
        dest_dir="${BASE_DIR}/${plural_new}"
        export dest_dir
    fi
    return 0
}
# @function Validate command dependencies
check_dependencies() {
    local missing=()
    local required=(git sed awk find xargs)
    [[ "$PLATFORM" == "macOS" ]] && required+=(gsed)
    for cmd in "${required[@]}"; do
        command -v "$cmd" &> /dev/null || missing+=("$cmd")
    done
    if [ ${#missing[@]} -gt 0 ]; then
        echo "DEBUG: Missing dependencies: ${missing[*]}"
        handle_error "Missing dependencies: ${missing[*]}"
        return 1
    fi
    return 0
}

# @function Parse command line arguments
parse_arguments() {
    [ $# -eq 0 ] && { show_help; return 0; }
    while [[ $# -gt 0 ]]; do
    # shellcheck disable=SC2145
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -v|--version)
                show_version
                exit 0
                ;;
            -m|--module)
                validate_argument "$1" "$2"
                export module_name="$2"
                shift 2
                ;;
            -n|--new)
                validate_argument "$1" "$2"
                export plural_new="$2"
                shift 2
                ;;
            -r|--restore)
                validate_argument "$1" "$2"
                export restore_module="$2"
                shift 2
                ;;
            -d|--dry-run)
                CONFIG[dry_run]="true"
                export CONFIG
                shift
                ;;
            -f|--force)
                CONFIG[interactive]="false"
                export CONFIG
                shift
                ;;
            -y|--non-interactive)
                CONFIG[interactive]="false"
                export CONFIG
                shift
                ;;
            -b|--backup-dir)
                validate_argument "$1" "$2"
                export BACKUP_DIR="$2"
                shift 2
                ;;
            --list-backups)
                CONFIG[list_backups]="true"
                export CONFIG
                shift
                ;;
            *)
                handle_error "Unknown option: $1"
                shift
                ;;
        esac
    done
    return 0
}

validate_argument() {
    local opt="$1"
    local arg="$2"
    [ -z "$arg" ] && handle_error "Option $opt requires an argument"
    [[ "$arg" =~ ^- ]] && handle_error "Invalid argument for $opt: $arg"
    return 0
}

cleanup() {
    # Default to "no_logging" if no argument is passed
    local mode="${1:-no_logging}"
    if [[ "$mode" != "no_logging" ]]; then
        if command -v cleanup_logging &>/dev/null; then
            cleanup_logging
        fi
    fi
    # Clean temporary files
    if [[ -d "${TMP_DIR:-}" ]]; then
        rm -rf "$TMP_DIR"
    fi
    return 0
}

cleanup_on_error() {
    local exit_code=$1
    log_error "Script failed with exit code: ${exit_code}"
    cleanup "error_exit"
    exit "${exit_code}"
}

# Handle errors
handle_error() {
    local message=$1
    if command -v log_error &>/dev/null; then
        log_error "$message"
    else
        echo -e "\033[31m❌ $message\033[0m" >&2
    fi
    return 1
}

# Show help message
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
return 0
}

show_version() {
    echo -e "Module Management Tool v${SCRIPT_VERSION:-1.2.0}"
    exit 0
}