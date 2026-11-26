# SBM 0.0.1 integration audit

**Baseline** 2026-11-26. The shortest path is to restore Linux Core builds and hosted ARM smoke, then qualify one assembled USB image on both architectures. The baseline has component-level evidence and no confirmed real UEFI-to-Core boot.

## Evidence by component

| Component | Verified at the audited revision | Remaining gap |
|---|---|---|
| Shared contracts | The existing Rust model builds and its golden vectors round-trip. | Draft prose diverged from Rust on release protocol fields and firmware scopes. The combined-media field and vectors are coordinated in the shared revision. |
| UEFI | Two real EFI applications have the expected PE machines. Host tests and both cross-builds passed. Archived QEMU runs show GOP, discovery and StartImage against synthetic children. | The fixture returns to firmware and supplies no kernel, root or Linux transition. No production Core launch has been verified. Runtime remote polling passes no command and does not check a signature. |
| Core | macOS host tests pass for data paths. The source contains a Fedora image recipe, Iced UI and GParted launcher. | Linux CI and the Fedora builder fail at the same unstable socket credential call. The inspected builder stopped before mkosi. UKI creation, verity activation, GUI, GParted and reboot remain release gates. |
| Lab | Host tests pass, archived local fixtures boot, and the x86_64 hosted fixture passes. | Both hosted ARM smoke scenarios miss the first EFI marker. CI retained no per-guest artifacts. The current harness copies --core into a synthetic ESP, treats a firmware banner as sufficient for some runs, and launches QEMU with -no-reboot. None proves the release loop. |
| Server | The real server and simulator cover enrollment, signed next boot, result acknowledgment and an authenticated RFB tunnel. | The simulator reports a selection and does not reboot an actual device. Its framebuffer is generated. Core has a conditional wayvnc unit, but the outbound tunnel has no actual Core attachment. TPM is recorded without quote verification. |
| Catalog | Catalog tests cover selected Debian and Fedora signature fixtures and development TUF tamper, rollback and expiry. An archived Debian ARM64 boot reaches GRUB. | Several linked upstream signatures remain unverified, Debian ARM64 differs from the signed Debian fixture, and no production TUF trust root is evidenced. |
| Apple adapter | Local tests cover platform constraints. An archived AArch64 QEMU U-Boot run exercised a protocol probe. | The actual menu under U-Boot, Asahi Core build, and physical Apple Silicon boot remain experimental. Generic AAVMF does not cover those platforms. |

The [baseline evidence log](https://github.com/smart-boot-menu/research/blob/integration/0.0.1/validation/evidence/sbm-integration-baseline-2026-11-26.md) records full revisions, CI and builder output, local test counts, and EFI hashes. The six component and shared-contract checks are summarized in the [compatibility matrix](INTEGRATION_PLAN.md).

## Cross-repository discrepancies

| Finding | Effect on integration | Resolution |
|---|---|---|
| Firmware hashes recovery files only up to 32 MiB; an inconclusive digest can remain selectable. The observed digest is carried in verified_signature. | A real UKI can evade the intended integrity check and produce an inaccurate signature claim. | Stream and recheck the digest, reject inconclusive results, and keep PE trust independent. [UEFI task](https://github.com/smart-boot-menu/sbm-uefi/issues/1) |
| Core mounts the first candidate ESP and reads handoff data from a path list. UEFI persists its own ESP state. | A decoy or OS ESP can receive writes, and a test can succeed while reading another disk's data. | Resolve the BLI PARTUUID, verify the device and parent, and exercise a decoy ESP. [Core handoff task](https://github.com/smart-boot-menu/sbm-core/issues/1) |
| UEFI supplies external options and can retry recovery as a pathless buffer. Core relies on embedded mkosi settings. | The real child can lose its device identity or boot parameters. Secure Boot can ignore external options. | Use the exact EFI path, complete embedded command line, and volatile variables for per-boot context. [UEFI task](https://github.com/smart-boot-menu/sbm-uefi/issues/1) |
| Core emits a fallback attempt ID and hard-codes Slot A. UEFI never reads boot-success.json. Existing UEFI attempt IDs derive from elapsed time and failure counts can carry across targets. | A UI boot can leave stale health state, and mismatched reports can be mistaken for current results. | Bind the report to a fresh attempt ID and exact target, and verify it after reboot. [Core handoff task](https://github.com/smart-boot-menu/sbm-core/issues/1) |
| Core's post-output hook copies a fallback UKI, whereas release media need both fallback paths for the menu. | Using a Core disk unchanged can bypass SBM entirely. | Keep native Core outputs as build inputs. Assemble a distinct GPT image that preserves both verity pairs and replaces the fallback entries. [Installer task](https://github.com/smart-boot-menu/install/issues/1) |
| Core smoke writes injected demo context and its readiness markers can precede successful compositor rendering or GParted launch. | A marker alone can produce a false positive. | Verify real QMP frames, action outcomes, disk selector, and durable state. [Lab task](https://github.com/smart-boot-menu/sbm-lab/issues/2) |
| Passkey login writes through the registration insert and discards duplicate-key failure. | Credential updates such as authenticator counters can be lost. | Persist the updated matching credential and exercise a restart. [Server task](https://github.com/smart-boot-menu/sbm-server/issues/3) |
| Scope prose allowed recovery access in firmware, while Rust's helper rejects it. | Producers and consumers can disagree about a signed command's authority. | Follow the deployed signing format and authorize only a known boot target under boot_select in firmware. [Remote command task](https://github.com/smart-boot-menu/sbm-uefi/issues/2) |
| UEFI, Core and Server have independently authored theme values. | The interfaces drift despite the shared design-system ADR. | Agree on a versioned asset and migrate each renderer separately. [Design token task](https://github.com/smart-boot-menu/sbm/issues/1) |

The current Lab Secure Boot profile uses an unenrolled variable store, and Core's standalone smoke notes say Secure Boot was disabled. A signed PE file and an enrolled enforcement run provide different evidence. [Secure Boot experiment](https://github.com/smart-boot-menu/sbm-lab/issues/4)

See [release gates](RELEASE_GATES.md) for the evidence required to promote a candidate.
