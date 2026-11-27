# Agent 7 — Cross-Platform SBM Installer & Media Creator (`install`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/install` (`~/gh/smart-boot-menu/install`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
  - `~/gh/smart-boot-menu/install/README.md` & `.github/agent-reference.md` (§5 `install` guardrails)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common`, `sbm-uefi`, `sbm-core`, `sbm-as`, `docs/specifications/04, 07`, `docs/threat-model/README.md`

## 2. Domain Scope & Deliverables

- Build a cross-platform Rust CLI (`sbm-install`) responsible ONLY for **installing, updating, uninstalling SBM itself**, and **creating bootable SBM removable USB/disk images**.
- For SBM 0.1: implement deterministic creation of a dual-architecture (`x86_64` + `aarch64`) bootable GPT FAT32/ESP disk image (`.img`) containing `\EFI\BOOT\BOOTX64.EFI`, `\EFI\BOOT\BOOTAA64.EFI`, `\EFI\sbm\policy.json`, and `sbm-core` UKI slots — usable directly in QEMU (`sbm-lab`) and flashable to USB drives for read-only physical HP laptop testing.
- Implement strict safety pre-flight checks before any internal disk / `BootOrder` modification:
  - Detect Windows BitLocker volumes -> require explicit confirmation of 48-digit Recovery Key backup (or 1-reboot suspension) before touching `BootOrder` or Secure Boot keys.
  - Detect Apple Silicon hosts -> delegate strictly to `sbm-as` safety flow and block raw ESP/NVRAM tampering.
  - Verify TUF signatures & SHA-256 checksums (`tough`) on all downloaded SBM release artifacts before installing or A/B updating.
  - Support clean, verifiable uninstallation restoring previous `BootOrder` entries without breaking existing OSes.
- Write unit and QEMU-backed installation/rollback tests.

## 3. Strict Boundaries (Do NOT Do)

Do NOT implement general OS installation (Windows/Linux/BSD installs belong in `sbm-core`); NEVER modify the dev Mac's internal partitions during tests.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Verify APIs, crate versions, firmware/OS quirks, and existing open-source solutions across languages and ecosystems (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `install/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification (and empirical baselines where practical) for any new subsystem, major dependency, architectural change, or replacement of established software.
5. **Implement Working Proof of Concept:** Prefer reusing, composing, or thinly integrating the strongest existing open-source solutions (or contributing upstream) per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` original code (Rust for original systems software where justified) targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `install/README.md` and `install/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `install`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
