# Smart Boot Menu — Release Gates (SBM 0.0.1, 0.0.2, 0.0.3 & 0.1)

**Current Status (2026-11-27)**
- **SBM 0.0.1 (`aarch64`) — OPEN / UNQUALIFIED.** The rebuilt offline recovery image passed all nine local graphical integration checks. Ten real-media HVF runs reached menu readiness in 15.7 ms median. Per-architecture reproducibility, remaining negative checks, and independent qualification remain open.
- **SBM 0.0.1 (`x86_64`) — OPEN / UNQUALIFIED.** Native KVM firmware smoke and Secure Boot rejection passed with fixtures. Final real-media timing, graphical integration, reproducibility, and independent qualification remain open.
- **Dual-architecture combined media (`dualarch`):** **OPTIONAL EXPERIMENTAL PROFILE** — preserved for specialized operator use; **NOT** a recommended distribution and **NOT** a mandatory release gate for 0.0.1 or later milestones (per [ADR-009](../docs/architecture-decisions/ADR-009-dual-architecture-offline-preview-media.md)).
- **SBM 0.0.2, SBM 0.0.3 & SBM 0.1:** **PLANNED / OPEN.**

> **Honest Qualification Rule:** Do NOT declare any release or architecture qualified until every mandatory Tier 1 and Tier 2 gate below passes from **merged, immutable committed source revisions** with archived machine-readable evidence and green hosted CI. **Tier 1 simulated previews (Track A) NEVER substitute for Tier 2 disposable VM qualification**, and **aspirational engineering targets MUST always be distinguished from measured results**.

---

## 1. Three Mandatory Testing Tiers (Applies to All Releases)

Per [`docs/testing/benchmarks.md`](../docs/testing/benchmarks.md), [ADR-011](../docs/architecture-decisions/ADR-011-native-preview-internal-install-and-media-creator.md), and [ADR-012](../docs/architecture-decisions/ADR-012-profiles-network-recovery-modularity-and-ux.md), every release gate explicitly states its testing tier:

- **Tier 1 (Simulated / Native Host):** Unit tests, property tests, regular-file `sbm-plan`/`sbm-exec` simulations, and Track A native interactive previews (`sbm-gfx`/`sbm-boot` + Iced `sbm-ui`, primary UX studio). Fast PR/dev feedback; never touches block devices or counts as firmware/kernel qualification.
- **Tier 2 (Disposable VM Disk — `sbm-lab` / Linux CI):** Real UEFI firmware (OVMF/AAVMF), real Linux kernel + CLI storage tools, and disposable copy-on-write QCOW2 disk/NVRAM overlays. **Mandatory automated qualification authority for 0.0.1, 0.0.2, 0.0.3, and 0.1.**
- **Tier 3 (Explicitly Authorized Physical Hardware):** Strictly opt-in manual validation on dedicated non-workstation hardware (e.g., `EXP-HW-HP01`). Never automated on developer workstations; required only before marking a physical device *Verified* on the public compatibility matrix.

---

## 2. SBM 0.0.1 Gates — Independently Qualified Architecture-Specific Recovery Media

`x86_64` (`sbm-0.0.1-uefi-x86_64.raw[.zst]`) and `aarch64` (`sbm-0.0.1-uefi-aarch64.raw[.zst]`) are qualified **independently**. Each architecture has its own gate pass/fail status and can be tagged/published independently once all mandatory gates pass for that architecture.

### 2.1 Current SBM 0.0.1 Scorecard (2026-11-27)

