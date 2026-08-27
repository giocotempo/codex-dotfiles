# codex-dotfiles

Minimal, Git-managed configuration and global development instructions for the
Codex CLI.

## What this repository manages

```text
codex-dotfiles/
├── codex/
│   ├── config.toml
│   └── AGENTS.md
├── install.sh
└── README.md
```

- `codex/config.toml` contains Codex CLI and runtime configuration.
- `codex/AGENTS.md` contains development rules shared across projects.
- `install.sh` connects these files to the locations Codex expects.

Machine-specific secrets and credentials do not belong in this repository.

## Install

Run the installer from anywhere:

```bash
./install.sh
```

The installer creates `~/.codex` when needed and creates these absolute symbolic
links:

```text
~/.codex/config.toml -> <repository>/codex/config.toml
~/.codex/AGENTS.md   -> <repository>/codex/AGENTS.md
```

If a target already links to the correct repository file, the installer leaves
it unchanged. If a different file or link exists, the installer moves it to a
timestamped backup in `~/.codex` before creating the new link. It reports every
action it takes, so repeated runs are safe.

If `CODEX_HOME` is set, the installer uses that directory instead of
`~/.codex`, matching Codex CLI behavior.

## Configuration and instructions

These files have distinct responsibilities:

- `config.toml` controls Codex CLI/runtime behavior, including sandboxing and
  approval policy. The included configuration allows workspace inspection but
  requires user approval before file modifications.
- The global `AGENTS.md` provides broadly applicable development rules for all
  projects. Codex reads it from its home directory.
- A project's own `AGENTS.md` contains repository-specific architecture,
  conventions, commands, and constraints. Project instructions are layered on
  top of the global rules, and more specific instructions closer to the working
  directory take precedence.

Keep project-specific details out of the global file.

## Bootstrap another computer

Clone the repository, enter it, and run the installer:

```bash
git clone <repository-url>
cd codex-dotfiles
./install.sh
```

After installation, update the shared configuration normally with Git. Because
Codex reads through the symlinks, changes in the repository take effect for new
Codex sessions without copying files into `~/.codex` manually.
