# Smart Boot Menu — System Requirements

**Status:** Normative Baseline (Updated 2026-11-26, aligned with [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md) & [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md))

## 1. Functional Requirements
- **FR-01 (Fast Native Boot & Upgradeable `efi-only`):** `sbm-uefi` MUST present a graphical boot menu, discover installed EFI/BLS/UKI targets, and chainload Windows, Linux, and BSD without initializing Linux. A minimal `efi-only` installation MUST be independently useful and upgradeable to richer recovery/modular profiles without reinstalling the boot manager.
- **FR-02 (Offline-First & Zero Mandatory Services):** All local boot, discovery, partitioning, diagnostics, backup, and local-media OS installation features MUST work with zero internet access, zero account, zero cloud service, and no `sbm-server`.
- **FR-03 (Configurable Profiles & Multi-Architecture):** SBM MUST support independently configurable installation and execution profiles (`efi-only`, `net-ondemand`, `cached-usb`/`cached-ssd`, `ram-only`, `offline-full`, `modular-custom`) across `x86_64` and `aarch64` from shared source code (with dual-architecture media preserved strictly as optional/experimental), plus Apple Silicon via `sbm-as` in SBM 0.2.
- **FR-04 (Immutable, 0SFS-Style Modular `SBM Core`):** `sbm-core` MUST keep its mandatory base immutable (`dm-verity` EROFS) and as small as practical, using standard `mkosi` + signed `systemd-sysext`/`systemd-confext` DDIs + `systemd-sysupdate` so users can download, cache, activate, deactivate, and remove optional capabilities **without** inventing a general-purpose package manager.
- **FR-05 (Standards-Based Network Recovery):** SBM MUST support preparing recovery USBs via **`SBM Manager`** (optionally preconfiguring network settings, modules, cache policy, and revocable remote access) to download and authenticate `sbm-core` over Ethernet or Wi-Fi using standard mechanisms (UEFI HTTP(S) Boot + signed minimal Linux Network-Bootstrap UKI + `dm-verity` `switch-root`), handling low RAM, unavailable networking, interrupted downloads (`Range` resume), and offline fallback cleanly.
- **FR-06 (Disk, Internal Install & OS Lifecycle):** `sbm-core` and `install` MUST support read-only disk inspection, GParted, persistent internal SSD install/uninstall/boot-repair, allowlisted safe partition shrinking (0.0.3), verified OS catalog installation (0.1), and partition backup/cloning (`partclone`).
- **FR-07 (First-Principles UX & Native Simulation):** SBM's UI MUST prioritize speed, clarity, accessibility, responsive layouts, useful diagnostics, minimal resource consumption, and progressive disclosure—evaluated primarily via Track A's native interactive simulator running the real `sbm-gfx`/`sbm-boot` and Iced `sbm-ui` code.

## 2. Security & Safety Requirements
- **SR-01 (No RCE or Disk Mutation in UEFI):** Zero arbitrary remote code execution or destructive storage actions in `sbm-uefi`.
- **SR-02 (Strict `ram-only` & Authorized-Cache Disk Isolation):** SBM MUST **NEVER** cache images or modules to an internal disk without explicit user authorization. In **`ram-only`** mode, SBM MUST NOT touch target internal SSDs for temporary storage, cache, logs, or swap—even when RAM is constrained.
- **SR-03 (Ephemeral, Opt-In, Revocable Remote Recovery):** Remote access (both persistent `sbm-server` enrollment and `SBM Manager` recovery USB sessions) MUST be opt-in, authenticated, encrypted, revocable, and scope-limited. Recovery USBs MUST **NEVER** store permanent shared credentials or unattended arbitrary command execution hooks, and active remote sessions MUST show an unmistakable local indicator with one-action local revocation.
- **SR-04 (Signed Commands, Releases & Extensions):** Remote commands MUST use signed `CommandEnvelope`s with `device_id` binding, monotonic anti-replay `sequence`, and short TTL. Releases, OS catalogs, and production `systemd-sysext`/`confext` modules MUST enforce cryptographic integrity (`TUF` + SHA-256 + signed `dm-verity` DDIs; zero remote shell scripts).
- **SR-05 (Non-Destructive Storage Guardrails):** Zero unauthorized physical disk modifications across runtime and testing. Read-only discovery by default; composite `DiskIdentity`; `expected_partition_table_sha256` optimistic lock; hard guardrails protecting Apple `iSCPreboot`/`Recovery`/macOS, active ESP, and BitLocker/LUKS/unsafe layouts; explicit BitLocker Recovery Key warning before `BootOrder` changes.
- **SR-06 (Privacy):** Zero mandatory telemetry; zero committed secrets or physical device identifiers.

## 3. Initial Engineering Targets (Aspirational — Distinguished From Measured Capabilities)
These figures are **initial engineering targets** subject to measurement and refinement, NOT measured claims. See full benchmark methodology and current measured status in [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md):
- UEFI initialization (`sbm-uefi` to first GOP paint): **`< 250 ms`**
- Minimal EFI application (`efi-only` / `sbm-uefi` stripped binary): **`< 1 MiB`**
- Compressed base management OS (`sbm-core` base, `x86_64` / `aarch64`): **`< 500 MiB`**
- Local recovery boot on modern hardware (HVF/KVM / NVMe): **`< 10 s`**
- Basic recovery memory footprint: **`≤ 2 GiB RAM`** where practical
- Native interactive UI preview startup (Track A): **`< 1 s`**
- Warm UI iteration (Track A edit-compile-preview): **`< 5 s`**
- Offline independence: **Zero mandatory internet, account, or cloud service**
- Storage safety: **Zero unauthorized physical disk modifications**
