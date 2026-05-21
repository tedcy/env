#!/usr/bin/env bash

clang_make_require_glibc() {
    local min_version="$1"
    local name="$2"
    local current_version
    current_version=$(ldd --version 2>/dev/null | sed -n '1{s/.* //;p;}')

    if [ -z "$current_version" ] || [ "$(printf '%s\n%s\n' "$min_version" "$current_version" | sort -V | head -1)" != "$min_version" ]; then
        echo "clang_make: $name requires glibc >= $min_version, current is ${current_version:-unknown}" >&2
        exit 1
    fi
}
