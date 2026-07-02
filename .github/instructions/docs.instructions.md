---
applyTo: 'docs/**'
---
# Documentation Conventions

## Structure for Mathematical Concept Documentation

Documentation in `docs/src/` explains general math concepts (not code). Follow these patterns:

**Document Organization:**
- Start with concept overview and [MathWorld](https://mathworld.wolfram.com/) link in opening paragraph
- Use hierarchical headings: `##` for major topics, `###` for subtopics
- Group related concepts logically (e.g., by operation type, by geometric meaning)
- Include real-world applications section

**Content Style:**
- **Definitions first**: Clear, precise mathematical definitions with MathWorld links
- **Define before use**: All terms must be defined before they are used elsewhere in the document. This principle drives the order and structure of sections—ensure logical progression where each concept builds only on previously defined terms.
- **Build progressively**: Simple concepts → complex relationships → applications
- **Multiple representations**: Equations, tables, visual aids (SVG diagrams when helpful)
- **Context matters**: Explain _why_ concepts are important, not just _what_ they are
  - Example: "Projections are fundamental to least-squares approximation, computer graphics, and data compression"
- **Derivations**: Show mathematical reasoning step-by-step (see projection and transformation matrix derivations)

## Mathematical Notation, MathJax3 & MathWorld Links

See the `documenter-jl-conventions` skill for:
- LaTeX formatting rules (`$$` display blocks, bullet point style, `\lbrack`, `\lvert`)
- MathJax3 configuration for `docs/make.jl`
- MathWorld linking convention

## Visual Elements

- SVG diagrams for geometric concepts
- Tables for reference data (common values, conversions)
- Consistent styling in diagrams (colors, labels, annotations)

## Markdown Conventions

- _Underscore_ for emphasis (not asterisk)
- **Bold** for important terms and section labels
- Fix all linting issues after editing (except config files)
- Code blocks with language tags: ````julia` for Julia examples
- Follow the pattern of existing function documentation in src directory

## Cross-Document Links

See `documenter-jl-conventions` skill for section anchor rules and examples.

## Documentation Structure

- **Cross-Repository Deployment**: Deploys to math_tech_study repository
- **Subdirectory Pattern**: Available at study.fourm.info/linear_algebra/
- **Auto-docs Integration**: Uses `@autodocs` for automatic function documentation
- **Mathematical Notation**: Supports LaTeX rendering in documentation

## Building Documentation

```bash
julia --project=. docs/make.jl
```

**IMPORTANT**: Always run `julia --project=. docs/make.jl` after making changes to documentation files in `docs/src/`. This allows the user to preview changes in the browser immediately without running the build manually.

For a live, auto-refreshing preview served from `docs/build/`, use `LiveServer` (declared in `docs/Project.toml`). See the `documenter-jl-conventions` skill for the exact `serve` command.
