# Smart Boot Menu — Release Gates (SBM 0.0.1, 0.0.2, 0.0.3 & 0.1)

**Current Status (2026-11-27 — Independent Audit by Agent 11):**
- **SBM 0.0.1 (`aarch64`) — OPEN / UNQUALIFIED (Strong Functional Evidence).** All 8 repos pass hosted CI on `origin/main`; a fresh single-arch ARM64 image (`sbm-uefi@664a0b3`, `sbm-core@c2020c7`, `install@d2d2b3a`) achieved `15.73 ms` median HVF `menu_ready` (`N=10`), passed 9/9 local graphical integration checks, and refused a 1-byte tampered UKI. **Still open:** 4 small implementation blockers (`B1`–`B4`, including `sbm-smoke.service` isolation in `sbm-core` and stale `install` lockfile/pin), clean immutable `sbm-core` rebuild, compressed reproducibility (`check-reproducible.sh`), and remaining Tier 2 negative security gates (corrupted `dm-verity`, invalid handoff/stale confirmation, bound `LocalBootRequest`).
- **SBM 0.0.1 (`x86_64`) — OPEN / UNQUALIFIED.** Hosted KVM OVMF smoke (`64.77 ms` synthetic fixture) and enrolled Secure Boot unsigned-recovery rejection (`ACCESS_DENIED`, CI run `45967541247`) passed on `sbm-uefi@66704ea`. **Zero real-media `x86_64` runs exist on current commits** — final `sbm-0.0.1-uefi-x86_64.raw[.zst]` assembly, reproducibility, KVM real-media latency (`N >= 10`), graphical integration, and all Tier 2 negative gates remain open.
- **Dual-architecture combined media (`dualarch`):** **OPTIONAL EXPERIMENTAL PROFILE** — preserved for specialized operator use; **NOT** a recommended distribution and **NOT** a release prerequisite or mandatory gate for 0.0.1 or later milestones (per [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)).
- **Release Trust Tier ([ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md) §7 & [Spec 07](../docs/specifications/07-releases-compatibility-and-diagnostics.md) §17):** SBM 0.0.1 is a **development/preview release** with explicitly documented narrower trust & hardware compatibility (`production_secure_boot_claimed: false`, `production_tuf_signed: false`; physical Secure Boot must be disabled or test keys enrolled). **Consumer-ready releases (SBM 0.2+ / Stable)** MUST account for **production Secure Boot compatibility** (`rhboot/shim` + SBAT + NX + Microsoft UEFI CA 2023 / `shim-review`). Do NOT prematurely pull production Secure Boot, network recovery, or runtime `systemd-sysext` features into 0.0.1.
- **SBM 0.0.2, SBM 0.0.3 & SBM 0.1:** **PLANNED / OPEN.**

> **Honest Qualification Rule:** Do NOT declare any release or architecture qualified until every mandatory Tier 1 and Tier 2 gate below passes from **merged, immutable committed source revisions** with archived machine-readable evidence and green hosted CI. **Functional integration runs on pre-final or un-locked inputs NEVER substitute for full release qualification**, **Tier 1 simulated previews (Track A) NEVER substitute for Tier 2 disposable VM qualification**, and **aspirational engineering targets MUST always be distinguished from measured results**.

---

## 1. Three Mandatory Testing Tiers (Applies to All Releases)

Per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), every release gate explicitly states its testing tier:

