# Smart Boot Menu — Prioritized Development Roadmap

**Last updated:** 2026-11-26  
**Canonical Decisions:** [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md), [ADR-010](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md)  
**Testing Policy:** Strictly separates **Tier 1 (Simulated)**, **Tier 2 (Disposable VM Disk)**, and **Tier 3 (Explicitly Authorized Physical Hardware)** per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md).

---

## Target End-User Installation Experience (North Star Through SBM 0.0.3)

```text
Download Media Creator -> flash USB -> boot target computer -> Install SBM
-> inspect and optionally adjust partitions -> confirm -> install
-> reboot into SBM from internal SSD
```

Every milestone below builds cleanly toward this end-user flow in risk-isolated increments, following **ADR-010** (*write less software; reuse the best open-source tools first*).

---

## Phase 0 — Architecture & Foundation (Completed)

- Initialized 14 GitHub repositories (`smart-boot-menu/*`), dual licenses (`MIT OR Apache-2.0`), centralized `.github/AGENTS.md` + `agent-reference.md`, and CI conventions.
- Completed primary-source ecosystem, hardware, dev-infrastructure, Media Creator, and internal-install/Calamares research (`research/`).
- Ratified ADRs 001–011, v1 specifications (19 interfaces), threat model, and 10 Mermaid diagrams (`docs/`).
- Implemented and verified `sbm-common` (`no_std` `sbm-types` + `sbm-protocol`, `std` `sbm-schema`, 18 JSON Schemas, golden test vectors).

---

## Continuous Enabling Tracks (Start Immediately in Parallel With 0.0.1–0.0.3)

> **Milestone Structure Refinement:** Priorities **A** and **B** are structured as continuous enabling tracks running *alongside* 0.0.1–0.0.3 rather than sequential version gates, so every product milestone benefits immediately from sub-second native UI iteration and low-RAM open-source developer tooling.

### Track A (Priority A) — Native Interactive SBM Development (`Agent 18`)

- **Goal:** Run the **actual** `sbm-uefi` renderer (`sbm-gfx` + `sbm-boot`) and the **actual** Iced `sbm-core` UI (`sbm-ui`) natively on macOS and Linux against simulated platform interfaces — no VM boots required for UI, theme, layout, handoff, or installation-wizard iteration.
- **Scope:**
  - Interactive native host window over real `sbm-gfx`/`sbm-boot` (keyboard/mouse navigation, HiDPI scaling, dark/light theme, diagnostics/error views, simulated ESP & discovered OS cards, **Manage Computer** handoff).
  - Pluggable `CoreBackend` trait in `sbm-ui` with a rich deterministic `SimulatedCoreBackend` (simulated disks, OSes, protected BitLocker/APFS partitions, recovery tools, and interactive **Install SBM** / resize dry-run preview).
  - End-to-end simulated transition from UEFI picker -> Manage Computer -> Iced Core UI -> Reboot -> UEFI picker.
- **Tier:** Strictly **Tier 1 (Simulated)** — visibly badged as simulated mode; never counts as firmware or block-device qualification.

### Track B (Priority B) — Efficient Open-Source Development Infrastructure (`Agent 16`)

- **Goal:** Keep development fast, reproducible, and comfortable on a 16 GiB fanless workstation by composing mature open-source tools instead of maintaining bespoke infrastructure (per `ADR-010` and `research/ecosystem/dev-infrastructure-and-testing-landscape-2026-11-26.md`).
- **Completed Baseline:** Measured host resource audit, 13.24 GiB physical SSD reclaimed, single-arch dev defaults in `sbm-uefi`/`sbm-core`, uncompressed dev builds, QCOW2 `discard=unmap` + `fstrim`, `xtask preview` Level 0 PNG renderer, `check-reproducible.sh` disk-footprint fix.
- **Next Steps:**
  - Cargo 1.100 per-workspace `build.build-dir` + `mozilla/sccache` (`SCCACHE_ALLOW_INCREMENTAL=1`) + thin root `justfile` (`just`) instead of a custom `sbm-dev` CLI.
  - Incremental `sbm-core` dev iteration via `mkosi --incremental=yes` + `Format=sysext` + `systemd-sysext`.
  - Trial **Lima (`vmType: krunkit`, `libkrun >= v1.19.8`)** to replace custom QEMU cloud-init/`rsync` builder scripts if benchmarks win on `virtiofs` speed and macOS memory reclamation.
  - Shrink `sbm-lab` by consolidating duplicate `gpt.rs`/`fatimg.rs` onto `sbm-media`, adopting **U-Boot `sandbox`** on Linux CI, evaluating **`os-autoinst` (`isotovideo`)** for Linux CI graphical/needle integration tests, and reserving **`labgrid`** for future Tier 3 physical hardware labs.

