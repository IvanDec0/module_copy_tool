#!/usr/bin/env bash
# @title Validation Library
# @description Input validation and safety checks

validate_restore() {
    [ -z "$BACKUP_DIR" ] && handle_error "BACKUP_DIR variable not set"
    [ -z "$module_name" ] && handle_error "Module name required for restore"
    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
    src_dir="${BASE_DIR}/${module_name}"
    [ ! -d "$src_dir" ] && mkdir -p "$src_dir"
}

validate_inputs() {
    [ -z "$plural_new" ] && handle_error "New module name is required"
    [ -z "$module_name" ] && handle_error "Source module name is required"
    validate_reserved_names
    validate_syntax
    validate_paths
    return 0
}

validate_reserved_names() {
    local reserved=("backup" "shared" "core" "base")
    for name in "${reserved[@]}"; do
        [ "$plural_new" = "$name" ] && handle_error "'$plural_new' is a reserved directory name"
    done
    return 0
}

validate_syntax() {
    local name_regex='^[a-z][a-z0-9_-]{1,63}$'
    [[ ! "${plural_new:-}" =~ $name_regex ]] && \
        handle_error "Invalid name format. Use lowercase, numbers, hyphens/underscores"
    return 0
}

validate_paths() {
    [ -z "$src_dir" ] && handle_error "Source directory path not set"
    [ -z "$dest_dir" ] && handle_error "Destination directory path not set"
    [ ! -d "$src_dir" ] && handle_error "Source directory not found: $src_dir"
    [ -d "$dest_dir" ] && handle_error "Destination already exists: $dest_dir"
    [ ! -w "$(dirname "$src_dir")" ] && handle_error "Source directory not writable"
    [ ! -w "$(dirname "$dest_dir")" ] && handle_error "Destination directory not writable"
    return 0
}

validate_environment() {
    [ -z "$SCRIPT_DIR" ] && handle_error "SCRIPT_DIR not set"
    [ -z "$BASE_DIR" ] && handle_error "BASE_DIR not set"
    [ -z "$BACKUP_DIR" ] && handle_error "BACKUP_DIR not set"
    [ ! -d "$BASE_DIR" ] && mkdir -p "$BASE_DIR"
    [ ! -d "$BACKUP_DIR" ] && mkdir -p "$BACKUP_DIR"
    return 0
}

validate_required_params() {
    [ -z "$module_name" ] && handle_error "Source module name (-m) is required"
    [ -z "$plural_new" ] && handle_error "New module name (-n) is required"
    return 0
}