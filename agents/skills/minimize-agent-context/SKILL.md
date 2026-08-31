---
name: minimize-agent-context
description: Audit and reduce redundant, conflicting, obsolete, or unnecessarily loaded AI-agent instructions and customization files in a repository. Use only when the user explicitly invokes $minimize-agent-context.
---

# Minimize agent context

Use the requested repository, or the current workspace when none is specified.

1. Read repository guidance and inspect agent-related files before editing.
   Include `AGENTS.md`, configuration, skills, rules, hooks, MCP definitions,
   plugin metadata, and documentation that describes them.
2. Classify context cost:
   - Always loaded: minimize aggressively.
   - Loaded on activation or events: keep only necessary workflow details.
   - Client-only or ordinary documentation: simplify for maintenance, but do
     not claim it consumes model context automatically.
   Verify version-sensitive loading behavior from current official documentation
   when it affects a decision.
3. Measure relevant files before changes using bytes and lines. Treat these as
   comparison metrics, not exact token counts.
4. Preserve explicit user requirements, security boundaries, necessary domain
   knowledge, and functional behavior. Do not remove content solely because it
   is long.
5. Remove or consolidate:
   - duplicated or contradictory instructions;
   - vague advice and restatements of reliable platform defaults;
   - obsolete settings, placeholders, and unused mechanisms;
   - repeated explanations that can have one authoritative location.
6. Keep scope clear: global instructions contain only cross-project policy;
   project instructions contain repository-specific guidance; skills contain
   repeatable procedures. Prefer progressive disclosure for conditional detail.
7. Avoid adding dependencies, scripts, hooks, rules, or MCP servers merely to
   perform the cleanup.
8. Validate affected formats and behavior. Report before/after measurements,
   removals, preserved exceptions, and checks that could not run.
