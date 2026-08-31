#!/bin/sh

# Disable this repository's Codex configuration, global instructions, and
# personal skills. Only symbolic links that point to this exact repository are
# removed; unrelated files, directories, and links are never changed.

# Exit on the first failed command (-e) or use of an unset variable (-u).
set -eu

# Resolve paths exactly as install.sh does so ownership checks compare the same
# absolute repository paths.
repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
codex_source_dir="$repository_dir/codex"
skills_source_dir="$repository_dir/agents/skills"
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skills_home="$HOME/.agents/skills"
common_profile_name=codex-dotfiles
common_config_source="$codex_source_dir/config.toml"
common_config_target="$codex_home/$common_profile_name.config.toml"
legacy_config_target="$codex_home/config.toml"

# Restore a backup only when exactly one candidate exists. Choosing among
# multiple backups automatically could reactivate the wrong configuration, so
# ambiguous candidates are listed for manual review instead.
#
# Argument:
#   $1: destination path whose timestamped backups should be inspected
restore_backup() {
    target_path=$1
    backup_count=0
    backup_candidate=

    for backup_path in "${target_path}.backup."*; do
        # A POSIX shell can leave a non-matching glob unexpanded.
        if [ ! -e "$backup_path" ] && [ ! -L "$backup_path" ]; then
            continue
        fi

        backup_count=$((backup_count + 1))
        backup_candidate=$backup_path
    done

    if [ "$backup_count" -eq 0 ]; then
        printf 'No backup to restore for: %s\n' "$target_path"
        return
    fi

    if [ "$backup_count" -eq 1 ]; then
        mv -- "$backup_candidate" "$target_path"
        printf 'Restored: %s <- %s\n' "$target_path" "$backup_candidate"
        return
    fi

    printf 'Multiple backups found; none was restored for: %s\n' "$target_path" >&2
    printf 'Review these candidates and move the intended one manually:\n' >&2

    for backup_path in "${target_path}.backup."*; do
        if [ -e "$backup_path" ] || [ -L "$backup_path" ]; then
            printf '  %s\n' "$backup_path" >&2
        fi
    done
}

# Remove a destination only when it is a symlink created by this repository.
# After removal, restore the single unambiguous backup created by install.sh.
#
# Arguments:
#   $1: absolute repository-managed source path
#   $2: destination path expected by Codex
remove_managed_link() {
    source_path=$1
    target_path=$2

    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
        unlink "$target_path"
        printf 'Removed managed link: %s -> %s\n' "$target_path" "$source_path"
        restore_backup "$target_path"
        return
    fi

    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        printf 'Skipped path not owned by this repository: %s\n' "$target_path"
    else
        printf 'Not installed: %s\n' "$target_path"
    fi
}

# Remove the current profile link. Also recognize the config.toml link created
# by older revisions, but never touch an ordinary machine-specific config.toml.
remove_managed_link "$common_config_source" "$common_config_target"

if [ -L "$legacy_config_target" ] && [ "$(readlink "$legacy_config_target")" = "$common_config_source" ]; then
    remove_managed_link "$common_config_source" "$legacy_config_target"
fi

remove_managed_link "$codex_source_dir/AGENTS.md" "$codex_home/AGENTS.md"

# Disable every skill that still exists in this repository. Unrelated personal
# skills remain untouched. Skills removed from the repository are intentionally
# not guessed; stale links must be reviewed explicitly by the user.
if [ -d "$skills_source_dir" ]; then
    for skill_path in "$skills_source_dir"/*; do
        [ -d "$skill_path" ] || continue

        skill_name=${skill_path##*/}
        remove_managed_link "$skill_path" "$skills_home/$skill_name"
    done
fi

# Parent directories are deliberately preserved because they may contain
# unrelated Codex state or personal skills.
