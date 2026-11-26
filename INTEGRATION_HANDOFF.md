# Agent 11 Wave 2 integration audit handoff

**Date:** 2026-11-26. **SBM 0.0.1 status:** **UNQUALIFIED** (mandatory release gates remain open).

All Wave 3 engineering agents operate from the dedicated `~/gh/smart-boot-menu/` workspace and must honor the 16 GiB physical RAM budget on the macOS development host.

## Delivered & merged on `main`

- **`sbm-common` PR #1 merged (`b3c77141504be71bfad6602d8df628f84f704c7b`):** Unified `4b43222` (`command_signing_preimage`) and `57e9b3d` (`ReleaseManifest` 1.1 `media`), preserving `57e9b3d` in git history. Passed `rustfmt`, Clippy, 8/8 unit tests, `sbm-schema`, both `no_std` UEFI target checks, hosted CI, and offline verification against `sbm-core`, `sbm-server`, and `sbm-as`.
- **`docs` PR #1 merged (`157d34ca440dc98d5792c19b043c84ebb1f48327`):** Unified ADR-009 and Specs 02/03/06/07 with `77e1b90`, clarified lazy launch-time single-open sequential streaming SHA-256 verification (Spec 03 §9), and standardized the canonical `extra_cmdline_preset` allowlist (`quiet`, `verbose`, `nomodeset`, `diagnostic`) in Spec 02 §5.
- **`research` PR #1 merged (`2d0fab4bf72af242d65c1d658a8d48a35a1a112e`):** Archived Wave 1 baseline plus [Wave 2 integration audit evidence](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-integration-wave2-2026-11-26.md).
- **`sbm` PR #2 updated and merged:** Refreshed [INTEGRATION_AUDIT.md](INTEGRATION_AUDIT.md), [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md), and [RELEASE_GATES.md](RELEASE_GATES.md) on `main`.
- **GitHub issue coordination:** Filed [sbm-lab#5](https://github.com/smart-boot-menu/sbm-lab/issues/5) (P0 shared host resource manager defects) and posted Wave 3 acceptance criteria on `sbm-uefi#1`, `sbm-core#1`, `sbm-core#2`, `sbm-lab#2`, `sbm-lab#3`, `sbm-lab#4`, `install#1`, `sbm-common#2`, `sbm-server#3`, `sbm-catalog#1`, and `sbm-as#1`.

## Wave 3 execution order

1. **Unblock CI & host resource safety:** Agent 03 fixes `sbm-lab#5` (resource manager critical defects), `sbm-lab#3` (AArch64 TCG `-cpu max` stall), and `sbm-lab#4` (`run.rs:495-505` `forbid_markers` bug). Agent 01 fixes `sbm-uefi` `cargo fmt` CI failure immediately.
2. **Fix UEFI latency/contract & Core graphical blockers in parallel:**
   - Agent 01 (`sbm-uefi#1`): Lazy launch-time single-open sequential streaming SHA-256 (`1–4 MiB` buffer, `sha2` `opt-level = 3`), Spec 02/03 volatile EFI vars, fail-closed integrity, `sbm-common` `b3c77141`.
   - Agent 02 (`sbm-core#1`, `#2`): `/efi` in EROFS, `resolve_disk()` + ESP exemption, auto-software renderer + root-routed desktop markers, `labwc_environ()` via `sbm-ui`, BLI/EFI-var handoff, remove double-reboot `BootCommand::Reboot` write, rebuild both clean committed Core images (`c7e9439` + fixes), and verify direct graphical boot.
3. **Re-assemble & qualify once:** Agent 07 (`install#1`) fixes Spec 07 `artifacts`/`release-manifest.v1.json` gaps and assembles the immutable candidate from clean committed Agent 01 + Agent 02 revisions; Agent 03 (`sbm-lab#2`) runs `sbm-lab test --tier integration --image PATH` on both architectures against the exact same raw image digest.
