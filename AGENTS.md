# AGENTS.md — `sbm` (Central Coordination Repository)

## Canonical Organization Policy (Read First)

Before designing or implementing changes, read the canonical organization-wide engineering rules in [`smart-boot-menu/.github/AGENTS.md`](https://github.com/smart-boot-menu/.github/blob/main/AGENTS.md) (local workspace: `../.github/AGENTS.md`), the operational checklists in [`.github/agent-reference.md`](https://github.com/smart-boot-menu/.github/blob/main/agent-reference.md) (`../.github/agent-reference.md`), and the **Open-Source Reuse & Engineering Principles** in [`ADR-010`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md) (`../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md`).

> **Standalone / Single-Repo Agents:** If you were launched inside this repository alone and `../.github/AGENTS.md` is not present locally, fetch and follow the GitHub URLs above before proceeding. Do not recreate inferior versions of existing software; apply proportional build-versus-reuse evaluation for new components, major dependencies, architectural changes, or replacements.

## Repository Role

`smart-boot-menu/sbm` is the **executive coordination hub** for the Smart Boot Menu organization: high-level vision, architecture overview, roadmap, repository ownership map, release manifests, and launch prompts for specialized autonomous engineering agents (`agents/01..09.md`).

## Ownership

- `README.md`, `VISION.md`, `ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`, `REQUIREMENTS.md`, `SECURITY.md`, `CONTRIBUTING.md`, `HANDOFF.md`
- `agents/01-uefi.md` through `agents/09-website.md`
- `releases/` (signed release manifests)
- `docs/*` pointer indexes to canonical `smart-boot-menu/docs` and `smart-boot-menu/research`

## Boundaries (Do NOT Duplicate)

- Deep normative specs, ADRs, threat models, and Mermaid diagrams belong canonically in **`../docs`** (`smart-boot-menu/docs`).
- Primary-source ecosystem research and raw validation evidence belong canonically in **`../research`** (`smart-boot-menu/research`).
- Shared Rust crates, JSON schemas, and protocol test vectors belong canonically in **`../sbm-common`** (`smart-boot-menu/sbm-common`).
- Component implementation code belongs in its respective component repo (`sbm-uefi`, `sbm-core`, `sbm-as`, `install`, `sbm-server`, `sbm-catalog`, `sbm-agent`, `sbm-lab`, `smart-boot-menu.github.io`).
