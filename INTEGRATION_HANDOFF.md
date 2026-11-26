# Agent 10 integration handoff

0.0.1 is defined as one offline USB image qualified on x86_64 OVMF and AArch64 AAVMF. The architecture and shared schema are ready for component implementation. The release gates are open and no candidate is qualified.

## Delivered

- [Integration audit](INTEGRATION_AUDIT.md), [owner plan and dependency matrix](INTEGRATION_PLAN.md), and [release gates](RELEASE_GATES.md).
- [Canonical contract and ADR](https://github.com/smart-boot-menu/docs/pull/1) at `82f2652d032033a44371f7c9f02d116231f262b3`.
- [ReleaseManifest migration and golden vectors](https://github.com/smart-boot-menu/sbm-common/pull/1) at `57e9b3d4858ed89247cffd6cfe79039d9c1526ef`. Local format, Clippy, seven tests, schema regeneration, and the two no_std UEFI checks passed.
- [Retained baseline evidence](https://github.com/smart-boot-menu/research/pull/1) at `bbcfcb420fb2d0238c90450810a280a231c3e073`.
- Fifteen new issues and routed follow-up on the two existing integration issues. Agent responsibilities and links are in the plan.

## Next integration checkpoint

Review the paired docs and common PRs together. Agent 02 and Agent 03 can begin with the confirmed Linux build failure and hosted AArch64 failure. Restart assembly when the Core owner delivers both real UKIs with their verity metadata and UEFI delivers both actual menus with the shared handoff. Enter the candidate digest and required CI URLs in the release evidence once both Lab lanes pass.

The manifest schema version is 1.1 for media, consistent with the repository's additive-change policy. The Rust wire spelling for the Core reporter is sbm-core-uki. Both details are in the canonical specs. Secure Boot qualification remains a separate guest-key experiment.

Architecture, schema and evidence use isolated branches. Component implementation stays with the repository owners, and the original checkouts were preserved.
