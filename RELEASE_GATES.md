# Smart Boot Menu — Release Gates (SBM 0.0.1, 0.0.2 & 0.0.3)

**Current Status (2026-11-26):**
- **SBM 0.0.1 (`aarch64`):** **OPEN — UNQUALIFIED.** Core graphical recovery loop passed locally in Agent 13's unmerged runs (9/9 gates), but mandatory UEFI latency (`< 250 ms`), Spec 03 volatile EFI vars, per-arch manifest/reproducibility, and merged green CI gates remain open.
- **SBM 0.0.1 (`x86_64`):** **OPEN — UNQUALIFIED.** Same remaining UEFI/manifest/merge gates plus native `x86_64` per-arch artifact assembly and CI verification.
- **Dual-architecture combined media (`dualarch`):** **OPTIONAL EXPERIMENTAL PROFILE** — preserved for specialized operator use; **NOT** a recommended distribution and **NOT** a mandatory release gate for 0.0.1 or later milestones (per [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)).
- **SBM 0.0.2 & SBM 0.0.3:** **PLANNED / OPEN.**

> **Honest Qualification Rule:** Do NOT declare any release or architecture qualified until every mandatory Tier 1 and Tier 2 gate below passes from **merged, immutable committed source revisions** with archived machine-readable evidence and green hosted CI. **Tier 1 simulated previews (Track A) NEVER substitute for Tier 2 disposable VM qualification.**

---

## 1. Three Mandatory Testing Tiers (Applies to All Releases)

- **Distribution classification (ADR-009 amendment, pending Agent 11 review):** Architecture-specific distributions (`x86_64` and generic `aarch64`) are **recommended** for users and CI; the universal dual-architecture image (`sbm-0.0.1-uefi-dualarch.raw[.zst]`) is preserved as **experimental and optional**; Apple Silicon (`sbm-as`) is a separate experimental track; local development builds MUST default to native architecture only.
Per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md) and [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), every release gate explicitly states its testing tier:

