#!/usr/bin/env bash
# @title Backup Management
# @description Backup creation and restoration

create_backup() {
    [ -z "$BACKUP_DIR" ] && handle_error "BACKUP_DIR not set"
    [ -z "$module_name" ] && handle_error "module_name not set"
    [ -z "$src_dir" ] && handle_error "Source directory path not set"

    local timestamp
    timestamp=$(date +%s)
    export backup_dir_final="${BACKUP_DIR}/${module_name}_${timestamp}"
    log_info "Creating backup: ${backup_dir_final/$BACKUP_DIR\//}"

    [ ! -d "$src_dir" ] && handle_error "Source directory not found: $src_dir"
    mkdir -p "$backup_dir_final" || handle_error "Backup directory creation failed"
    cp -r "$src_dir/." "$backup_dir_final" || handle_error "Backup copy failed"
    return 0
}

find_latest_backup() {
    find "$BACKUP_DIR" -maxdepth 1 -name "${module_name}_*" -type d | sort -r | head -n1
    return 0
}

restore_backup() {
    local latest
    latest=$(find_latest_backup)
    [ -z "$latest" ] && handle_error "No backups available for module: $module_name"
    log_info "Restoring from: ${latest/$BACKUP_DIR\//}"

    mkdir -p "$(dirname "$src_dir")" || handle_error "Failed to create parent directory"
    [ -d "$src_dir" ] && rm -rf "$src_dir"
    cp -r "$latest/." "$src_dir" || {
        rm -rf "$src_dir"
        handle_error "Restore failed - system cleaned up"
    }
    log_success "Restored module $module_name successfully"
    return 0
}

backup_exists() {
    local module=$1
    [ -z "$module" ] && handle_error "Module name required for backup check"
    find "$BACKUP_DIR" -maxdepth 1 -name "${module}_*" -type d | grep -q .
    return 0
}