# Smart Boot Menu — Prioritized Development Roadmap

**Last updated:** 2026-11-26  
**Canonical Decisions:** [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md), [ADR-010](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md)  
**Testing Policy:** Strictly separates **Tier 1 (Simulated)**, **Tier 2 (Disposable VM Disk)**, and **Tier 3 (Explicitly Authorized Physical Hardware)** per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md).

---

## Target End-User Experiences (North Star)

**1. Everyday Local & Internal SSD Installation (Through SBM 0.0.3):**
```text
Download SBM Manager -> configure profile & flash USB -> boot target computer
-> Install SBM -> inspect and optionally adjust partitions -> confirm -> install
-> reboot into SBM from internal SSD
```

**2. Network Recovery & Remote Repair of a Broken OS (SBM 0.1):**
```text
Working computer: SBM Manager (optional network preconfig, modules, cache policy,
revocable ephemeral remote-access grant) -> flash recovery USB
-> Broken computer boots SBM from USB -> downloads & authenticates SBM Core
-> runs in RAM (zero SSD writes) or authorized storage
-> establishes authenticated, encrypted, revocable remote session -> repair broken OS
```

Every milestone below builds toward these flows in risk-isolated increments, following **ADR-010** (*write less software; reuse the best open-source tools first*), **ADR-012** (*configurable profiles, 0SFS-style modularity, first-principles Nov 2026 UX*), and **strict separation of aspirational targets from measured capabilities**.

---

## Installation & Execution Profiles (Staged Across SBM 0.0.1–0.1, [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md))

- **`efi-only` (SBM 0.0.2):** Minimal UEFI boot manager only (`< 1 MiB` EFI target), independently useful and upgradeable to richer profiles without reinstalling the boot manager.
- **`offline-full` (SBM 0.0.1 USB / 0.0.2 SSD):** Self-contained offline installation (`sbm-uefi` + verified `sbm-core` base + profile-bundled tools).
- **`modular-custom` (SBM 0.0.3 initial / 0.1 full):** Minimal `< 500 MiB` compressed base + user-selected signed `systemd-sysext`/`systemd-confext` capability modules (download, cache, activate, deactivate, remove — zero custom package manager).
- **`cached-usb` / `cached-ssd` (SBM 0.0.3 / 0.1):** Optional persistent caching on USB or explicitly authorized internal SSD (**NEVER** cache to internal disk without explicit authorization).
- **`net-ondemand` (SBM 0.1):** Standards-based on-demand network loading (UEFI HTTP(S) Boot + signed minimal Linux Network-Bootstrap UKI + `dm-verity` `switch-root`).
- **`ram-only` (SBM 0.1):** Fully RAM-resident execution with zero persistent disk writes (**MUST NOT** use target internal SSD for temporary storage, cache, logs, or swap).

---

## Initial Engineering Performance Targets (Aspirational — Subject to Measurement)

Full target table and measured-vs-aspirational rules live in [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md):
- UEFI initialization: **`< 250 ms`** | Minimal EFI application: **`< 1 MiB`**
- Compressed base management OS (`sbm-core` base): **`< 500 MiB`**
- Local recovery boot on modern hardware: **`< 10 s`** | Basic recovery: **`≤ 2 GiB RAM`** where practical
- Native UI preview startup (Track A): **`< 1 s`** | Warm UI iteration (Track A): **`< 5 s`**
- Zero mandatory internet, account, or cloud service | Zero unauthorized physical disk modifications

---

## Phase 0 — Architecture & Foundation (Completed)

- Initialized 14 GitHub repositories (`smart-boot-menu/*`), dual licenses (`MIT OR Apache-2.0`), centralized `.github/AGENTS.md` + `agent-reference.md`, and CI conventions.
- Completed primary-source ecosystem, hardware, dev-infrastructure, `SBM Manager`/flasher, internal-install/Calamares, and network-recovery/modularity research (`research/`).
- Ratified ADRs 001–012, v1 specifications (Specs 01–07), threat model, and 10 Mermaid diagrams (`docs/`).
- Implemented and verified `sbm-common` (`no_std` `sbm-types` + `sbm-protocol`, `std` `sbm-schema`, 18 JSON Schemas, golden test vectors).

