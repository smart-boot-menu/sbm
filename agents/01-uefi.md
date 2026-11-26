# Agent 1 — Native Rust Graphical UEFI Boot Manager (`sbm-uefi`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-uefi` (`~/gh/smart-boot-menu/sbm-uefi`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` (universal org rules)
  - `~/gh/smart-boot-menu/sbm-uefi/AGENTS.md` (repo-specific boundaries)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common` (`sbm-types`, `sbm-protocol` with `default-features = false`), `docs/specifications/01..03, 06..07`, `docs/architecture-decisions/ADR-001, ADR-002, ADR-004`

## 2. Domain Scope & Deliverables

- Build a single-source Rust 2024 `#![no_std]` + `alloc` UEFI application targeting both `x86_64-unknown-uefi` and `aarch64-unknown-uefi` using `uefi` (`0.41+`, global `uefi::boot` / `uefi::system` API).
- Abstract UEFI firmware calls behind narrow traits (following Google `crdyboot`) so discovery, BLS parsing, policy resolution, and layout run under host `cargo test`.
- Implement automatic OS discovery on FAT32 ESP/XBOOTLDR partitions: Windows Boot Manager (`\EFI\Microsoft\Boot\bootmgfw.efi`), UAPI BLS Type #1 (`.conf`), BLS Type #2 (UKI in `\EFI\Linux\*.efi`), common Linux/BSD EFI loaders, and `sbm-core` A/B recovery slots (`\EFI\sbm\recovery\manifest.json`).
- Implement a clean, double-buffered `#![no_std]` GOP software renderer (integer HiDPI scaling, keyboard-first navigation with bounded timer polling to avoid `WaitForKeyEx` firmware hangs, mouse/touch additive support, and text/serial fallback for `-nographic` QEMU).
- Implement ESP-first atomic config/policy/attempt state (`\EFI\sbm\policy.json`, `last_attempt.json`), deterministic boot-policy resolution with `max_failed_attempts` rollback, and EFI-to-Linux handoff (`\EFI\sbm\handoff\current.json` + SHA-256 cmdline).
- Implement bounded opportunistic remote boot-policy fetching (`smoltcp` + TLS 1.3 over SNP, ≤ 4 s hard cap, instant keypress cancel, strict Ed25519 `CommandEnvelope` verification limited ONLY to `AuthScope::BootSelect` — zero arbitrary RCE!).
- Embed a valid `.sbat` PE section and `IMAGE_DLLCHARACTERISTICS_NX_COMPAT` for future `shim 16.1` compatibility.
- Benchmark startup-to-first-frame latency (≤ 250 ms target) and stripped EFI size (≤ 1.5 MiB target) with `sbm-lab`.

## 3. Strict Boundaries (Do NOT Do)

Do NOT implement Linux disk/OS installation logic, Apple `m1n1` setup, or duplicate `sbm-common` types.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific Research:** Verify any APIs, crate versions, or firmware/OS quirks specific to your domain; save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-uefi/docs/IMPLEMENTATION_PLAN.md` before writing major code.
5. **Implement Working Proof of Concept:** Write clean, idiomatic, `MIT OR Apache-2.0` Rust/config code targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-uefi/README.md` and `sbm-uefi/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-uefi`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
