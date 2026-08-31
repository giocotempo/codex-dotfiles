# codex-dotfiles

Git-managed Codex CLI configuration, global instructions, and personal skills.

```text
codex-dotfiles/
├── agents/skills/notion-create-ticket/
│   ├── SKILL.md
│   └── agents/openai.yaml
├── agents/skills/minimize-agent-context/
│   ├── SKILL.md
│   └── agents/openai.yaml
├── codex/
│   ├── config.toml
│   └── AGENTS.md
├── install.sh
├── uninstall.sh
└── README.md
```

Do not store secrets or credentials here.

## Install

```bash
./install.sh
```

The installer creates these absolute symlinks:

```text
~/.codex/codex-dotfiles.config.toml
                      -> <repository>/codex/config.toml
~/.codex/AGENTS.md    -> <repository>/codex/AGENTS.md
~/.agents/skills/notion-create-ticket
                      -> <repository>/agents/skills/notion-create-ticket
~/.agents/skills/minimize-agent-context
                      -> <repository>/agents/skills/minimize-agent-context
```

`CODEX_HOME` replaces `~/.codex` when set. Personal skills remain under
`~/.agents/skills`.

The installer does not replace or edit the machine-specific
`~/.codex/config.toml`. Start Codex with the repository profile to load the
machine configuration first and overlay the common settings:

```bash
codex --profile codex-dotfiles
codex exec --profile codex-dotfiles '<prompt>'
```

The common profile wins when both files define the same key. Codex 0.134.0 and
later cannot select a default profile from `config.toml`, so `--profile` is
required. If desired, configure a machine-local shell alias outside this
repository:

```bash
alias codex='command codex --profile codex-dotfiles'
```

Existing managed targets are backed up before linking. An installation made by
an older repository revision is migrated: its `config.toml` link is removed and
the sole previous backup is restored. Multiple backups require manual selection.
Correct links are left unchanged, so repeated installation is safe.

## Uninstall

```bash
./uninstall.sh
```

The uninstaller removes only links owned by this repository and never changes
the machine-specific `config.toml`. It restores a replaced managed target when
exactly one backup exists and lists multiple candidates for manual selection.
Repeated uninstallation is safe.

## What each mechanism is for

| Mechanism | Purpose |
| --- | --- |
| Prompt | One task's intent or temporary constraint |
| `config.toml` | Runtime settings and permission boundaries |
| Global `AGENTS.md` | Short rules that should apply in every repository |
| Project `AGENTS.md` | Repository or directory-specific instructions |
| Skill | A reusable multi-step workflow loaded when selected |
| Command rule | Allow, prompt for, or forbid command prefixes outside the sandbox |
| Hook | Trusted automation at a lifecycle event |
| MCP | Live access to an external service or data source |

Prefer a prompt, `AGENTS.md`, or skill. Add rules, hooks, or MCP only for a
specific need. `AGENTS.md` is guidance, not a security boundary; use sandbox and
approval settings for permissions. Command rules are experimental. Never commit
MCP credentials.

This repository currently manages configuration, global instructions, and two
skills. It intentionally defines no hooks, command rules, or MCP servers.

## Loading and context lifecycle

For a new Codex run or TUI session:

1. Codex resolves configuration from highest to lowest precedence: CLI
   overrides, trusted project configuration (closest directory wins), selected
   profile, user configuration, system configuration, then defaults.
2. It discovers hooks, command rules, and MCP definitions from active
   configuration layers.
3. It builds `AGENTS.md` instructions: global first, then project root down to
   the working directory. Later, more local instructions take precedence.
4. It discovers skill names and descriptions. A complete `SKILL.md` is loaded
   only when that skill is selected.
5. During work, hooks run on matching events, command rules evaluate applicable
   command requests, and MCP results enter context only when tools are used.

This sequence describes lifecycle phases, not a timing contract between
integrations.

| Resource | Lifetime |
| --- | --- |
| Configuration, `AGENTS.md`, rules, hooks | Loaded for the run/session; restart after editing |
| Skill metadata | Available for selection during the session |
| Full skill instructions | Loaded for the task that selects the skill |
| Prompt and tool results | Kept in chat context; older content may be compacted into a summary |
| Local memories | Optional cross-chat state; off by default and not managed here |

Required policy belongs in `AGENTS.md`, not memory. Start a new session after
changing configuration or instructions for deterministic behavior.

Official documentation: [configuration](https://learn.chatgpt.com/docs/config-file/config-basic),
[`AGENTS.md`](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[skills](https://learn.chatgpt.com/docs/build-skills),
[rules](https://learn.chatgpt.com/docs/agent-configuration/rules),
[hooks](https://learn.chatgpt.com/docs/hooks), and
[MCP](https://learn.chatgpt.com/docs/extend/mcp).

## Personal skills

Audit and reduce unnecessary agent context with:

```text
$minimize-agent-context Audit and simplify the agent customization in this repository.
```

Create a Notion ticket with a destination supplied each time:

```text
$notion-create-ticket Create a bug ticket in <Notion URL>: <details>.
```

Both skills disable implicit invocation. Notion destinations are not stored in
Git, and Notion authentication is configured separately on each computer.

## Bootstrap another computer

```bash
git clone <repository-url>
cd codex-dotfiles
./install.sh
codex --profile codex-dotfiles
```