| Gate | Tier | `aarch64` (AAVMF) | `x86_64` (OVMF) | Current Evidence & Blocking Gap |
|---|---|---|---|---|
| **0. Immutable per-arch reproducible build** | Tier 1/2 | **OPEN** | **OPEN** | ARM64 clean build and verified single-architecture assembly passed. Repeat-build byte identity and final media outputs remain open. |
| **1. Real UEFI menu & startup latency** | Tier 2 | **LOCAL PASS** | **FIXTURE PASS** | ARM64 real media reached menu-ready in 15.7 ms median and 17.027 ms maximum across ten HVF runs. x86-64 real-media KVM timing remains open. |
| **2. Discovered targets** | Tier 2 | **LOCAL PASS** | **FIXTURE PASS** | The ARM64 graphical picker showed the decoy OS and recovery Slot A. Current target IDs flow from UEFI discovery to Core. |
| **3. Manage Computer & Spec 03 handoff** | Tier 2 | **LOCAL PASS** | **FIXTURE PASS** | Both firmware fixtures checked all five volatile variables, the exact boot ESP UUID, UUIDv4 attempt, flushed files, and empty external recovery load options. The 74,513,752-byte ARM64 UKI passed full launch-time verification. |
| **4. Real Linux Core (`dm-verity` EROFS)** | Tier 2 | **LOCAL PASS** | **OPEN** | Rebuilt ARM64 Core verified the integrated handoff on the actual backing disk, with the decoy ESP first. |
| **5. Management UI (`sbm-ui`)** | Tier 2 | **LOCAL PASS** | **OPEN** | Rebuilt ARM64 Core showed the daemon-backed UI and wrote the boot-success report after the live snapshot. |
| **6. GParted & virtual disks** | Tier 2 | **LOCAL PASS** | **OPEN** | ARM64 GParted opened and showed both fixture disks in its device selector. |
| **7. Return to menu & confirmation** | Tier 2 | **LOCAL PASS** | **OPEN** | The ARM64 graphical reboot returned to the picker, confirmed the matching attempt, reset its failure count, and consumed the success report. |
| **8. Offline operation** | Tier 2 | **LOCAL PASS** | **OPEN** | The rebuilt ARM64 image completed the full loop in a guest with no attached NICs. |
| **9. CI, integrity & host resource hygiene** | Tier 1/2 | **LOCAL PASS** | **FIXTURE PASS** | Hosted CI passed for the coordinated source revisions. ARM64 base images and the decoy ESP remained unchanged. Native x86-64 OVMF refused the unsigned recovery fixture under enrolled Secure Boot. |
| **Exp. Dual-arch combined media** *(Optional / Non-Gating)* | Tier 2 | *Optional* | *Optional* | Preserved as an optional experimental profile in `install`; passing or skipping this profile does NOT block 0.0.1 qualification of `x86_64` or `aarch64`. |

[Agent 15 evidence and machine-readable measurements](https://github.com/smart-boot-menu/research/blob/main/validation/evidence/sbm-uefi-agent15-2026-11-27.md)

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

Agent 15 observed ARM64 recovery refusal on a real-media copy after a one-byte UKI change and verified zero mutations on the decoy ESP. Native tests cover invalid handoffs and stale confirmations. The remaining negative cases still require independent disposable-VM qualification on the final per-architecture media.

1. **Tampered UKI:** 1-byte flip in native UKI -> UEFI refuses launch fail-closed before `StartImage` and returns to usable picker.
2. **Corrupted `dm-verity`:** Corrupted verity hash/data block -> Linux never reaches `SBM_UI_READY` or writes `boot-success.json`.
3. **Invalid Handoff / Stale Confirmation:** Mismatched `SbmHandoffSha256` -> Core declines `boot-success.json`; stale `attempt_id` or `"local"` -> UEFI refuses confirmation.
4. **Decoy ESP Priority:** Decoy ESP enumerated before boot ESP -> zero mutations on decoy ESP.

---

## 3. SBM 0.0.2 Gates — Persistent Internal SSD Installation, `efi-only` Profile, Uninstall & Recovery

Qualified per architecture (`x86_64`, `aarch64`) against **Spec 03 §9a**, **Spec 04 §11a**, **ADR-011**, and **ADR-012**.

| Gate | Tier | Mandatory Acceptance Criteria |
|---|---|---|
| **0.2-1. Planner & Safety Guards** | Tier 1 | `sbm-plan`/`sbm-exec` unit & property tests verify: `sbm-common#2` partition GUID/attribute round-trip, available-space-only enforcement (refuses shrink in 0.0.2), `ProtectedAppleSystem` hard-block, MBR rejection, BitLocker recovery-key warning gate, `DiskIdentity` & `expected_partition_table_sha256` mismatch abort, and rollback on simulated fault. |
| **0.2-2. Native UI Flow Preview** | Tier 1 | Track A native preview exercises **Install SBM** (`efi-only` and `offline-full`), dry-run diff review, confirmation, uninstall, and boot-repair screens in Iced `sbm-ui` with zero crashes. *(Does not satisfy Tier 2.)* |
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

## 6. SBM 0.2 Gates — Apple Silicon, Enrolled-Key Secure Boot & Public Portal

- **Enrolled-key Secure Boot (`sbm-lab#4`):** `SecureBoot=1`, `SetupMode=0` in disposable OVMF VARS, signed menu -> signed Core boot, untrusted UKI rejected without masking `SECURITY_VIOLATION`, external load options cannot override signed `.cmdline`.
- **Signed Distribution Trust (Spec 07):** TUF + Sigstore/Cosign verification before public trust claims.
- **Apple Silicon Physical Boot (`sbm-as`) & Public Portal (`smart-boot-menu.github.io`):** Tracked in [ROADMAP.md](ROADMAP.md) under SBM 0.2.
