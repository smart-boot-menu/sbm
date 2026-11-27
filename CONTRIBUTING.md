# Contributing to Smart Boot Menu

Follow the organization-wide guide in [`.github/CONTRIBUTING.md`](https://github.com/smart-boot-menu/.github/blob/main/CONTRIBUTING.md), the canonical engineering rules in [`.github/AGENTS.md`](https://github.com/smart-boot-menu/.github/blob/main/AGENTS.md), and the **Open-Source Reuse & Engineering Principles** in [`ADR-010`](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md).

## Proposing & Reviewing New Components or Shared Interface Changes

1. For any new subsystem, major dependency, architectural change, or replacement of existing software, complete a proportional build-versus-reuse evaluation per [`.github/agent-reference.md`](https://github.com/smart-boot-menu/.github/blob/main/agent-reference.md#4-proportional-build-vs-reuse-evaluation) and record comparative research in **`smart-boot-menu/research`**.
2. Open an RFC, ADR, or specification PR in **`smart-boot-menu/docs`** (`specifications/` or `architecture-decisions/`).
3. Implement canonical shared Rust types, JSON Schemas, and golden test vectors in **`smart-boot-menu/sbm-common`** — verifying both host `cargo test` AND `no_std` UEFI cross-compilation (`x86_64-unknown-uefi`, `aarch64-unknown-uefi`).
4. Bump `schema_version` / `ProtocolVersion` following `docs/specifications/README.md`.
5. Update affected downstream components and verify end-to-end compatibility in **`smart-boot-menu/sbm-lab`**.

## Commit & Licensing Rules

- Dual license for all original code and docs: **`MIT OR Apache-2.0`**.
- Never commit credentials, private keys, personal info, or physical machine identifiers (serials/ECIDs/MACs).
- Never force-push `main`.
