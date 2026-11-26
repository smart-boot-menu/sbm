# SBM 0.0.1 release gates

**Status:** **OPEN — SBM 0.0.1 IS UNQUALIFIED (Wave 2 Audit, 2026-11-26).** Do not declare the release complete or tag 0.0.1 until every mandatory gate below passes with archived evidence on the exact same raw image SHA-256 across both architectures.

## 1. Current gate scorecard (Wave 2)

| Gate | `aarch64` (AAVMF) | `x86_64` (OVMF) | Blocking evidence gap |
|---|---|---|---|
| **0. Immutable reproducible build** | FAIL | FAIL | Candidate Core images built from `0a49e45` + uncommitted edits (predating `c7e9439`); `release-manifest.json` has `artifacts: []` and wrong filename; `build-receipt.json` from `3037bbc`. |
| **1. Real UEFI menu & startup latency** | PARTIAL (1,748 ms) | FAIL (16.96–31.69 s; splash-only PNG) | 117×–211× regression from eager dual-arch hashing + $O(N^2)$ FAT32 reopen/seek. Must restore `< 250 ms` HVF while keeping fail-closed launch-time streaming SHA-256. |
| **2. Discovered targets** | PARTIAL (`SBM Core Slot A` only) | UNVERIFIED (no decoy ESP fixture) | Must display both discovered decoy/OS fixture target and **Manage Computer** control on the picker. |
| **3. Manage Computer & Spec 03 handoff** | PARTIAL (legacy cmdline only) | PARTIAL (legacy cmdline only) | Must verify native UKI digest at launch (fail-closed), flush UUIDv4 `last_attempt.json` & `current.json` on boot ESP only, publish all 5 volatile EFI vars, and launch without external load options. |
| **4. Real Linux Core (dm-verity EROFS)** | PASS (kernel/verity/cored) | PARTIAL (serial reached login; `x86_64-run.json` 0 B) | Missing BLI PARTUUID ESP validation, `resolve_disk()` RO protection (`unchanged`), and clean `x86_64` JSON report. |
| **5. Management UI (`sbm-ui`)** | **FAIL** (`status=217/USER`) | **FAIL** (`status=217/USER`) | `labwc` never started due to missing `sbm` GID 1000, `/boot` vs `/efi` mount, `/dev/kmsg` EACCES, and missing software-renderer auto-selection. Zero UI screenshots or `boot-success.json` confirmations exist. |
| **6. GParted & virtual disks** | **FAIL** (not reached) | **FAIL** (not reached) | Never executed; requires `SBM_UI_READY`, `labwc_environ()` fix, and QMP frames showing both 1 GiB and 2 GiB virtual disks in GParted. |
| **7. Return to menu & confirmation** | **FAIL** (not reached) | **FAIL** (not reached) | `sbm-lab` passes `-no-reboot`; `sbm-cored` triggers double reboot via `requested-command.json`; `sbm-uefi` still allows `"local"` wildcard confirmation. |
| **8. Offline operation** | PASS (no NIC attached) | PASS (no NIC attached) | Must be re-verified across the complete Gates 1–7 loop. |
| **9. CI, integrity & host resource hygiene** | **FAIL** (`sbm-uefi` & `sbm-lab` CI red) | **FAIL** (`sbm-uefi` & `sbm-lab` CI red) | `sbm-uefi` `cargo fmt` fail (`45900855497`); `sbm-lab` `smoke`/`product`/`secure` fail (`45900849263`); `sbm-lab#5` resource-manager defects break sibling VM launchers. |

## 2. Inputs and execution rules

- **Immutable source provenance:** Build `sbm-uefi`, `sbm-core` (both arches), and the dual-arch image from clean, committed, tagged/recorded revisions pinned to unified `sbm-common` `b3c77141504be71bfad6602d8df628f84f704c7b` with zero uncommitted local edits. Populate `ReleaseManifest` 1.1 `artifacts` (both menus + both UKIs) and `media` (`.raw` + `.raw.zst`) in `release-manifest.v1.json`, verify `sbm-install media verify`, prove byte-identical assembly via `check-reproducible.sh` on `media/0.0.1.lock.toml`, and archive `build-receipt.json` with exact builder package lists and commands.
- **VM execution topology:** Boot a disposable QCOW2 overlay of the exact same unchanged raw image as removable USB storage on `x86_64` `q35`/OVMF and `AArch64` `virt`/AAVMF with graphical output (`virtio-vga` / `virtio-gpu-pci`), QMP, serial logging, no virtual NIC, no `-no-reboot`, and no synthetic probe or direct kernel boot. Use fresh copies of OVMF/AAVMF variable templates and attach a decoy ESP (enumerated before the boot ESP) plus two virtual disks of distinct known capacities (1 GiB and 2 GiB).
- **Host resource safety:** On the 16 GiB macOS host, all VM launchers must reserve through the fixed shared host resource manager (`sbm-lab#5`), run heavy/graphical guests sequentially, and never pass physical host disks (`/dev/*`) to QEMU or the installer.
- **Required automated commands:** `cargo fmt --all -- --check`, `cargo clippy --all-targets -- -D warnings`, `cargo test --locked --workspace` in every repo, plus `sbm-lab test --tier smoke`, `sbm-lab test --tier product`, `sbm-lab test --tier secure`, and `sbm-lab test --tier integration --image PATH` (`sbm-lab#2`). Missing required assertions or skipped Core scenarios fail qualification.

