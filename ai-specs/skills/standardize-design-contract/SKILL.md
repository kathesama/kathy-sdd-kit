---
name: standardize-design-contract
description: Use when a frontend/UI repository needs a root DESIGN.md created or refreshed from existing local design sources before UI planning or implementation.
---

# Skill: Standardize Design Contract

## Purpose

Create or update root `DESIGN.md` as the SDD-facing design agent contract for a
frontend/UI repository. The contract must point to the detailed design source,
summarize agent rules, and avoid inventing a new brand or visual system.

## Usage

```
/standardize-design-contract
```

Default output:

`DESIGN.md` in the consuming repository root.

## Required Inputs

Read:

- `.sdd-kit/ai-specs/specs/design-system-standards.mdc` or
  `ai-specs/specs/design-system-standards.mdc`
- `.sdd-kit/ai-specs/specs/design-md-template.md` or
  `ai-specs/specs/design-md-template.md`
- existing root `DESIGN.md` when present
- local design sources discovered in the repository

Look for design sources in this order:

1. root `DESIGN.md`
2. `docs/design-system/MASTER.md`
3. `docs/design/MASTER.md`
4. `docs/design-system/**` or `docs/design/**`
5. `design-system/**/MASTER.md` for repositories with an existing local convention
6. `design-system/**`
7. Storybook config, stories, or design docs
8. token files such as `tokens.json`, `theme.json`, CSS variables, or style dictionaries
9. Tailwind config files
10. shadcn/ui theme or component configuration
11. shared UI components and layout primitives
12. docs, ADRs, screenshots, or brand guidelines

## Source Selection

- If the user names a master design document, read it first and treat it as
  primary unless it is missing.
- If exactly one authoritative design source is obvious, use it as primary and
  record the secondary sources reviewed.
- Prefer `docs/design-system/MASTER.md` as the standard detailed design source
  when it exists.
- If `design-system/**/MASTER.md` exists, treat it as a high-priority
  compatibility candidate for repositories that already use that convention.
- If multiple plausible primary sources exist and priority is unclear, ask the
  user which source should be treated as authoritative before writing
  `DESIGN.md`.
- If no durable design source exists beyond current UI code, ask the user
  whether to proceed from observed conventions or to stop until design guidance
  is provided.

Ask at most one concise question when blocked. Examples:

- `Which document should be the primary design source for DESIGN.md?`
- `No authoritative design source was found. Should I derive DESIGN.md from current UI conventions?`

## Workflow

1. Inspect the repository for candidate design sources.
2. Choose the primary source using `Source Selection`.
3. Read the primary source before drafting `DESIGN.md`.
4. Read only the secondary sources needed to fill gaps or confirm conflicts.
5. Create or update root `DESIGN.md` using the template structure.
6. Reference the primary source in `Source Of Truth`; do not duplicate long
   design-system documentation.
7. Preserve project-specific tokens, components, terminology, and constraints.
8. Add `Source Of Truth`, `Reviewed Sources`, `Agent Rules`, `Conflicts`, and
   `Gaps` sections.
9. If updating an existing `DESIGN.md`, preserve useful project-specific
   sections and remove obsolete generic template text.

## Output Requirements

`DESIGN.md` must include:

- YAML front matter with project name, version, source references, and
  machine-readable tokens when available
- `Overview`
- `Source Of Truth`
- `Reviewed Sources`
- `Agent Rules`
- `Colors`
- `Typography`
- `Layout`
- `Elevation & Depth`
- `Shapes`
- `Components`
- `States & Accessibility`
- `Do's and Don'ts`
- `Conflicts`
- `Gaps`

When a value is not available, write an explicit gap instead of inventing it.

## Rules

- Do not create a new brand, palette, type scale, radius scale, or component
  language unless the user explicitly asks for a redesign.
- Do not modify UI code, token files, Storybook, screenshots, or design-system
  source docs from this skill.
- Do not move an existing master design document into `docs/` unless the user
  explicitly asks for a documentation reorganization.
- Do not treat a copied template as complete project design guidance.
- If a primary source and secondary source conflict, prefer the primary source
  and record the conflict.
- If the source priority is unclear, ask before writing.
- Output in English unless the repository's design documentation is clearly in
  another language.