---

## Continuous Enabling Tracks (Run in Parallel With 0.0.1–0.1)

> **Milestone Structure Refinement:** Priorities **A** and **B** run continuously alongside 0.0.1–0.1 so every product milestone benefits immediately from sub-second native UX iteration and low-RAM open-source developer tooling.

### Track A (Priority A) — Native Interactive SBM Development & Primary UX Studio (`Agent 18`)

- **Goal:** Run the **actual** `sbm-uefi` renderer (`sbm-gfx` + `sbm-boot`) and the **actual** Iced `sbm-core` UI (`sbm-ui`) natively on macOS and Linux against simulated platform interfaces — serving as the **primary environment for evaluating and refining SBM's first-principles November 2026 UX** ([ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md)).
- **UX Philosophy:** Treat legacy boot managers and recovery discs as references, not visual constraints. Optimize for speed, clarity, accessibility, responsive layouts, useful diagnostics, minimal resource consumption, and progressive disclosure.
- **Scope & Targets:**
  - Interactive native host window over real `sbm-gfx`/`sbm-boot` (keyboard/mouse navigation, HiDPI scaling, themes, diagnostics/error views, simulated ESP & discovered OS cards, **Manage Computer** handoff).
  - Pluggable `CoreBackend` trait in `sbm-ui` with a deterministic `SimulatedCoreBackend` (simulated disks, OSes, protected BitLocker/APFS partitions, recovery tools, and interactive **Install SBM** / resize / modular extension preview).
  - Engineering targets: **`< 1 s`** preview startup, **`< 5 s`** warm UI iteration.
- **Tier:** Strictly **Tier 1 (Simulated)** — visibly badged as simulated mode; never counts as firmware or block-device qualification.

### Track B (Priority B) — Efficient Open-Source Development Infrastructure (`Agent 16`)

- **Goal:** Keep development fast, reproducible, and comfortable on a 16 GiB workstation by composing mature open-source tools instead of maintaining bespoke infrastructure (per `ADR-010` and `research/ecosystem/dev-infrastructure-and-testing-landscape-2026-11-26.md`).
- **Completed Baseline:** Measured host resource audit, 13.24 GiB physical SSD reclaimed, single-arch dev defaults, root `justfile`, Cargo `build.build-dir` + `sccache` + `nextest` + `zigbuild` benchmarks, Lima+`krunkit` vs QEMU HVF evaluation, and `os-autoinst` CI assessment.
- **Next Steps:** Continue shrinking custom `sbm-lab` code (`gpt.rs`/`fatimg.rs` -> `sbm-media`), adopt `mkosi --incremental=yes` + `Format=sysext` for Level 2 Core iteration, adopt U-Boot `sandbox` & `os-autoinst` on Linux CI, and reserve `labgrid` for future Tier 3 physical hardware labs.

---

## Milestone: SBM 0.0.1 (Priority C) — Independently Qualified Architecture-Specific Recovery Media

**Goal:** Independently qualify reproducible, offline, **architecture-specific** bootable recovery media (`sbm-0.0.1-uefi-x86_64.raw[.zst]` and `sbm-0.0.1-uefi-aarch64.raw[.zst]`) through the complete real UEFI -> Core -> Iced UI -> GParted -> clean Reboot -> confirmation workflow.

- **Distribution Policy ([ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)):**
  - `x86_64` (OVMF) and `aarch64` (AAVMF) are qualified **independently**.
  - **Dual-architecture combined media (`sbm-0.0.1-uefi-dualarch.raw[.zst]`) is preserved strictly as an optional experimental build profile**, NOT a recommended distribution or mandatory release gate.
- **Zero-Code Flashing Bridge:** Publish a schema-validated `sbm-os-list.json` compatible with **Raspberry Pi Imager (`>= 2.0.11`, `--repo`)** alongside documented instructions for USBImager, Fedora Media Writer, GNOME Impression, and Rufus.
- **Verification:** Tier 1 unit/contract tests + Tier 2 disposable VM positive (Gates 0–9) and negative qualification per architecture. See [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md) and [RELEASE_GATES.md](RELEASE_GATES.md).

