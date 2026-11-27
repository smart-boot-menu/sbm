# Agent 11 Architecture & Roadmap Alignment Handoff

**Date:** 2026-11-26  
**SBM 0.0.1 Status:** **OPEN — UNQUALIFIED** (per-architecture `aarch64` and `x86_64` gates remain open until UEFI latency/handoff, per-arch manifest assembly, and merged CI evidence close).

All engineering agents operate from `~/gh/smart-boot-menu/`, follow centralized [`.github/AGENTS.md`](../.github/AGENTS.md) + [`ADR-010`](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), and respect the 16 GiB physical RAM budget on the macOS host. **Never modify physical host disks, firmware `BootOrder`, or macOS `LocalPolicy`/SIP.**

## Delivered in This Direction Update

- **Primary-Source Research (`research/`):**
  - Added [`ecosystem/media-creator-evaluation.md`](https://github.com/smart-boot-menu/research/blob/main/ecosystem/media-creator-evaluation.md): evaluated Raspberry Pi Imager (`--repo` v4 JSON schema, `.zst` via `libarchive`+`libzstd`, v2.0.11+ fixes, minimal `Apache-2.0` forkability), Fedora Media Writer, balenaEtcher, USBImager, GNOME Impression, KDE ISO Image Writer, Rufus, and Caligula.
  - Added [`architecture/internal-install-and-calamares-evaluation.md`](https://github.com/smart-boot-menu/research/blob/main/architecture/internal-install-and-calamares-evaluation.md): evaluated Calamares `3.4.3` (Qt6/KF6/KPMcore, `GPL-3.0-or-later`) vs preserving SBM's Rust planner/security boundaries while wrapping mature CLI tools (`sfdisk`, `sgdisk`, `dosfstools`, `efibootmgr`, `e2fsprogs`, `ntfsresize`, `btrfs-progs`, `GParted`), safe shrinking rules, and Windows/BitLocker coexistence pitfalls.
  - Incorporated Agent 16's completed dev infrastructure landscape audit and measured host resource audit (13.24 GiB SSD reclaimed, QEMU HVF balloon vs `discard=unmap` benchmarks).
- **Canonical ADRs & Specifications (`docs/`):**
  - Revised [`ADR-009`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md), [Spec 03](https://github.com/smart-boot-menu/docs/blob/main/specifications/03-efi-linux-handoff-and-recovery.md), and [Spec 07](https://github.com/smart-boot-menu/docs/blob/main/specifications/07-releases-compatibility-and-diagnostics.md): **architecture-specific offline recovery media** (`x86_64` and `aarch64`) are now the primary independently qualified 0.0.1 distribution; **dual-architecture media** is preserved strictly as an **optional experimental profile**, not a recommended distribution or mandatory release gate.
  - Added [`ADR-011`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md): normative decisions for Track A native interactive UI previews, Track B composed OSS dev infra, 0.0.2 internal SSD installation + uninstall/recovery, 0.0.3 Media Creator (reuse-first `rpi-imager` trial) + allowlisted guided partition resizing, and strict 3-tier testing separation.
  - Updated [Spec 04](https://github.com/smart-boot-menu/docs/blob/main/specifications/04-storage-and-installation-plans.md) (§11a internal SSD install/uninstall/recovery & §11b allowlisted guided resizing) and [`testing/benchmarks.md`](https://github.com/smart-boot-menu/docs/blob/main/testing/benchmarks.md) (explicit Tier 1 Simulated / Tier 2 Disposable VM Disk / Tier 3 Explicitly Authorized Physical Hardware separation).
- **Central Roadmap, Gates & Ownership (`sbm/`):**
  - Updated [ROADMAP.md](ROADMAP.md), [RELEASE_GATES.md](RELEASE_GATES.md), [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md), [ARCHITECTURE.md](ARCHITECTURE.md), [REPOSITORIES.md](REPOSITORIES.md), [TECHNOLOGY_STACK.md](TECHNOLOGY_STACK.md), and [agents/README.md](agents/README.md) to align Tracks A & B (Agents 18 & 16) and SBM 0.0.1 -> 0.0.2 -> 0.0.3 -> 0.1 -> 0.2.

## Immediate Next Execution Priorities

1. **Track A (`Agent 18`):** Build interactive native macOS/Linux previews for actual `sbm-gfx`/`sbm-boot` and actual Iced `sbm-ui` over simulated platform interfaces (including simulated UEFI -> Core -> **Install SBM** -> Reboot round-trip, strictly badged Tier 1 Simulated).
2. **Track B (`Agent 16`):** Land root `justfile`, Cargo 1.100 `build.build-dir` + `sccache`, `mkosi --incremental=yes` + `systemd-sysext`, consolidate `sbm-lab`'s duplicate `gpt.rs`/`fatimg.rs` onto `sbm-media`, and benchmark Lima+`krunkit` upon user approval.
3. **Finish SBM 0.0.1 Per-Arch Qualification (`Agent 01`, `Agent 02/13`, `Agent 03`, `Agent 07`):** Reconcile/push Agent 13's passing Core graphical recovery fixes (`5031613`) and `sbm-lab` `integration.rs`; fix `sbm-lab#5`; fix `sbm-uefi#1` startup latency (`< 250 ms` HVF) + Spec 03 volatile EFI vars; emit independently qualified per-arch images (`x86_64`, `aarch64`) + populated `release-manifest.v1.json` + optional `sbm-os-list.json` (`install#1`); qualify each architecture independently via `sbm-lab#2`.
4. **Launch SBM 0.0.2 (`sbm-common#2` + `install` + `sbm-core` + `sbm-lab`):** Persistent internal SSD available-space installation, `efibootmgr` registration, install receipt, uninstall, and boot recovery verified across Tier 1 and Tier 2.
5. **Launch SBM 0.0.3 (`install` + `sbm-core` + `sbm-lab`):** Empirical `rpi-imager` Media Creator trial + allowlisted safe partition resizing (`ext4`, clean non-hibernated `NTFS`, single-device `Btrfs`).
