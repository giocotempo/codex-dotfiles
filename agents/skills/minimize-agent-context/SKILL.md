---
name: minimize-agent-context
description: Audit and reduce redundant, conflicting, obsolete, or unnecessarily loaded agent instructions and customization. Use only when the user explicitly invokes $minimize-agent-context.
---

# Minimize agent context

Use the requested repository, or the current workspace when none is specified.

1. Before editing, read repository guidance and inspect `AGENTS.md`, configuration,
   skills, rules, hooks, MCP and plugin definitions, and related documentation.
2. Classify files as always loaded, activation/event loaded, or client/ordinary
   documentation. Minimize the first most aggressively; do not claim ordinary
   files consume model context. Verify version-sensitive behavior in current
   official documentation when it affects a decision.
3. Measure relevant files in bytes and lines before and after changes; these are
   comparison metrics, not token counts.
4. Preserve user requirements, security boundaries, necessary domain knowledge,
   and behavior. Remove or consolidate:
   - duplicated or contradictory instructions;
   - vague advice and restatements of reliable platform defaults;
   - obsolete settings, placeholders, and unused mechanisms;
   - repeated explanations that can have one authoritative location.
5. Keep scope clear: global instructions contain only cross-project policy;
   project instructions contain repository-specific guidance; skills contain
   repeatable procedures. Prefer progressive disclosure for conditional detail.
6. Do not add dependencies or integrations merely to perform the cleanup.
7. Validate affected formats and behavior. Report before/after measurements,
   removals, preserved exceptions, and checks that could not run.
