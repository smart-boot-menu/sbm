# Smart Boot Menu — Autonomous Engineering Agent Prompts

Each file below is a self-contained launch prompt for a specialized autonomous engineering agent working in parallel across the Smart Boot Menu repositories.

Every agent must follow the canonical organization rules in [`.github/AGENTS.md`](https://github.com/smart-boot-menu/.github/blob/main/AGENTS.md), the operational procedures in [`.github/agent-reference.md`](https://github.com/smart-boot-menu/.github/blob/main/agent-reference.md), and the **Open-Source Reuse & Engineering Principles** in [`ADR-010`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md) (*do not recreate inferior versions of existing software*). Independently launched agents operating in a single-repository checkout MUST fetch those canonical GitHub URLs if `../.github/AGENTS.md` is not present locally.

## Mandatory 10-Step Engineering Workflow

Every agent follows the same 10-step disciplined engineering workflow:
1. Read central project docs (`.github/AGENTS.md`, `.github/agent-reference.md`, `docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md`, `sbm`, `docs`, `research`, and the target repository's `AGENTS.md`).
2. Inspect relevant existing codebases and upstream references.
3. Conduct proportional domain-specific and **build-versus-reuse** research across languages and ecosystems (inspecting existing implementations, limitations, licenses, benchmarks, and maintenance status; saving reusable findings to `research/`).
4. Write a concise implementation plan before coding — including explicit build-versus-reuse justification (per `ADR-010` and `.github/agent-reference.md`) for any new subsystem, major dependency, architectural change, or replacement of established software, plus empirical baselines where practical.
5. Implement cleanly by preferring reuse, configuration/composition, thin integration layers, or upstream contributions over original reimplementations; write original code only where justified by measurable advantages (respecting `sbm-common` contracts and licensing boundaries).
6. Write comprehensive automated tests (unit/contract tests, integration tests, fuzz/property tests where applicable).
7. Run documented benchmarks where applicable (archiving raw evidence in `research/validation/evidence/`).
8. Document known limitations, open questions, and any retrospective candidates for replacing custom SBM code with superior upstream alternatives.
9. Commit and push changes (or present exact push steps per repo rules) without AI attribution trailers.
10. Report cross-repository integration requirements cleanly.

## Agent Roster

| Agent | Prompt File | Assigned Repository | Primary SBM 0.1 Milestone Role |
|---|---|---|---|
| **Agent 1** | [01-uefi.md](01-uefi.md) | `sbm-uefi` | Native Rust graphical UEFI boot manager (`x86_64` & `aarch64`) |
| **Agent 2** | [02-core.md](02-core.md) | `sbm-core` | Minimal immutable Linux recovery & management OS (`mkosi`) |
| **Agent 3** | [03-lab.md](03-lab.md) | `sbm-lab` | QEMU/OVMF/AAVMF/U-Boot/`swtpm` virtual hardware & integration lab |
| **Agent 4** | [04-apple-silicon.md](04-apple-silicon.md) | `sbm-as` | Apple Silicon `m1n1`/U-Boot integration, light Asahi profile & external boot |
| **Agent 5** | [05-server.md](05-server.md) | `sbm-server` | Optional self-hosted management server (`axum`/`sqlx`/SvelteKit/`noVNC`) |
| **Agent 6** | [06-catalog.md](06-catalog.md) | `sbm-catalog` | TUF-signed declarative OS catalog, recipes & schema validation |
| **Agent 7** | [07-installer.md](07-installer.md) | `install` | Cross-platform SBM installer, updater, uninstaller & USB media creator |
| **Agent 8** | [08-os-agent.md](08-os-agent.md) | `sbm-agent` | Optional guest OS daemon (boot-success confirmation & remote reboot) |
| **Agent 9** | [09-website.md](09-website.md) | `smart-boot-menu.github.io` | Official public website, docs portal & download index |

## Task Prompt Template (For New Autonomous Agents)

When authoring a new agent launch prompt or orchestration task, include:
- **Canonical Policy Pointer:** Link `.github/AGENTS.md`, `.github/agent-reference.md`, `ADR-010`, and the repository's `AGENTS.md` (with GitHub URLs for standalone single-repo launches).
- **Proportional Build-vs-Reuse Gate:** Require cross-ecosystem evaluation (following the `ADR-010` 6-level order of preference and rejecting language-only rewrites) before introducing new subsystems, major dependencies, architectural changes, or replacements of existing software.
- **Evidence & Sunk-Cost Discipline:** Require empirical baselines for performance/resource/reliability claims and permit recommending removal or replacement of existing SBM code when a superior open-source alternative exists.
- **Explicit Scope, Safety & Licensing Boundaries:** Preserve `docs/threat-model/README.md`, offline-first invariants, `MIT OR Apache-2.0` licensing / subprocess isolation, and workstation safety.
