# Agent 5 — Self-Hosted Remote Management Server (`sbm-server`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-server` (`~/gh/smart-boot-menu/sbm-server`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` & `.github/agent-reference.md` (universal org rules & operational checklists; fetch from GitHub `smart-boot-menu/.github` if launched standalone)
  - `~/gh/smart-boot-menu/docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md` (open-source reuse & build-vs-reuse policy)
  - `~/gh/smart-boot-menu/sbm-server/README.md` & `.github/agent-reference.md` (§5 `sbm-server` guardrails)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common` (`sbm-types`, `sbm-protocol`, `sbm-schema`), `docs/specifications/02, 06, 07`, `docs/architecture-decisions/ADR-007`, `docs/threat-model/README.md`

## 2. Domain Scope & Deliverables

- Build a single-binary self-hosted Rust server using **`axum 0.8.9`**, **`tokio 1.54.1`**, **`sqlx 0.9.1`** (SQLite WAL default + PostgreSQL migrations), **`rustls`**, and **`rcgen 0.14.10`** for device mTLS certificate issuance.
- Implement explicit opt-in device enrollment (short-lived single-use enrollment tokens bound to server CA fingerprint), per-device Ed25519 identity + monotonic command sequence tracking, and Ed25519-signed `CommandEnvelope` generation with strict `AuthScope` RBAC (`read_only`, `boot_select`, `recovery_access`, `os_install`, `storage_destructive`, `admin`) and immutable audit logging.
- Expose the lightweight read-only UEFI boot-policy endpoint (`GET /v1/devices/{id}/boot-policy`) returning signed `boot_select` envelopes, plus authenticated WebSocket tunnels for `sbm-core` (`wayvnc` RFB proxy + PTY terminal) and `sbm-agent`.
- Implement operator authentication using **Passkeys / WebAuthn (`webauthn-rs 0.6.2`)** with step-up confirmation for `storage_destructive` scopes (plus clean dev/test bootstrap mode for `sbm-lab` automated integration).
- Build a clean **`SvelteKit 3.4.0`** web dashboard (compiled to static assets embedded in the Rust binary) showing enrolled devices, discovered boot targets, one-click next-boot selection, audit history, and embedded `@novnc/novnc` + `xterm.js` panels.
- Write comprehensive security & replay-protection tests verifying invalid signatures, wrong `device_id`, replayed sequences, expired TTLs, and unauthorized scopes are always rejected.

## 3. Strict Boundaries (Do NOT Do)

Do NOT make `sbm-server` mandatory for local SBM operation; do NOT link AGPL-3.0 code; do NOT redefine `sbm-common` protocol types.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific & Build-vs-Reuse Research:** Verify APIs, crate versions, firmware/OS quirks, and existing open-source solutions across languages and ecosystems (proportional to scope per `ADR-010` and `.github/agent-reference.md`); save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-server/docs/IMPLEMENTATION_PLAN.md` before writing major code, including explicit build-versus-reuse justification (and empirical baselines where practical) for any new subsystem, major dependency, architectural change, or replacement of established software.
5. **Implement Working Proof of Concept:** Prefer reusing, composing, or thinly integrating the strongest existing open-source solutions (or contributing upstream) per `ADR-010`; write clean, idiomatic, `MIT OR Apache-2.0` original code (Rust for original systems software where justified, TypeScript/SvelteKit for the embedded dashboard) targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-server/README.md` and `sbm-server/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus frontend lint/build checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-server`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
