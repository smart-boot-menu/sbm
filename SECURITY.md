# Security Policy — Smart Boot Menu

Smart Boot Menu is privileged pre-boot and bare-metal system software. Please report suspected vulnerabilities privately via [GitHub Security Advisories](https://github.com/smart-boot-menu/sbm/security/advisories/new) — **never** in public issues.

## Canonical Security Documentation

- **Full Threat Model & 12 Threat Classes:** [`docs/threat-model/README.md`](https://github.com/smart-boot-menu/docs/blob/main/threat-model/README.md)
- **Boot Security, Microsoft UEFI CA 2023, TPM/BitLocker & Supply Chain Research:** [`research/architecture/security-and-supply-chain.md`](https://github.com/smart-boot-menu/research/blob/main/architecture/security-and-supply-chain.md)
- **Organization Disclosure Policy:** [`.github/SECURITY.md`](https://github.com/smart-boot-menu/.github/blob/main/SECURITY.md)

## Key Security Invariants

1. **No arbitrary remote code execution in `sbm-uefi`.**
2. **Offline-first & opt-in enrollment:** Remote control is disabled until explicitly enrolled.
3. **Signed & replay-protected remote commands:** Ed25519 `CommandEnvelope` with `device_id`, monotonic `sequence`, short TTL, and strict `AuthScope` separation (`boot_select` vs `storage_destructive`).
4. **BitLocker & Apple Silicon protection gates:** Explicit recovery-key warnings before altering UEFI `BootOrder`; hard read-only guardrails on Apple `iSCPreboot`/`Recovery`/macOS partitions.
5. **No mandatory telemetry and no unsigned remote install scripts.**
