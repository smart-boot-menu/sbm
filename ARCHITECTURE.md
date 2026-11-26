# Smart Boot Menu — System Architecture

**Baseline:** November 2026 | **Canonical ADRs & Diagrams:** [`smart-boot-menu/docs`](https://github.com/smart-boot-menu/docs)

Smart Boot Menu is architected around **two strictly separated execution environments** sharing versioned data contracts from [`sbm-common`](https://github.com/smart-boot-menu/sbm-common):

## 1. Tier 1 — `sbm-uefi` (Pre-OS Fast Path)

A small, deterministic, `#![no_std]` + `alloc` native Rust UEFI application compiled from shared source for `x86_64-unknown-uefi` and `aarch64-unknown-uefi` (with best-effort `i686-unknown-uefi`):
- **Graphical Boot Menu:** Custom lightweight `#![no_std]` software renderer over UEFI GOP (double-buffered dirty-rect blitting, integer HiDPI scaling, text/serial fallback when GOP is absent).
- **Automatic OS Discovery:** Scans standard FAT32 ESP/XBOOTLDR partitions for Windows Boot Manager, UAPI Boot Loader Specification (BLS) Type #1 & Type #2 (UKI) entries, Linux/BSD EFI loaders, and `sbm-core` A/B recovery slots.
- **Chainloading & Policies:** Deterministic precedence (local physical override -> verified one-shot -> healthy default -> fallback), atomic ESP-backed config/attempt counters (avoiding UEFI NVRAM wear/bricking), and automatic rollback when `consecutive_failures >= max_failed_attempts`.
- **Bounded Opportunistic Networking:** Optional Rust `smoltcp` + TLS 1.3 over UEFI SNP with hard-capped timeout (≤ 4 s, immediately interruptible by any keypress), restricted strictly to read-only signed policy fetch and boot-attempt reporting (**no RCE in UEFI**).

## 2. Tier 2 — `sbm-core` (Minimal Linux Management & Recovery Path)

An independently bootable, immutable, modular, RAM-capable minimal Linux OS launched by `sbm-uefi` as a **signed Unified Kernel Image (UKI)** with a **`dm-verity`-verified EROFS (`zstd`)** root filesystem:
- **Unified `mkosi v27.1` Build Pipeline across ALL Platforms (ADR-003):**
  - **x86-64 & Generic ARM64 PCs (`sbm-core-x86_64`, `sbm-core-aarch64`):** Stripped **Fedora Minimal** (~420–650 MB compressed) with fresh mainline Linux kernels, curated `.zst` `linux-firmware`, and full Wi-Fi/NVMe/GPU driver coverage.
  - **Apple Silicon (`sbm-core-aarch64-apple`):** Super-light **Fedora Asahi Minimal** (~500–850 MB compressed, well under 1 GB / 4 GB ceiling) using official Asahi `kernel-16k` (`linux-asahi`), `mesa-asahi`, and local `asahi-fwextract` firmware extraction.
- **Graphics & Recovery Desktop:** `labwc` Wayland compositor + **XWayland** (required for GTK3 **GParted `1.8.1`**) + **Iced** native Rust management shell (GPU-accelerated via `wgpu` with automatic `tiny-skia`/`llvmpipe` CPU fallback) + `wayvnc` for browser-native remote desktop.
- **Storage, Cloning & OS Installation:** Rust safety orchestrator (`DiskIdentity`, `PartitionProtectionClass`, `StorageOperationPlan`, dry-run diff) wrapping battle-tested CLI utilities (`util-linux`, `sgdisk`, `e2fsprogs`, `ntfs-3g`, `btrfs-progs`, `cryptsetup 2.8.9` LUKS2/BitLocker, `partclone`, `ddrescue`, `testdisk`, `wimlib-imagex 1.14.5`, `bootc`).
- **RAM-Resident & Low-RAM Adaptive Execution:** Automatically copies the ~500 MB EROFS image to RAM (`sbm.toram=auto`) on systems with ≥ 4 GiB RAM (freeing all physical disks for partitioning/cloning), and mounts EROFS directly with `zram` overlay on older 2 GiB hardware.
- **A/B Atomic Updates:** Dual recovery slots (`Slot A` / `Slot B`) updated via TUF-verified `systemd-sysupdate` with automatic `sbm-uefi` rollback.

## 3. Apple Silicon Bootstrap (`sbm-as`)

Apple Silicon is not native UEFI. `sbm-as` integrates upstream **`m1n1`** (blessed once in 1TR via `bputil`) -> **`AsahiLinux/u-boot`** (`CONFIG_EFI_LOADER`) -> the **exact same `aarch64-unknown-uefi` `sbm-uefi` binary**.
- Internal stub footprint (~1.5–2.0 GB total including APFS stub + ESP + light `< 1 GB` Asahi `sbm-core`) enables booting compatible `linux-asahi` OSes from **external USB 3.x SSDs** on M1/M2/M3 today.
- **Verified Nov 2026 M5 (`T8142`) Status:** Early `linux-asahi` bring-up only (NVMe, boot framebuffer, keyboard); USB/Thunderbolt/PCIe/DART/GPU/Wi-Fi are still `TBA`. Physical M5 bare-metal support is tracked upstream and explicitly deferred past SBM 0.1.

## 4. Optional Ecosystem Components

- **`install`:** Installs, updates, and uninstalls SBM itself, builds bootable SBM USB media, and enforces BitLocker & Apple partition safety gates.
- **`sbm-server`:** Optional single-binary Rust server (`axum`, `tokio`, `sqlx` SQLite/PostgreSQL) + embedded `SvelteKit` dashboard (`noVNC` + `xterm.js`), Passkeys (`webauthn-rs`), mTLS device identity, and Ed25519-signed `CommandEnvelope`s.
- **`sbm-catalog`:** TUF-signed declarative OS definitions and verified mirror checksums (zero executable shell scripts).
- **`sbm-agent`:** Optional guest OS daemon confirming boot success, reporting health, and coordinating remote reboots.
- **`sbm-lab`:** QEMU + OVMF/AAVMF + U-Boot `qemu_arm64` + `swtpm` automated virtual hardware lab, benchmarks, and fault injection.

See all 10 Mermaid architecture and sequence diagrams in [`docs/diagrams/architecture-diagrams.md`](https://github.com/smart-boot-menu/docs/blob/main/diagrams/architecture-diagrams.md).
