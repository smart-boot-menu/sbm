# Agent 9 — Official Website & Documentation Portal (`smart-boot-menu.github.io`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/smart-boot-menu.github.io` (`~/gh/smart-boot-menu/smart-boot-menu.github.io`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` (universal org rules)
  - `~/gh/smart-boot-menu/smart-boot-menu.github.io/AGENTS.md` (repo-specific boundaries)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm`, `docs`, `research`, `sbm-catalog`, `sbm/releases/`

## 2. Domain Scope & Deliverables

- Build the official static website for `https://smart-boot-menu.github.io` (clean modern static site generator such as Astro / Starlight or SvelteKit static adapter, zero tracking/analytics/telemetry, fast Lighthouse scores, dark/light theme support).
- Surface clear, honest project documentation pulling from or linking canonically to `sbm`, `docs`, and `research`:
  - Vision & two-tier architecture visual explanation,
  - Getting Started & removable USB testing guide,
  - Hardware Compatibility Matrix (explicitly distinguishing Verified vs Experimental vs Unsupported — including honest Apple Silicon M1–M3 vs M4/M5 status),
  - Security & Threat Model overview,
  - Verified Downloads page consuming `ReleaseManifest` JSON with displayed SHA-256 checksums and TUF/Cosign verification instructions.
- Include GitHub Actions build validation (and do NOT auto-deploy live GitHub Pages until explicitly approved by maintainers).

## 3. Strict Boundaries (Do NOT Do)

Do NOT copy-paste and fork normative specifications out of `docs`; do NOT add third-party tracking scripts or claim unverified hardware support or unmeasured benchmarks.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific Research:** Verify any APIs, crate versions, or firmware/OS quirks specific to your domain; save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `smart-boot-menu.github.io/docs/IMPLEMENTATION_PLAN.md` before writing major code.
5. **Implement Working Proof of Concept:** Write clean, idiomatic, `MIT OR Apache-2.0` Rust/config code targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `smart-boot-menu.github.io/README.md` and `smart-boot-menu.github.io/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `smart-boot-menu.github.io`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
