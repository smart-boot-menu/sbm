# SBM 0.0.1 Final Release Readiness Audit

**Audit date:** 2026-11-27 (fourth & final SBM 0.0.1 release audit by Agent 11 — independent verification of Agent 13's qualification archive `research@0c87009`, frozen source revisions, hosted CI, artifact digests, build receipts, and closure of the native `x86_64` KVM cold-boot performance gate).  
**Release status:** **BOTH `aarch64` AND `x86_64` ARE TIER 2 QUALIFIED (Development / Preview Trust Tier) — READY FOR OWNER RELEASE APPROVAL & OPT-IN TIER 3 PHYSICAL HARDWARE TESTING.** *(No public release, git tag, or public upload has been published.)*  
**Trust tier:** **Development / Preview** (`production_secure_boot_claimed: false`, `production_tuf_signed: false` per [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md) §7 & [Spec 07](../docs/specifications/07-releases-compatibility-and-diagnostics.md) §17). Consumer-ready releases (SBM 0.2+) require production Secure Boot compatibility (`rhboot/shim` + SBAT + NX + Microsoft UEFI CA 2023 / `shim-review`).  
**UI shipped in SBM 0.0.1:** **Classic UI with Atkinson Hyperlegible Next/Mono vector typography** (`sbm-uefi@4bfb3ba`). Newer experimental hardware dashboards (`sbm-uefi@70a84c5..457c545`) remain strictly behind host-only `experimental-layouts` and are **NOT** part of SBM 0.0.1.  
**Physical hardware status:** **UNVERIFIED (`Tier 3: NOT RUN`)** — awaiting human-authorized USB boot testing on the dedicated HP laptop (`EXP-HW-HP01`) using [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md).  
**Dual-architecture media:** Strictly **optional / experimental** (`experimental: true`); NOT a release prerequisite or mandatory gate.

---

## 1. Frozen Release Inputs vs. Current `origin/main` Evaluation

Per release discipline, newer `main` commits are **not** substituted without explicit impact evaluation:

| Repository | Frozen 0.0.1 Revision | Frozen Hosted CI | Current `origin/main` | Substitution Impact & Decision |
|---|---|---|---|---|
| **`sbm-common`** | `abe3029c831f05d77d10cfb214a0c236903d00d9` (`abe3029`) | **PASS** (`45958218582`) | `abe3029` (identical) | **Exact frozen HEAD.** Canonical 0.0.1 contract (`LocalBootRequest`, UUIDv4, `ReleaseManifest` 1.1). |
| **`sbm-uefi`** | `4bfb3ba6457a4f6625d13c6a1435f69f15b8d011` (`4bfb3ba`) | **PASS** (`45980442284`, incl. native KVM OVMF + Secure Boot denial) | `457c545` (`70a84c5`, `ebbdbe4`, `457c545`) | **DO NOT SUBSTITUTE.** `70a84c5..457c545` add experimental hardware dashboards (`Compact`/`Detailed` views, QR tile, CPU/GPU QOI logos, 2D scroll) behind `experimental-layouts` for `sbm-preview`. While committed `artifacts/sbm-*.efi` at `457c545` are still byte-identical to `4bfb3ba`, `ebbdbe4` changed `sbm-menu` `VERSION` from `"0.1.0"` to 0SFS `YY.MM.DD#N` (`build.rs`), so rebuilding from `457c545` would diverge from `0.0.1.lock.toml`. Keep frozen **`4bfb3ba`** (Classic UI + Atkinson typography). |
| **`sbm-core`** | `960f11a5e748e30f105cd79cc648f0633af63138` (`960f11a`) | **PASS** (`45977817124`) | `960f11a` (identical) | **Exact frozen HEAD.** Closes B1 (`sbm-smoke.service` excluded from `mkosi.extra`) and B2 (`BackingRoTracker` + `GpartedDiskLease`, `FirmwareSetup` filter, fail-closed `random_password()`). |
| **`install`** | `870069dccd2b7fc680a35955c27a6481bb46a0e4` (`870069d`) | **PASS** (`46014761860`) | `870069d` (identical) | **Exact frozen HEAD.** Closes B3 (`sbm-common@abe3029` pin, frozen `media/0.0.1.lock.toml`, `size_bytes` enforcement, `--profile` precedence, Rust `1.100.0` CI pin). |
| **`sbm-lab`** | `5ab4f8c0485a226fc639778a65a8a1467c352bde` (`5ab4f8c`) | **PASS** (`46059331789`) | `5c27927` (`2c2cc84`, `9c5fc97..5c27927`) | **No functional Rust delta.** `2c2cc84` ignores local `/build`; `9c5fc97..5c27927` add only the manual `workflow_dispatch` file `.github/workflows/x86_64-kvm-cold-boot-bench.yml` used to run the `N=10` native KVM timing benchmark (`46073194023`). Zero Rust crate changes vs. frozen `5ab4f8c`. |
| **`sbm-as`** | `759be4eabed0cb760eabe5d8befcbba43fe067c6` (`759be4e`) | **PASS** (`45977832267`) | `759be4e` (identical) | **Exact frozen HEAD.** Closes `uboot-efi-poc.sh` `SBM_OWNER_PID` reservation attach check. |
| **`docs` / `research`** | `720793b` / `0c87009` (+ KVM bench archive) | **PASS** (`45972755355`, `46060573659`) | Updated with this audit | Canonical specs + archived Tier 2 qualification evidence & QMP screenshots. |

---

## 2. Independent Closure Verification of `B1`–`B4` and `V1`–`V4`

| Item | Status | Independent Source & Evidence Verification |
|---|---|---|
| **B1 (`sbm-core` — Dev-tooling isolation)** | **CLOSED** | Verified in `sbm-core@960f11a`: `sbm-smoke.service`/`sbm-smoke.sh` removed from `mkosi.extra/` and `00-sbm.preset`, moved to opt-in `dev/smoke-tree/`; `scripts/build-inside.sh` fails closed (`exit 2`) if `SBM_ENABLE_SMOKE=1` under `release`; `sync-and-build.sh` verifies clean `../sbm-common@abe3029`; unit test `production_mkosi_extra_contains_no_smoke_service_or_script` passes; zero `SBM_SMOKE_BEGIN` markers in all Tier 2 runs. |
| **B2 (`sbm-core` — GParted RO safety & hygiene)** | **CLOSED** | Verified in `sbm-core@960f11a`: `BackingRoTracker` + RAII `GpartedDiskLease` (`crates/sbm-cored/src/lib.rs:897-985`) refcounts active GParted instances, fails closed on missing backing disk or `blockdev` error, rolls back RO on `spawn()` error, and re-protects backing partitions on final drop. `FirmwareSetup` filtered in `handoff.rs:136`; `random_password()` (`lib.rs:1119-1135`) fails closed on `/dev/urandom` read error. *(Non-blocking minor note: `GpartedDiskLease::drop` ignores `set_ro`/`protect_backing_device` errors without logging to `kmsg`.)* |
| **B3 (`install` — Contract & lockfile alignment)** | **CLOSED** | Verified in `install@a14cc84` + `870069d`: `Cargo.toml`/`Cargo.lock` pin `sbm-common@abe3029`; `media/0.0.1.lock.toml` locks exact SHA-256s matching `git show 4bfb3ba:artifacts/sbm-{aarch64,x86_64}.efi` (`410,112 B` / `465,920 B`, `<< 1 MiB`) and local `sbm-core@960f11a` release builds; `media_cmd.rs` checks both `sha256` and `size_bytes`; CLI `--profile` overrides `lock.profile`; CI pins Rust `1.100.0`. |
| **B4 (`sbm-lab` — Assertions & `sbm-lab#5`)** | **CLOSED** | Verified in `sbm-lab@5ab4f8c` & `sbm-as@759be4e`: `integration.rs` enforces `menu_ready_1_us < 250_000` on HVF/KVM, `verify_done result=ok`, `/dev/mapper/root` + `SBM_PROTECT` + `!SBM_SMOKE_BEGIN`, `rgb_luma_stddev >= 5.0` across all 5 positive screenshots, `ppm_diff_ratio >= 0.05` for GParted, before/after fixture-disk & decoy-ESP SHA-256 checks, single-arch `--arch native` default, and 6 Tier 2 `--tier integration-negative` scenarios. `NOTED_QEMU` & `boot-smoke.sh` PID cleared immediately on reap; `run.rs:125-129` passes `opts.core.is_some()` (no 1024 MiB clamp); `SBM_DETACHED=1` stops detached `start-builder.sh` from failing `doctor`; ancestor depth expanded to 6 + `SBM_OWNER_PID` fixes `sbm-as`. *(Non-blocking follow-up hygiene tracked for 0.0.2: tighten `corrupt-verity` `verity_error` string check, kill spawned child if `attach_qemu` errors, enable `/dev/kvm` permissions in `sbm-lab/.github/workflows/ci.yml`.)* |
| **V1 (`sbm-core` immutable release builds)** | **CLOSED** | Clean `SBM_BUILD_PROFILE=release` (`Incremental=no`) builds from `sbm-core@960f11a` + `sbm-common@abe3029` exported and matched byte-for-byte against `0.0.1.lock.toml` for both `arm64` (`4f4aa593...`) and `x86-64` (`05cd737e...`). |
| **V2 (Per-arch assembly & compressed reproducibility)** | **CLOSED** | Independent verification confirmed all `.raw`, `.raw.zst`, `.sha256` sidecars, `release-manifest.v1.json`, `build-receipt.json`, and `repro-report.json` (`reproducible: true`, `compressed: true`, 6/6 files identical) match byte-for-byte on disk for BOTH `aarch64` and `x86_64`. |
| **V3 (Independent Tier 2 positive qualification)** | **CLOSED** | **`aarch64`:** `N=10` HVF cold boots (`min 8.36 ms`, **`median 15.83 ms`**, `p95/max 17.69 ms`, `< 250 ms`) + 9/9 positive integration on both `virtio-gpu-pci` and `ramfb` software fallback. **`x86_64`:** `N=10` native Linux KVM cold boots on the exact digest-verified frozen `sbm-0.0.1-uefi-x86_64.raw` (GitHub Actions run `46073194023`, `AMD EPYC 7763`, `min 36.19 ms`, **`median 38.63 ms`**, `p95/max 41.32 ms`, `< 250 ms`) + 9/9 positive integration on both `virtio-vga` and `-device VGA` software fallback (functional TCG). |
| **V4 (Complete Tier 2 negative security matrix)** | **CLOSED** | All 6 Tier 2 scenarios (`tampered-uki`, `corrupt-verity`, `invalid-handoff`, `stale-boot-success`, `local-boot-request-negative`, `local-boot-request-positive`) passed on final immutable per-arch media for **both** `aarch64` and `x86_64`, plus hosted KVM enrolled dev Secure Boot refusal (`ACCESS_DENIED`, run `45980442284`). |

---

## 3. Reproducibility Scope Distinction (Honest Provenance)

- **Verified (Gate 0):** `install/scripts/check-reproducible.sh` proves **reproducible media assembly** — given the locked prebuilt `sbm-uefi@4bfb3ba` and `sbm-core@960f11a` inputs in `install/media/0.0.1.lock.toml`, running `sbm-install media build` independently twice produces **byte-for-byte identical** `.raw`, `.raw.zst`, `.sha256` sidecars, `release-manifest.v1.json`, and `build-receipt.json` (6/6 files identical for both `aarch64` and `x86_64`).
- **Not claimed in 0.0.1:** Full end-to-end **from-source Linux OS reproducibility** across independent build hosts (rebuilding 501 Fedora 45 RPMs via `mkosi` from live upstream repos without a pinned RPM snapshot mirror) and independent cross-host Rust UEFI toolchain reproducibility are **not** proven or claimed in SBM 0.0.1.

---

## 4. Verified Local Release Artifacts & Archived Evidence

- **Prepared release notes, flasher evaluation & HP physical test checklist:** [`releases/0.0.1-RELEASE-NOTES.md`](releases/0.0.1-RELEASE-NOTES.md), [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md).
- **Archived evidence (`research`):**
  - ARM64: [`sbm-0.0.1-qual-aarch64-2026-11-27.md`](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-aarch64-2026-11-27.md) ([JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-aarch64-2026-11-27.json))
  - x86-64: [`sbm-0.0.1-qual-x86_64-2026-11-27.md`](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-x86_64-2026-11-27.md) ([JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-x86_64-2026-11-27.json), [standalone KVM `N=10` JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-x86_64-kvm-cold-boot-2026-11-27.json))
- **Verified local compressed images (unmodified, matching all manifests/receipts/sidecars):**
  - `aarch64`: `/Users/felg/gh/smart-boot-menu/install/build/qual-0.0.1/aarch64/sbm-0.0.1-uefi-aarch64.raw.zst` (`860,581,891 B` / `820.71 MiB`, SHA-256 `56639af5a3e8d03d067b566cfd36495c424a8f352c26ca099ab1c0271203be24`)
  - `x86_64`: `/Users/felg/gh/smart-boot-menu/install/build/qual-0.0.1/x86_64/sbm-0.0.1-uefi-x86_64.raw.zst` (`896,237,084 B` / `854.72 MiB`, SHA-256 `4f825fc1eaedebe6cf2436a3ea33613c4be9879e7e950de313d11e115a23381e`)
