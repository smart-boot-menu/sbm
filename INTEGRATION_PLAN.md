# SBM 0.0.1 integration plan

Deliver one offline USB image qualified on x86_64 OVMF and AArch64 AAVMF. The candidate boots the real Rust menu, discovers boot targets, launches Core through **Manage Computer**, renders the management UI, opens GParted with virtual disks visible, and reboots into the same menu. Both CI lanes use identical image bytes. Enrolled-key Secure Boot runs separately.

## Dependencies and compatibility

| Producer or consumer | Audited source | Current binding | 0.0.1 compatibility requirement |
|---|---|---|---|
| sbm-common | 28d38450954f0b93815e12f31da92370b13a7462 | Rust crate family 0.1.0, protocol 1.0 | Candidate revision `57e9b3d4858ed89247cffd6cfe79039d9c1526ef` introduces ReleaseManifest 1.1 media. Use the exact final merged revision in the receipt. |
| sbm-uefi | 52657522ac734c2aec064130f0a91fcbe79b8b51 | Git revision of sbm-types and sbm-protocol, default features off | Update both pins and Cargo.lock together. Produce native PE images for each fallback path. Consume RecoveryManifest and EfiHandoffPayload 1.0. |
| sbm-core | 7f389cb293fa55cd4448c6705d085f759025cf26 | CI-pinned sibling common checkout | Pin the same revision in CI and the builder. Export Fedora 45 and mkosi v27.1 inputs for both arches and consume handoff 1.0. |
| sbm-lab | 4c4ba5d22e7bd42cc6c5f82fd46f2da0d0e318f9 | No direct common crate dependency | Consume release media and integration evidence at pinned commits. OVMF and AAVMF consume identical raw bytes. |
| install | 0359c04 (scaffold) | No image packer | Use the candidate common model and vectors for RecoveryManifest 1.0 and ReleaseManifest 1.1. Combine the two native Core inputs and two menu binaries. |
| sbm-server | 4840ee3118083c1d054ad1f0d8839286d5cb4576 | CI-pinned sibling common checkout | No dependency in the offline image. Migrate common with its next protocol change. Preserve the command envelope and signing bytes. |
| sbm-catalog | 820aa333061446809f6190b56d25f3ae957e8261 | Git pin of sbm-types | No dependency in the image. Migrate before consuming combined release media. |
| sbm-as | f0f81fb20cb3d71950aacb45b8507da49ab9b7fe | CI-pinned sibling common checkout, default features off | No Apple bootstrap in the candidate. Adopt the applicable common pin when testing the actual AArch64 application. |
| sbm-agent and website | Scaffolds | No current integration binding | Guest reporting and public compatibility documentation follow the validated contract. |

