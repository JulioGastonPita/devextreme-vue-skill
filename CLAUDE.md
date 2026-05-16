# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A collection of development rules and Claude Code skills for building **Vue 3 + DevExtreme** applications. It contains:

- `rules/` — Opinionated coding standards for DevExtreme + Vue 3 (used as Cursor rules or reference guidelines)
- `.agents/skills/skill-creator/` — A skill for creating, testing, and iterating on Claude Code skills
- `skills-lock.json` — Tracks installed skills and their source/hash (analogous to a package lock file)

## Project structure

```
rules/                        # DevExtreme + Vue 3 dev standards
  code-quality.md             # Component size, naming, separation of concerns
  dx-components.md            # DX component usage, imports, baseline configs
  performance.md              # Grid, Vue 3, and lazy-loading optimizations
  state-and-data.md           # Pinia, TanStack Query, CustomStore patterns

.agents/skills/skill-creator/ # Skill for creating/improving Claude skills
  SKILL.md                    # Main skill instructions (draft → eval → iterate loop)
  agents/                     # Specialized subagent prompts (grader, comparator, analyzer)
  scripts/                    # Python scripts for running evals and optimizing descriptions
  eval-viewer/                # HTML viewer + generate_review.py for qualitative review
  references/schemas.md       # JSON schemas for evals.json, grading.json, benchmark.json
  assets/eval_review.html     # Template for description-optimization eval review UI

skills-lock.json              # Skill registry (source: github, anthropics/skills)
```

## Rules — DevExtreme + Vue 3 standards

The `rules/` files define non-negotiable patterns for any Vue 3 + DevExtreme project. Key decisions:

**Components** (`dx-components.md`): Always import DevExtreme components individually (tree-shaking). Never use native HTML equivalents (`<table>` → `DxDataGrid`, `<select>` → `DxSelectBox`, etc.). Use `notify()` from `devextreme/ui/notify` — never `DxToast`. Theme CSS is imported once in `main.ts`; override DX styles with `:deep()` — never `!important`.

**Architecture** (`code-quality.md`): Views are thin; logic lives in composables. API calls belong only in `src/services/`. Queries/mutations belong only in `src/queries/` (TanStack Query). Pinia stores hold only business/application state — UI state (loading, popup open) stays in local `ref`. Composition API (`<script setup lang="ts">`) everywhere; Options API is banned in new code.

**Data layer** (`state-and-data.md`): Pass `CustomStore` / `ODataStore` / `ArrayStore` to `DxDataGrid` — never a raw reactive array. The `useGridStore<T>` composable in `src/composables/` is the standard wrapper for CRUD grids. Always type DevExtreme events (`RowInsertedEvent`, `ValueChangedEvent`, etc.) — never `any`.

**Performance** (`performance.md`): Always set `:remote-operations="true"` and `:repaint-changes-only="true"` on server-backed grids. `editorOptions` must be `const` defined outside the template to prevent per-tick re-renders.

## skill-creator — how to use it

Invoke via `/skill-creator` (or the skill triggers automatically when the user wants to create/improve/test a skill).

The core loop: **draft → run test cases in parallel (with-skill + baseline) → grade assertions → show `generate_review.py` viewer to user → iterate**.

Key operational notes:
- All eval results go in `<skill-name>-workspace/iteration-N/eval-<ID>/with_skill/` (and `without_skill/` or `old_skill/` for baselines)
- Always spawn with-skill AND baseline runs in the same turn
- Generate the eval viewer with `generate_review.py` **before** editing the skill yourself — get human eyes on outputs first
- Description optimization uses `scripts/run_loop.py` — pass the model ID from the current session
- In headless/Cowork environments: use `--static <output_path>` instead of the browser server

Scripts are run from the `.agents/skills/skill-creator/` directory:
```bash
python -m scripts.aggregate_benchmark <workspace>/iteration-N --skill-name <name>
python -m scripts.run_loop --eval-set <path> --skill-path <path> --model <model-id> --max-iterations 5
python -m scripts.package_skill <path/to/skill-folder>
```
