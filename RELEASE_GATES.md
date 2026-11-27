# Smart Boot Menu — Release Gates (SBM 0.0.1, 0.0.2, 0.0.3 & 0.1)

**Current Status (2026-11-27 — Final Release Audit by Agent 11):**
- **SBM 0.0.1 (`aarch64`) — TIER 2 QUALIFIED (Development / Preview).** All mandatory Gates 0–9, all 4 mandatory negative security gates, and both bound `LocalBootRequest` scenarios pass on the frozen immutable, compressed-reproducible `sbm-0.0.1-uefi-aarch64.raw[.zst]` (`N=10` HVF `menu_ready` median **`15.83 ms`**, min `8.36 ms`, p95/max `17.69 ms`; both `virtio-gpu-pci` and `ramfb` software fallback verified). **Tier 3 physical hardware remains unverified.** Ready for owner release approval (no public release/tag published).
- **SBM 0.0.1 (`x86_64`) — TIER 2 QUALIFIED (Development / Preview).** All mandatory Gates 0–9, all 4 mandatory negative security gates, and both bound `LocalBootRequest` scenarios pass on the frozen immutable, compressed-reproducible `sbm-0.0.1-uefi-x86_64.raw[.zst]`. Gate 1 `N=10` native x86-64 KVM cold-boot timing closed on the exact digest-verified frozen image via GitHub Actions native KVM (`run 46073194023`, `AMD EPYC 7763`, `menu_ready` min **`36.19 ms`**, median **`38.63 ms`**, p95/max **`41.32 ms`**, `<< 250 ms`); hosted KVM CI (`45980442284`) also verified enrolled dev Secure Boot refusal (`ACCESS_DENIED`). **Tier 3 physical hardware (`EXP-HW-HP01`) remains unverified.** Ready for owner release approval & opt-in HP laptop USB testing (no public release/tag published).
- **Qualified UI vs. Experimental Dashboards:** SBM 0.0.1 ships the frozen **Classic UI with Atkinson Hyperlegible Next/Mono vector typography** (`sbm-uefi@4bfb3ba`). Newer experimental hardware dashboards (`sbm-uefi@70a84c5..457c545`, behind `experimental-layouts`) are strictly host-preview / post-0.0.1 and are NOT part of 0.0.1.
- **Dual-architecture combined media (`dualarch`):** **OPTIONAL EXPERIMENTAL PROFILE** — preserved for specialized operator use; **NOT** a recommended distribution and **NOT** a release prerequisite or mandatory gate for 0.0.1 or later milestones (per [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)).
- **Release Trust Tier ([ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md) §7 & [Spec 07](../docs/specifications/07-releases-compatibility-and-diagnostics.md) §17):** SBM 0.0.1 is a **development/preview release** with explicitly documented narrower trust & hardware compatibility (`production_secure_boot_claimed: false`, `production_tuf_signed: false`; physical Secure Boot must be disabled or test keys enrolled). **Consumer-ready releases (SBM 0.2+ / Stable)** MUST account for **production Secure Boot compatibility** (`rhboot/shim` + SBAT + NX + Microsoft UEFI CA 2023 / `shim-review`). Do NOT prematurely pull production Secure Boot, network recovery, or runtime `systemd-sysext` features into 0.0.1.
- **SBM 0.0.2, SBM 0.0.3 & SBM 0.1:** **PLANNED / OPEN.**

> **Honest Qualification Rule:** Do NOT declare any release or architecture qualified until every mandatory Tier 1 and Tier 2 gate below passes from **merged, immutable committed source revisions** with archived machine-readable evidence and green hosted CI. **Functional integration runs on pre-final or un-locked inputs NEVER substitute for full release qualification**, **Tier 1 simulated previews (Track A) NEVER substitute for Tier 2 disposable VM qualification**, **reproducible media assembly does NOT imply independent bit-for-bit reproducibility of the entire upstream Linux source build**, and **Tier 2 VM qualification does NOT claim Tier 3 physical hardware verification**.

---

## 1. Three Mandatory Testing Tiers (Applies to All Releases)

Per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), every release gate explicitly states its testing tier:

