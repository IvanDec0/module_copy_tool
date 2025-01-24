setup_replacements() {
    singular_old="${module_name%s}"
    plural_old="$module_name"
    singular_new="${plural_new%s}"
}

perform_replacements() {
    if $CONFIG[dry_run]; then
        simulate_replacements
    else
        execute_replacements
    fi
}

execute_replacements() {
    local count=0
    while IFS= read -r -d '' file; do
        process_file "$file"
        ((count++))
    done < <(find "$dest_dir" -type f -print0)
    
    log_success "Processed $count files successfully"
}

process_file() {
    local file=$1
    if file_is_text "$file"; then
        safe_replace "$file"
        rename_file "$file"
    else
        log_info "Skipping binary file: ${file/$dest_dir\//}"
    fi
}

safe_replace() {
    local file=$1
    local temp_file
    temp_file=$(mktemp)
    
    try_replace "$file" "$temp_file" && 
        mv "$temp_file" "$file" || 
        handle_rollback "$file" "$temp_file"
}

try_replace() {
    local src=$1 dest=$2
    case "$PLATFORM" in
        macOS) mac_sed_replace "$src" "$dest" ;;
        *) linux_sed_replace "$src" "$dest" ;;
    esac
}

linux_sed_replace() {
    sed -e "${replace_patterns[@]}" "$1" > "$2"
}

mac_sed_replace() {
    gsed -e "${replace_patterns[@]}" "$1" > "$2"
}