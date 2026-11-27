# Smart Boot Menu (`sbm`)

**Open-source, network-native, operating-system-independent bare-metal lifecycle management.**

Install Smart Boot Menu once and manage the entire lifecycle of your computer: ultra-fast graphical UEFI boot selection, automatic OS discovery, persistent internal SSD installation alongside existing operating systems, online & offline OS installation, multiboot management, disk partitioning (GParted), backup/cloning, hardware diagnostics, system recovery, and optional self-hosted remote desktop & remote boot control.

> **100% Offline-First:** Smart Boot Menu requires **no internet connection, no account, no cloud server, and no mandatory telemetry**. Self-hosted remote management (`sbm-server`) is completely optional.

## Repository Role

`smart-boot-menu/sbm` is the **central coordination, roadmap, and executive architecture hub** for the Smart Boot Menu organization.

To keep documentation clean and prevent copy-paste drift (modeled after `0SFS`'s dedicated knowledge repositories):
- **Central agent rules & guardrails** live canonically in [`smart-boot-menu/.github`](https://github.com/smart-boot-menu/.github) (`../.github/` locally).
- **Normative specifications, ADRs (001–011), threat models, hardware profiles, 3-tier testing methodology, and Mermaid diagrams** live canonically in [`smart-boot-menu/docs`](https://github.com/smart-boot-menu/docs) (`../docs/` locally).
- **Primary-source ecosystem research, build-vs-reuse evaluations, Apple Silicon studies, and retained benchmark evidence** live canonically in [`smart-boot-menu/research`](https://github.com/smart-boot-menu/research) (`../research/` locally).
- **Shared Rust libraries (`no_std` + `std`), JSON Schemas, and protocol test vectors** live canonically in [`smart-boot-menu/sbm-common`](https://github.com/smart-boot-menu/sbm-common) (`../sbm-common/` locally).

## Executive Documents

- [VISION.md](VISION.md) — Long-term vision, design philosophy, and offline-first principles.
- [ARCHITECTURE.md](ARCHITECTURE.md) — Two-tier architecture (`sbm-uefi` + `sbm-core`), Track A native previews, per-arch media, internal SSD installation, and 3-tier testing.
- [TECHNOLOGY_STACK.md](TECHNOLOGY_STACK.md) — Concrete recommended technology stack (November 2026 baseline, aligned with ADR-010 & ADR-011).
- [REPOSITORIES.md](REPOSITORIES.md) — Complete 14-repository ownership matrix and strict boundaries.
- [REQUIREMENTS.md](REQUIREMENTS.md) — Functional, security, offline, and measurable initial engineering targets.
- [ROADMAP.md](ROADMAP.md) — Prioritized delivery roadmap (Tracks A–B, SBM 0.0.1, 0.0.2, 0.0.3, 0.1, and 0.2).
- [SECURITY.md](SECURITY.md) — Security invariants, disclosure process, and threat model index.
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution workflow and cross-repository interface change process.
- [AGENTS.md](AGENTS.md) — Minimal pointer to centralized `.github/AGENTS.md`.
- [agents/README.md](agents/README.md) — Autonomous engineering agent prompts and active coordination roster.
- [HANDOFF.md](HANDOFF.md) — Agent 0 initialization and handoff report.

## Release Coordination & Gates (SBM 0.0.1–0.0.3)

- [Integration audit](INTEGRATION_AUDIT.md) — Wave 2 cross-repo audit findings.
- [Integration plan, dependency matrix, and owner assignments](INTEGRATION_PLAN.md) — Coordinates Tracks A & B (Agents 18 & 16) and SBM 0.0.1–0.0.3.
- [Release gates](RELEASE_GATES.md) — Independent per-arch 0.0.1 gates (dual-arch optional experimental) plus Tier 1/2/3 gates for 0.0.2 and 0.0.3.
- [Integration handoff](INTEGRATION_HANDOFF.md) — Latest Chief Integration Architect coordination handoff.

## License

Original Smart Boot Menu code and documentation are dual-licensed under [MIT](LICENSE-MIT) OR [Apache-2.0](LICENSE-APACHE), subject to third-party licensing requirements for external bundled utilities.
