# AGENTS.md — `sbm` (Central Coordination Repository)

Follow the universal Smart Boot Menu agent rules in [`smart-boot-menu/.github/AGENTS.md`](https://github.com/smart-boot-menu/.github/blob/main/AGENTS.md) (locally `../.github/AGENTS.md`).

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
