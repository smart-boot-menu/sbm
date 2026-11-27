# Agent 3 — Virtual Hardware, Emulation & Integration Lab (`sbm-lab`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-lab` (`~/gh/smart-boot-menu/sbm-lab`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
  - `~/gh/smart-boot-menu/sbm-lab/README.md` & `.github/agent-reference.md` (§5 `sbm-lab` guardrails)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common`, `docs/architecture-decisions/ADR-008`, `docs/testing/benchmarks.md`, `research/architecture/virtualization-and-testing.md`

## 2. Domain Scope & Deliverables

- Maintain a reproducible test harness (reusing existing open-source virtualization and test tooling where superior per `ADR-010`) orchestrating **QEMU** (`qemu-system-x86_64` and `qemu-system-aarch64`) with **EDK2 OVMF** (standard + Secure Boot), **AAVMF**, **Das U-Boot `qemu_arm64`** (`CONFIG_EFI_LOADER`), and **`swtpm`** virtual TPM 2.0.
- Automatically detect host acceleration (`-accel hvf` on Apple Silicon M5 Mac for native-speed ARM64 VMs, `-accel kvm` on Linux CI, graceful `-accel tcg` fallback).
- Create deterministic, versioned QCOW2 copy-on-write disk fixtures:
  1. Windows-like GPT/ESP layout (`\EFI\Microsoft\Boot\bootmgfw.efi` stub + BitLocker-marked fixture),
  2. Multi-Linux BLS Type #1 & Type #2 UKI ESP fixture,
  3. Apple-style protected partition fixture (`iSCPreboot`/`Recovery` guard test),
  4. Corrupt GPT / bad config fault-injection fixture.
- Implement QMP automation: serial log assertions, framebuffer `screendump` capture & visual sanity checks, boot-timing marker capture, and power-cut / network-blackhole / replay-attack fault injection.
- Wire end-to-end SBM 0.1 integration test scenarios: UEFI boot -> OS discovery -> chainload stub -> recovery launch -> GParted/read-only disk inspection -> `sbm-server` remote next-boot selection -> offline fallback test.
- Archive real measured benchmark baselines in `research/validation/evidence/`.

## 3. Strict Boundaries (Do NOT Do)

Do NOT modify physical host disks or macOS boot configuration; keep all VM fixtures isolated in ephemeral copy-on-write QCOW2 overlays.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Verify APIs, crate versions, firmware/OS quirks, and existing open-source solutions across languages and ecosystems (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-lab/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification (and empirical baselines where practical) for any new subsystem, major dependency, architectural change, or replacement of established software.
5. **Implement Working Proof of Concept:** Prefer reusing, composing, or thinly integrating the strongest existing open-source solutions (or contributing upstream) per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` original code (in the best-fit language/tooling, with Rust preferred for original systems software where justified) targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-lab/README.md` and `sbm-lab/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus repo-appropriate lint/test checks). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-lab`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
