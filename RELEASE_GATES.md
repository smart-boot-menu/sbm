# SBM 0.0.1 release gates

**Status** Open. The acceptance target is one offline dual-architecture image. A released candidate must have the same raw SHA-256 in both required lanes.

## Inputs and execution

- Build Core, the menu and the USB image from recorded immutable revisions. Check the artifact manifest against the final bytes and archive the assembly receipt. Boot a QCOW2 overlay of the same raw image as removable USB storage. Use fresh copies of OVMF/AAVMF variable templates and give the release medium firmware boot priority.
- Use x86_64 q35/OVMF and AArch64 virt/AAVMF with graphical output, QMP, serial logging, no virtual NIC, and no synthetic probe or direct kernel boot. Pin runner, CPU and accelerator, QEMU/firmware versions and hashes, disk topology, and display resolution in each run. Attach a decoy ESP with a recognizable target and two inspectable virtual disks of distinct known capacities, 1 GiB and 2 GiB. The decoy ESP can occupy one of those disks.
- Run `cargo test --locked --workspace` and the repository CI checks where applicable. Required lab commands are `sbm-lab test --tier smoke` and `sbm-lab test --tier integration --image PATH`. The integration command is the required owner deliverable in [the Lab issue](https://github.com/smart-boot-menu/sbm-lab/issues/2). Missing required assertions fail CI.

## Positive scenario

| Gate | Automated acceptance | Evidence |
|---|---|---|
| 1. Real UEFI menu | Firmware loads the correct fallback binary; the candidate build ID and menu-ready event appear. | Firmware path and build ID in serial, QMP frame of the real graphical picker. |
| 2. Discovered targets | The expected fixture label and path appear in discovery and the picker. | Discovery output and frame with the expected target label. |
| 3. Manage Computer | QMP activates the visible control; UEFI selects the native manifest UKI and persists a fresh started attempt. | Input trace, selection event, UKI path, target and attempt ID. |
| 4. Real Linux Core | Core verifies the ESP UUID, matching attempt ID and handoff digest. The running root is the native dm-verity EROFS pair from the build receipt. | Effective command line, mapper and root source, partition UUIDs and handoff result. |
| 5. Management UI | The real Iced window presents daemon-backed data, and the daemon successfully writes the matching success report. | QMP frame showing populated UI, readiness event, and report after flush. |
| 6. GParted and disks | QMP presses the GParted button. The real GParted device selector shows both expected fixture identifiers and capacities. | Window and opened selector frames, with machine-checked labels and sizes, plus input trace. No Apply operation occurs. |
| 7. Return to the menu | QMP uses Core's Reboot control and confirms it. QEMU stays alive, reports the guest reset, and the same menu returns and confirms the previous attempt. | Reset event, second menu-ready event, final state with matching ID, confirmed status and zero failures. |
| 8. Offline | The entire sequence completes with no virtual NIC, account, or server. | Resolved launch arguments and completed structured assertions for each stage. |
| 9. CI and integrity | Linux Core checks, both Lab smoke architectures and both full-system lanes pass. Original image bytes, firmware templates, fixture bases, protective MBR and GPT metadata remain unchanged. | Required job links, immutable input hashes and before/after structural checks. |

## Negative acceptance and evidence retention

- Damage the native UKI on a disposable copy while preserving its manifest digest. Assert the picker refuses recovery before StartImage and remains usable.
- Break the native verity hash partition or corrupt a boot-critical data block on a disposable copy. Assert the expected verity-backed root never reports desktop success.
- Seed a mismatched handoff digest in the firmware-to-Core test path and a stale success report in a separate run. Assert Core declines confirmation and UEFI never accepts the stale ID.
- Enumerate the decoy ESP before the real one. Assert the handoff resolves to the boot ESP and the decoy receives no state changes.
- Upload the machine-readable run report, logs, QMP event and input trace, stage frames, state files, and hashes for both successes and failures. Keep reusable evidence summaries in the research repository. A compositor start marker, a generated screenshot, or a probe result cannot stand in for the required UI evidence.

## Separate gates

Enrolled-key Secure Boot requires SecureBoot=1 and SetupMode=0 in a disposable OVMF VARS image, signed menu-to-Core boot, rejection of an untrusted replacement UKI even when its recovery digest matches, and evidence that external arguments cannot override the signed .cmdline. The beta offline gate uses ordinary firmware boot. Public trust claims require the signed-distribution metadata and verification path from Spec 07. [Secure Boot experiment](https://github.com/smart-boot-menu/sbm-lab/issues/4)
