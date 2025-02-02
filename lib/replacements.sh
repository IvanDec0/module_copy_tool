#!/usr/bin/env bash
# @title Text Replacement Engine
# @description Handles safe text/file replacements

setup_replacements() {
    [ -z "$module_name" ] && handle_error "module_name not set for replacements"
    [ -z "$plural_new" ] && handle_error "plural_new not set for replacements"
    singular_old="${module_name%s}"
    plural_old="$module_name"
    singular_new="${plural_new%s}"
    [ -z "$singular_old" ] && handle_error "Failed to derive singular form of source module"
    [ -z "$singular_new" ] && handle_error "Failed to derive singular form of target module"
    replace_patterns=(
        "s/${singular_old}/${singular_new}/g"
        "s/${plural_old}/${plural_new}/g"
    )
    export replace_patterns
    log_info "Setup replacements: singular_old=$singular_old, singular_new=$singular_new, plural_old=$plural_old, plural_new=$plural_new"
}

perform_replacements() {
    if [[ "${CONFIG[dry_run]:-false}" == true ]]; then
        simulate_replacements
    else
        execute_replacements
    fi
    log_success "Replacements complete"
    return 0
}

execute_replacements() {
    [ -z "$dest_dir" ] && handle_error "Destination directory not set"
    local count=0
    log_info "Searching for files in: $dest_dir"
    while IFS= read -r -d '' file; do
        log_info "Processing file: $file"
        process_file "$file"
        ((count++))
    done < <(find "$dest_dir" -type f -print0)
    log_success "Processed $count files successfully"
    return 0
}

process_file() {
    local file=$1
    log_info "Checking if file is text: $file"
    if file_is_text "$file"; then
        log_info "Performing replacements in file: $file"
        safe_replace "$file"
        rename_file "$file"
    else
        log_info "Skipping binary file: ${file/$dest_dir\//}"
    fi
    return 0
}

file_is_text() {
    local file=$1
    file "$file" | grep -qE 'text|empty'
    return 0
}

rename_file() {
    local file=$1
    local new_name="$file"

    log_info "Original file name: $file"

    # Replace singular_old if it exists in the file name
    if [[ "$new_name" == *"$singular_old"* ]]; then
        log_info "Replacing singular_old ($singular_old) with singular_new ($singular_new)"
        new_name="${new_name}"
    fi

    # Replace plural_old if it exists in the file name
    if [[ "$new_name" == *"$plural_old"* ]]; then
        log_info "Replacing plural_old ($plural_old) with plural_new ($plural_new)"
        new_name="${new_name}"
    fi

    log_info "New file name: $new_name"

    # Rename the file if the name has changed
    if [ "$file" != "$new_name" ]; then
        log_info "Renaming file: ${file/$dest_dir\//} → ${new_name/$dest_dir\//}"
        mv "$file" "$new_name" || handle_error "Failed to rename file: $file"
    else
        log_info "No renaming needed for file: ${file/$dest_dir\//}"
    fi
}

safe_replace() {
    local file=$1
    log_info "Processing replacements in file: ${file/$dest_dir\//}"

    # Ensure replace_patterns array is set
    if [ -z "${replace_patterns+x}" ]; then
        log_error "Replace patterns not initialized"
        return 1
    fi

    # Perform replacements using sed
    for pattern in "${replace_patterns[@]}"; do
        log_info "Applying pattern: $pattern to file: $file"
        if ! sed -i.bak -E "$pattern" "$file"; then
            log_error "Replacement failed for pattern: $pattern in file: $file"
            return 1
        fi
    done

    # Remove backup files created by sed
    find "$(dirname "$file")" -name "*.bak" -delete

    log_success "Replacements completed successfully for file: ${file/$dest_dir\//}"
}