- **Tier 1 (Simulated / Native Host):** Unit tests, property tests, regular-file `sbm-plan`/`sbm-exec` simulations, and Track A native interactive previews (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`, primary UX studio). Fast PR/dev feedback; never touches block devices or counts as firmware/kernel qualification.
- **Tier 2 (Disposable VM Disk — `sbm-lab` / Linux CI):** Real UEFI firmware (OVMF/AAVMF), real Linux kernel + CLI storage tools, and disposable copy-on-write QCOW2 disk/NVRAM overlays. **Mandatory automated qualification authority for 0.0.1, 0.0.2, 0.0.3, and 0.1.**
- **Tier 3 (Explicitly Authorized Physical Hardware):** Strictly opt-in manual validation on dedicated non-workstation hardware (e.g., `EXP-HW-HP01`). Never automated on developer workstations; required only before marking a physical device *Verified* on the public compatibility matrix.

---

## 2. SBM 0.0.1 Gates — Independently Qualified Architecture-Specific Recovery Media

`x86_64` (`sbm-0.0.1-uefi-x86_64.raw[.zst]`) and `aarch64` (`sbm-0.0.1-uefi-aarch64.raw[.zst]`) are qualified **independently**. Each architecture has its own gate pass/fail status and can be tagged/published independently once all mandatory gates pass for that architecture.

### 2.1 Current SBM 0.0.1 Scorecard (Independent Audit, 2026-11-27)

| Gate | Tier | `aarch64` (AAVMF) | `x86_64` (OVMF) | Verified Evidence vs. Remaining Gap |
|---|---|---|---|---|
| **0. Immutable per-arch reproducible build** | Tier 1/2 | **BLOCKED (B1–B3, V1–V2)** | **BLOCKED (B1–B3, V1–V2)** | `install@d2d2b3a` implements single-arch 3-part GPT, `release-manifest.v1.json` (populated `artifacts`+`media`), `build-receipt.json`, and `ProfilePreset` (76 tests green). **Gaps:** `install` still pins `sbm-common@b3c77141` (not `abe3029`), `media/0.0.1.lock.toml` pins stale `sbm-uefi@653012f` + `sbm-core@5031613`, `sbm-core` post-B1/B2 images are unbuilt, and compressed `check-reproducible.sh` has not been run on final committed inputs for either arch. |
| **1. Real UEFI menu & startup latency** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **FIXTURE PASS / REAL OPEN** | `sbm-uefi@66704ea` (merged, CI green; EFI sizes `230,912 B` / `261,632 B` `<< 1 MiB`) achieved **`15.73 ms` median** (`14.35–17.03 ms`, `N=10`, `< 250 ms`) on fresh ARM64 real media (`664a0b3`+`c2020c7`+`d2d2b3a`). `x86_64` has only `N=1` synthetic-fixture KVM (`64.77 ms`); needs `N >= 10` real-media KVM timing. `sbm-lab/integration.rs` does not yet assert `< 250 ms` (B4). |
| **2. Discovered targets** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **FIXTURE PASS / REAL OPEN** | ARM64 real-media picker displayed decoy OS (`Fedora Linux`) and recovery Slot A; `sbm-core@c2020c7` separates display-only `os:<partuuid>` from verified `BootTargetId`. Needs final-artifact qualification for both arches. |
| **3. Launch-time UKI verification & Spec 03 handoff** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **FIXTURE PASS / REAL OPEN** | Single-open 1 MiB streaming SHA-256 (`sha2` `opt-level=3`, `bytes_read == file_size`, `362.04 ms` median on 74.5 MiB ARM64 UKI), all 5 `BS\|RT` UTF-16 NUL volatile EFI vars, exact boot ESP UUID, UUIDv4 `attempt_id`, and empty load options verified in `sbm-uefi@66704ea` + `sbm-core@c2020c7` (ARM64 real + x86_64 KVM fixture). `sbm-lab/integration.rs` should assert `verify_done ... result=ok` (B4). |
| **4. Real Linux Core (`dm-verity` EROFS)** | Tier 2 | **FUNC PASS / B1 OPEN** | **OPEN (V1/V3)** | `sbm-core` is merged (`c2020c7` -> `a74ea48`, CI green) and ARM64 real media verified strict 5-var BLI handoff with decoy ESP first. **Blocker B1:** `sbm-smoke.service` is still enabled in production `00-sbm.preset:12` and must be removed before final Core rebuilds. `x86_64` Core `c2020c7`/post-B1 image not yet built or booted. |
| **5. Management UI (`sbm-ui`) & software fallback** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **OPEN (V1/V3)** | ARM64 single-arch HVF verified live daemon-backed `sbm-ui` and fsynced `boot-success.json` after `UiReady`. `ramfb`/`tiny-skia` software fallback verified in source and on prior `5031613` run; re-verify on final post-B1/B2 builds for both arches. |
| **6. GParted & virtual disks** | Tier 2 | **FUNC PASS / B2 OPEN** | **OPEN (V1/V3)** | ARM64 HVF verified GParted XWayland launch and 1 GiB + 2 GiB virtual disks. **Blocker B2:** `launch_gparted()` (`sbm-cored/src/lib.rs:488-498`) has a concurrent-instance RO clear race and failed-spawn RO leak; `integration.rs` should also hash virtual fixture disks before/after (B4). |
| **7. Return to menu & confirmation** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **OPEN (V1/V3)** | ARM64 HVF verified plain `Reboot` (no spurious `requested-command.json`), `RESET`, post-reboot picker (`23.324 ms`), strict UUIDv4 `attempt_id` confirmation (`consecutive_failures = 0`, no `"local"` wildcard), and `boot-success.json` deletion. `x86_64` not yet run on current commits. |
| **8. Offline operation** | Tier 2 | **FUNC PASS** *(re-run V3 on final)* | **OPEN (V3)** | Full ARM64 loop ran with zero NIC (`-nodefaults`, zero `-netdev`). Needs `x86_64` and final-artifact confirmation. |
| **9. CI, integrity, isolation & host resource hygiene** | Tier 1/2 | **PARTIAL (B1, B4)** | **PARTIAL (B1, B4)** | All 8 repos pass hosted CI on `origin/main` (`sbm-lab#3` fixed in `9c3c381`, run `45966525437`; `sbm-uefi` KVM + Secure Boot rejection pass in run `45967541247`; Track A `sbm-preview`/`sbm-sim` isolated & green). **Still open:** `B1` (`sbm-smoke.service` isolation), `B4` (remaining `sbm-lab#5` resource manager defects & `integration.rs` assertions). |
| **Neg. 1–4 Security & integrity negative gates** | Tier 2 | **PARTIAL (2/4)** | **OPEN (0/4 real)** | **ARM64:** Tampered UKI (`N=1`) & Decoy ESP (`N=1`) passed on `664a0b3`+`c2020c7`; **missing** corrupted `dm-verity` on current commits and Tier 2 invalid-handoff / stale `attempt_id` VM runs. **x86_64:** 0 real-media negative runs on current commits (only Tier 1 unit tests + KVM synthetic Secure Boot rejection). |
| **Exp. Dual-arch combined media** *(Optional / Non-Gating)* | Tier 2 | *Optional* | *Optional* | Preserved strictly as an optional experimental profile in `install@d2d2b3a` (`experimental: true`); NOT a release prerequisite and NOT a mandatory gate. |

**Primary Archived Evidence:**
- [Agent 15 UEFI launch, handoff, Secure Boot & ARM64 single-arch integration evidence](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-uefi-agent15-2026-11-27.md) ([JSON](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-uefi-agent15-2026-11-27.json))
- [Agent 13 prior dual-arch graphical recovery evidence (`5031613`/`653012f` baseline)](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/2026-11-26-graphical-recovery-integration.md)
- [Agent 18 Track A native simulator evidence](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-native-sim-2026-11-26.md)
- [Agent 16 Track B benchmarks & host resource audit](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-dev-resource-audit-2026-11-26.md)
- [Independent Wave 3 Release Readiness Audit](INTEGRATION_AUDIT.md)

### 2.2 Mandatory Positive Acceptance Per Architecture (Gates 0–9)

1. **Gate 0 — Immutable Per-Arch Provenance:** Built from clean committed revisions pinned to unified `sbm-common` (`abe3029` or newer merged `main`), emitting `sbm-0.0.1-uefi-<arch>.raw`, `.raw.zst`, `.sha256`, populated `release-manifest.v1.json` (`artifacts` + `media` per Spec 07), and `build-receipt.json` (`production_secure_boot_claimed: false`), verified byte-identical (with zstd compression enabled) via `check-reproducible.sh` and `sbm-install media verify`.
2. **Gate 1 — Real UEFI Menu & Startup Speed:** Native fallback binary boots on disposable QCOW2 overlay; `menu_ready < 250 ms` median across `N >= 10` runs on `aarch64` HVF and native `x86_64` KVM (TCG is functional-only, not a latency benchmark); QMP frame proves real non-blank graphical picker (never splash-only).
3. **Gate 2 — Discovered Targets:** Decoy/fixture OS target AND **Manage Computer** both appear in discovery and on the picker.
4. **Gate 3 — Launch-Time Verification & Spec 03 Handoff:** Activating **Manage Computer** streams the native UKI once from a single file handle (`bytes == size`), verifies SHA-256 fail-closed (`verify_done ... result=ok`), flushes UUIDv4 `last_attempt.json` & `current.json` on boot ESP only, publishes all 5 Spec 03 volatile EFI vars, and calls `LoadImage`/`StartImage` via exact device path with empty load options.
5. **Gate 4 — Real Linux Core:** Resolves boot ESP via BLI `LoaderDevicePartUUID` (rejecting decoy ESP enumerated first), verifies all 5 EFI vars + `current.json` SHA-256, mounts native `dm-verity` EROFS root (`/dev/mapper/root`), protects non-ESP partitions on backing recovery disk, and ships zero dev/smoke root hooks (`sbm-smoke.service` excluded).
6. **Gate 5 — Live Management UI & Software Fallback:** Real `labwc` + Iced `sbm-ui` renders live daemon-backed disk/handoff info (including `ramfb`/`tiny-skia` software fallback when DRM render node is absent or `wgpu` fails) and writes fsynced `boot-success.json` (`sbm-core-uki`, exact `attempt_id`).
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
