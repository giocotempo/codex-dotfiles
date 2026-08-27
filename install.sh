#!/bin/sh

set -eu

repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
source_dir="$repository_dir/codex"
codex_home=${CODEX_HOME:-"$HOME/.codex"}
backup_timestamp=$(date '+%Y%m%d%H%M%S')

create_link() {
    source_path=$1
    target_path=$2

    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
        printf 'Already linked: %s -> %s\n' "$target_path" "$source_path"
        return
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup_path="${target_path}.backup.${backup_timestamp}"
        backup_suffix=1

        while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
            backup_path="${target_path}.backup.${backup_timestamp}.${backup_suffix}"
            backup_suffix=$((backup_suffix + 1))
        done

        printf 'Existing path found: %s\n' "$target_path"
        printf 'Moving it safely to: %s\n' "$backup_path"
        mv -- "$target_path" "$backup_path"
    fi

    ln -s "$source_path" "$target_path"
    printf 'Linked: %s -> %s\n' "$target_path" "$source_path"
}

if [ ! -f "$source_dir/config.toml" ] || [ ! -f "$source_dir/AGENTS.md" ]; then
    printf 'Error: expected repository files were not found in %s\n' "$source_dir" >&2
    exit 1
fi

mkdir -p "$codex_home"

create_link "$source_dir/config.toml" "$codex_home/config.toml"
create_link "$source_dir/AGENTS.md" "$codex_home/AGENTS.md"
