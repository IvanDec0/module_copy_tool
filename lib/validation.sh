validate_inputs() {
    validate_reserved_names
    validate_syntax
    validate_paths
}

validate_reserved_names() {
    local reserved=("backup" "shared" "core" "base")
    array_contains "$plural_new" "${reserved[@]}" && 
        handle_error "'$plural_new' is a reserved name"
}

validate_syntax() {
    local name_regex='^[a-z][a-z0-9_-]{1,63}$'
    [[ ! "$plural_new" =~ $name_regex ]] &&
        handle_error "Invalid name format. Use lowercase, numbers, hyphens/underscores"
}

validate_paths() {
    [ ! -d "$src_dir" ] && handle_error "Source directory not found: $src_dir"
    [ -d "$dest_dir" ] && handle_error "Destination already exists: $dest_dir"
}