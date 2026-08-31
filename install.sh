#!/bin/sh

# Install this repository's Codex configuration, global instructions, and
# personal skills as symbolic links. The script is idempotent for a fixed
# repository state: after a successful run, later runs detect the same links and
# make no filesystem changes.

# Exit on the first failed command (-e) or use of an unset variable (-u). This
# prevents the script from continuing after a partial or ambiguous operation.
set -eu

# Resolve the physical directory containing this script so every link target is
# absolute and independent of the directory from which the installer is run.
repository_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

# Repository-managed sources.
codex_source_dir="$repository_dir/codex"
skills_source_dir="$repository_dir/agents/skills"

# Codex honors CODEX_HOME for its configuration. Personal skills have their own
# documented user location and therefore remain under $HOME/.agents/skills.
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skills_home="$HOME/.agents/skills"
common_profile_name=codex-dotfiles
common_config_source="$codex_source_dir/config.toml"
common_config_target="$codex_home/$common_profile_name.config.toml"
legacy_config_target="$codex_home/config.toml"

# Use one timestamp for every backup produced by this run. A numeric suffix is
# added below if a backup with the same timestamp already exists.
backup_timestamp=$(date '+%Y%m%d%H%M%S')

# Create one managed symbolic link without silently overwriting anything.
#
# Arguments:
#   $1: absolute repository-managed source path
#   $2: destination path expected by Codex
create_link() {
    source_path=$1
    target_path=$2

    # This is the idempotent no-op path. The installer itself creates absolute
    # links, so an unchanged installation compares equal on every later run.
    if [ -L "$target_path" ] && [ "$(readlink "$target_path")" = "$source_path" ]; then
        printf 'Already linked: %s -> %s\n' "$target_path" "$source_path"
        return
    fi

    # Preserve any conflicting regular file, directory, different symlink, or
    # broken symlink. Testing both -e and -L is necessary because -e is false
    # for a broken symlink.
    if [ -e "$target_path" ] || [ -L "$target_path" ]; then
        backup_path="${target_path}.backup.${backup_timestamp}"
        backup_suffix=1

        # Never overwrite an earlier backup, including one created during the
        # same second by another installer run.
        while [ -e "$backup_path" ] || [ -L "$backup_path" ]; do
            backup_path="${target_path}.backup.${backup_timestamp}.${backup_suffix}"
            backup_suffix=$((backup_suffix + 1))
        done

        printf 'Existing path found: %s\n' "$target_path"
        printf 'This installer does not merge it with the repository-managed file.\n'
        printf 'Moving it safely to: %s\n' "$backup_path"
        mv -- "$target_path" "$backup_path"
    fi

    # Create the link only after any conflict has been moved safely. If this
    # command fails, set -e stops the script and the original remains available
    # at the reported backup path.
    ln -s "$source_path" "$target_path"
    printf 'Linked: %s -> %s\n' "$target_path" "$source_path"
}

# Older revisions linked the common configuration directly over config.toml.
# Migrate only that exact repository-owned link; an ordinary machine-specific
# config.toml is never changed. Restore the old backup when there is one clear
# candidate. Stop before changing anything when several backups are ambiguous.
migrate_legacy_config_link() {
    if [ ! -L "$legacy_config_target" ] || [ "$(readlink "$legacy_config_target")" != "$common_config_source" ]; then
        return
    fi

    backup_count=0
    backup_candidate=

    for backup_path in "${legacy_config_target}.backup."*; do
        if [ ! -e "$backup_path" ] && [ ! -L "$backup_path" ]; then
            continue
        fi

        backup_count=$((backup_count + 1))
        backup_candidate=$backup_path
    done

    if [ "$backup_count" -gt 1 ]; then
        printf 'Error: multiple backups exist for the legacy managed config: %s\n' "$legacy_config_target" >&2
        printf 'Select and restore the intended backup manually before rerunning install.sh.\n' >&2
        return 1
    fi

    unlink "$legacy_config_target"
    printf 'Removed legacy managed link: %s -> %s\n' "$legacy_config_target" "$common_config_source"

    if [ "$backup_count" -eq 1 ]; then
        mv -- "$backup_candidate" "$legacy_config_target"
        printf 'Restored machine configuration: %s <- %s\n' "$legacy_config_target" "$backup_candidate"
    else
        printf 'No previous machine configuration was found; leaving %s absent.\n' "$legacy_config_target"
    fi
}

# Validate repository inputs before changing either destination tree.
if [ ! -f "$codex_source_dir/config.toml" ] || [ ! -f "$codex_source_dir/AGENTS.md" ]; then
    printf 'Error: expected repository files were not found in %s\n' "$codex_source_dir" >&2
    exit 1
fi

if [ ! -d "$skills_source_dir" ]; then
    printf 'Error: expected skills directory was not found: %s\n' "$skills_source_dir" >&2
    exit 1
fi

# mkdir -p is itself idempotent: existing directories are left unchanged.
mkdir -p "$codex_home" "$skills_home"

# Migrate the old whole-file replacement layout, then install the common
# settings as a named profile. Codex overlays this profile on the untouched
# machine-specific config.toml when invoked with --profile codex-dotfiles.
migrate_legacy_config_link
create_link "$common_config_source" "$common_config_target"
create_link "$codex_source_dir/AGENTS.md" "$codex_home/AGENTS.md"

# Install each immediate child of agents/skills as an independent personal
# skill. Individual links let this repository coexist with skills installed by
# other tools instead of taking ownership of the entire user skills directory.
for skill_path in "$skills_source_dir"/*; do
    # When the directory has no children, a POSIX shell may leave the glob
    # unexpanded. It is not a directory, so skip it safely.
    [ -d "$skill_path" ] || continue

    # Refuse malformed managed skill directories rather than exposing them to
    # Codex as if installation had succeeded.
    if [ ! -f "$skill_path/SKILL.md" ]; then
        printf 'Error: managed skill is missing SKILL.md: %s\n' "$skill_path" >&2
        exit 1
    fi

    skill_name=${skill_path##*/}
    create_link "$skill_path" "$skills_home/$skill_name"
done

# Deliberately do not delete unrelated or formerly managed skills. Automatic
# pruning would make the installer destructive; stale links can be reviewed and
# removed explicitly by the user.
