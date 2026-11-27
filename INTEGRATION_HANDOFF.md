# Agent 11 Architecture & Release Readiness Audit Handoff

**Date:** 2026-11-27  
**SBM 0.0.1 Status:** **OPEN — UNQUALIFIED** (development trust tier; `aarch64` has strong functional integration evidence, `x86_64` has synthetic KVM fixture & Secure Boot rejection evidence; 4 surgical implementation blockers `B1`–`B4` and 4 validation gates `V1`–`V4` remain).

All engineering agents operate from `~/gh/smart-boot-menu/`, follow centralized [`.github/AGENTS.md`](../.github/AGENTS.md), [`ADR-010`](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [`ADR-011`](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [`ADR-012`](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), and respect the 16 GiB physical RAM budget on the macOS host. **Never modify physical host disks, firmware `BootOrder`, or macOS `LocalPolicy`/SIP.**

## Delivered in Wave 3 Independent Release Readiness Audit

- **Canonical Clarifications (`docs/`):**
  - Updated [`ADR-012`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), [Spec 03 §9a](https://github.com/smart-boot-menu/docs/blob/main/specifications/03-efi-linux-handoff-and-recovery.md), and [Spec 07 §17](https://github.com/smart-boot-menu/docs/blob/main/specifications/07-releases-compatibility-and-diagnostics.md) to record:
    1. The six installation/execution profiles MUST be implemented as **validated presets of shared configuration options** driving a single pipeline—NOT six duplicated implementations.
    2. **Consumer-ready releases** MUST account for **production Secure Boot compatibility** (`rhboot/shim` + SBAT + NX + Microsoft UEFI CA 2023 / `shim-review`), while **development releases** (such as SBM 0.0.1) carry narrower, explicitly documented trust and hardware compatibility (`production_secure_boot_claimed: false`) without prematurely pulling future features into 0.0.1.
- **Independent Audit & Updated Scorecards (`sbm/`):**
  - Replaced stale Wave 2 claims with the verified [Wave 3 Independent Release Readiness Audit](INTEGRATION_AUDIT.md), updated [RELEASE_GATES.md](RELEASE_GATES.md), [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md), and [ARCHITECTURE.md](ARCHITECTURE.md) across actual `origin/main` commits (`sbm-common@abe3029`, `sbm-uefi@66704ea`, `sbm-core@a74ea48`, `install@d2d2b3a`, `sbm-lab@8dee38d`, `docs@2d41168`, `research@5c701f8`).
  - Verified optional dual-architecture media is NOT a release prerequisite anywhere in `install` or `sbm-lab`.
  - Documented exact satisfied gates, remaining implementation blockers (`B1`–`B4`), remaining validation-only gates (`V1`–`V4`), immutable target revisions, required artifacts, positive & negative scenarios, known limitations, and the **precise final qualification assignment for Agent 13** in [INTEGRATION_PLAN.md](INTEGRATION_PLAN.md) §3.

## Immediate Next Execution Priority — Agent 13 Final SBM 0.0.1 Qualification

1. **Close 4 Surgical Implementation Blockers (`B1`–`B4`):**
   - `B1` (`sbm-core`): remove/disable `sbm-smoke.service` from production `00-sbm.preset:12`.
   - `B2` (`sbm-core`): refcount concurrent GParted RO protection & roll back RO on spawn failure (`sbm-cored/src/lib.rs:488-498`).
   - `B3` (`install`): pin `sbm-common@abe3029` in `Cargo.toml`/`Cargo.lock` and lock `sbm-uefi@66704ea` + final post-B1/B2 `sbm-core` in `media/0.0.1.lock.toml` for BOTH arches.
   - `B4` (`sbm-lab`): harden `integration.rs` assertions (`menu_ready < 250 ms`, `verify_done`, `dm-verity`, non-blank frames, fixture-disk immutability, single-arch default) and close remaining `sbm-lab#5` defects.
2. **Execute Independent Per-Arch Validation (`V1`–`V4`) & Archive Evidence:**
   - Rebuild immutable `sbm-core` (`SBM_BUILD_PROFILE=release`) for `arm64` and `x86-64` (`V1`).
   - Assemble & prove compressed reproducibility (`check-reproducible.sh`) for both per-arch images (`V2`).
   - Independently qualify **`aarch64`** (HVF) and **`x86_64`** (native Linux KVM timing + graphical integration) across all positive & negative Tier 2 scenarios (`V3`–`V4`). Do NOT mix uncommitted local `sbm-uefi` typography WIP into 0.0.1 qualification.