---

## Milestone: SBM 0.0.1 (Priority C) — Independently Qualified Architecture-Specific Recovery Media

**Goal:** Independently qualify reproducible, offline, **architecture-specific** bootable recovery media (`sbm-0.0.1-uefi-x86_64.raw[.zst]` and `sbm-0.0.1-uefi-aarch64.raw[.zst]`) through the complete real UEFI -> Core -> Iced UI -> GParted -> clean Reboot -> confirmation workflow.

- **Distribution Policy ([ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)):**
  - `x86_64` (OVMF) and `aarch64` (AAVMF) are qualified **independently** — a slowdown or issue on one architecture does not block qualification of the other.
  - **Dual-architecture combined media (`sbm-0.0.1-uefi-dualarch.raw[.zst]`) is preserved strictly as an optional experimental build profile**, NOT a recommended consumer distribution or mandatory release gate.
- **Zero-Code Media Flashing Bridge:** Publish a schema-validated `sbm-os-list.json` compatible with **Raspberry Pi Imager (`>= 2.0.11`, `--repo`)** alongside documented instructions for USBImager, Fedora Media Writer, GNOME Impression, and Rufus.
- **Verification:** Tier 1 unit/contract tests + Tier 2 disposable VM end-to-end positive (Gates 1–9) and negative (tampered UKI, broken dm-verity, invalid handoff, decoy ESP) qualification per architecture. See [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md) and [RELEASE_GATES.md](RELEASE_GATES.md).

---

## Milestone: SBM 0.0.2 (Priority D) — Persistent Internal SSD Installation, Uninstall & Recovery

**Goal:** Boot SBM from removable USB media and safely install Smart Boot Menu permanently onto an internal GPT SSD alongside existing Windows and Linux operating systems, with clean firmware boot registration, uninstall, and boot recovery.

- **Scope & Risk Boundary ([Spec 04 §11a](../docs/specifications/04-storage-and-installation-plans.md)):**
  - **Available-space-only installation (no partition shrinking yet):** Allocates native-arch `sbm-core` `root-<arch>` + `root-<arch>-verity` partitions only in existing unallocated GPT space (or an explicit empty disk), isolating partition creation, ESP coexistence, and NVRAM registration from high-risk filesystem shrinking.
  - **Preserve SBM planner & security boundaries (`sbm-plan`, `sbm-exec`, `sbm-common#2`):** Typed `StorageOperationPlan`, composite `DiskIdentity`, `expected_partition_table_sha256` optimistic concurrency lock, `PartitionProtectionClass` guards (Apple `ProtectedAppleSystem` hard-block, BitLocker recovery-key warning before `BootOrder` changes), GPT backup (`sgdisk --backup`), and human-readable dry-run diff.
  - **Reuse mature CLI tools (`ADR-006`, `ADR-011`):** `lsblk`, `blkid`, `sgdisk`/`sfdisk`, `partprobe`, `dosfstools`, `efibootmgr` via isolated `execve` subprocesses (rejecting full Calamares framework adoption while adopting its deferred-execution and quiescing patterns).
  - **Install SBM UI in `sbm-ui`:** Interactive installation, uninstall, and **Repair SBM Boot Registration** flows inside Iced `sbm-ui` (designed and exercised first in Track A native preview!).
  - **Install Receipt & Clean Uninstall:** `\EFI\sbm\install-receipt.json` records created PARTUUIDs, installed files, and prior `BootOrder` so uninstall cleanly restores prior `BootOrder`, deletes SBM's NVRAM entry, removes `\EFI\sbm\` without touching Windows/Linux bootloaders, and optionally removes SBM's recovery partitions.
- **Verification:** Tier 1 simulated regular-file tests + Tier 2 disposable VM multi-OS disk tests (Windows ESP + Linux ESP + unallocated space -> install -> detach USB -> reboot into internal SSD SBM -> chainload existing OS -> uninstall -> restore prior `BootOrder` -> boot recovery after simulated NVRAM reset). Optional Tier 3 testing only on explicitly authorized non-workstation hardware.

---

## Milestone: SBM 0.0.3 (Priority E) — Cross-Platform Media Creator & Guided Partition Resizing