---

## Milestone: SBM 0.0.2 (Priority D) — Persistent Internal SSD Installation, Uninstall & Recovery

**Goal:** Boot SBM from removable USB media and safely install Smart Boot Menu permanently onto an internal GPT SSD alongside existing Windows and Linux operating systems, with clean firmware boot registration, uninstall, and boot recovery.

- **Supported 0.0.2 Internal Profiles ([Spec 03 §9a](../docs/specifications/03-efi-linux-handoff-and-recovery.md), [Spec 04 §11a](../docs/specifications/04-storage-and-installation-plans.md)):**
  - **Minimal EFI-only (`efi-only`):** Installs only `\EFI\sbm\sbm-<arch>.efi` (targeting **`< 1 MiB`**) + small config/handoff metadata on the existing ESP with zero extra partitions. Must be independently useful and **upgradeable** later to offline/cached/network profiles **without reinstalling the boot manager**.
  - **Offline Internal Core (`offline-full`):** Available-space-only installation (zero partition shrinking yet) placing native `root-<arch>` + `root-<arch>-verity` partitions in existing unallocated GPT space (or explicit empty disk).
- **Safety & Reuse (`ADR-006`, `ADR-011`):** Preserve `sbm-plan`/`sbm-exec`/`sbm-common#2` typed contracts, composite `DiskIdentity`, `expected_partition_table_sha256` optimistic lock, Apple/BitLocker guards, `sgdisk --backup`, `\EFI\sbm\install-receipt.json`, and direct `execve` subprocess wrapping (`lsblk`, `blkid`, `sgdisk`, `sfdisk`, `dosfstools`, `efibootmgr`; Calamares framework rejected).
- **Install/Uninstall/Repair UI:** Built and refined first in Track A native preview (`sbm-ui`), then wired to `sbm-cored`.
- **Verification:** Tier 1 simulated regular-file tests + Tier 2 disposable VM multi-OS disk tests (install -> detach USB -> reboot from internal SSD -> chainload existing OS -> uninstall restoring `BootOrder` -> boot recovery after simulated NVRAM reset; plus `efi-only` upgrade test).

---

## Milestone: SBM 0.0.3 (Priority E) — Cross-Platform `SBM Manager` MVP, Guided Partition Resizing & Initial `systemd-sysext` Modularity

**Goal:** Deliver the complete everyday consumer flow (`Download SBM Manager -> configure profile & flash USB -> boot target computer -> Install SBM -> inspect and optionally adjust partitions -> confirm -> install -> reboot into SBM from internal SSD`) and establish the modular `< 500 MiB` `sbm-core` base.

- **`SBM Manager` MVP ([research/ecosystem/media-creator-evaluation.md](../research/ecosystem/media-creator-evaluation.md), [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md)):**
  - User-facing desktop provisioning and configuration application (replacing "Media Creator"): configures installation profiles, selects optional modules/cache policies, downloads verified per-arch artifacts, filters out internal system drives, flashes USB drives, and verifies read-back integrity.
  - Empirically compare a minimal Apache-2.0 `rpi-imager` fork against a thin Rust/Iced `SBM Manager` reusing mature OS flashing backends (`udisks2`/DiskArbitration/Win32) before locking long-term implementation.
- **Guided Partition Resizing ([Spec 04 §11b](../docs/specifications/04-storage-and-installation-plans.md)):**
  - Strictly allowlisted shrinking of clean unencrypted `ext4`, clean non-hibernated/non-BitLocker `NTFS`, and clean single-device `Btrfs` using the Golden Rule of Safe Shrinking; hard-block BitLocker, LUKS, LVM/RAID/ZFS/XFS, dirty/hibernated NTFS, Apple APFS, and MBR disks (GParted remains available for manual expert layouts).
