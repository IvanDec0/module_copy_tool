#!/usr/bin/env bash
# @file Logging functionality and output formatting

# Define color codes
declare -r COLOR_RED="\033[31m"
declare -r COLOR_GREEN="\033[32m"
declare -r COLOR_YELLOW="\033[33m"
declare -r COLOR_RESET="\033[0m"

# Initialize logging system
init_logging() {
    LOG_FILE=${LOG_FILE:-"${SCRIPT_DIR}/logs/log_$(date +%Y%m%d).log"}
    LOG_DIR=$(dirname "$LOG_FILE")
    if ! mkdir -p "$LOG_DIR"; then
        echo "❌ Critical Error: Failed to create log directory at ${LOG_DIR}" >&2
        echo "❌ Check permissions or specify different log location with -l" >&2
        exit 1
    fi
    # Save original descriptors
    exec 3>&1 4>&2
    # Redirect output only if not in help/version mode
    if [[ "$1" != "--help" && "$1" != "--version" ]]; then
        exec 1> >(tee -a "$LOG_FILE")
        exec 2> >(tee -a "$LOG_FILE" >&2)
    fi
    log_success "Logging initialized at ${LOG_FILE}"
    return 0
}

# Restore original file descriptors
cleanup_logging() {
    # Restore original descriptors if they exist
    if { true >&3; } 2>/dev/null; then
        exec 1>&3
    fi
    if { true >&4; } 2>/dev/null; then
        exec 2>&4
    fi
    return 0
}

# Logging functions with emoji and colors
log_success() { echo -e "${COLOR_GREEN}✅ $1${COLOR_RESET}"; }
log_info() { echo -e "${COLOR_RESET}ℹ️  $1"; }
log_warning() { echo -e "${COLOR_YELLOW}⚠️  $1${COLOR_RESET}" >&2; }
log_error() { echo -e "${COLOR_RED}❌ $1${COLOR_RESET}" >&2; }

# Color wrapper function
colorize() {
    local color=$1
    shift
    case $color in
        red) echo -e "${COLOR_RED}$*${COLOR_RESET}";;
        green) echo -e "${COLOR_GREEN}$*${COLOR_RESET}";;
        yellow) echo -e "${COLOR_YELLOW}$*${COLOR_RESET}";;
        *) echo -e "$*";;
    esac
}

# Operation summary display
show_summary() {
    local dry_run_status="No"
    local interactive_status="Yes"
    
    [[ "${CONFIG[dry_run]:-false}" == true ]] && dry_run_status="Yes"
    [[ "${CONFIG[interactive]:-true}" == false ]] && interactive_status="No"
    
    cat << EOF
$(colorize yellow "=== Operation Summary ===")
$(printf "%-20s %s" "Operation Type:" "$([ -n "$restore_module" ] && echo "Restore" || echo "Copy")")
$(printf "%-20s %s" "Source Module:" "${module_name:-N/A}") 
$(printf "%-20s %s" "New Module:" "${plural_new:-N/A}")
$(printf "%-20s %s" "Backup Directory:" "${backup_dir:-$BACKUP_DIR}")
$(printf "%-20s %s" "Dry Run Mode:" "$dry_run_status")
$(printf "%-20s %s" "Interactive Mode:" "$interactive_status")
$(printf "%-20s %s" "Platform:" "${PLATFORM:-Unknown}")
$(printf "%-20s %s" "Start Time:" "$(date +'%Y-%m-%d %H:%M:%S')")
$(colorize yellow "=============================")
EOF
}

# Display available backups for a module
display_available_backups() {
    local module=$1
    
    [ ! -d "$BACKUP_DIR" ] && handle_error "Backup directory not found"
    [ -z "$module" ] && handle_error "Module name required"
    
    echo -e "\n$(colorize yellow "Available backups for $module:")"
    
    if ! find "$BACKUP_DIR" -maxdepth 1 -name "${module}_*" -type d 2>/dev/null | sort -r | while read -r backup; do
        local timestamp
        timestamp=$(basename "$backup" | cut -d_ -f2)
        printf "• Backup from: %s (%s)\n" \
            "$(date -d "@$timestamp" +'%Y-%m-%d %H:%M:%S' 2>/dev/null || date -r "$timestamp" +'%Y-%m-%d %H:%M:%S')" \
            "$(basename "$backup")"
    done; then
        log_warning "No backups found for module: $module"
        return 1
    fi
    return 0
}