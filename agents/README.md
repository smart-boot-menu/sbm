# Smart Boot Menu — Autonomous Engineering Agent Prompts

Each file below is a self-contained launch prompt for a specialized autonomous engineering agent working in parallel across the Smart Boot Menu repositories.

All agent rules and repository-specific guardrails live centrally in [`.github/AGENTS.md`](https://github.com/smart-boot-menu/.github/blob/main/AGENTS.md) and [`.github/agent-reference.md`](https://github.com/smart-boot-menu/.github/blob/main/agent-reference.md) (modeled on `0SFS`), backed by [`ADR-010`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md) (*do not recreate inferior versions of existing software*). Individual repository `AGENTS.md` files are minimal pointers back to `.github/AGENTS.md`. Independently launched agents operating in a single-repository checkout MUST fetch those canonical GitHub URLs if `../.github/AGENTS.md` is not present locally.

## Mandatory 10-Step Engineering Workflow

Every agent follows the same 10-step disciplined engineering workflow:
1. Read central project docs (`.github/AGENTS.md`, `.github/agent-reference.md` including §5 repository guardrails, `docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md`, `ADR-011`, `sbm`, `docs`, `research`, and the target repository's `README.md`).
2. Inspect relevant existing codebases and upstream references.
3. Conduct proportional domain-specific and **build-versus-reuse** research across languages and ecosystems (inspecting existing implementations, limitations, licenses, benchmarks, and maintenance status; saving reusable findings to `research/`).
4. Write a concise implementation plan before coding — including explicit build-versus-reuse justification (per `ADR-010` and `.github/agent-reference.md` §4) for any new subsystem, major dependency, architectural change, or replacement of established software, plus empirical baselines where practical.
5. Implement cleanly by preferring reuse, configuration/composition, thin integration layers, or upstream contributions over original reimplementations; write original code only where justified by measurable advantages (respecting `sbm-common` contracts and licensing boundaries).
6. Write comprehensive automated tests adhering to the **3-tier testing policy** (`Tier 1` simulated, `Tier 2` disposable VM disk, never unrequested `Tier 3` physical hardware mutations).
7. Run documented benchmarks where applicable (archiving raw evidence in `research/validation/evidence/`).
8. Document known limitations, open questions, and any retrospective candidates for replacing custom SBM code with superior upstream alternatives.
9. Commit and push changes (or present exact push steps per repo rules) without AI attribution trailers.
10. Report cross-repository integration requirements cleanly.

## Agent Roster

### Repository Ownership Prompts (`01`–`09`)

| Agent | Prompt File | Assigned Repository | Primary Role |
|---|---|---|---|
| **Agent 01** | [01-uefi.md](01-uefi.md) | `sbm-uefi` | Native Rust graphical UEFI boot manager (`x86_64` & `aarch64`), launch-time streaming UKI verification, Spec 02/03 handoff |
| **Agent 02** | [02-core.md](02-core.md) | `sbm-core` | Minimal immutable Linux recovery & management OS (`mkosi`, `labwc`, Iced `sbm-ui`, GParted, `sbm-cored`) |
| **Agent 03** | [03-lab.md](03-lab.md) | `sbm-lab` | macOS host RAM guard (`resources.rs`), QEMU/OVMF/AAVMF/U-Boot/`swtpm` Tier 2 disposable VM harness & integration gates |
| **Agent 04** | [04-apple-silicon.md](04-apple-silicon.md) | `sbm-as` | Apple Silicon `m1n1`/U-Boot integration, light Asahi profile & external boot (SBM 0.2) |
| **Agent 05** | [05-server.md](05-server.md) | `sbm-server` | Optional self-hosted management server (`axum`/`sqlx`/SvelteKit/`noVNC`, SBM 0.1) |
| **Agent 06** | [06-catalog.md](06-catalog.md) | `sbm-catalog` | TUF-signed declarative OS catalog, recipes & schema validation (SBM 0.1) |
| **Agent 07** | [07-installer.md](07-installer.md) | `install` | Per-arch & optional dual-arch media assembly (`0.0.1`), internal SSD install/uninstall/repair (`0.0.2`), Media Creator & guided partition resizing (`0.0.3`) |
| **Agent 08** | [08-os-agent.md](08-os-agent.md) | `sbm-agent` | Optional guest OS daemon (boot-success confirmation & remote reboot, SBM 0.1) |
| **Agent 09** | [09-website.md](09-website.md) | `smart-boot-menu.github.io` | Official public website, docs portal, download index & evidenced Tier 3 compatibility matrix (SBM 0.2) |

### Cross-Cutting & Specialized Active Agents (`11`, `13`, `16`, `18`)

| Agent | Scope / Track | Repositories | Coordination Reference |
|---|---|---|---|
| **Agent 11** | Chief Integration Architect | `sbm`, `docs`, `research`, `sbm-common` | [INTEGRATION_PLAN.md](../INTEGRATION_PLAN.md), [RELEASE_GATES.md](../RELEASE_GATES.md) |
| **Agent 13** | Graphical Recovery Integration | `sbm-core`, `sbm-lab`, `install` | `sbm-core/HANDOFF.md` (unmerged graphical recovery 9/9 local pass) |
| **Agent 16** | **Track B — OSS Dev Infrastructure & Resource Optimization** | `sbm-lab`, `sbm-core`, `install`, `sbm`, `research` | `ADR-010`, `ADR-011`, `research/ecosystem/dev-infrastructure-and-testing-landscape-2026-11-26.md` |
| **Agent 18** | **Track A — Native Interactive UI Preview** | `sbm-uefi`, `sbm-core`, `sbm` | `ADR-011`, [INTEGRATION_PLAN.md](../INTEGRATION_PLAN.md) (actual `sbm-gfx`/`sbm-boot` + Iced `sbm-ui` over simulated platform interfaces) |

## Task Prompt Template (For New Autonomous Agents)

When authoring a new agent launch prompt or orchestration task, include:
- **Central Policy Pointer:** Link `.github/AGENTS.md`, `.github/agent-reference.md` (including §4 and §5), `ADR-010`, `ADR-011`, and the target repository's `README.md` (with GitHub URLs for standalone single-repo launches).
- **Proportional Build-vs-Reuse Gate:** Require cross-ecosystem evaluation (following the `ADR-010` 6-level order of preference and rejecting language-only rewrites) before introducing new subsystems, major dependencies, architectural changes, or replacements of existing software.
- **Evidence & Sunk-Cost Discipline:** Require empirical baselines for performance/resource/reliability claims and permit recommending removal or replacement of existing SBM code when a superior open-source alternative exists.
- **Three-Tier Testing & Safety Boundaries:** Preserve `docs/threat-model/README.md`, offline-first invariants, `MIT OR Apache-2.0` licensing / subprocess isolation, explicit Tier 1 / Tier 2 / Tier 3 separation, and workstation safety.