- **Tier 1 (Simulated / Native Host):** Unit tests, property tests, regular-file `sbm-plan`/`sbm-exec` simulations, and Track A native interactive previews (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`). Fast PR/dev feedback; never touches block devices or counts as firmware/kernel qualification.
- **Tier 2 (Disposable VM Disk — `sbm-lab` / Linux CI):** Real UEFI firmware (OVMF/AAVMF), real Linux kernel + CLI storage tools, and disposable copy-on-write QCOW2 disk/NVRAM overlays. **Mandatory automated qualification authority for 0.0.1, 0.0.2, and 0.0.3.**
- **Tier 3 (Explicitly Authorized Physical Hardware):** Strictly opt-in manual validation on dedicated non-workstation hardware (e.g., `EXP-HW-HP01`). Never automated on developer workstations; required only before marking a physical device *Verified* on the public compatibility matrix.

---

## 2. SBM 0.0.1 Gates — Independently Qualified Architecture-Specific Recovery Media

`x86_64` (`sbm-0.0.1-uefi-x86_64.raw[.zst]`) and `aarch64` (`sbm-0.0.1-uefi-aarch64.raw[.zst]`) are qualified **independently**. Each architecture has its own gate pass/fail status and can be tagged/published independently once all mandatory gates pass for that architecture.

### 2.1 Current SBM 0.0.1 Scorecard (2026-11-26)

| Gate | Tier | `aarch64` (AAVMF) | `x86_64` (OVMF) | Current Evidence & Blocking Gap |
|---|---|---|---|---|
| **0. Immutable per-arch reproducible build** | Tier 1/2 | **OPEN** | **OPEN** | Agent 13 proved reproducible *dual-arch* build locally (`5031613`, unmerged), but `install` still needs per-arch primary media profiles (`sbm-0.0.1-uefi-<arch>.raw[.zst]`), populated `ReleaseManifest.artifacts`, `release-manifest.v1.json`, and merged immutable revisions across `sbm-uefi`/`sbm-core`/`install`. |
| **1. Real UEFI menu & startup latency** | Tier 2 | **FAIL** (1,083 ms HVF) | **FAIL** (16.0 s TCG) | `sbm-uefi` (`653012f`) still hashes UKI at discovery time. Must implement lightweight startup check + launch-time single-open streaming SHA-256 (`sha2` `opt-level = 3`) so `menu_ready < 250 ms` on `aarch64` HVF (and native KVM on `x86_64` CI). |
| **2. Discovered targets** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Agent 13's local `sbm-lab` integration run showed both decoy OS fixture and recovery entry; needs merged `sbm-lab#2` + **Manage Computer** label per Spec 03. |
| **3. Manage Computer & Spec 03 handoff** | Tier 2 | **PARTIAL** | **PARTIAL** | `sbm-uefi` still passes legacy cmdline load options instead of publishing all 5 Spec 03 volatile EFI variables with empty load options, UUIDv4 `attempt_id`, and fail-closed launch-time streaming SHA-256. |
| **4. Real Linux Core (`dm-verity` EROFS)** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Agent 13 (`sbm-core` `5031613`, unmerged) fixed `/efi`, `resolve_disk()`, ESP protection, and strict BLI/EFI-var handoff. Needs merge with Agent 16's `098921f` and clean CI build. |
| **5. Management UI (`sbm-ui`)** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Agent 13 fixed `systemd-pam`, `/run/sbm`, `sbm-ui` `tiny-skia` fallback, and `SBM_UI_READY` + `boot-success.json` (`aarch64` HVF, `x86_64` TCG, `ramfb` software). Needs merge & re-run on final per-arch media. |
| **6. GParted & virtual disks** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Agent 13 fixed XWayland `xhost` refresh and captured QMP frames showing 1 GiB + 2 GiB fixture disks in GParted. Needs merge & re-run on final per-arch media. |
| **7. Return to menu & confirmation** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Agent 13 verified clean QMP `RESET`, menu reboot, `status=confirmed`, `consecutive_failures=0`, `boot-success.json` consumed. Needs `sbm-uefi#1` strict `attempt_id` check (no `"local"` wildcard) and merge. |
| **8. Offline operation** | Tier 2 | **LOCAL PASS** *(unmerged)* | **LOCAL PASS** *(unmerged)* | Zero NIC attached across full loop; re-verify on final merged per-arch images. |
| **9. CI, integrity & host resource hygiene** | Tier 1/2 | **OPEN** | **OPEN** | `sbm-lab#5` shared resource manager fixes, `sbm-core` merge (`5031613` + `098921f`), `sbm-lab` `integration.rs` push, and green hosted CI across `sbm-common`, `docs`, `sbm-uefi`, `sbm-core`, `sbm-lab`, and `install` still pending. |
| **Exp. Dual-arch combined media** *(Optional / Non-Gating)* | Tier 2 | *Optional* | *Optional* | Preserved as an optional experimental profile in `install`; passing or skipping this profile does NOT block 0.0.1 qualification of `x86_64` or `aarch64`. |

### 2.2 Mandatory Positive Acceptance Per Architecture (Gates 0–9)

1. **Gate 0 — Immutable Per-Arch Provenance:** Built from clean committed revisions pinned to unified `sbm-common` (`b3c77141` or newer merged `main`), emitting `sbm-0.0.1-uefi-<arch>.raw`, `.raw.zst`, `.sha256`, populated `release-manifest.v1.json` (`artifacts` + `media` per Spec 07), and `build-receipt.json`, verified byte-identical via `check-reproducible.sh` and `sbm-install media verify`.
2. **Gate 1 — Real UEFI Menu & Startup Speed:** Native fallback binary boots on disposable QCOW2 overlay; `menu_ready < 250 ms` on `aarch64` HVF (and native KVM on `x86_64` CI); QMP frame proves real graphical picker (never splash-only).
3. **Gate 2 — Discovered Targets:** Decoy/fixture OS target AND **Manage Computer** both appear in discovery and on the picker.
4. **Gate 3 — Launch-Time Verification & Spec 03 Handoff:** Activating **Manage Computer** streams the native UKI once from a single file handle (`bytes == size`), verifies SHA-256 fail-closed, flushes UUIDv4 `last_attempt.json` & `current.json` on boot ESP only, publishes all 5 Spec 03 volatile EFI vars, and calls `LoadImage`/`StartImage` via exact device path with empty load options.
5. **Gate 4 — Real Linux Core:** Resolves boot ESP via BLI `LoaderDevicePartUUID` (rejecting decoy ESP enumerated first), verifies all 5 EFI vars + `current.json` SHA-256, mounts native `dm-verity` EROFS root, and protects non-ESP partitions on backing recovery disk.
6. **Gate 5 — Live Management UI:** Real `labwc` + Iced `sbm-ui` renders live daemon-backed disk/handoff info (including software fallback when DRM render node is absent or `wgpu` fails) and writes fsynced `boot-success.json` (`sbm-core-uki`, exact `attempt_id`).
7. **Gate 6 — GParted & Virtual Disks:** Real GParted launches via XWayland and its device selector displays both 1 GiB and 2 GiB virtual fixture disks without mutating them.
8. **Gate 7 — Return to Menu & Confirmation:** Core's Reboot control performs a plain guest reboot (no `requested-command.json`), firmware boots the same menu, and UEFI confirms the exact prior attempt (`status: confirmed`, `consecutive_failures: 0`, deletes `boot-success.json`).
9. **Gate 8 — Offline:** Complete Gates 1–7 loop finishes with zero virtual NIC, account, or `sbm-server`.
10. **Gate 9 — CI & Integrity:** All hosted CI jobs pass across all participating repos; original `.raw` image bytes, firmware templates, fixture bases, and GPT metadata remain byte-identical before and after runs.

### 2.3 Mandatory Negative Acceptance Per Architecture (Tier 2)

1. **Tampered UKI:** 1-byte flip in native UKI -> UEFI refuses launch fail-closed before `StartImage` and returns to usable picker.
2. **Corrupted `dm-verity`:** Corrupted verity hash/data block -> Linux never reaches `SBM_UI_READY` or writes `boot-success.json`.
3. **Invalid Handoff / Stale Confirmation:** Mismatched `SbmHandoffSha256` -> Core declines `boot-success.json`; stale `attempt_id` or `"local"` -> UEFI refuses confirmation.
4. **Decoy ESP Priority:** Decoy ESP enumerated before boot ESP -> zero mutations on decoy ESP.

---

## 3. SBM 0.0.2 Gates — Persistent Internal SSD Installation, Uninstall & Recovery

Qualified per architecture (`x86_64`, `aarch64`) against **Spec 04 §11a** and **ADR-011**.

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.2-1. Planner & Safety Guards** | Tier 1 | `sbm-plan`/`sbm-exec` unit & property tests verify: `sbm-common#2` partition GUID/attribute round-trip, available-space-only enforcement (refuses shrink in 0.0.2), `ProtectedAppleSystem` hard-block, MBR rejection, BitLocker recovery-key warning gate, `DiskIdentity` & `expected_partition_table_sha256` mismatch abort, and rollback on simulated fault. |
| **0.2-2. Native UI Flow Preview** | Tier 1 | Track A native preview exercises **Install SBM**, dry-run diff review, confirmation, uninstall, and boot-repair screens in Iced `sbm-ui` with zero crashes. *(Does not satisfy Tier 2.)* |
| **0.2-3. Internal SSD Install Alongside Existing OS** | Tier 2 | Boot SBM USB on a disposable multi-OS QCOW2 disk fixture (existing Windows-style ESP + Linux BLS ESP + >= 2 GiB unallocated GPT tail space); run **Install SBM** via `sbm-ui`/`sbm-cored`; verify `\EFI\Microsoft\` and existing Linux loaders are byte-identical, native `root-<arch>` + `root-<arch>-verity` partitions created with exact DPS GUIDs/PARTUUIDs, `\EFI\sbm\install-receipt.json` written, and `efibootmgr` entry registered first in `BootOrder`. |
| **0.2-4. Reboot Into Internal SSD SBM & Chainload** | Tier 2 | Detach USB medium; reboot VM; verify firmware boots internal SSD `\EFI\sbm\sbm-<arch>.efi`, discovers existing OS fixture(s), chainloads existing OS cleanly, and boots internal **Manage Computer** (`sbm-core` `dm-verity` EROFS) -> Reboot -> confirmation. |
| **0.2-5. Clean Uninstall** | Tier 2 | Run **Uninstall SBM** from internal or USB Core; verify prior `BootOrder` is restored, SBM NVRAM entry deleted, `\EFI\sbm\` removed, SBM-created recovery PARTUUIDs optionally removed, existing OS ESP/partitions untouched, and VM boots prior OS directly. |
| **0.2-6. Boot Registration Recovery** | Tier 2 | Simulate Windows Update overwriting `BootOrder` to place Windows first; boot SBM USB -> run **Repair SBM Boot Registration**; verify zero partition changes and VM boots internal SSD SBM again on next reboot. |
| **0.2-7. Negative & Fault Injection** | Tier 2 | Insufficient unallocated space -> clean refusal with zero writes; Apple APFS fixture -> hard-blocked; disk changed between plan & exec -> optimistic hash-lock abort; power-cut before `efibootmgr` -> existing OS still boots cleanly. |
| **0.2-8. Physical Hardware (Opt-In Only)** | Tier 3 | *Optional for 0.0.2 beta; required before marking any physical device "Verified".* Explicitly human-authorized run on dedicated test machine (`EXP-HW-HP01`) with archived receipt. |

---

## 4. SBM 0.0.3 Gates — Cross-Platform Media Creator & Guided Partition Resizing

Qualified against **Spec 04 §11b**, **ADR-011**, and [`research/ecosystem/media-creator-evaluation.md`](../research/ecosystem/media-creator-evaluation.md).

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.3-1. Media Creator Reuse Decision & Verification** | Tier 1/2 | Documented empirical evaluation of minimal `rpi-imager` Apache-2.0 branded build vs custom alternative completed; Media Creator fetches verified per-arch manifest, filters out internal system drives, verifies download/extract SHA-256, performs read-back verification, supports offline local `.raw`/`.raw.zst` files, and flashes a bootable image verified in Tier 2 QEMU. |
| **0.3-2. Resize Planner & Allowlist Guards** | Tier 1 | Unit/property tests prove allowlist enforcement (`ext4`, clean non-hibernated `NTFS`, single-device `Btrfs`), SI/IEC safety-margin math, and hard refusal of BitLocker, LUKS, LVM/RAID/ZFS/XFS, dirty/hibernated NTFS, Apple APFS, and MBR disks. |
| **0.3-3. Guided Resize + Internal Install (Populated OS Fixtures)** | Tier 2 | On disposable populated QCOW2 disks with **zero unallocated space** (one `ext4` Linux fixture, one clean `NTFS` fixture, one single-device `Btrfs` fixture): inspect -> shrink via Golden Rule sequence -> install SBM -> detach USB -> reboot into internal SSD SBM -> verify pre-existing sentinel files inside the shrunk filesystem pass `fsck`/SHA-256 verification and existing OS still boots. |
| **0.3-4. Resize Negative Gates** | Tier 2 | BitLocker fixture, LUKS fixture, hibernated/dirty NTFS fixture, and XFS fixture are hard-blocked before any disk write with actionable remediation messages and byte-identical disk hashes before/after. |
| **0.3-5. End-to-End Consumer Journey** | Tier 2 (+ opt-in Tier 3) | Full documented walkthrough verified end-to-end: `Media Creator -> flash image -> boot target -> Install SBM -> inspect & resize -> confirm -> install -> reboot into internal SSD SBM`. |

---

## 5. Separate Post-0.0.3 Gates (SBM 0.1 / 0.2)

- **Enrolled-key Secure Boot (`sbm-lab#4`):** `SecureBoot=1`, `SetupMode=0` in disposable OVMF VARS, signed menu -> signed Core boot, untrusted UKI rejected without masking `SECURITY_VIOLATION`, external load options cannot override signed `.cmdline`.
- **Signed Distribution Trust (Spec 07):** TUF + Sigstore/Cosign verification before public trust claims.
- **OS Catalog, Remote Management & Apple Silicon Physical Boot:** Tracked in [ROADMAP.md](ROADMAP.md) under SBM 0.1 and SBM 0.2.
