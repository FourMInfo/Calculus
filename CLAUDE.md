# CLAUDE.md

Claude Code does not read `.github/copilot-instructions.md` or the `applyTo`-scoped files in
`.github/instructions/` — both are VS Code Copilot mechanisms. This file bridges them, so the
two assistants work from one source instead of two copies that drift.

This file is **shared**: copied unchanged into every math study repo from the hub
(`FourMInfo/math_tech_study`, `project_resources/claude/CLAUDE.template.md`) and byte-identical
everywhere. Never edit a repo's copy — change the hub template and propagate.

## Repo instructions (loaded below)

@.github/copilot-instructions.md

@.github/instructions/ecosystem.instructions.md

@.github/instructions/project.instructions.md

## Path-scoped instructions

Copilot loads these automatically by glob. Claude Code does not, so read the matching file
before editing in that area:

| Before editing | Read |
|---|---|
| `src/**` | `.github/instructions/source.instructions.md` |
| `test/**` | `.github/instructions/testing.instructions.md` |
| `docs/**` | `.github/instructions/docs.instructions.md` |
| `notebooks/**` | `.github/instructions/notebooks.instructions.md` |
