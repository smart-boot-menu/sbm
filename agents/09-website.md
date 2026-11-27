# Agent 9 — Official Website & Documentation Portal (`smart-boot-menu.github.io`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/smart-boot-menu.github.io` (`~/gh/smart-boot-menu/smart-boot-menu.github.io`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
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

1. **Read Central Documentation:** Read the central files listed above and confirm release/schema contracts in `sbm-common` and `sbm/releases/`.
2. **Inspect Relevant Codebases:** Inspect `sbm`, `docs`, `research`, and relevant upstream static-site tooling cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Evaluate existing open-source static-site generators, themes, and accessibility/link-check tooling (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `smart-boot-menu.github.io/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification for the chosen site generator and tooling.
5. **Implement Working Proof of Concept:** Prefer reusing and configuring mature open-source static-site tooling per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` site source and configuration targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add build, link-check, schema-consumption, and accessibility verification checks in CI.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive measured Lighthouse/page-weight results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `smart-boot-menu.github.io/README.md` and `smart-boot-menu.github.io/docs/`.
9. **Validate & Commit:** Run repository formatting, linting, static build, and automated checks. Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` or `sbm/releases/` interface additions needed and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `smart-boot-menu.github.io`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