- **Tier 1 (Simulated / Native Host):** Unit tests, property tests, regular-file `sbm-plan`/`sbm-exec` simulations, and Track A native interactive previews (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`, primary UX studio). Fast PR/dev feedback; never touches block devices or counts as firmware/kernel qualification.
- **Tier 2 (Disposable VM Disk — `sbm-lab` / Linux CI):** Real UEFI firmware (OVMF/AAVMF), real Linux kernel + CLI storage tools, and disposable copy-on-write QCOW2 disk/NVRAM overlays. **Mandatory automated qualification authority for 0.0.1, 0.0.2, 0.0.3, and 0.1.**
- **Tier 3 (Explicitly Authorized Physical Hardware):** Strictly opt-in manual validation on dedicated non-workstation hardware (e.g., `EXP-HW-HP01`). Never automated on developer workstations; required only before marking a physical device *Verified* on the public compatibility matrix.

---

## 2. SBM 0.0.1 Gates — Independently Qualified Architecture-Specific Recovery Media

`x86_64` (`sbm-0.0.1-uefi-x86_64.raw[.zst]`) and `aarch64` (`sbm-0.0.1-uefi-aarch64.raw[.zst]`) are qualified **independently** against frozen revisions `sbm-common@abe3029`, `sbm-uefi@4bfb3ba`, `sbm-core@960f11a`, `install@870069d`, and `sbm-lab@5ab4f8c`.

### 2.1 Final SBM 0.0.1 Scorecard (Verified 2026-11-27)

| Gate | Tier | `aarch64` (AAVMF) | `x86_64` (OVMF) | Verified Evidence |
|---|---|---|---|---|
| **0. Immutable per-arch reproducible media assembly** | Tier 1/2 | **PASS** | **PASS** | `install@870069d` (`sbm-common@abe3029`, `0.0.1.lock.toml` locking `sbm-uefi@4bfb3ba` + `sbm-core@960f11a` release builds); `sbm-install media verify` green; `check-reproducible.sh` (`reproducible: true`, `compressed: true`, 6/6 files identical for both arches). *Distinction: proves deterministic media assembly over locked inputs, not independent reproducibility of the 501-RPM Fedora 45 Linux build.* |
| **1. Real UEFI menu & startup latency (`N >= 10`)** | Tier 2 | **PASS** | **PASS** | **Classic UI + Atkinson typography** (`410,112 B` aarch64 / `465,920 B` x86_64, `<< 1 MiB`). **`aarch64` HVF (`N=10`):** min `8.36 ms`, **median `15.83 ms`**, p95/max `17.69 ms`. **`x86_64` native KVM (`N=10`, run `46073194023` on frozen `9bebf042...`):** min `36.19 ms`, **median `38.63 ms`**, p95/max `41.32 ms` (`<< 250 ms`). Non-blank QMP picker frames visually verified. |
| **2. Discovered targets** | Tier 2 | **PASS** | **PASS** | Both architectures rendered `Fedora Linux (Decoy Fixture)` and `SBM Core Slot A`; `os:<partuuid>` separated from verified `BootTargetId`; `FirmwareSetup` filtered from Core boot requests. |
| **3. Launch-time UKI verification & Spec 03 handoff** | Tier 2 | **PASS** | **PASS** | Single-open 1 MiB streaming SHA-256 `verify_done result=ok` (`368.06 ms` virtio / `194.90 ms` ramfb on aarch64; `1,341.57 ms` TCG on x86_64), all 5 `BS\|RT` UTF-16 NUL volatile EFI vars, exact boot ESP UUID, UUIDv4 `attempt_id`, and empty load options verified on both arches. |
| **4. Real Linux Core (`dm-verity` EROFS, zero smoke)** | Tier 2 | **PASS** | **PASS** | Clean `sbm-core@960f11a` (`SBM_BUILD_PROFILE=release`, Fedora 45 kernel `7.3.4-300.fc45`, `sbm-smoke.service` removed from production EROFS), BLI resolves boot ESP over decoy ESP, `/dev/mapper/root` mounted, `SBM_PROTECT backing-protected` active, zero `SBM_SMOKE` units/markers. |
| **5. Management UI (`sbm-ui`) & software fallback** | Tier 2 | **PASS** | **PASS** | Live daemon-backed `sbm-ui` and fsynced `boot-success.json` after `UiReady` passed 9/9 on BOTH accelerated virtual GPUs (`virtio-gpu-pci` / `virtio-vga`) AND software-rendering fallback (`ramfb` / `-device VGA`, `pixman + tiny-skia`). |
| **6. GParted & virtual disks** | Tier 2 | **PASS** | **PASS** | Real GParted via XWayland (`gparted_visual_delta` `0.438–0.577` `>= 0.05`); device dropdown displayed `/dev/sda`, `/dev/vda`, `/dev/vdb (1.00 GiB)`, `/dev/vdc (2.00 GiB)`; `BackingRoTracker` + `GpartedDiskLease` refcount RO safely; `fixture_disks_unchanged: true`. |
| **7. Return to menu & confirmation** | Tier 2 | **PASS** | **PASS** | Plain `Reboot` -> `RESET` -> post-reboot picker -> strict UUIDv4 attempt confirmed (`status: confirmed`, `consecutive_failures: 0`), `boot_success_consumed: true` on both arches. |
| **8. Offline operation** | Tier 2 | **PASS** | **PASS** | Zero `-netdev` across all positive, benchmark, and negative runs on both arches. |
| **9. CI, integrity, isolation & host resource hygiene** | Tier 1/2 | **PASS** | **PASS** | All frozen repos pass hosted CI; `inputs_unchanged: true`, `decoy_esp_unchanged: true`, `fixture_disks_unchanged: true`; B1–B4 closed (`sbm-lab#5` critical defects fixed, zero reservation leaks). |
| **Neg. 1–4 + Rec. 5 Security & integrity negative gates** | Tier 2 | **PASS (6/6)** | **PASS (6/6)** | All 6 Tier 2 scenarios (`tampered-uki`, `corrupt-verity`, `invalid-handoff`, `stale-boot-success`, `local-boot-request-negative`, `local-boot-request-positive`) passed on final per-arch media for BOTH arches, plus x86_64 hosted KVM enrolled dev Secure Boot refusal (`ACCESS_DENIED`, run `45980442284`). |
| **Tier 3 — Physical hardware (`EXP-HW-HP01`)** | Tier 3 | **NOT RUN (Opt-In)** | **NOT RUN (Opt-In)** | Physical hardware remains **unverified** for both architectures. See [`releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md`](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md). |
| **Exp. Dual-arch combined media** *(Optional / Non-Gating)* | Tier 2 | *Optional* | *Optional* | Preserved strictly as an optional experimental profile in `install@870069d` (`experimental: true`); NOT a release prerequisite and NOT a mandatory gate. |

**Primary Archived Evidence:**
- [Final SBM 0.0.1 `aarch64` Qualification Report](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-aarch64-2026-11-27.md) ([JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-aarch64-2026-11-27.json))
- [Final SBM 0.0.1 `x86_64` Qualification Report](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-x86_64-2026-11-27.md) ([JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-qual-x86_64-2026-11-27.json), [Native KVM `N=10` JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-0.0.1-x86_64-kvm-cold-boot-2026-11-27.json))
- [Final Release Audit](INTEGRATION_AUDIT.md) | [Prepared 0.0.1 Release Notes](releases/0.0.1-RELEASE-NOTES.md) | [HP Laptop Physical Test Checklist](releases/0.0.1-HP-PHYSICAL-TEST-CHECKLIST.md)
- [Agent 18 Track A native simulator evidence](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-native-sim-2026-11-26.md)
- [Agent 16 Track B benchmarks & host resource audit](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-dev-resource-audit-2026-11-26.md)

### 2.2 Mandatory Positive Acceptance Per Architecture (Gates 0–9)

1. **Gate 0 — Immutable Per-Arch Provenance:** Built from clean committed revisions pinned to unified `sbm-common` (`abe3029`), emitting `sbm-0.0.1-uefi-<arch>.raw`, `.raw.zst`, `.sha256`, populated `release-manifest.v1.json` (`artifacts` + `media` per Spec 07), and `build-receipt.json` (`production_secure_boot_claimed: false`), verified byte-identical (with zstd compression enabled) via `check-reproducible.sh` and `sbm-install media verify`.
2. **Gate 1 — Real UEFI Menu & Startup Speed:** Native fallback binary boots on disposable QCOW2 overlay; `menu_ready < 250 ms` median across `N >= 10` runs on `aarch64` HVF and native `x86_64` KVM (TCG is functional-only, not a latency benchmark); QMP frame proves real non-blank graphical picker (never splash-only).
3. **Gate 2 — Discovered Targets:** Decoy/fixture OS target AND **Manage Computer** both appear in discovery and on the picker.
4. **Gate 3 — Launch-Time Verification & Spec 03 Handoff:** Activating **Manage Computer** streams the native UKI once from a single file handle (`bytes == size`), verifies SHA-256 fail-closed (`verify_done ... result=ok`), flushes UUIDv4 `last_attempt.json` & `current.json` on boot ESP only, publishes all 5 Spec 03 volatile EFI vars, and calls `LoadImage`/`StartImage` via exact device path with empty load options.
5. **Gate 4 — Real Linux Core:** Resolves boot ESP via BLI `LoaderDevicePartUUID` (rejecting decoy ESP enumerated first), verifies all 5 EFI vars + `current.json` SHA-256, mounts native `dm-verity` EROFS root (`/dev/mapper/root`), protects non-ESP partitions on backing recovery disk, and ships zero dev/smoke root hooks (`sbm-smoke.service` excluded).
6. **Gate 5 — Live Management UI & Software Fallback:** Real `labwc` + Iced `sbm-ui` renders live daemon-backed disk/handoff info (including `ramfb`/`VGA` `tiny-skia` software fallback when DRM render node is absent or `wgpu` fails) and writes fsynced `boot-success.json` (`sbm-core-uki`, exact `attempt_id`).
7. **Gate 6 — GParted & Virtual Disks:** Real GParted launches via XWayland and its device selector displays both 1 GiB and 2 GiB virtual fixture disks without mutating them (virtual disk images byte-identical before/after; backing-disk RO refcounted safely).
8. **Gate 7 — Return to Menu & Confirmation:** Core's Reboot control performs a plain guest reboot (no `requested-command.json`), firmware boots the same menu, and UEFI confirms the exact prior attempt (`status: confirmed`, `consecutive_failures: 0`, deletes `boot-success.json`).
9. **Gate 8 — Offline:** Complete Gates 1–7 loop finishes with zero virtual NIC, account, or `sbm-server`.
10. **Gate 9 — CI, Integrity & Resource Hygiene:** All hosted CI jobs pass across all participating repos; original `.raw` image bytes, firmware templates, fixture bases, decoy ESP, and GPT metadata remain byte-identical before and after runs; host resource protection (`sbm-lab#5`) has zero active race/PID-reuse/accounting defects.

### 2.3 Mandatory Negative Acceptance Per Architecture (Tier 2 Disposable VM on Final Per-Arch Media)

1. **Tampered UKI:** 1-byte flip in native UKI -> UEFI refuses launch fail-closed before `StartImage`, emits zero handoff/chainload, and returns to usable picker.
2. **Corrupted `dm-verity`:** Corrupted verity hash or data block -> Linux never reaches `SBM_UI_READY` or writes `boot-success.json`.
3. **Invalid Handoff / Stale Confirmation:** Mismatched `SbmHandoffSha256` -> Core declines `boot-success.json` and exposes zero `boot_targets`; stale `attempt_id` or `"local"` -> UEFI refuses confirmation and removes stale report.
4. **Decoy ESP Priority:** Decoy ESP enumerated before boot ESP -> zero mutations on decoy ESP (byte-identical SHA-256 before/after).
5. **Bound One-Shot `LocalBootRequest` (Recommended Functional + Negative Check):** Valid request from confirmed Core attempt is consumed atomically (deleted before act) and boots discovered target; stale/invalid request triggers error screen without substituting another entry or booting default.

---

## 3. SBM 0.0.2 Gates — Persistent Internal SSD Installation, `efi-only` Profile, Uninstall & Recovery

Qualified per architecture (`x86_64`, `aarch64`) against **Spec 03 §9a**, **Spec 04 §11a**, **ADR-011**, and **ADR-012**.

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.2-1. Planner & Safety Guards** | Tier 1 | `sbm-plan`/`sbm-exec` unit & property tests verify: `sbm-common#2` partition GUID/attribute round-trip, available-space-only enforcement (refuses shrink in 0.0.2), `ProtectedAppleSystem` hard-block, MBR rejection, BitLocker recovery-key warning gate, `DiskIdentity` & `expected_partition_table_sha256` mismatch abort, and rollback on simulated fault. |
| **0.2-2. Native UI Flow Preview** | Tier 1 | Track A native preview exercises **Install SBM** (`efi-only` and `offline-full` validated presets), dry-run diff review, confirmation, uninstall, and boot-repair screens in Iced `sbm-ui` with zero crashes. *(Does not satisfy Tier 2.)* |
| **0.2-3. Minimal `efi-only` Install & Upgradeability** | Tier 2 | Stripped `sbm-uefi` binary size measured against the **`< 1 MiB`** target; `efi-only` installs cleanly on existing ESP with zero extra partitions, boots & chainloads existing OS fixtures, and upgrades cleanly to `offline-full` (adding Core slots + manifest) **without reinstalling `sbm-uefi` or altering unrelated OS boot entries**. |
| **0.2-4. Internal SSD `offline-full` Install Alongside Existing OS** | Tier 2 | Boot SBM USB on a disposable multi-OS QCOW2 disk fixture (existing Windows-style ESP + Linux BLS ESP + >= 2 GiB unallocated GPT tail space); run **Install SBM** via `sbm-ui`/`sbm-cored`; verify `\EFI\Microsoft\` and existing Linux loaders are byte-identical, native `root-<arch>` + `root-<arch>-verity` partitions created with exact DPS GUIDs/PARTUUIDs, `\EFI\sbm\install-receipt.json` written, and `efibootmgr` entry registered first in `BootOrder`. |
| **0.2-5. Reboot Into Internal SSD SBM & Chainload** | Tier 2 | Detach USB medium; reboot VM; verify firmware boots internal SSD `\EFI\sbm\sbm-<arch>.efi`, discovers existing OS fixture(s), chainloads existing OS cleanly, and boots internal **Manage Computer** (`sbm-core` `dm-verity` EROFS) -> Reboot -> confirmation. |
| **0.2-6. Clean Uninstall** | Tier 2 | Run **Uninstall SBM** from internal or USB Core; verify prior `BootOrder` is restored, SBM NVRAM entry deleted, `\EFI\sbm\` removed, SBM-created recovery PARTUUIDs optionally removed, existing OS ESP/partitions untouched, and VM boots prior OS directly. |
| **0.2-7. Boot Registration Recovery** | Tier 2 | Simulate Windows Update overwriting `BootOrder` to place Windows first; boot SBM USB -> run **Repair SBM Boot Registration**; verify zero partition changes and VM boots internal SSD SBM again on next reboot. |
| **0.2-8. Negative & Fault Injection** | Tier 2 | Insufficient unallocated space -> clean refusal with zero writes; Apple APFS fixture -> hard-blocked; disk changed between plan & exec -> optimistic hash-lock abort; power-cut before `efibootmgr` -> existing OS still boots cleanly. |
| **0.2-9. Physical Hardware (Opt-In Only)** | Tier 3 | *Optional for 0.0.2 beta; required before marking any physical device "Verified".* Explicitly human-authorized run on dedicated test machine (`EXP-HW-HP01`) with archived receipt. |

---

## 4. SBM 0.0.3 Gates — Cross-Platform `SBM Manager` MVP, Guided Partition Resizing & Initial `systemd-sysext` Modularity

Qualified against **Spec 04 §11b**, **Spec 07 §17a**, **ADR-011**, **ADR-012**, and [`research/ecosystem/media-creator-evaluation.md`](../research/ecosystem/media-creator-evaluation.md).

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.3-1. `SBM Manager` Architecture Decision & Verification** | Tier 1/2 | Documented empirical evaluation comparing a minimal Apache-2.0 `rpi-imager` fork vs. a thin Rust/Iced `SBM Manager` reusing OS flashing backends completed; `SBM Manager` configures profile/cache/modules, fetches verified per-arch manifest, filters out internal system drives, verifies download/extract SHA-256, performs read-back verification, supports offline local `.raw`/`.raw.zst` files, and flashes a bootable image verified in Tier 2 QEMU. |
| **0.3-2. Resize Planner & Allowlist Guards** | Tier 1 | Unit/property tests prove allowlist enforcement (`ext4`, clean non-hibernated `NTFS`, single-device `Btrfs`), SI/IEC safety-margin math, and hard refusal of BitLocker, LUKS, LVM/RAID/ZFS/XFS, dirty/hibernated NTFS, Apple APFS, and MBR disks. |
| **0.3-3. Guided Resize + Internal Install (Populated OS Fixtures)** | Tier 2 | On disposable populated QCOW2 disks with **zero unallocated space** (one `ext4` Linux fixture, one clean `NTFS` fixture, one single-device `Btrfs` fixture): inspect -> shrink via Golden Rule sequence -> install SBM -> detach USB -> reboot into internal SSD SBM -> verify pre-existing sentinel files inside the shrunk filesystem pass `fsck`/SHA-256 verification and existing OS still boots. |
| **0.3-4. Resize Negative Gates** | Tier 2 | BitLocker fixture, LUKS fixture, hibernated/dirty NTFS fixture, and XFS fixture are hard-blocked before any disk write with actionable remediation messages and byte-identical disk hashes before/after. |
| **0.3-5. Initial Signed `systemd-sysext` Modularity & Base Size** | Tier 1/2 | Compressed `sbm-core` base image measured against **`< 500 MiB`** target; signed `dm-verity` `.sysext.raw` module activates cleanly over immutable root (`--image-policy='root=signed+absent:usr=signed+absent:=unused+absent'`) and unsigned/tampered `.sysext.raw` is rejected fail-closed. |
| **0.3-6. End-to-End Consumer Journey** | Tier 2 (+ opt-in Tier 3) | Full documented walkthrough verified end-to-end: `SBM Manager -> configure profile & flash USB -> boot target -> Install SBM -> inspect & resize -> confirm -> install -> reboot into internal SSD SBM`. |

---

## 5. SBM 0.1 Gates — Network Recovery, Ephemeral Remote Repair, Full Modularity & OS Catalog ([`sbm#5`](https://github.com/smart-boot-menu/sbm/issues/5))

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.1-1. Standards-Based Network Bootstrap & HTTP `Range` Resume** | Tier 2 | Recovery USB boots signed minimal Linux Network-Bootstrap UKI -> downloads & authenticates `sbm-core` from local HTTPS test server (surviving simulated mid-transfer disconnect via HTTP `Range` resume) -> `switch-root` into verified `dm-verity` EROFS root; unavailable-network path degrades cleanly with offline fallback. |
| **0.1-2. Strict `ram-only` Zero-SSD-Touch & Low-RAM Guard** | Tier 2 | In `ram-only` mode, target internal SSD raw disk SHA-256 is **byte-identical before and after** full network boot + recovery session (zero temp/cache/log/swap writes); under insufficient simulated RAM (`≤ 2 GiB`), bootstrapper refuses cleanly with actionable options rather than touching internal disks. |
| **0.1-3. Ephemeral Revocable Remote Recovery Session** | Tier 1/2 | Recovery USB contains zero permanent shared credentials and zero unattended command hooks; valid non-expired `EphemeralRecoveryGrant` establishes authenticated encrypted remote session, displays local active-session banner, and immediately terminates + wipes ephemeral RAM keys on one-action local revoke, expiry, or reboot. |
| **0.1-4. Full `systemd-sysext`/`confext` Lifecycle** | Tier 1/2 | Signed `ModuleDescriptor` acyclic dependency & `SYSEXT_LEVEL`/arch validation; users download, cache (RAM or authorized storage only), activate, deactivate, and remove optional modules cleanly without mutating the immutable base. |

---

## 6. SBM 0.2 / Consumer-Ready Release Gates — Production Secure Boot, Apple Silicon & Public Portal

- **Consumer-Ready Production Secure Boot Compatibility ([ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md) §7, `sbm-lab#4`):** `SecureBoot=1`, `SetupMode=0` in disposable OVMF VARS with signed menu -> signed Core UKI boot, untrusted UKI rejected without masking `SECURITY_VIOLATION`, external load options cannot override signed `.cmdline`, plus `rhboot/shim 16.1` + SBAT + NX + `shim-review` (Microsoft UEFI CA 2023) before recommending any release for general Secure-Boot-enabled consumer PCs.
- **Signed Distribution Trust (Spec 07):** TUF + Sigstore/Cosign verification before public trust claims.
- **Apple Silicon Physical Boot (`sbm-as`) & Public Portal (`smart-boot-menu.github.io`):** Tracked in [ROADMAP.md](ROADMAP.md) under SBM 0.2.
