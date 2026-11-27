# Smart Boot Menu — Integration Plan, Dependencies & Ownership

**Last updated:** 2026-11-27 (Final SBM 0.0.1 Release Audit by Agent 11)  
**Scope:** Records completed **SBM 0.0.1** Tier 2 qualification (both `aarch64` and `x86_64` independently qualified on frozen immutable artifacts, awaiting owner release approval & opt-in Tier 3 `EXP-HW-HP01` USB validation), continuous **Track A (Agent 18 — primary UX studio)** & **Track B (Agent 16)**, **SBM 0.0.2** (persistent internal SSD installation incl. `< 1 MiB` `efi-only` upgradeable profile, uninstall & recovery), **SBM 0.0.3** (cross-platform **`SBM Manager`** MVP, guided partition resizing & initial signed `systemd-sysext` modularity), and **SBM 0.1** (standards-based network recovery, `ram-only`, ephemeral remote repair, full modularity & OS catalog; [`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5)).

All engineering agents operate from `~/gh/smart-boot-menu/`, follow centralized [`.github/AGENTS.md`](../.github/AGENTS.md), [`ADR-010`](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [`ADR-011`](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [`ADR-012`](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), and respect the 16 GiB physical RAM budget on the macOS host. **Never modify physical host disks, firmware `BootOrder`, or macOS `LocalPolicy`/SIP.**

---

## 1. Frozen SBM 0.0.1 Revisions & Cross-Repository Dependency Matrix (2026-11-27)

| Repository | Frozen 0.0.1 Commit | Current `origin/main` | `sbm-common` Binding | Verified State & Post-0.0.1 Status |
|---|---|---|---|---|
| **`.github`** | `main` | `main` | N/A | Canonical single source of truth for agent policies (`ADR-010` 0SFS pattern). |
| **`docs`** | `720793b` | `720793b` | N/A | CI green (`45972755355`). ADRs 001–012, Specs 01–07, shared-options presets, dev vs. consumer Secure Boot trust tiers. |
| **`research`** | `0c87009` (+ KVM bench archive) | Updated | N/A | CI green. Archives complete `aarch64` & `x86_64` Tier 2 qualification bundles, `N=10` HVF & native KVM cold-boot benchmarks, and QMP screenshots. |
| **`sbm-common`** | **`abe3029`** (`abe3029c831f05d77d10cfb214a0c236903d00d9`) | `abe3029` | Canonical `main` | **CI green (`45958218582`). Frozen & qualified for 0.0.1.** Next for **0.0.2**: merge [`sbm-common#2`](https://github.com/smart-boot-menu/sbm-common/issues/2). |
| **`sbm-uefi`** | **`4bfb3ba`** (`4bfb3ba6457a4f6625d13c6a1435f69f15b8d011`) | `457c545` | **`abe3029`** (aligned) | **CI green (`45980442284`). Frozen & qualified for 0.0.1** (**Classic UI + Atkinson typography**, `410.1 KiB` aarch64 / `465.9 KiB` x86_64; `15.83 ms` HVF / `38.63 ms` native KVM median `menu_ready`). Newer `70a84c5..457c545` commits add **experimental hardware dashboards** (behind `experimental-layouts`) and 0SFS `YY.MM.DD#N` versioning — **do NOT substitute into 0.0.1**. |
| **`sbm-core`** | **`960f11a`** (`960f11a5e748e30f105cd79cc648f0633af63138`) | `960f11a` | **`abe3029`** (verified by `sync-and-build.sh`) | **CI green (`45977817124`). Frozen & qualified for 0.0.1.** B1 (`sbm-smoke` excluded) & B2 (refcounted `GpartedDiskLease`, `FirmwareSetup` filter, fail-closed `random_password()`) closed; clean release `arm64` & `x86-64` images built and locked. |
| **`install`** | **`870069d`** (`870069dccd2b7fc680a35955c27a6481bb46a0e4`) | `870069d` | **`abe3029`** (pinned in `Cargo.toml`/`Cargo.lock`) | **CI green (`46014761860`). Frozen & qualified for 0.0.1.** B3 closed; `media/0.0.1.lock.toml` locks `abe3029` + `4bfb3ba` + `960f11a`; compressed media-assembly reproducibility proven (`6/6` files identical for both arches). |
| **`sbm-lab`** | **`5ab4f8c`** (`5ab4f8c0485a226fc639778a65a8a1467c352bde`) | `5c27927` | None | **CI green (`46059331789`). Frozen & qualified for 0.0.1.** B4 closed (`integration.rs` assertions, 6 negative scenarios, `sbm-lab#5` fixes). Post-freeze `2c2cc84..5c27927` add only `.gitignore` `/build` and the manual `x86_64-kvm-cold-boot-bench.yml` workflow (`46073194023`, zero Rust changes). |
| **`sbm-as`** | **`759be4e`** (`759be4eabed0cb760eabe5d8befcbba43fe067c6`) | `759be4e` | N/A | **CI green (`45977832267`).** Closed `uboot-efi-poc.sh` `SBM_OWNER_PID` reservation attach check. |
| **`sbm-server` / `sbm-catalog` / `sbm-agent` / `website`** | Post-0.0.1 tracks | — | Align to `abe3029` as needed | Execute under SBM 0.1 and SBM 0.2 per [ROADMAP.md](ROADMAP.md). |

---

## 2. SBM 0.0.1 Closure & Release-Approval Handoff

All `B1`–`B4` implementation blockers and `V1`–`V4` validation gates from Wave 3 are **CLOSED** (see [INTEGRATION_AUDIT.md](INTEGRATION_AUDIT.md) & [RELEASE_GATES.md](RELEASE_GATES.md)):

- **Tier 2 Qualification:** **COMPLETE** for both `aarch64` (HVF) and `x86_64` (native Linux KVM `N=10` + full graphical/negative suite) on the frozen immutable artifacts.
- **Prepared Release Package (NOT yet published or tagged):**
  - Release notes, exact checksums, sizes, flasher evaluation & install instructions: [`releases/0.0.1-RELEASE-NOTES.md`](releases/0.0.1-RELEASE-NOTES.md)
  - Dedicated HP laptop (`EXP-HW-HP01`) physical USB testing checklist: [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md)
- **Remaining Owner Actions Before Any Public Tag/Release:**
  1. *(Recommended opt-in Tier 3 check)* Flash `sbm-0.0.1-uefi-x86_64.raw.zst` to a dedicated test USB using **USBImager** or **Raspberry Pi Imager `>= 2.0.11`** and run [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md) on `EXP-HW-HP01` (recording redacted hardware facts in `research/hardware/hp-laptop-profile.md`).
  2. Explicitly approve tagging (`v0.0.1`) and uploading the verified `.raw.zst`, `.sha256`, `release-manifest.v1.json`, `build-receipt.json`, and `repro-report.json` files as a **Development / Preview** release.

---

## 3. Non-Blocking Hygiene Carried Into SBM 0.0.2 (Do Not Delay 0.0.1)

Small cleanup items noticed during the final 0.0.1 audit (none block 0.0.1):
- `sbm-lab`: enable `/dev/kvm` permissions (`chgrp`/`chmod`) in `.github/workflows/ci.yml` so hosted `smoke`/`product`/`secure` jobs run under KVM instead of silently falling back to TCG; tighten `corrupt-verity` `verity_error` string match in `integration.rs:951-955`; kill spawned child if `attach_qemu` returns `Err`.
- `sbm-core`: log any `set_ro`/`protect_backing_device` failure inside `GpartedDiskLease::drop` to `/dev/kmsg`.
- `install`: optionally add `sbm-os-list.json` (`rpi-imager` v4 feed) generator ahead of `SBM Manager` in 0.0.3.

---

## 4. Subsequent Milestone Phases (Start Only After Owner Sign-Off on 0.0.1)

- **Continuous Track A (Agent 18, [`sbm#3`](https://github.com/smart-boot-menu/sbm/issues/3)):** Native interactive simulator (`sbm-preview` + `sbm-sim`/`sbm-ui`) continues as primary UX refinement studio (including evaluating the experimental hardware dashboards in `sbm-uefi@70a84c5..457c545` separately from frozen 0.0.1).
- **Continuous Track B (Agent 16, [`sbm#4`](https://github.com/smart-boot-menu/sbm/issues/4)):** OSS developer infrastructure, `justfile`, `sccache`/`nextest`, `mkosi` incremental/`sysext`, Linux CI `os-autoinst` & U-Boot `sandbox`.
- **Phase 2 — SBM 0.0.2 ([`install#2`](https://github.com/smart-boot-menu/install/issues/2), [`sbm-common#2`](https://github.com/smart-boot-menu/sbm-common/issues/2)):** Persistent internal SSD installation (`efi-only` `< 1 MiB` upgradeable + available-space `offline-full` via shared validated presets), `efibootmgr` registration, uninstall, and boot recovery.
- **Phase 3 — SBM 0.0.3 ([`install#3`](https://github.com/smart-boot-menu/install/issues/3)):** **`SBM Manager`** MVP, allowlisted guided partition resizing, and initial signed `systemd-sysext` modularity (`< 500 MiB` compressed base target).
- **Phase 4 — SBM 0.1 ([`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5)):** Standards-based on-demand network recovery, strict `ram-only` zero-SSD-touch mode, revocable ephemeral remote repair, full `systemd-sysext`/`confext` lifecycle, `sbm-catalog`, and optional `sbm-server`.
- **Phase 5 — SBM 0.2 (Consumer-Ready Trust & Expanded Hardware):** Production Secure Boot (`rhboot/shim` + SBAT + NX + `shim-review` / Microsoft UEFI CA 2023), signed TUF/Sigstore trust, Apple Silicon physical support (`sbm-as`), and public portal.
