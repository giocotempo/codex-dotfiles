# Global development policy

Keep project-specific rules in the project's own `AGENTS.md`.

## Code changes

- Understand the relevant code before changing it.
- Keep changes scoped to the user's request; do not perform unrelated refactoring.
- Preserve the existing architecture, conventions, and naming unless there is a clear reason to change them.
- Do not modify generated files manually unless that is the appropriate workflow.

## Git

- Inspect changes before committing.
- Never force push unless explicitly requested.
- Do not push directly to protected or default branches unless explicitly requested.
- Do not commit secrets or credentials.

## Testing

- Run relevant tests after code changes when practical.
- Do not delete, disable, or weaken tests simply to make them pass.
- Clearly report tests that could not be executed.

## Dependencies

- Avoid introducing unnecessary dependencies.
- Check whether existing dependencies can solve the problem before adding new ones.
