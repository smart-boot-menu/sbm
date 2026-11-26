# Agent 4 — Apple Silicon Bootstrap & Integration (`sbm-as`)

## 1. Assignment & Repository

- **Assigned Repository:** `smart-boot-menu/sbm-as` (`~/gh/smart-boot-menu/sbm-as`)
- **Canonical Dependencies & Specs to Read First:**
  - `~/gh/smart-boot-menu/.github/AGENTS.md` (universal org rules)
  - `~/gh/smart-boot-menu/sbm-as/AGENTS.md` (repo-specific boundaries)
  - `~/gh/smart-boot-menu/sbm/ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`
  - `sbm-common`, `sbm-uefi` (`aarch64-unknown-uefi`), `sbm-core` (`mkosi` profile), `docs/architecture-decisions/ADR-005`, `docs/hardware/target-hardware.md`, `research/hardware/apple-silicon-m1-to-m5.md`

## 2. Domain Scope & Deliverables

- **ABSOLUTE SAFETY RULE:** NEVER modify the development M5 MacBook Air's macOS boot configuration, LocalPolicy, SIP, NVRAM, or physical NVMe partitions!
- Research and document exact integration with upstream `AsahiLinux/m1n1` + `AsahiLinux/u-boot` (`asahi-releng`, U-Boot `v2026.07`+) so that U-Boot boots the **standard unmodified `aarch64-unknown-uefi` `sbm-uefi` binary** (zero fork of `sbm-uefi`).
- Implement Apple-specific `PlatformCapabilities` & partition-protection classifiers in Rust (`iSCPreboot`, `RecoveryOS`, macOS APFS System/Data/Preboot/Recovery containers — permanently hard-blocked from destructive ops) and macOS reboot-target selection adapters.
- Co-author the `aarch64-apple` `mkosi` profile for `sbm-core` using Fedora Asahi Minimal (`kernel-16k` `linux-asahi`, compressed size target **≤ 900 MiB**, never redistributing Apple firmware blobs — integrating `asahi-fwextract` at install time).
- Execute Experiment `EXP-AS-EXT01` Phase 1 safely inside QEMU `qemu_arm64` U-Boot (`sbm-lab`): verify internal ESP bootstrap discovering and booting an ARM64 Linux OS on an external virtual USB3 xHCI disk.
- Maintain a verified, date-stamped upstream tracker in `research/hardware/apple-silicon-m1-to-m5.md` for M1/M2/M3 (supported), M4 (early), and M5 `T8142` (awaiting DART/PCIe/USB3/GPU/Wi-Fi drivers & macOS 27.3 `mBoot` `FB23916610` considerations).

## 3. Strict Boundaries (Do NOT Do)

Do NOT duplicate `sbm-uefi`; do NOT claim M5 bare-metal support until upstream Asahi drivers are verified; do NOT redistribute proprietary Apple firmware blobs.

## 4. Mandatory 10-Step Execution Workflow

1. **Read Central Documentation:** Read the central files listed above and confirm protocol/schema types in `sbm-common`.
2. **Inspect Relevant Codebases:** Inspect `sbm-common` crates and relevant upstream reference projects cited in `research/`.
3. **Conduct Domain-Specific Research:** Verify any APIs, crate versions, or firmware/OS quirks specific to your domain; save reusable findings into `~/gh/smart-boot-menu/research/`.
4. **Write an Implementation Plan:** Record a concise plan in `sbm-as/docs/IMPLEMENTATION_PLAN.md` before writing major code.
5. **Implement Working Proof of Concept:** Write clean, idiomatic, `MIT OR Apache-2.0` Rust/config code targeting the **SBM 0.1** milestone.
6. **Write Automated Tests:** Add unit tests, contract/schema tests, property/fuzz tests where applicable, and integration hooks for `sbm-lab`.
7. **Benchmark Where Applicable:** Follow `docs/testing/benchmarks.md`; archive raw measured results in `research/validation/evidence/` (never invent metrics).
8. **Document Limitations & Open Questions:** Clearly separate verified behavior from experimental/untested behavior in `sbm-as/README.md` and `sbm-as/docs/`.
9. **Validate & Commit:** Run `cargo fmt --check`, `cargo clippy --all-targets -D warnings`, `cargo test` (plus UEFI cross-compile checks where applicable). Commit cleanly on a branch or `main` (never force-push; no AI co-author trailers) and push only per repo/user authorization.
10. **Report Integration Requirements:** Conclude with a concise summary listing any upstream `sbm-common` interface additions needed, exact artifacts produced for `sbm-lab`, and blockers for adjacent agents.

## 5. Coordinating Shared Interface Changes

If you discover a missing field or breaking protocol requirement:
- Do **NOT** invent a private fork of a struct inside `sbm-as`.
- Propose the specification update in `docs/specifications/` and add/update the canonical Rust type + JSON Schema + golden test vector in `sbm-common`.