## 3. Mandatory positive scenario (Gates 1–9)

| Gate | Automated acceptance | Required evidence |
|---|---|---|
| 1. Real UEFI menu & startup speed | Firmware loads the native fallback binary; build ID and `menu-ready` appear without eager full-file or foreign-arch hashing (`menu_ready < 250 ms` on `aarch64` HVF). | Firmware path, build ID, `first_frame` / `discovery_done` / `menu_ready` timestamps in serial, and QMP frame of the real graphical picker. |
| 2. Discovered targets | Expected decoy/fixture OS label and **Manage Computer** control both appear in discovery and on the picker. | Discovery output and QMP frame showing both the fixture target and **Manage Computer**. |
| 3. Manage Computer & launch-time verification | QMP activates **Manage Computer**; UEFI performs single-open sequential streaming SHA-256 verification of the native UKI, persists and flushes a fresh UUIDv4 `started` attempt and `current.json` on the boot ESP only, publishes all 5 Spec 03 volatile EFI vars, and invokes `LoadImage`/`StartImage` via exact device path with no external load options. | Input trace, verification timing & result, UKI path, attempt ID, and volatile var publication log. |
| 4. Real Linux Core | Core resolves the boot ESP via BLI `LoaderDevicePartUUID` (rejecting decoy ESP), validates all 5 EFI vars and `current.json` SHA-256, activates the native dm-verity EROFS pair from the build receipt, and protects the backing recovery disk (exempting the ESP). | Effective cmdline, mapper/root source, partition UUIDs, `sbm-protect` status, and handoff verification result. |
| 5. Management UI | Real `labwc` + Iced `sbm-ui` window renders live daemon-backed disk/handoff data; `sbm-cored` writes and fsyncs matching `boot-success.json` (`sbm-core-uki`, exact `attempt_id`) on the boot ESP. | Post-`SBM_UI_READY` QMP frame showing populated UI, readiness events, and flushed `boot-success.json` contents. |
| 6. GParted and disks | QMP activates the GParted button; real GParted opens and its device selector displays both expected 1 GiB and 2 GiB virtual fixture disks without executing any Apply operation. | GParted window and opened device-selector QMP frames, machine-checked disk labels/sizes, and input trace. |
| 7. Return to menu & confirmation | QMP activates Core's Reboot control (plain guest reboot, no `requested-command.json`); QEMU stays alive, reports guest reset, boots the same UEFI menu, and confirms the prior attempt (`status: confirmed`, `consecutive_failures: 0`, deletes `boot-success.json`). | QMP reset event, second `menu-ready` event, post-reboot QMP frame, and final `last_attempt.json` state. |
| 8. Offline | Complete sequence finishes with no virtual NIC, account, or `sbm-server`. | Resolved QEMU argv and completed structured assertions for every stage. |
| 9. CI & integrity | All hosted CI jobs pass across `sbm-common`, `docs`, `sbm-uefi`, `sbm-core`, `sbm-lab` (`check`, `smoke`, `product`, `secure`), and `install`, plus both full-system integration lanes. Original `.raw` image bytes, firmware templates, fixture bases, and GPT metadata remain unchanged. | Hosted CI URLs, immutable input hashes, and before/after structural checks. |

## 4. Mandatory negative acceptance & evidence retention

1. **Tampered UKI:** Modify 1 byte of the native UKI on a disposable copy while preserving `manifest.json`; assert UEFI refuses launch at verification time before `StartImage` and returns cleanly to the usable picker (fail-closed; no `FromBuffer` fallback).
2. **Broken dm-verity:** Corrupt the native verity hash partition or a boot-critical data block on a disposable copy; assert the verity-backed root never reaches desktop success.
3. **Invalid handoff / stale confirmation:** Seed a mismatched `SbmHandoffSha256` (assert Core declines `boot-success.json` emission) and in a separate run seed a stale `attempt_id` or `"local"` report (assert UEFI refuses confirmation).
4. **Decoy ESP priority:** Enumerate the decoy ESP before the boot ESP; assert both UEFI and Core bind strictly to the boot ESP and the decoy receives zero state changes.
5. **Retention:** Archive machine-readable `result.json`, `serial.log`, `qemu.stderr`, QMP event/input trace, multi-stage QMP frames (never substituting an early splash frame, generated screenshot, or probe result), ESP state files, and SHA-256 digests for both passes and failures. Summarize qualified evidence in `research/validation/evidence/`.

## 5. Separate post-0.0.1 gates

Enrolled-key Secure Boot (`SecureBoot=1`, `SetupMode=0` in disposable OVMF VARS, signed menu -> signed Core boot, rejection of untrusted UKI even with matching manifest digest without masking `SECURITY_VIOLATION`, and verification that external load options cannot override signed `.cmdline`) remains tracked separately in [sbm-lab#4](https://github.com/smart-boot-menu/sbm-lab/issues/4). Public trust claims require signed TUF/Sigstore metadata per Spec 07.
