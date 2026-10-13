---
name: assess-idea
description: Optionally assess an uncertain idea before SDD refinement using evidence for and against it.
---

# Skill: Assess Idea

## Required Inputs

Use the user's problem, existing repository/product context and available evidence.
This workflow is opt-in; do not add it to already-refined tickets by default.

## Workflow

Write `.ai-specs/changes/{TICKET}/ASSESSMENT-{TICKET}.md` with problem, intended
beneficiary, evidence for, evidence against, alternatives (including doing
nothing), assumptions, cheapest discriminating check and decision:

- `go`: enough evidence to refine; does not approve implementation.
- `clarify`: name the material unknown and why it changes the decision.
- `kill`: explain contrary evidence and conditions that could reopen the idea.

Reuse answers already present in the conversation or repository. Ask only about
a blocking unknown. Preserve contrary evidence and distinguish observations
from inference; do not manufacture research, market validation or certainty.

Examples: a reproducible user failure with a bounded fix can go to refinement;
two incompatible meanings of a required outcome need clarification; an idea
duplicating an adequate existing feature can be killed with the source cited.
