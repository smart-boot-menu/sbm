# Agent 2 — Minimal Linux Management & Recovery OS (`sbm-core`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-core` (`~/gh/smart-boot-menu/sbm-core`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
  - `~/gh/smart-boot-menu/sbm-core/README.md` & `.github/agent-reference.md` (§5 `sbm-core` guardrails)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common` (`sbm-types`, `sbm-protocol`, `sbm-schema`), `docs/specifications/03..06`, `docs/architecture-decisions/ADR-001, ADR-002, ADR-003, ADR-006`

## 2. Domain Scope & Deliverables

- Set up a declarative **`mkosi v27.1`** build pipeline producing immutable **EROFS (`zstd`)** root filesystems + signed **Unified Kernel Images (UKIs)** + `dm-verity` verification:
  - Primary SBM 0.1 profiles: `x86_64` and `aarch64` **Fedora Minimal** (target compressed size **≤ 650 MiB**, hard cap < 1 GiB).
  - Prepare the shared profile hook for `sbm-as`'s `aarch64-apple` Fedora Asahi Minimal (`kernel-16k`, target ≤ 900 MiB).
- Configure adaptive RAM execution (`sbm.toram=auto` copies EROFS to RAM on ≥ 4 GiB machines; mounts EROFS read-only + `zram` overlay on 2 GiB laptops) and curated `.zst` `linux-firmware` + `systemd-sysext` modularity.
- Configure `labwc` Wayland compositor with **XWayland enabled** (to launch **GParted `1.8.1`** cleanly), `llvmpipe`/`pixman` software fallback, and `wayvnc` for authenticated browser-native remote desktop.
- Implement `sbm-cored` (Rust daemon) reading & verifying the `EfiHandoffPayload` from `sbm-uefi`, confirming recovery slot health, performing read-only disk discovery (`lsblk --json`, `blkid`, `sfdisk --json`) into stable `DiskIdentity` & `PartitionProtectionClass` structs (hard-blocking Apple system partitions & BitLocker by default), and exposing a local IPC API to an **Iced** management UI.
- For SBM 0.1: demonstrate booting the UKI in QEMU, reading EFI handoff, inspecting virtual disks read-only, opening GParted, and bridging `wayvnc` + PTY terminal over mTLS WSS to `sbm-server`.
- Benchmark image size, cold boot to desktop latency (≤ 10 s target on HVF/KVM), and RAM footprint under 1 GiB / 2 GiB / 4 GiB VMs.

## 3. Strict Boundaries (Do NOT Do)

Do NOT rewrite `e2fsprogs`/`ntfs-3g`/`partclone`/`wimlib`/`gparted` in Rust; do NOT perform destructive disk mutations in SBM 0.1 without full plan validation; do NOT handle installing SBM itself (`install`).

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Verify APIs, crate versions, firmware/OS quirks, and existing open-source solutions across languages and ecosystems (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-core/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification (and empirical baselines where practical) for any new subsystem, major dependency, architectural change, or replacement of established software.
5. **Implement Working Proof of Concept:** Prefer reusing, composing, or thinly integrating the strongest existing open-source solutions (or contributing upstream) per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` original code (Rust for original systems software where justified) targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-core/README.md` and `sbm-core/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-core`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
