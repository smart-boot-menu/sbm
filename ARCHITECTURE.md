# Smart Boot Menu — System Architecture

**Baseline:** November 2026 | **Canonical ADRs & Diagrams:** [`smart-boot-menu/docs`](https://github.com/smart-boot-menu/docs)

Smart Boot Menu is architected around **two strictly separated execution environments** (`sbm-uefi` + `sbm-core`) sharing versioned data contracts from [`sbm-common`](https://github.com/smart-boot-menu/sbm-common), configurable across **six installation/execution profiles implemented as validated presets of shared configuration options** (NOT six duplicated implementations, [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md)), provisioned by **`SBM Manager`**, evaluated daily in **Track A's native interactive simulator**, and verified by **composed open-source infrastructure** (Track B, [ADR-010](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md)).

## 1. Tier 1 — `sbm-uefi` (Pre-OS Fast Path)

A small, deterministic, `#![no_std]` + `alloc` native Rust UEFI application targeting **`< 1 MiB`** stripped binary size and **`< 250 ms`** initialization, compiled from shared source for `x86_64-unknown-uefi` and `aarch64-unknown-uefi`:
- **Graphical Boot Menu (`sbm-gfx`):** Custom lightweight `#![no_std]` software renderer over UEFI GOP (double-buffered dirty-rect blitting, integer HiDPI scaling, text/serial fallback when GOP is absent), designed from first principles (Nov 2026 UX philosophy) and runnable natively on macOS/Linux in Track A interactive host preview against simulated platform traits.
- **Automatic OS Discovery & Policy (`sbm-boot`):** Scans standard FAT32 ESP/XBOOTLDR partitions for Windows Boot Manager, UAPI Boot Loader Specification (BLS) Type #1 & Type #2 (UKI) entries, Linux/BSD EFI loaders, and native `sbm-core` recovery slots. Performs lightweight boot-ESP checks at startup and single-open sequential streaming SHA-256 verification fail-closed immediately before launching recovery (Spec 03 §9).
- **Independently Useful & Upgradeable `efi-only` Profile (0.0.2+):** Can be installed standalone on an existing ESP (`< 1 MiB`) with zero extra partitions and later upgraded to offline, cached, modular, or network-recovery profiles without reinstalling the boot manager.
- **Chainloading & Policies:** Deterministic precedence (local physical override -> verified one-shot / bound `LocalBootRequest` -> healthy default -> fallback), atomic ESP-backed config/attempt counters (avoiding UEFI NVRAM wear/bricking), and automatic rollback when `consecutive_failures >= max_failed_attempts`.
- **Bounded Opportunistic Networking (SBM 0.1+):** Optional standard UEFI HTTP(S) Boot fast path and Rust `smoltcp` + TLS 1.3 over UEFI SNP with hard-capped timeout (≤ 4 s, immediately interruptible by any keypress), restricted strictly to read-only signed policy fetch and boot-attempt reporting (**no RCE in UEFI**).

## 2. Tier 2 — `sbm-core` (Minimal, Immutable, Modular Linux Management OS)

Retaining **`SBM Core`** as the internal management OS name, `sbm-core` is an independently bootable, immutable, **0SFS-style modular**, RAM-capable minimal Linux OS launched by `sbm-uefi` as a **signed Unified Kernel Image (UKI)** with a **`dm-verity`-verified EROFS (`zstd`)** root filesystem:
- **Unified `mkosi v27.1` Build Pipeline across ALL Platforms (ADR-003, ADR-012):**
  - **x86-64 & Generic ARM64 PCs (`sbm-core-x86_64`, `sbm-core-aarch64`):** Stripped **Fedora Minimal** base targeting **`< 500 MiB`** compressed (with optional capabilities split into signed `systemd-sysext` DDIs starting in 0.0.3), mainline Linux kernels, curated `.zst` `linux-firmware`, and Wi-Fi/NVMe/GPU driver coverage.
  - **Apple Silicon (`sbm-core-aarch64-apple`, SBM 0.2):** Super-light **Fedora Asahi Minimal** (`kernel-16k` `linux-asahi`, `mesa-asahi`, local `asahi-fwextract`).
- **0SFS-Style Maximum Modularity (Zero Custom Package Manager, Spec 07 §17a):**
  - Optional capabilities are packaged via **`mkosi`** (`Format=sysext`/`Format=confext`, `Overlay=yes`, `BaseTrees=`) as signed `dm-verity` GPT DDIs, activated/deactivated with **`systemd-sysext`/`systemd-confext`** (`--image-policy='root=signed+absent:usr=signed+absent:=unused+absent'`, TPM2 PCR 13 for initrd extensions), and fetched/updated via **`systemd-sysupdate`** + signed TUF `ModuleDescriptor` metadata.
  - Users can **download, cache, activate, deactivate, and remove** optional modules while preserving the immutable verified base root.
- **Graphics & First-Principles Recovery Desktop:** `labwc` Wayland compositor + **XWayland** (required for GTK3 **GParted `1.8.1`**) + **Iced** native Rust management shell (`sbm-ui`, GPU-accelerated via `wgpu` with automatic `tiny-skia`/`pixman` software fallback) + `wayvnc` for optional remote desktop (SBM 0.1+). `sbm-ui` abstracts daemon IPC behind a pluggable backend trait so the exact UI runs natively on macOS/Linux in **Track A's simulator** (our primary UX evaluation and refinement workbench).
- **Storage, Internal Installation & Recovery:** Rust safety orchestrator (`DiskIdentity`, `PartitionProtectionClass`, `StorageOperationPlan`, optimistic `expected_partition_table_sha256` lock, dry-run diff) wrapping mature CLI utilities via direct `execve` (`lsblk`, `blkid`, `sgdisk`, `sfdisk`, `dosfstools`, `efibootmgr`, `e2fsprogs`, `ntfsresize`, `btrfs-progs`, `cryptsetup 2.8.9`, `partclone`, `ddrescue`, `testdisk`, `wimlib-imagex 1.14.5`, `bootc`, and interactive `gparted 1.8.1`). Preserves SBM's security and `MIT OR Apache-2.0` licensing boundaries without adopting the Calamares/Qt6/KPMcore framework.
- **Validated Profile Presets & Cache Policies (`ram-only`, `cached-usb`, `cached-ssd`, `offline-full`):**
  - All six profiles are **validated presets over shared configuration options** driving one shared pipeline—never duplicated implementations; future-milestone presets fail closed in earlier releases.
  - **`ram-only`:** Strictly RAM-resident with zero persistent disk writes — **MUST NOT** use any target internal SSD for temporary storage, cache, logs, or swap (checks RAM up front; targets basic recovery on `≤ 2 GiB RAM` where practical).
  - **`cached-usb` / `cached-ssd`:** Persistent caching strictly requires explicit user authorization; internal disks are **NEVER** used as a cache without consent.

## 3. Network Recovery & Ephemeral Remote Repair (SBM 0.1, Spec 03 §9a & Spec 06 §16a)

- **No Custom Network Boot Protocol:** Combines standard **UEFI HTTP(S) Boot** (wired Ethernet fast path for `efi-only`, plus iPXE interop) with a compact **signed minimal Linux Network-Bootstrap UKI + `dm-verity` `switch-root`** for consumer Ethernet & Wi-Fi recovery USBs (full Linux TLS CA + pinned TUF verification, HTTP `Range` resume on interrupted downloads, low-RAM checks, and offline fallback).
- **Ephemeral, Revocable Remote Access:** Enabled strictly opt-in via `SBM Manager` (short-lived single-session `EphemeralRecoveryGrant`, fresh in-RAM ephemeral target keypair, end-to-end encryption, unmistakable local active-session banner + one-action kill switch, automatic revocation on exit/expiry/reboot). **Zero permanent shared credentials and zero unattended arbitrary command execution on recovery USB drives.**

## 4. Distribution Media, Release Trust Tiers, Internal SSD Installation & `SBM Manager`

- **Independently Qualified Per-Architecture Media (0.0.1 Primary, ADR-009):** `sbm-<ver>-uefi-x86_64.raw[.zst]` and `sbm-<ver>-uefi-aarch64.raw[.zst]` (3-partition GPT). Combined dual-architecture media (`sbm-<ver>-uefi-dualarch.raw[.zst]`) is preserved strictly as an **optional experimental profile**.
- **Release Trust Tiers (ADR-012 §7 & Spec 07 §17):** **Development releases** (such as SBM 0.0.1) carry narrower, explicitly documented trust and hardware compatibility (`production_secure_boot_claimed: false`, requiring Secure Boot disabled or custom keys on physical hardware). **Consumer-ready releases** (SBM 0.2+ / Stable) MUST include **production Secure Boot compatibility** (`rhboot/shim` + SBAT + NX + Microsoft UEFI CA 2023 / `shim-review`) and verified TUF/Sigstore release trust.
- **Persistent Internal SSD Installation (0.0.2, Spec 04 §11a):** Supports both **`efi-only` (`< 1 MiB`)** and available-space **`offline-full`** installation alongside existing Windows/Linux OSes without touching existing bootloaders, registers UEFI boot entry via `efibootmgr`, writes `\EFI\sbm\install-receipt.json`, and supports clean **Uninstall** and **Boot Registration Repair**.
- **`SBM Manager` & Guided Partition Resizing (0.0.3+, ADR-011 & ADR-012):**
  - *`SBM Manager`:* The user-facing desktop provisioning & configuration application (superseding "Media Creator"). Uses zero-code `sbm-os-list.json` (`rpi-imager >= 2.0.11`) in 0.0.1–0.0.2, then delivers `SBM Manager` MVP in 0.0.3 (comparing minimal `rpi-imager` fork vs. thin Rust/Iced app reusing OS flashing backends) and expands in 0.1 to recovery USB network preconfig, module management, cache policy, and ephemeral remote-access grants.
  - *Guided Resizing (0.0.3):* Strictly allowlisted shrinking of clean unencrypted `ext4`, clean non-hibernated/non-BitLocker `NTFS`, and single-device `Btrfs` following the Golden Rule of Safe Shrinking, hard-blocking encrypted/unsafe layouts.

## 5. Three-Tier Verification & Composed OSS Dev Infrastructure

- **Tier 1 (Simulated / Native Host):** `cargo test`, `proptest`, regular-file `sbm-plan`/`sbm-exec`, and **Track A native interactive previews** (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`, primary UX studio targeting `< 1 s` startup and `< 5 s` warm iteration).
- **Tier 2 (Disposable VM Disk):** QEMU + OVMF/AAVMF/U-Boot + `swtpm` over disposable copy-on-write QCOW2 overlays (`sbm-lab` macOS host RAM guard + minimal HVF runner; `os-autoinst` and U-Boot `sandbox` on Linux CI).
- **Tier 3 (Explicitly Authorized Physical Hardware):** Opt-in manual testing on dedicated non-workstation hardware (future `labgrid` lab); never automated on developer workstations.

## 6. Apple Silicon & Optional Ecosystem Components (SBM 0.1–0.2)

- **`sbm-as`:** Integrates upstream `m1n1` -> `AsahiLinux/u-boot` (`CONFIG_EFI_LOADER`) -> the exact same `aarch64` `sbm-uefi` binary (external USB3 boot on M1/M2/M3 in SBM 0.2; M4/M5 `T8142` tracked upstream).
- **`sbm-server`:** Optional single-binary Rust server (`axum`, `tokio`, `sqlx`) + embedded `SvelteKit` dashboard (`noVNC` + `xterm.js`), Passkeys, mTLS, and Ed25519-signed `CommandEnvelope`s.
- **`sbm-catalog`:** TUF-signed declarative OS definitions and verified mirror checksums (zero executable shell scripts).
- **`sbm-agent`:** Optional guest OS daemon confirming boot success and coordinating remote reboots.

See all 10 Mermaid architecture and sequence diagrams in [`docs/diagrams/architecture-diagrams.md`](https://github.com/smart-boot-menu/docs/blob/main/diagrams/architecture-diagrams.md).
