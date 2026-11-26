# Smart Boot Menu — Prioritized Development Roadmap

**Last updated:** 2026-11-26

## Phase 0 — Architecture & Foundation (Completed by Agent 0)
- Initialize 14 GitHub repositories (`smart-boot-menu/*`), dual licenses, org policies, CI conventions.
- Complete primary-source ecosystem & hardware research (`research/`).
- Ratify ADRs 001–008, v1 specifications (19 interfaces), threat model, and 10 Mermaid diagrams (`docs/`).
- Implement and compile `sbm-common` (`no_std` UEFI + `std` host + JSON Schemas + golden test vectors).
- Deliver agent guides (`AGENTS.md`) and launch prompts (`agents/01..09.md`).

---

## Milestone: SBM 0.1 — End-to-End Architectural Proof of Concept (Priority 1)

**Goal:** Demonstrate the complete two-tier architecture end-to-end inside automated QEMU VMs and from removable USB media.

*Explicit Non-Goals for SBM 0.1:* Physical Apple Silicon M5 bare-metal boot (blocked on upstream `linux-asahi` M5 USB/PCIe/DART drivers); destructive storage writes/resizing; Microsoft CA 2023 shim signing submission.

| Workstream | Owner Repo(s) | SBM 0.1 Exit Criteria |
|---|---|---|
| **1. Virtual Lab & CI** | `sbm-lab` (Agent 3) | QEMU + OVMF (`x86_64`) + AAVMF (`aarch64`) + U-Boot (`qemu_arm64`) + `swtpm` harness; golden QCOW2 Windows/Linux ESP fixtures; automated QMP screenshot & serial assertions |
| **2. Fast-Path UEFI Menu** | `sbm-uefi` (Agent 1) | Native Rust graphical GOP menu (`x86_64` & `aarch64`), automatic EFI/BLS/UKI discovery, chainloading Windows & Linux fixtures, offline ESP config, bounded remote boot-policy fetch (`boot_select`), launching `sbm-core` UKI with handoff |
| **3. Minimal Linux Core** | `sbm-core` (Agent 2) | `mkosi` Fedora Minimal (`x86_64` & `aarch64`, < 650 MB EROFS + UKI), boots in QEMU, reads EFI handoff, launches `labwc` + XWayland + GParted (read-only virtual disk inspection) + prototype Iced status UI + `wayvnc` |
| **4. Self-Hosted Server** | `sbm-server` (Agent 5) | Single-binary Rust `axum` + SQLite server, SvelteKit dashboard, device enrollment, Ed25519-signed `CommandEnvelope`, remote next-boot selection verified by VM `sbm-uefi`, embedded `noVNC` to `sbm-core` |
| **5. Bootable Media Creator** | `install` (Agent 7) | CLI creating a dual-arch (`x86_64` + `aarch64`) removable SBM USB/disk image for QEMU and read-only physical HP laptop testing |

---

## Milestone: SBM 0.2 — OS Catalog, Safe Storage & Real Hardware (Priority 2)
- **`sbm-catalog` (Agent 6):** TUF-signed catalog with verified Linux/BSD/recovery entries + offline mirroring tool.
- **`sbm-core` (Agent 2):** Validated `StorageOperationPlan` execution (non-destructive partitioning first, then explicit destructive workflows with dry-run + partition-table hash lock), Linux & Windows (`wimlib-imagex`) installation engines, `partclone` backup/restore.
- **`sbm-agent` (Agent 8):** Linux & Windows guest daemon for boot-success confirmation (enabling real A/B rollback) and remote reboot coordination.
- **Physical Hardware:** Characterize older x86 HP laptop (`EXP-HW-HP01`) and validate SBM USB boot + chainload + `sbm-core` Wi-Fi/GParted.
- **`sbm-as` (Agent 4):** Validate `sbm-uefi` under `qemu_arm64` U-Boot + build light `< 900 MB` `sbm-core-aarch64-apple` (`mkosi` Fedora Asahi Minimal) + validate external USB3 boot on supported M1/M2/M3 hardware.

---

## Milestone: SBM 0.3 — Production Security, Fleet Features & Website (Priority 3)
- UEFI Secure Boot hardening: custom key enrollment helper, `rhboot/shim 16.1` + SBAT + NX verification, reproducible build verification, preparation for `shim-review` (Microsoft UEFI CA 2023).
- `sbm-server` WebAuthn/Passkeys step-up auth, PostgreSQL backend, optional Iroh P2P / WireGuard / PiKVM / JetKVM / Redfish adapters.
- `smart-boot-menu.github.io` (Agent 9): Full public documentation site, release downloads, and hardware compatibility matrix.
- Track upstream `linux-asahi` M4/M5 (`T8142`) DART/PCIe/USB3 enablement for future physical M5 Mac support.
