# Agent 6 — Operating System Catalog & Recipes (`sbm-catalog`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-catalog` (`~/gh/smart-boot-menu/sbm-catalog`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
  - `~/gh/smart-boot-menu/sbm-catalog/README.md` & `.github/agent-reference.md` (§5 `sbm-catalog` guardrails)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common` (`sbm-types`, `sbm-schema`), `docs/specifications/05-os-catalog.md`, `docs/threat-model/README.md`

## 2. Domain Scope & Deliverables

- Design the declarative catalog directory layout (`catalog/linux/`, `catalog/bsd/`, `catalog/windows/`, `catalog/recovery/`) strictly conforming to `sbm-common`'s `OsCatalogEntry` JSON Schema.
- Author initial curated, verified catalog definitions (e.g., Fedora, Debian, Ubuntu, Arch Linux, FreeBSD, OpenBSD, SystemRescue, and a `user_supplied_only` Windows 11 recipe) with exact `architectures`, `supported_platforms` (strictly distinguishing generic `uefi-native` from `apple-silicon-m1n1-uboot`!), HTTPS mirrors, and mandatory SHA-256 checksums.
- Build a Rust CLI validator (`tools/catalog-check`) using `sbm-schema` that validates every catalog entry against the canonical JSON Schema, verifies HTTPS mirror reachability/checksums in CI, rejects any executable shell scripts, and produces a **TUF v1.0.33** signed catalog bundle + offline mirror export tarball.
- Document mirror verification, EOL archival, and community PR submission workflows.

## 3. Strict Boundaries (Do NOT Do)

Do NOT embed arbitrary executable scripts in catalog definitions; do NOT redistribute proprietary Windows ISOs or Apple firmware.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Verify APIs, crate versions, firmware/OS quirks, and existing open-source solutions across languages and ecosystems (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-catalog/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification (and empirical baselines where practical) for any new subsystem, major dependency, architectural change, or replacement of established software.
5. **Implement Working Proof of Concept:** Prefer reusing, composing, or thinly integrating the strongest existing open-source solutions (or contributing upstream) per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` original code (Rust for original systems software where justified) and declarative catalog metadata targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-catalog/README.md` and `sbm-catalog/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus schema/catalog validation checks). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-catalog`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