**Goal:** Deliver the complete consumer installation flow end-to-end: `Download Media Creator -> flash USB -> boot target computer -> Install SBM -> inspect and optionally adjust partitions -> confirm -> install -> reboot into SBM from internal SSD`.

- **Cross-Platform Media Creator ([research/ecosystem/media-creator-evaluation.md](../research/ecosystem/media-creator-evaluation.md)):**
  - Evaluate and ship based on primary-source build-vs-reuse evidence: default to a **minimal Apache-2.0 branded build/fork of `raspberrypi/rpi-imager`** (reusing cross-platform macOS/Windows/Linux elevation, system-drive filtering, `libarchive`+`libzstd`, and post-write verification, with telemetry disabled and SBM's release catalog baked in). Only build an original Rust/Iced Media Creator if empirical trial reveals unacceptable UX, Qt6 packaging/signing TCO, or TUF-verification limitations.
- **Guided Partition Resizing for Explicitly Supported Configurations ([Spec 04 §11b](../docs/specifications/04-storage-and-installation-plans.md)):**
  - Visual partition inspection + bounded shrink slider in `sbm-ui` (iterated in Track A preview first).
  - **Explicitly supported allowlist ONLY:** clean unencrypted `ext4` (`e2fsck`/`resize2fs`), clean unencrypted non-hibernated/non-BitLocker `NTFS` (`ntfsresize`), and clean unencrypted single-device `Btrfs` (`btrfs filesystem resize`), strictly following the Golden Rule of Safe Shrinking (shrink FS with margin -> shrink partition keeping start sector -> expand FS to boundary).
  - **Hard-blocked with clear remediation guidance:** BitLocker, LUKS, LVM/RAID/ZFS/XFS, Windows Dynamic Disks, dirty/hibernated NTFS, Apple APFS, MBR disks. Bundled GParted remains available for manual expert layouts.
- **Verification:** Tier 1 simulated resize-math/guard tests + Tier 2 disposable VM tests on real populated ext4, NTFS, and Btrfs QCOW2 disks (verifying surviving OS files and bootability after shrink + internal SBM install + reboot) + Media Creator dry-run/image-write verification.

---

## Milestone: SBM 0.1+ (Priority F) — Advanced OS Installation, Remote Management & Apple Silicon

> **Milestone Structure Refinement:** Split Priority F into **SBM 0.1** (standard UEFI PCs: OS Catalog + Remote Management) and **SBM 0.2** (Apple Silicon physical hardware + Production Secure Boot / `shim-review` + public compatibility portal) so upstream Apple M4/M5 kernel timelines and Microsoft CA 2023 signing waits never block OS installation or remote management.

### SBM 0.1 — Advanced OS Installation & Optional Self-Hosted Remote Management
- **`sbm-catalog` (Agent 06):** TUF-signed declarative OS catalog with verified upstream signatures (Linux, Windows, BSD) and offline mirroring.
- **`sbm-core` (Agent 02):** Full `OsInstallPlan` execution (`bootc`/OCI, rootfs extraction, `wimlib-imagex` Windows installation, `partclone` backup/restore, `wayvnc` remote desktop relay).
- **`sbm-server` (Agent 05) & `sbm-uefi` (Agent 01):** Live `wayvnc`/`noVNC` recovery tunnel, real TPM quote attestation verification, signed remote `CommandEnvelope` verification in `sbm-uefi`, and bounded opportunistic networking.
- **`sbm-agent` (Agent 08):** Optional guest OS daemon (Linux/Windows) for boot-success confirmation (enabling A/B rollback) and authorized remote reboot.

### SBM 0.2 — Apple Silicon Physical Support, Production Secure Boot & Public Portal
- **`sbm-as` (Agent 04):** Real `sbm-aarch64.efi` under QEMU U-Boot (`sbm-as#1`), light `< 900 MiB` Fedora Asahi Minimal `sbm-core-aarch64-apple`, and Tier 3 external USB3 boot qualification on supported M1/M2/M3 hardware. Track upstream `linux-asahi` M4/M5 (`T8142`) DART/PCIe/USB3 enablement (not an install target until upstream drivers exist).
- **Production Secure Boot & Supply Chain:** Enrolled-key Secure Boot qualification (`sbm-lab#4`), `rhboot/shim 16.1` + SBAT + NX verification, TUF/Sigstore signed releases, and `shim-review` (Microsoft UEFI CA 2023) preparation.
- **`smart-boot-menu.github.io` (Agent 09):** Public documentation portal, Media Creator & verified per-architecture download index, and strictly evidenced Tier 3 hardware compatibility matrix.
