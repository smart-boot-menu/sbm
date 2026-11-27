# Smart Boot Menu — Prioritized Development Roadmap

**Last updated:** 2026-11-27  
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
- UEFI initialization: **`< 250 ms`** *(measured in 0.0.1 Tier 2: `15.83 ms` median `aarch64` HVF, `38.63 ms` median `x86_64` KVM)* | Minimal EFI application: **`< 1 MiB`** *(measured in 0.0.1: `400.5 KiB` `aarch64`, `455.0 KiB` `x86_64`)*
- Compressed base management OS (`sbm-core` base): **`< 500 MiB`** *(0.0.1 full offline image is `820.7 MiB` aarch64 / `854.7 MiB` x86_64; `< 500 MiB` base targeted in 0.0.3 via `systemd-sysext` split)*
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
- **Current Status:** Operational (`sbm-preview` + `sbm-sim`, `< 1 s` startup, `< 5 s` warm rebuild). Experimental hardware dashboards (`sbm-uefi@70a84c5..457c545`, behind `experimental-layouts`) are being iterated here without altering frozen SBM 0.0.1 (`sbm-uefi@4bfb3ba` Classic UI + Atkinson typography).
- **Tier:** Strictly **Tier 1 (Simulated)** — visibly badged as simulated mode; never counts as firmware or block-device qualification.

### Track B (Priority B) — Efficient Open-Source Development Infrastructure (`Agent 16`)

- **Goal:** Keep development fast, reproducible, and comfortable on a 16 GiB workstation by composing mature open-source tools instead of maintaining bespoke infrastructure (per `ADR-010` and `research/ecosystem/dev-infrastructure-and-testing-landscape-2026-11-26.md`).
- **Completed Baseline:** Measured host resource audit, 13.24 GiB physical SSD reclaimed, single-arch dev defaults, root `justfile`, Cargo `build.build-dir` + `sccache` + `nextest` + `zigbuild` benchmarks, `sbm-lab` `gpt.rs`/`fatimg.rs` deduplication onto `sbm-media`, and `os-autoinst` Linux CI prototype.
- **Next Steps:** Adopt `mkosi --incremental=yes` + `Format=sysext` for Level 2 Core iteration, enable `/dev/kvm` permissions in `sbm-lab/.github/workflows/ci.yml`, adopt U-Boot `sandbox` on Linux CI, and reserve `labgrid` for future Tier 3 physical hardware labs.

---

## Milestone: SBM 0.0.1 (Priority C) — Independently Qualified Architecture-Specific Recovery Media (**TIER 2 QUALIFIED — READY FOR OWNER APPROVAL & PHYSICAL USB TEST**)

**Status (2026-11-27):** **BOTH `aarch64` and `x86_64` are Tier 2 Qualified (Development / Preview Trust Tier)** on frozen revisions (`sbm-common@abe3029`, `sbm-uefi@4bfb3ba`, `sbm-core@960f11a`, `install@870069d`, `sbm-lab@5ab4f8c`). All Gates 0–9 (including `N=10` `aarch64` HVF `15.83 ms` median and `N=10` `x86_64` native Linux KVM `38.63 ms` median), software-rendering fallback, and all 6 Tier 2 negative security/integrity checks pass with archived evidence. **Tier 3 physical hardware remains unverified** (pending opt-in HP laptop `EXP-HW-HP01` USB testing); no public release or git tag has been published yet.

- **UI Scope:** Ships the frozen **Classic UI with Atkinson Hyperlegible Next/Mono typography** (`sbm-uefi@4bfb3ba`); newer experimental hardware dashboards (`sbm-uefi@70a84c5..457c545`) remain host-only preview experiments outside 0.0.1.
- **Distribution Policy ([ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)):**
  - `x86_64` (OVMF) and `aarch64` (AAVMF) are qualified **independently**.
  - **Dual-architecture combined media (`sbm-0.0.1-uefi-dualarch.raw[.zst]`) is preserved strictly as an optional experimental build profile**, NOT a recommended distribution or mandatory release gate.
- **Flashing & Release Prep:** Prepared in [`releases/0.0.1-RELEASE-NOTES.md`](releases/0.0.1-RELEASE-NOTES.md) and [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md) using existing graphical flashers (**USBImager**, **Raspberry Pi Imager `>= 2.0.11`**, **Fedora Media Writer**, **GNOME Impression**, **Rufus**) — do NOT build `SBM Manager` prematurely. *(Optional `sbm-os-list.json` feed deferred cleanly to post-0.0.1 / 0.0.3.)*
- **Verification:** See [INTEGRATION_AUDIT.md](INTEGRATION_AUDIT.md), [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md), and [RELEASE_GATES.md](RELEASE_GATES.md).

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
