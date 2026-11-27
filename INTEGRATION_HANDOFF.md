# Agent 11 Final SBM 0.0.1 Release Audit Handoff

**Date:** 2026-11-27  
**SBM 0.0.1 Status:** **BOTH `aarch64` AND `x86_64` ARE TIER 2 QUALIFIED (Development / Preview Trust Tier) — READY FOR OWNER RELEASE APPROVAL & OPT-IN TIER 3 PHYSICAL HARDWARE TESTING.** *(No public release, git tag, or public upload has been published.)*

All engineering agents operate from `~/gh/smart-boot-menu/`, follow centralized [`.github/AGENTS.md`](../.github/AGENTS.md), [`ADR-010`](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [`ADR-011`](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [`ADR-012`](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), and respect the 16 GiB physical RAM budget on the macOS host. **Never modify physical host disks, firmware `BootOrder`, or macOS `LocalPolicy`/SIP.**

## Delivered in Final SBM 0.0.1 Release Audit

1. **Independent Verification of Agent 13's Archive (`research@0c87009`) & Closure of `B1`–`B4` / `V1`–`V4`:**
   - Verified frozen release revisions (`sbm-common@abe3029`, `sbm-uefi@4bfb3ba`, `sbm-core@960f11a`, `install@870069d`, `sbm-lab@5ab4f8c`, `sbm-as@759be4e`), hosted CI runs, local `.raw`/`.raw.zst`/`.sha256`/`release-manifest.v1.json`/`build-receipt.json`/`repro-report.json` digests (100% byte-for-byte match), and archived QMP screenshots.
   - Confirmed **Classic UI with Atkinson Hyperlegible typography (`sbm-uefi@4bfb3ba`)** is the qualified SBM 0.0.1 UI, strictly separate from newer experimental hardware dashboards (`sbm-uefi@70a84c5..457c545`, behind `experimental-layouts`).
   - Distinguished verified **reproducible media assembly** (`check-reproducible.sh`: 6/6 files identical with zstd compression for both arches) from full independent **Linux OS source-build reproducibility** (501 Fedora 45 RPMs via `mkosi`, not claimed in 0.0.1).
2. **Closed the Remaining `x86_64` Native KVM Cold-Boot Performance Gate (`N = 10`):**
   - Executed `N = 10` offline cold-boot timing runs on the exact digest-verified frozen `sbm-0.0.1-uefi-x86_64.raw` (`9bebf042...`) via hosted GitHub Actions native x86-64 KVM (`run 46073194023`, `AMD EPYC 7763`, `QEMU 10.2.1`, `OVMF_CODE_4M.fd`, `virtio-vga` `1280×800`, fresh QCOW2 + `vars.fd`, `inputs_unchanged: true`): `menu_ready` **min `36.19 ms`**, **median `38.63 ms`**, **p95/max `41.32 ms`** (`<< 250 ms`).
   - Archived machine-readable timing JSON and updated `x86_64` qualification report in `research/validation/evidence/`; deleted the temporary unpublished CI staging draft immediately (zero releases, zero tags left behind).
3. **Prepared Complete Release Artifacts & Owner Checklists (Not Yet Published):**
   - Updated [INTEGRATION_AUDIT.md](INTEGRATION_AUDIT.md), [RELEASE_GATES.md](RELEASE_GATES.md), [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md), and [ROADMAP.md](ROADMAP.md).
   - Prepared [`releases/0.0.1-RELEASE-NOTES.md`](releases/0.0.1-RELEASE-NOTES.md) (exact local paths, sizes, SHA-256s, release metadata, graphical flasher evaluation & install instructions, known limitations) and [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md) for the dedicated HP laptop (`EXP-HW-HP01`).

## Next Steps (Owner Decision Required)

1. **Optional Tier 3 Physical USB Smoke Test (`EXP-HW-HP01`):** Flash `/Users/felg/gh/smart-boot-menu/install/build/qual-0.0.1/x86_64/sbm-0.0.1-uefi-x86_64.raw.zst` to a dedicated test USB with **USBImager** or **Raspberry Pi Imager `>= 2.0.11`** and execute [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md).
2. **Release Sign-Off:** Explicitly approve tagging (`v0.0.1`) and publishing the verified per-architecture Development / Preview release artifacts.
3. **Transition to SBM 0.0.2:** Begin internal SSD installation (`efi-only` `< 1 MiB` upgradeable + available-space `offline-full`, uninstall, boot-registration repair) per [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md) §4.
