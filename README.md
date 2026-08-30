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

## Customization mechanism policy

Use the smallest mechanism that matches the need. Do not add a mechanism only
because Codex supports it; add one after a concrete need appears.

| Mechanism | Use it for | Do not use it for |
| --- | --- | --- |
| Prompt or thread context | A one-off request or temporary constraint | Behavior that must persist across sessions |
| `config.toml` | Runtime defaults and capability boundaries, such as sandboxing, approvals, models, features, and MCP server definitions | Development conventions or multi-step procedures |
| `AGENTS.md` | Durable guidance: conventions, commands, review expectations, and verification requirements | Security enforcement, executable automation, or long procedural playbooks |
| Skill | A repeatable workflow that benefits from steps, examples, scripts, references, or templates | A short rule that should apply to every task |
| Command `.rules` | Allowing, prompting for, or forbidding specific command prefixes when Codex requests execution outside the sandbox | Coding style, general agent behavior, or arbitrary event automation |
| Hook | Trusted code that must run at a specific lifecycle event, such as checking a tool call or validating a completed turn | Ordinary guidance or a problem already handled by configuration or command rules |
| MCP | Access to live external data or actions, such as issue trackers, design tools, or documentation services | Static instructions, local repository knowledge, or storing credentials |
| Plugin | Distributing a cohesive bundle of skills, hooks, MCP configuration, tools, or assets | A small personal customization that does not need packaging |

Apply these mechanisms in this order:

1. Put temporary intent in the prompt.
2. Put stable personal or project guidance in the nearest appropriate
   `AGENTS.md`.
3. Create a skill when a workflow repeats and needs more than a concise rule.
4. Add MCP only when the workflow needs an external system.
5. Use built-in sandbox and approval configuration for permission boundaries.
6. Add command rules only for repeated command-level approval decisions that
   the sandbox policy does not express.
7. Add hooks only when event-driven executable enforcement is necessary.
8. Package a plugin only when the customization needs to be installed or shared
   as one unit.

### Scope and safety

- Keep personal defaults global and project-specific behavior in the project.
  Global guidance lives in `~/.codex/AGENTS.md`; project guidance lives in an
  `AGENTS.md` at the relevant repository or directory level.
- Personal skills live under `~/.agents/skills`; project skills live under
  `.agents/skills` in the relevant repository.
- Treat `AGENTS.md` as guidance, not a security boundary. Prefer Codex sandbox
  and approval settings for access control, command rules for command-level
  decisions, and established project checks such as tests or linters for code
  correctness.
- Command rules are experimental. Keep them narrow, include matching and
  non-matching examples, and test them before relying on them.
- Hooks execute trusted commands or tools. Review their behavior, keep them
  narrowly scoped, and prefer one hook representation per configuration layer.
- Never commit credentials. MCP configuration may reference environment
  variable names, while each computer supplies the values separately.
- Document any executable, server, environment variable, or authentication step
  that another computer needs to use a managed skill, hook, or MCP server.

References: [customization](https://learn.chatgpt.com/docs/customization/overview),
[`AGENTS.md`](https://learn.chatgpt.com/docs/agent-configuration/agents-md),
[skills](https://learn.chatgpt.com/docs/build-skills),
[command rules](https://learn.chatgpt.com/docs/agent-configuration/rules),
[hooks](https://learn.chatgpt.com/docs/hooks), and
[MCP](https://learn.chatgpt.com/docs/extend/mcp).

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