- **Initial 0SFS-Style Modularity ([Spec 07 §17a](../docs/specifications/07-releases-compatibility-and-diagnostics.md)):**
  - Split optional heavy recovery utilities out of the mandatory base into signed `dm-verity` `systemd-sysext` DDIs built with `mkosi` (`Format=sysext`, `Overlay=yes`, `BaseTrees=`) and enforced with `--image-policy='root=signed+absent:usr=signed+absent:=unused+absent'` so compressed `sbm-core` base converges toward **`< 500 MiB`** without inventing a custom package manager.
- **Verification:** Tier 1 simulated resize/module-dependency tests + Tier 2 populated ext4/NTFS/Btrfs shrink + install + signed-`sysext` activation/rejection VM tests + `SBM Manager` verification.

---

## Milestone: SBM 0.1 (Priority F1) — On-Demand Network Recovery, Ephemeral Remote Repair, Full Modularity & Advanced OS Installation

> **Milestone Structure Refinement:** Split Priority F into **SBM 0.1** (standard UEFI PCs: Network Recovery & Ephemeral Remote Repair, Full Modularity, Advanced OS Installation, optional `sbm-server`) and **SBM 0.2** (Apple Silicon physical hardware, Production Secure Boot / `shim-review`, public portal) so upstream Apple M4/M5 kernel timelines and Microsoft CA 2023 signing waits never block core recovery and OS-lifecycle features.

- **On-Demand Network Recovery & Ephemeral Remote Repair ([`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5), [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md)):**
  - `SBM Manager` recovery USB preparation (optional network settings, selected modules, cache policy, and opt-in revocable `EphemeralRecoveryGrant` — zero permanent shared credentials or unattended arbitrary command hooks on USB).
  - Standards-based network boot: **UEFI HTTP(S) Boot** (wired fast path) + **signed minimal Linux Network-Bootstrap UKI + `dm-verity` `switch-root`** (Ethernet + consumer Wi-Fi, Linux TLS + pinned TUF, HTTP `Range` resume, low-RAM detection, offline fallback).
  - Strict **`ram-only`** mode (zero persistent disk writes; **never** uses target SSD for temp storage or swap) and opt-in **`cached-usb`/`cached-ssd`**.
  - Full **`systemd-sysext`/`systemd-confext` + `systemd-sysupdate`** user lifecycle (download, cache, activate, deactivate, remove).
- **Advanced OS Installation & Optional Self-Hosted Fleet Management:**
  - **`sbm-catalog` (Agent 06):** TUF-signed declarative OS catalog (Linux, Windows, BSD) and offline mirroring.
  - **`sbm-core` (Agent 02):** Full `OsInstallPlan` execution (`bootc`/OCI, rootfs extraction, `wimlib-imagex`, `partclone`, `wayvnc` remote desktop relay).
  - **`sbm-server` (Agent 05) & `sbm-uefi` (Agent 01):** Optional self-hosted server (`noVNC`/`xterm.js`), TPM quote attestation, signed remote `CommandEnvelope` verification, and bounded opportunistic UEFI networking.
  - **`sbm-agent` (Agent 08):** Optional guest OS daemon for boot-success confirmation and authorized remote reboot.

---

## Milestone: SBM 0.2 (Priority F2) — Apple Silicon Physical Support, Production Secure Boot & Public Portal

- **`sbm-as` (Agent 04):** Real `sbm-aarch64.efi` under QEMU U-Boot (`sbm-as#1`), light Fedora Asahi Minimal `sbm-core-aarch64-apple`, and Tier 3 external USB3 boot qualification on supported M1/M2/M3 hardware. Track upstream `linux-asahi` M4/M5 (`T8142`) DART/PCIe/USB3 enablement (not an install target until upstream drivers exist).
- **Production Secure Boot & Supply Chain:** Enrolled-key Secure Boot qualification (`sbm-lab#4`), `rhboot/shim 16.1` + SBAT + NX verification, TUF/Sigstore signed releases, and `shim-review` (Microsoft UEFI CA 2023) preparation.
- **`smart-boot-menu.github.io` (Agent 09):** Public documentation portal, `SBM Manager` & verified per-architecture download index, and strictly evidenced Tier 3 hardware compatibility matrix.
