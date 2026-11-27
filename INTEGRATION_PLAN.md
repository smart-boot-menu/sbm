# Smart Boot Menu — Integration Plan, Dependencies & Ownership

**Last updated:** 2026-11-27 (Independent SBM 0.0.1 Release Readiness Audit by Agent 11)  
**Scope:** Coordinates final **SBM 0.0.1** qualification (independently qualified per-arch offline recovery media; development trust tier), continuous **Track A (Agent 18 — primary UX studio)** & **Track B (Agent 16)**, **SBM 0.0.2** (persistent internal SSD installation incl. `< 1 MiB` `efi-only` upgradeable profile, uninstall & recovery), **SBM 0.0.3** (cross-platform **`SBM Manager`** MVP, guided partition resizing & initial signed `systemd-sysext` modularity), and **SBM 0.1** (standards-based network recovery, `ram-only`, ephemeral remote repair, full modularity & OS catalog; [`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5)).

All engineering agents operate from `~/gh/smart-boot-menu/`, follow centralized [`.github/AGENTS.md`](../.github/AGENTS.md), [`ADR-010`](../docs/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md), [`ADR-011`](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [`ADR-012`](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), and respect the 16 GiB physical RAM budget on the macOS host. **Never modify physical host disks, firmware `BootOrder`, or macOS `LocalPolicy`/SIP.**

---

## 1. Canonical Contract Revisions & Cross-Repository Dependency Matrix (2026-11-27)

| Repository | Audited `origin/main` | `sbm-common` Binding | Current Verified State & Next Action |
|---|---|---|---|
| **`.github`** | `main` | N/A | Canonical single source of truth for agent policies (`ADR-010` 0SFS pattern). |
| **`docs`** | `2d41168` (+ audit clarifications) | N/A | CI green. ADRs 001–012, Specs 01–07, 3-tier testing, shared-options profile presets, and dev vs. consumer-ready Secure Boot trust boundary. |
| **`research`** | `5c701f8` | N/A | CI green. Archives Agent 13/15/16/18/20 evidence (`sbm-uefi-agent15-2026-11-27.{md,json}`, `sbm-native-sim-2026-11-26.md`, `sbm-dev-resource-audit-2026-11-26.md`, `sbm-uefi-typography-2026-11-27.md`). |
| **`sbm-common`** | **`abe3029`** (`abe3029c831f05d77d10cfb214a0c236903d00d9`) | Canonical `main` | **CI green. Frozen for SBM 0.0.1.** Adds `LocalBootRequest` + UUIDv4 helpers on top of `b3c77141`. For **0.0.2**, merge [`sbm-common#2`](https://github.com/smart-boot-menu/sbm-common/issues/2); for **0.0.3/0.1**, add `ModuleDescriptor` & `EphemeralRecoveryGrant`. |
| **`sbm-uefi`** | **`66704ea`** (`66704ea6b3b5eb94d94205aa8c53bebbd07c82cb`) | **`abe3029`** (aligned) | **CI green** (KVM OVMF smoke + enrolled Secure Boot unsigned rejection, run `45967541247`). **No 0.0.1 blockers in `origin/main`!** `15.73 ms` median ARM64 HVF `menu_ready`, launch-time 1 MiB streaming SHA-256, 5 Spec 03 volatile vars, empty load options, strict UUIDv4 confirmation, bound `LocalBootRequest`, `230.9 KiB`/`261.6 KiB` EFI binaries, `sbm-preview` isolated & green. *(Note: local working tree has Agent 20's uncommitted typography WIP on `e631fbd`; qualify strictly from clean `origin/main` `66704ea`!)* |
| **`sbm-core`** | **`a74ea48`** (`c2020c7` + UI typography) | **`abe3029`** (CI pinned; path dep locally) | **CI green.** Merged Agent 13 (`37fdc46`), Agent 18 `sbm-sim` (`e127018`), Agent 15 strict 5-var Spec 03 handoff & `LocalBootRequest` (`c2020c7`), and Agent 20 typography (`a74ea48`). **Remaining 0.0.1 blockers:** **B1** remove/disable `sbm-smoke.service` from production `00-sbm.preset:12`; **B2** fix `launch_gparted()` concurrent RO clear & spawn-fail RO leak (`sbm-cored/src/lib.rs:488-498`); **V1** rebuild clean release `arm64` & `x86-64` images (current `build/images/` is stale `5031613`!). |
| **`install`** | **`d2d2b3a`** (`d2d2b3ab1a05b1ff584fddb06fb63e2740b3de82`) | **`b3c77141` (STALE — bump to `abe3029`)** | **CI green (76 tests).** Single-arch 3-part GPT, complete `release-manifest.v1.json` (schema `1.1`, populated `artifacts`+`media`), `build-receipt.json`, optional non-gating `dualarch`, and single-pipeline `ProfilePreset` (`ADR-012`). **Remaining 0.0.1 blockers:** **B3** bump `Cargo.toml`/`Cargo.lock` to `sbm-common@abe3029` and update `media/0.0.1.lock.toml` from stale `653012f`/`5031613` to `sbm-uefi@66704ea` + final post-B1/B2 `sbm-core` for both arches; **V2** assemble & prove compressed `check-reproducible.sh` for both arches. *(Optional 0.0.1 nice-to-have: `sbm-os-list.json` `rpi-imager` v4 feed.)* |
| **`sbm-lab`** | **`8dee38d`** (`8dee38dd17b765571109b6069a838b69993f2504`) | None (`sbm-media` pinned to `b11c427`) | **CI green** (`check`, `smoke`, `product`, `secure`, run `45966525437`; `os-autoinst` prototype on `c3448d9`; `sbm-lab#3` fixed in `9c3c381`). `integration.rs` merged (`ba212d1`), `gpt.rs`/`fatimg.rs` deduplicated (`0794b0c`). **Remaining 0.0.1 blocker B4:** harden `integration.rs` assertions (`menu_ready < 250 ms`, `verify_done`, `dm-verity`, non-blank frames, fixture-disk immutability, single-arch default) + close remaining `sbm-lab#5` resource manager defects (`NOTED_QEMU`/`boot-smoke.sh` PID-reuse window, `run.rs:124` `product` Core 1024 MiB clamp, detached `start-builder.sh` `doctor`, `sbm-as` `attach` owner depth). |
| **`sbm-server` / `sbm-catalog` / `sbm-as` / `sbm-agent` / `website`** | Post-0.0.1 tracks | Align to `abe3029` as needed | Execute under SBM 0.1 and SBM 0.2 per [ROADMAP.md](ROADMAP.md). |

---

## 2. Exact Remaining SBM 0.0.1 Blockers & Validation Gates

### Implementation Blockers (Small, Surgical — Fix Before Final Qualification Build)

1. **B1 (`sbm-core` — Dev-Tooling Isolation):** Remove `enable sbm-smoke.service` from `mkosi.extra/usr/lib/systemd/system-preset/00-sbm.preset:12` (and exclude `sbm-smoke.service`/`sbm-smoke.sh` from production `mkosi.extra`) so an unverified `/efi/EFI/sbm/state/smoke` file can never trigger root execution.
2. **B2 (`sbm-core` — GParted Backing-Disk RO Safety):** In `crates/sbm-cored/src/lib.rs:488-498`, reference-count active GParted instances before clearing whole-disk RO and roll back `set_ro(&disk, true)` if `command.spawn()` fails. *(While touching `sbm-core`, also filter `BootTargetKind::FirmwareSetup` in `handoff.rs:131-139` and return `Err` instead of a hardcoded byte fallback in `random_password()` `lib.rs:1029-1034`.)*
3. **B3 (`install` — Contract & Lockfile Alignment):** Bump `Cargo.toml`/`Cargo.lock` to `sbm-common@abe3029` and update `media/0.0.1.lock.toml` to lock `sbm-common@abe3029`, `sbm-uefi@66704ea` (exact `sbm-aarch64.efi` / `sbm-x86_64.efi` SHA-256s), and the new post-B1/B2 immutable `sbm-core` release builds for BOTH `aarch64` and `x86_64`. *(Quick hygiene in same PR: check `size_bytes` in `media_cmd.rs:377,393`, fix `--profile` override precedence in `assemble.rs:314-318`, pin Rust `>= 1.95` in `install/.github/workflows/ci.yml`.)*
4. **B4 (`sbm-lab` — Qualification Assertions & Remaining `sbm-lab#5` Defects):**
   - Harden `integration.rs`: assert UEFI `menu_ready < 250 ms` on HVF/KVM, assert `verify_done ... result=ok`, assert `/dev/mapper/root` / `dm-verity` / `SBM_PROTECT`, verify non-blank screenshot pixel variance, verify `disk-1g`/`disk-2g` immutability, and support clean single-arch invocation (not defaulting `--arch` to `"both"`).
   - Close remaining `sbm-lab#5` defects: clear `NOTED_QEMU` immediately upon child reap in `run.rs`/`integration.rs` (and `pid=""` in `sbm-core/scripts/boot-smoke.sh:219`), honor `opts.core.is_some()` in `run.rs:124` so `product` Core UKIs aren't clamped to 1024 MiB, stop detached `start-builder.sh` from failing `resources doctor`, and fix `sbm-as/scripts/uboot-efi-poc.sh:207` `attach` owner-depth check.

### Validation-Only Gates (Execute Once B1–B4 Are Committed & Pushed)

- **V1 — Clean Immutable `sbm-core` Builds (`SBM_BUILD_PROFILE=release`):** Build both `sbm-core-arm64.raw` and `sbm-core-x86-64.raw` (with `.manifest` and receipts) from the clean committed post-B1/B2 `sbm-core` revision (verifying `../sbm-common` is clean at `abe3029`).
- **V2 — Final Per-Arch Assembly & Compressed Reproducibility (`install`):** Lock exact `V1` + `sbm-uefi@66704ea` digests in `media/0.0.1.lock.toml`, assemble BOTH `sbm-0.0.1-uefi-aarch64.raw[.zst]` and `sbm-0.0.1-uefi-x86_64.raw[.zst]`, run `sbm-install media verify`, and prove byte-for-byte determinism WITH zstd compression enabled via `scripts/check-reproducible.sh --arch aarch64` and `--arch x86_64` (archiving both `repro-report.json` files).
- **V3 — Independent Tier 2 Positive Qualification (`Gates 1–9` per arch):**
  - `aarch64` (AAVMF/HVF): `N >= 10` real-media cold boot timing (`menu_ready < 250 ms`) + full 9/9 graphical integration + `ramfb`/`tiny-skia` software-rendering fallback on final `sbm-0.0.1-uefi-aarch64.raw`.
  - `x86_64` (OVMF): `N >= 10` real-media cold boot timing on native Linux KVM (`menu_ready < 250 ms`; TCG is functional-only!) + full 9/9 graphical integration + software-rendering fallback on final `sbm-0.0.1-uefi-x86_64.raw`.
- **V4 — Complete Tier 2 Negative Security & Integrity Matrix (per arch, on final media):**
  1. Tampered UKI (1-byte flip -> fail-closed refusal before `StartImage`, usable picker, no handoff/chainload) — `aarch64` + `x86_64`.
  2. Corrupted `dm-verity` data/hash block (Linux fails before `SBM_UI_READY` / no `boot-success.json`) — `aarch64` + `x86_64`.
  3. Invalid handoff (`SbmHandoffSha256` mismatch -> Core declines `boot-success.json` & exposes zero `boot_targets`) & stale/`"local"` `attempt_id` confirmation refusal (UEFI rejects and deletes stale report) — `aarch64` + `x86_64`.
  4. Decoy ESP enumerated before boot ESP -> zero mutations on decoy ESP — `aarch64` + `x86_64`.
  5. Bound one-shot `LocalBootRequest` positive + stale/invalid negative verification on real media — `aarch64` + `x86_64`.

---

## 3. Final Qualification Assignment for Agent 13 (SBM 0.0.1 Release Qualification)

**Owner:** **Agent 13** (coordinating minimal surgical fixes with `sbm-core`, `install`, and `sbm-lab`, respecting the 16 GiB macOS host RAM budget via `sbm-lab resources`, and **NEVER** touching Agent 20's local `sbm-uefi` working tree or physical host disks).

1. **Freeze Target Revisions to Qualify:**
   - `sbm-common`: `abe3029c831f05d77d10cfb214a0c236903d00d9` (already clean & green).
   - `sbm-uefi`: **`66704ea6b3b5eb94d94205aa8c53bebbd07c82cb`** (`origin/main` — pull exact prebuilt `artifacts/sbm-{aarch64,x86_64}.efi` from clean `66704ea`, NOT the dirty local `sbm-uefi` checkout!).
   - `sbm-core`: clean post-**B1/B2** commit on `origin/main` (on top of `a74ea48`, or `c2020c7` + B1/B2 if typography is held — prefer HEAD `a74ea48` + B1/B2 so `main` stays linear and CI stays green).
   - `install`: clean post-**B3** commit on `origin/main` (pinning `sbm-common@abe3029`, `sbm-uefi@66704ea`, and post-B1/B2 `sbm-core` for both arches).
   - `sbm-lab`: clean post-**B4** commit on `origin/main`.
2. **Execute Sequentially (One Heavy Workload at a Time on 16 GiB Host):**
   - **Step 1:** Land **B1 + B2** in `sbm-core`, verify CI green, and run **V1** (`SBM_BUILD_PROFILE=release`) to export immutable `sbm-core-arm64.raw` and `sbm-core-x86-64.raw` + manifests.
   - **Step 2:** Land **B3** in `install` with exact `V1` + `sbm-uefi@66704ea` digests in `media/0.0.1.lock.toml`, verify CI green, and run **V2** (`scripts/check-reproducible.sh --arch aarch64` and `--arch x86_64`, WITH zstd compression enabled) + `sbm-install media verify`.
   - **Step 3:** Land **B4** in `sbm-lab`, verify all 4 hosted CI jobs green.
   - **Step 4:** Qualify **`aarch64` independently** (**V3 + V4** on `sbm-0.0.1-uefi-aarch64.raw` under macOS HVF: `N >= 10` cold-boot timing, 9/9 graphical integration + `ramfb` software fallback, and all 5 negative/bound-request Tier 2 checks). Archive machine-readable JSON + Markdown report + screenshots in `research/validation/evidence/sbm-0.0.1-qual-aarch64-2026-11-27.{md,json}`.
   - **Step 5:** Qualify **`x86_64` independently** (**V3 + V4** on `sbm-0.0.1-uefi-x86_64.raw`: run `N >= 10` real-media timing on **native Linux KVM** — e.g. via hosted Linux KVM CI or authorized x86_64 KVM runner, never citing TCG latency as `< 250 ms` compliance — plus 9/9 graphical integration, software fallback, and all 5 negative/bound-request Tier 2 checks). Archive evidence in `research/validation/evidence/sbm-0.0.1-qual-x86_64-2026-11-27.{md,json}`.
3. **Required Qualification Artifacts (Per Architecture, `dualarch` Optional/Non-Gating):**
   - `sbm-0.0.1-uefi-<arch>.raw` and `sbm-0.0.1-uefi-<arch>.raw.zst` + `.sha256` sidecars
   - `release-manifest.v1.json` (schema `1.1`, populated `artifacts` + `media`)
   - `build-receipt.json` (complete provenance + `production_secure_boot_claimed: false`)
   - `repro-report.json` (`reproducible: true`, `compressed: true`, matching committed `install` SHA)
   - `sbm-0.0.1-qual-<arch>-*.{md,json}` + QMP screenshots (`01-uefi-menu`, `02-core-ui`, `03-gparted`, `04-gparted-devices`, `05-post-reboot-menu`, `ramfb-software-ui`, negative refusal)
   - *(Optional, non-gating)* `sbm-os-list.json` (`rpi-imager` v4 feed) and `sbm-0.0.1-uefi-dualarch.raw[.zst]`
4. **Qualification Sign-Off Rule:** Because architectures qualify independently, **`aarch64`** can be declared 0.0.1-qualified as soon as Steps 1–4 pass with archived evidence and green CI, without waiting for `x86_64` KVM qualification in Step 5 (and vice versa). Do NOT claim production Secure Boot or Tier 3 physical hardware support in 0.0.1.

---

## 4. Subsequent Milestone Phases (Do Not Pull Into 0.0.1)

- **Continuous Track A (Agent 18, [`sbm#3`](https://github.com/smart-boot-menu/sbm/issues/3)):** Native interactive simulator (`sbm-preview` + `sbm-sim`/`sbm-ui`) continues as primary UX refinement studio (`< 1 s` startup, `< 5 s` warm iteration).
- **Continuous Track B (Agent 16, [`sbm#4`](https://github.com/smart-boot-menu/sbm/issues/4)):** OSS developer infrastructure, `justfile`, `sccache`/`nextest`, `mkosi` incremental/`sysext`, Linux CI `os-autoinst` & U-Boot `sandbox`.
- **Phase 2 — SBM 0.0.2 ([`install#2`](https://github.com/smart-boot-menu/install/issues/2), [`sbm-common#2`](https://github.com/smart-boot-menu/sbm-common/issues/2)):** Persistent internal SSD installation (`efi-only` `< 1 MiB` upgradeable + available-space `offline-full` via shared validated presets), `efibootmgr` registration, uninstall, and boot recovery.
- **Phase 3 — SBM 0.0.3 ([`install#3`](https://github.com/smart-boot-menu/install/issues/3)):** **`SBM Manager`** MVP, allowlisted guided partition resizing, and initial signed `systemd-sysext` modularity (`< 500 MiB` compressed base target).
- **Phase 4 — SBM 0.1 ([`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5)):** Standards-based on-demand network recovery, strict `ram-only` zero-SSD-touch mode, revocable ephemeral remote repair, full `systemd-sysext`/`confext` lifecycle, `sbm-catalog`, and optional `sbm-server`.
- **Phase 5 — SBM 0.2 (Consumer-Ready Trust & Expanded Hardware):** Production Secure Boot (`rhboot/shim` + SBAT + NX + `shim-review` / Microsoft UEFI CA 2023), signed TUF/Sigstore trust, Apple Silicon physical support (`sbm-as`), and public portal.
