create_backup() {
    backup_dir="${BACKUP_DIR}/${module_name}_$(date +%s)"
    log_info "Creating backup: ${backup_dir/$BACKUP_DIR\//}"
    
    mkdir -p "$backup_dir" && 
    cp -r "$src_dir/." "$backup_dir" ||
        handle_error "Failed to create backup"
}

restore_backup() {
    local latest=$(find_latest_backup)
    [ -z "$latest" ] && handle_error "No backups available"
    
    log_info "Restoring from: ${latest/$BACKUP_DIR\//}"
    rm -rf "$src_dir" && cp -r "$latest/." "$src_dir"
}

find_latest_backup() {
    find "$BACKUP_DIR" -name "${module_name}_*" -type d -print0 | 
    xargs -0 ls -dt | 
    head -n1
}