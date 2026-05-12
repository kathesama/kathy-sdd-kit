# DESIGN.md Template

Copy this file to the root of a consuming repository as `DESIGN.md` when the
project needs a persistent visual identity contract for AI agents.

```md
---
version: alpha
name: Project Design System
description: Visual identity contract for this product.
colors:
  primary: "#1A1C1E"
  on-primary: "#FFFFFF"
  secondary: "#6C7278"
  tertiary: "#B8422E"
  neutral: "#F7F5F2"
  surface: "#FFFFFF"
  on-surface: "#1A1C1E"
  border: "#D9DEE3"
  error: "#B42318"
  on-error: "#FFFFFF"
typography:
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: 700
    lineHeight: 40px
  headline-md:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: 600
    lineHeight: 32px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: 400
    lineHeight: 24px
  label-sm:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: 600
    lineHeight: 16px
rounded:
  none: 0px
  sm: 4px
  md: 8px
  lg: 12px
  full: 9999px
spacing:
  xs: 4px
  sm: 8px
  md: 16px
  lg: 24px
  xl: 32px
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.on-primary}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
    height: 40px
    padding: 0 16px
  button-danger:
    backgroundColor: "{colors.error}"
    textColor: "{colors.on-error}"
    typography: "{typography.label-sm}"
    rounded: "{rounded.md}"
    height: 40px
    padding: 0 16px
  card:
    backgroundColor: "{colors.surface}"
    textColor: "{colors.on-surface}"
    rounded: "{rounded.md}"
    padding: "{spacing.lg}"
---

## Overview

Describe the product personality, audience, density, and emotional tone. Keep
this practical enough that an agent can decide between competing UI choices.

## Colors

Explain how the color roles should be used.

- **Primary:** Main brand/action color.
- **Secondary:** Utility text, borders, and lower-emphasis UI.
- **Tertiary:** Accent for selected or high-attention moments.
- **Neutral/Surface:** Page and container foundations.
- **Error:** Destructive or failed states.

## Typography

Describe the type scale, hierarchy, and where each role applies.

## Layout

Describe the spacing rhythm, container widths, density, responsive behavior, and
where content should feel compact or spacious.

## Elevation & Depth

Describe how the product communicates hierarchy: borders, shadows, layers,
tonal surfaces, or flat composition.

## Shapes

Describe radius, border weight, icon style, and whether components should feel
sharp, soft, dense, editorial, utilitarian, or playful.

## Components

Describe expected styling for common components such as buttons, inputs, cards,
tabs, modals, menus, banners, tables, and navigation.

## Do's and Don'ts

- Do use design tokens instead of hard-coded visual values.
- Do keep WCAG AA contrast for normal text.
- Do preserve responsive behavior across supported viewports.
- Don't introduce new colors, fonts, spacing scales, or radius scales without
  changing this file deliberately.
- Don't treat screenshots as a substitute for the token contract when tokens
  exist.
```
