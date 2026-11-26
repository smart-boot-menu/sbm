# Agent 8 — Optional Guest OS Background Agent (`sbm-agent`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-agent` (`~/gh/smart-boot-menu/sbm-agent`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` (universal org rules)
  - `~/gh/smart-boot-menu/sbm-agent/AGENTS.md` (repo-specific boundaries)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common` (`sbm-types`, `sbm-protocol`), `docs/specifications/02, 03, 06, 07`

## 2. Domain Scope & Deliverables

- Build a lightweight, optional, low-overhead Rust daemon (`sbm-agent`) for installed Linux, Windows, and macOS guest operating systems.
- Core responsibilities:
  1. **Boot-Success Confirmation:** After guest OS reaches healthy multi-user/network target, emit `BootSuccessReport` locally (updating ESP `last_attempt.json` `consecutive_failures = 0`, `status = Confirmed`) and optionally to `sbm-server` — closing the loop on A/B rollback!
  2. **OS Health & Inventory Reporting:** Read-only OS version, uptime, disk health summary (opt-in, privacy-respecting).
  3. **Authorized Remote Reboot Coordination:** Receive Ed25519-signed `BootCommand` envelopes from `sbm-server`, stage verified `one_shot` next-boot policy on the ESP (or invoke clean reboot), and trigger graceful OS shutdown/reboot.
- Provide clean service packaging templates (`systemd` unit for Linux, Windows Service wrapper, `launchd` plist for macOS) and automated unit + mock-ESP integration tests.

## 3. Strict Boundaries (Do NOT Do)

Do NOT require `sbm-agent` for SBM to function; do NOT perform partitioning or OS installation inside the guest agent; never store plaintext operator credentials.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific Research:** Verify any APIs, crate versions, or firmware/OS quirks specific to your domain; save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-agent/docs/IMPLEMENTATION_PLAN.md` before writing major code.
5. **Implement Working Proof of Concept:** Write clean, idiomatic, `MIT OR Apache-2.0` Rust/config code targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-agent/README.md` and `sbm-agent/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-agent`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