ReleaseManifest 1.0 remains readable. New combined media uses 1.1 and optional `media`; Rust struct literals must initialize that field. RecoveryManifest, handoff, success and signed command formats stay at 1.0. No audited producer constructs ReleaseManifest literals. Update consumers in their owning repos. See the [specification PR](https://github.com/smart-boot-menu/docs/pull/1) and [shared migration PR](https://github.com/smart-boot-menu/sbm-common/pull/1).

## Critical path

1. **Restore the two independent prerequisites.** Agent 02 fixes the Linux credential build, then creates and directly boots both Core inputs. Agent 03 diagnoses the missing AArch64 marker on the hosted runner, capturing the selected firmware pair, QEMU configuration, stderr, serial and QMP frames. Complete both before treating a combined-image failure as a handoff defect.
2. **Land and use the same contract revision.** Agent 10 coordinates the spec and shared PRs. Agents 01 and 02 implement the ESP binding, handoff, slot selection and boot confirmation from those specs. Preserve progress by building the menu and preparing Lab and installer changes while Core images are building.
3. **Assemble once and qualify twice.** Agent 07 packages both Core pairs into one regular-file GPT image. Agent 03 verifies the raw image digest in both VM lanes, exercises the real UI sequence, then runs the negative cases. Retain the same image digest from assembly through release evidence.
4. **Run the separate Secure Boot experiment.** Agents 01, 02 and 03 qualify enrolled guest keys after the ordinary path works. Keep remote boot, attestation, real wayvnc, catalog trust and Apple experiments in their own tracks.

## Build and test entry points

- UEFI uses `cargo run --locked -p xtask -- build` with both UEFI targets installed. Feed the two resulting production PE images into the packer. Retain the fixture QEMU path for firmware regressions.
- Core uses `scripts/build-inside.sh` in a disposable Fedora builder. Its owner isolates the two mkosi outputs and records tool and package versions, UKI .cmdline, GPT IDs and attributes, and input SHA-256. Native direct boots verify the real verity-backed root and desktop before assembly.
- Installer accepts files for both menus and both native Core disk outputs. It emits the raw image, zstd form, compressed SHA-256 sidecar, release manifest and build receipt. Its issue owns the packer command and input documentation. No host block device is passed to any step.
- Lab runs `sbm-lab test --tier smoke` and adds `sbm-lab test --tier integration --image PATH` for the actual removable image. [Release gates](RELEASE_GATES.md) defines evidence and failure conditions.

## Owner assignments

| Agent | Assignment and acceptance |
|---|---|
| 01 · UEFI | Implement the [native recovery launch and attempt reconciliation](https://github.com/smart-boot-menu/sbm-uefi/issues/1). Retain fixture regressions. Co-own the [enrolled-key experiment](https://github.com/smart-boot-menu/sbm-lab/issues/4), [verified remote client](https://github.com/smart-boot-menu/sbm-uefi/issues/2) and [token migration](https://github.com/smart-boot-menu/sbm/issues/1). |
| 02 · Core | [Restore the Linux build and native artifacts](https://github.com/smart-boot-menu/sbm-core/issues/2). Use the [existing handoff issue](https://github.com/smart-boot-menu/sbm-core/issues/1) for UUID-bound ESP access, verified handoff and reboot reporting. Co-own the Secure Boot, wayvnc and token work. |
| 03 · Lab | [Restore hosted ARM smoke](https://github.com/smart-boot-menu/sbm-lab/issues/3) and [qualify the assembled image](https://github.com/smart-boot-menu/sbm-lab/issues/2). Keep the [FAT fixture task](https://github.com/smart-boot-menu/sbm-lab/issues/1) as a fast regression. Archive guest evidence on failure as well as success. |
| 04 · Apple Silicon | [Boot the actual ARM64 menu in QEMU U-Boot](https://github.com/smart-boot-menu/sbm-as/issues/1). Preserve the distinction between the U-Boot probe, generic AAVMF, and physical Apple Silicon. |
| 05 · Server | [Persist passkey updates across restart](https://github.com/smart-boot-menu/sbm-server/issues/3), [wire the real Core recovery relay](https://github.com/smart-boot-menu/sbm-server/issues/1), and [verify TPM quotes](https://github.com/smart-boot-menu/sbm-server/issues/2). Coordinate the verified firmware command path and shared tokens. |
| 06 · Catalog | [Close trust coverage gaps](https://github.com/smart-boot-menu/sbm-catalog/issues/1). Record exact architecture and verification tier for each claim. |
| 07 · Installer | [Assemble and verify regular-file media](https://github.com/smart-boot-menu/install/issues/1). Package both verity pairs and deliver the candidate and reproducibility receipt. |
| 08 · OS agent | [Consume canonical BootSuccessReport](https://github.com/smart-boot-menu/sbm-agent/issues/1). Prove a stale report cannot confirm another attempt. |
| 09 · Website | [Publish only evidenced compatibility](https://github.com/smart-boot-menu/smart-boot-menu.github.io/issues/1). Link the approved manifest and the actual test matrix after qualification. |
| 10 · Architecture | Own the paired docs and common changes, track dependency pins and inspect the release evidence. Coordinate a shared remote signing helper as a separate interface follow-up. |

The issue bodies identify engineering owners by agent number. GitHub's assignee is the organization maintainer account because the roster has no separate agent logins.
