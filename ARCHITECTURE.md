# Smart Boot Menu — System Architecture

**Baseline:** November 2026 | **Canonical ADRs & Diagrams:** [`smart-boot-menu/docs`](https://github.com/smart-boot-menu/docs)

Smart Boot Menu is architected around **two strictly separated execution environments** sharing versioned data contracts from [`sbm-common`](https://github.com/smart-boot-menu/sbm-common), backed by **native interactive host previews** (Track A) and **composed open-source developer & testing infrastructure** (Track B, [ADR-010](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md)).

## 1. Tier 1 — `sbm-uefi` (Pre-OS Fast Path)

A small, deterministic, `#![no_std]` + `alloc` native Rust UEFI application compiled from shared source for `x86_64-unknown-uefi` and `aarch64-unknown-uefi`:
- **Graphical Boot Menu (`sbm-gfx`):** Custom lightweight `#![no_std]` software renderer over UEFI GOP (double-buffered dirty-rect blitting, integer HiDPI scaling, text/serial fallback when GOP is absent). Also runnable natively on macOS/Linux in Track A interactive host preview against simulated platform traits.
- **Automatic OS Discovery & Policy (`sbm-boot`):** Scans standard FAT32 ESP/XBOOTLDR partitions for Windows Boot Manager, UAPI Boot Loader Specification (BLS) Type #1 & Type #2 (UKI) entries, Linux/BSD EFI loaders, and native `sbm-core` recovery slots. Performs lightweight boot-ESP checks at startup (`< 250 ms` target) and single-open sequential streaming SHA-256 verification fail-closed immediately before launching recovery (Spec 03 §9).
- **Chainloading & Policies:** Deterministic precedence (local physical override -> verified one-shot -> healthy default -> fallback), atomic ESP-backed config/attempt counters (avoiding UEFI NVRAM wear/bricking), and automatic rollback when `consecutive_failures >= max_failed_attempts`.
- **Bounded Opportunistic Networking (SBM 0.1+):** Optional Rust `smoltcp` + TLS 1.3 over UEFI SNP with hard-capped timeout (≤ 4 s, immediately interruptible by any keypress), restricted strictly to read-only signed policy fetch and boot-attempt reporting (**no RCE in UEFI**).

## 2. Tier 2 — `sbm-core` (Minimal Linux Management & Recovery Path)

An independently bootable, immutable, modular, RAM-capable minimal Linux OS launched by `sbm-uefi` as a **signed Unified Kernel Image (UKI)** with a **`dm-verity`-verified EROFS (`zstd`)** root filesystem:
- **Unified `mkosi v27.1` Build Pipeline across ALL Platforms (ADR-003):**
  - **x86-64 & Generic ARM64 PCs (`sbm-core-x86_64`, `sbm-core-aarch64`):** Stripped **Fedora Minimal** (~420–650 MiB compressed target) with mainline Linux kernels, curated `.zst` `linux-firmware`, and Wi-Fi/NVMe/GPU driver coverage. Supports `mkosi --incremental=yes` and `systemd-sysext` for fast local iteration.
  - **Apple Silicon (`sbm-core-aarch64-apple`, SBM 0.2):** Super-light **Fedora Asahi Minimal** (~500–850 MiB compressed target) using official Asahi `kernel-16k` (`linux-asahi`), `mesa-asahi`, and local `asahi-fwextract` firmware extraction.
- **Graphics & Recovery Desktop:** `labwc` Wayland compositor + **XWayland** (required for GTK3 **GParted `1.8.1`**) + **Iced** native Rust management shell (`sbm-ui`, GPU-accelerated via `wgpu` with automatic `tiny-skia`/`pixman` software fallback) + `wayvnc` for optional browser-native remote desktop (SBM 0.1+). `sbm-ui` abstracts daemon IPC behind a pluggable backend trait so the exact UI runs natively on macOS/Linux in Track A simulated preview.
- **Storage, Internal Installation & Recovery:** Rust safety orchestrator (`DiskIdentity`, `PartitionProtectionClass`, `StorageOperationPlan`, optimistic `expected_partition_table_sha256` lock, dry-run diff) wrapping mature CLI utilities via direct `execve` (`lsblk`, `blkid`, `sgdisk`, `sfdisk`, `dosfstools`, `efibootmgr`, `e2fsprogs`, `ntfsresize`, `btrfs-progs`, `cryptsetup 2.8.9`, `partclone`, `ddrescue`, `testdisk`, `wimlib-imagex 1.14.5`, `bootc`, and interactive `gparted 1.8.1`). Preserves SBM's security and `MIT OR Apache-2.0` licensing boundaries without adopting the Calamares/Qt6/KPMcore framework.
- **RAM-Resident & Low-RAM Adaptive Execution:** Automatically copies the EROFS image to RAM (`sbm.toram=auto`) on systems with ≥ 4 GiB RAM (freeing physical disks for partitioning/installation) and mounts EROFS directly with backing-disk RO protection on lower-RAM hardware.

## 3. Distribution Media, Internal SSD Installation & Media Creator

- **Independently Qualified Per-Architecture Media (0.0.1 Primary, ADR-009):** `sbm-<ver>-uefi-x86_64.raw[.zst]` and `sbm-<ver>-uefi-aarch64.raw[.zst]` (3-partition GPT: FAT32 ESP + native EROFS root + native dm-verity hash). Combined dual-architecture media (`sbm-<ver>-uefi-dualarch.raw[.zst]`) is preserved strictly as an **optional experimental profile**.
- **Persistent Internal SSD Installation (0.0.2, Spec 04 §11a):** Boots from USB and installs native-arch `sbm-uefi` (`\EFI\sbm\sbm-<arch>.efi`) + `sbm-core` recovery partitions into existing unallocated GPT space alongside existing Windows/Linux OSes without touching existing OS bootloaders, registers UEFI boot entry via `efibootmgr`, writes `\EFI\sbm\install-receipt.json`, and supports clean **Uninstall** and **Boot Registration Repair**.
- **Cross-Platform Media Creator & Guided Partition Resizing (0.0.3, ADR-011):**
  - *Media Creator:* Publish `sbm-os-list.json` for stock **Raspberry Pi Imager (`>= 2.0.11`)** in 0.0.1/0.0.2; evaluate a minimal Apache-2.0 branded `rpi-imager` build before considering any custom flasher for 0.0.3.
  - *Guided Resizing:* Strictly allowlisted shrinking of clean unencrypted `ext4`, clean non-hibernated/non-BitLocker `NTFS`, and single-device `Btrfs` following the Golden Rule of Safe Shrinking, hard-blocking encrypted/unsafe layouts.

## 4. Three-Tier Verification & Composed OSS Dev Infrastructure

- **Tier 1 (Simulated / Native Host):** `cargo test`, `proptest`, regular-file `sbm-plan`/`sbm-exec`, and Track A native interactive previews (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`).
- **Tier 2 (Disposable VM Disk):** QEMU + OVMF/AAVMF/U-Boot + `swtpm` over disposable copy-on-write QCOW2 overlays (`sbm-lab` macOS host RAM guard + minimal HVF runner; `os-autoinst` and U-Boot `sandbox` evaluated/adopted on Linux CI).
- **Tier 3 (Explicitly Authorized Physical Hardware):** Opt-in manual testing on dedicated non-workstation hardware (future `labgrid` lab); never automated on developer workstations.

## 5. Apple Silicon & Optional Ecosystem Components (SBM 0.1–0.2)

- **`sbm-as`:** Integrates upstream `m1n1` -> `AsahiLinux/u-boot` (`CONFIG_EFI_LOADER`) -> the exact same `aarch64` `sbm-uefi` binary (external USB3 boot on M1/M2/M3 in SBM 0.2; M4/M5 `T8142` tracked upstream).
- **`sbm-server`:** Optional single-binary Rust server (`axum`, `tokio`, `sqlx`) + embedded `SvelteKit` dashboard (`noVNC` + `xterm.js`), Passkeys, mTLS, and Ed25519-signed `CommandEnvelope`s.
- **`sbm-catalog`:** TUF-signed declarative OS definitions and verified mirror checksums (zero executable shell scripts).
- **`sbm-agent`:** Optional guest OS daemon confirming boot success and coordinating remote reboots.

See all 10 Mermaid architecture and sequence diagrams in [`docs/diagrams/architecture-diagrams.md`](https://github.com/smart-boot-menu/docs/blob/main/diagrams/architecture-diagrams.md).
