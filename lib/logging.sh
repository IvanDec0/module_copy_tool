init_logging() {
    exec 3>&1 4>&2
    trap 'cleanup_logging' EXIT
    
    LOG_FILE="module-tools_$(date +%Y%m%d).log"
    exec > >(tee -a "$LOG_FILE") 2>&1
}

cleanup_logging() {
    exec 1>&3 2>&4
}

log_success() { echo -e "✅ $1"; }
log_info() { echo -e "ℹ️  $1"; }
log_warning() { echo -e "⚠️  $1" >&2; }
log_error() { echo -e "❌ $1" >&2; }

colorize() {
    local color=$1
    shift
    case $color in
        red) echo -e "\033[31m$*\033[0m";;
        green) echo -e "\033[32m$*\033[0m";;
        yellow) echo -e "\033[33m$*\033[0m";;
        *) echo -e "$*";;
    esac
}

show_summary() {
    cat << EOF
$(colorize yellow "=== Operation Summary ===")
$(printf "%-20s %s" "Operation Type:" "$([ -n "$restore_module" ] && echo "Restore" || echo "Copy")")
$(printf "%-20s %s" "Source Module:" "${module_name:-N/A}") 
$(printf "%-20s %s" "New Module:" "${plural_new:-N/A}")
$(printf "%-20s %s" "Backup Directory:" "${backup_dir/$BACKUP_DIR\//}")
$(printf "%-20s %s" "Dry Run Mode:" "$($CONFIG[dry_run] && echo Yes || echo No)")
$(printf "%-20s %s" "Interactive Mode:" "$($CONFIG[interactive] && echo Yes || echo No)")
$(printf "%-20s %s" "Platform:" "${PLATFORM}")
$(printf "%-20s %s" "Start Time:" "$(date +'%Y-%m-%d %H:%M:%S')")
$(colorize yellow "=============================")
EOF
}

display_available_backups() {
    local module=$1
    echo -e "\n${COLOR_YELLOW}Available backups for ${module}:${COLOR_RESET}"
    
    find "${BACKUP_DIR}" -name "${module}_*" -type d -printf "%f\n" | 
    awk -F_ '{printf "• Backup: %-15s (Created: %s)\n", $3, strftime("%Y-%m-%d %H:%M", $2)}' |
    sort -r
}