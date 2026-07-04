# DESIGN.md Template

Copy this file to the root of a consuming repository as `DESIGN.md` when a
frontend/UI project needs an agent-facing design contract.

`DESIGN.md` is not the detailed design-system documentation. Prefer
`docs/design-system/MASTER.md` for the human-facing master source, then use
`DESIGN.md` as the root contract that tells agents how to apply that source.

```md
---
version: alpha
name: Project Design Agent Contract
description: Agent-facing design rules and summary for this product.
sourceOfTruth:
  - docs/design-system/MASTER.md
reviewedSources: []
colors: {}
typography: {}
rounded: {}
spacing: {}
components: {}
---

## Overview

Summarize the product personality, audience, density, and UI tone. Keep this
practical enough that an agent can make routine UI choices without inventing a
new visual language.

## Source Of Truth

Reference the detailed design source for this product. Prefer
`docs/design-system/MASTER.md` for new projects. If this repository already uses
another master document, link it here and state that it is the primary source.

If this file conflicts with the primary source, the primary source wins unless
the ticket explicitly changes the design contract.

## Reviewed Sources

List the local sources used to create this contract, such as Storybook, tokens,
Tailwind config, shadcn theme files, shared components, ADRs, screenshots, or
brand guidelines.

## Agent Rules

- Read the primary design source before changing visual behavior.
- Use existing tokens, components, spacing, typography, radius, and states.
- Do not introduce a new visual language unless the ticket explicitly asks for
  it.
- If a required token or component is missing, record the gap before inventing
  one.
- Keep accessibility, responsive behavior, and component states consistent with
  the primary design source.

## Colors

Summarize color roles from the primary source. Define DESIGN.md color tokens at
the top level in YAML front matter. Nested tokens may use dot-separated
references in tooling, such as `colors.background.light`. Record gaps instead
of inventing values.

## Typography

Summarize type scale, hierarchy, and usage from the primary source.

## Layout

Summarize spacing rhythm, container widths, density, responsive behavior, and
layout constraints from the primary source.

## Elevation & Depth

Summarize how the product communicates hierarchy: borders, shadows, layers,
tonal surfaces, or flat composition.

## Shapes

Summarize radius, border weight, icon style, and shape language.

## Components

Summarize expected styling for common components such as buttons, inputs,
cards, tabs, modals, menus, banners, tables, and navigation.

## States & Accessibility

Describe focus, hover, active, disabled, loading, empty, error, and
permission-limited states. Record contrast, keyboard, and screen-reader
expectations.

## Do's and Don'ts

- Do use design tokens instead of hard-coded visual values.
- Do keep WCAG AA contrast for normal text.
- Do preserve responsive behavior across supported viewports.

## Conflicts

Record conflicts between design sources. Prefer the declared source of truth
unless the ticket explicitly changes it.

## Gaps

Record missing design decisions instead of inventing values.
```
