# Contributing to Smart Boot Menu

Follow the organization-wide guide in [`.github/CONTRIBUTING.md`](https://github.com/smart-boot-menu/.github/blob/main/CONTRIBUTING.md).

## Proposing & Reviewing Shared Interface Changes

1. Open an RFC or specification PR in **`smart-boot-menu/docs`** (`specifications/` or `architecture-decisions/`).
2. Implement the canonical Rust types, JSON Schemas, and golden test vectors in **`smart-boot-menu/sbm-common`** — verifying both host `cargo test` AND `no_std` UEFI cross-compilation (`x86_64-unknown-uefi`, `aarch64-unknown-uefi`).
3. Bump `schema_version` / `ProtocolVersion` following `docs/specifications/README.md`.
4. Update affected downstream components and verify end-to-end compatibility in **`smart-boot-menu/sbm-lab`**.

## Commit & Licensing Rules

- Dual license for all original code and docs: **`MIT OR Apache-2.0`**.
- Never commit credentials, private keys, personal info, or physical machine identifiers (serials/ECIDs/MACs).
- Never force-push `main`.
