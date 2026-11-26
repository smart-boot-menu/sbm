# Smart Boot Menu — System Requirements

**Status:** Normative Baseline (2026-11-26)

## 1. Functional Requirements
- **FR-01 (Fast Native Boot):** `sbm-uefi` MUST present a graphical boot menu, discover installed EFI/BLS/UKI targets, and chainload Windows, Linux, and BSD without initializing Linux.
- **FR-02 (Offline-First):** All local boot, discovery, partitioning, diagnostics, backup, and local-media OS installation features MUST work with zero internet access, zero account, and no `sbm-server`.
- **FR-03 (Multi-Architecture):** `sbm-uefi` and `sbm-core` MUST support `x86_64` and `aarch64` from shared source code; Apple Silicon MUST be supported via `sbm-as` (`m1n1` + `Asahi U-Boot` + light Fedora Asahi `sbm-core`).
- **FR-04 (Independent Recovery OS):** `sbm-core` MUST be immutable, modular (`systemd-sysext`), RAM-resident capable on ≥ 4 GiB machines, low-RAM compatible on 2 GiB machines, and independently recoverable via A/B slots.
- **FR-05 (Disk & OS Lifecycle):** `sbm-core` MUST support read-only disk inspection, launching GParted, validated storage planning, verified OS catalog installation (Linux, Windows via `wimlib`, BSD), and partition backup/cloning (`partclone`).
- **FR-06 (Optional Remote Management):** Enrolled devices MAY fetch signed boot policies in `sbm-uefi` (bounded ≤ 4 s timeout) and expose authenticated browser-native remote desktop (`wayvnc`/`noVNC`) and terminal inside `sbm-core`.

## 2. Security & Safety Requirements
- **SR-01:** Zero arbitrary remote code execution or destructive storage actions in `sbm-uefi`.
- **SR-02:** Explicit opt-in device enrollment; strict RBAC separation between `boot_select` and `storage_destructive`; Passkey step-up for destructive remote operations.
- **SR-03:** Signed `CommandEnvelope`s with `device_id` binding, monotonic anti-replay `sequence`, and short expiration TTL.
- **SR-04:** Signed release artifacts & OS catalog via TUF + SHA-256 verification; declarative catalog recipes only (no remote shell scripts).
- **SR-05:** Read-only disk discovery by default; stable `DiskIdentity` matching; partition-table hash lock; hard guardrails protecting Apple `iSCPreboot`/`Recovery`/macOS, active ESP, and BitLocker volumes; explicit BitLocker Recovery Key warning before `BootOrder` changes.
- **SR-06:** Zero mandatory telemetry; zero committed secrets or physical device identifiers.

## 3. Initial Engineering Targets (Unmeasured — Goals Only)
See full target table and benchmark methodology in [`docs/testing/benchmarks.md`](https://github.com/smart-boot-menu/docs/blob/main/testing/benchmarks.md):
- `sbm-uefi` startup to first GOP paint: **≤ 250 ms** (stretch ≤ 100 ms)
- `sbm-uefi` binary size: **≤ 1.5 MiB** (stretch ≤ 750 KiB)
- `sbm-uefi` network timeout hard cap: **≤ 5.0 s** (default ≤ 3.0 s, instant local key cancel)
- `sbm-core` compressed size: **≤ 650 MiB** (x86-64/ARM64 PC), **≤ 900 MiB** (Apple Silicon Asahi — far below 4 GiB ceiling)
- `sbm-core` cold boot to interactive desktop (KVM/HVF/NVMe): **≤ 10 s**
