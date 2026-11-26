# Smart Boot Menu (`sbm`)

**Open-source, network-native, operating-system-independent bare-metal lifecycle management.**

Install Smart Boot Menu once and manage the entire lifecycle of your computer: ultra-fast graphical UEFI boot selection, automatic OS discovery, online & offline OS installation, multiboot management, disk partitioning (GParted), backup/cloning, hardware diagnostics, system recovery, and optional self-hosted remote desktop & remote boot control.

> **100% Offline-First:** Smart Boot Menu requires **no internet connection, no account, no cloud server, and no mandatory telemetry**. Self-hosted remote management (`sbm-server`) is completely optional.

## Repository Role

`smart-boot-menu/sbm` is the **central coordination, roadmap, and executive architecture hub** for the Smart Boot Menu organization.

To keep documentation clean and prevent copy-paste drift (modeled after `0SFS`'s dedicated knowledge repositories):
- **Normative specifications, ADRs, threat models, hardware profiles, testing methodology, and Mermaid diagrams** live canonically in [`smart-boot-menu/docs`](https://github.com/smart-boot-menu/docs) (`../docs/` locally).
- **Primary-source ecosystem research, Apple Silicon studies, and retained benchmark evidence** live canonically in [`smart-boot-menu/research`](https://github.com/smart-boot-menu/research) (`../research/` locally).
- **Shared Rust libraries (`no_std` + `std`), JSON Schemas, and protocol test vectors** live canonically in [`smart-boot-menu/sbm-common`](https://github.com/smart-boot-menu/sbm-common) (`../sbm-common/` locally).

## Executive Documents

- [VISION.md](VISION.md) — Long-term vision, design philosophy, and offline-first principles.
- [ARCHITECTURE.md](ARCHITECTURE.md) — Two-tier architecture (`sbm-uefi` fast path + `sbm-core` management path) & Apple Silicon integration.
- [TECHNOLOGY_STACK.md](TECHNOLOGY_STACK.md) — Concrete recommended technology stack (November 2026 baseline).
- [REPOSITORIES.md](REPOSITORIES.md) — Complete 14-repository ownership matrix and strict boundaries.
- [REQUIREMENTS.md](REQUIREMENTS.md) — Functional, security, offline, and measurable initial engineering targets.
- [ROADMAP.md](ROADMAP.md) — Phased delivery roadmap starting with **SBM 0.1** end-to-end PoC.
- [SECURITY.md](SECURITY.md) — Security invariants, disclosure process, and threat model index.
- [CONTRIBUTING.md](CONTRIBUTING.md) — Contribution workflow and cross-repository interface change process.
- [AGENTS.md](AGENTS.md) — Coordinator agent rules and routing table.
- [agents/README.md](agents/README.md) — Autonomous engineering agent prompts (`01-uefi.md` through `09-website.md`).
- [HANDOFF.md](HANDOFF.md) — Agent 0 initialization and handoff report.

## License

Original Smart Boot Menu code and documentation are dual-licensed under [MIT](LICENSE-MIT) OR [Apache-2.0](LICENSE-APACHE), subject to third-party licensing requirements for external bundled utilities.
