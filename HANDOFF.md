# Agent 0 — Smart Boot Menu Initialization & Architecture Handoff Report

**Date:** 2026-11-26  
**Baseline:** November 2026 (`rustc 1.100.0`, Rust 2024 edition, macOS 27.0 on Apple M5 `T8142` dev workstation)  
**GitHub Organization:** https://github.com/smart-boot-menu  
**Local Workspace:** `~/gh/smart-boot-menu/`  
**Original Code & Docs License:** `MIT OR Apache-2.0`

---

## 1. Created GitHub Repositories & Commit Identifiers (14 Repositories)

All 12 originally specified repositories **plus** dedicated `docs` and `research` repositories (modeled after `0SFS`'s clean separation of normative docs and primary-source research) were created as public repositories on `main`, cloned into `~/gh/smart-boot-menu/`, initialized with `README.md`, `AGENTS.md`, `LICENSE-MIT`, `LICENSE-APACHE`, `.gitignore`, and CI baselines, and pushed.

| Repository | URL | Initial Commit (`main`) | Canonical Role |
|---|---|---|---|
| `.github` | https://github.com/smart-boot-menu/.github | `8f8757a` (`8f8757ad8442c9b7cfae9d40f663c6c0014556b2`) | Org profile, universal `AGENTS.md` + task routing index, `agent-reference.md`, community & security policies, templates |
| `docs` | https://github.com/smart-boot-menu/docs | `0ea5951` (`0ea59512aac2c6d5f17ac16c4253e0f3f9ecdbfe`) | Canonical ADRs (001–008), 19 versioned specs (`01..07`), threat model, target hardware profiles, benchmark methodology, 10 Mermaid diagrams |
| `research` | https://github.com/smart-boot-menu/research | `917beb6` (`917beb6e940a51bcdb94b4ad9a0fcd07a2e3c830`) | Primary-source ecosystem surveys, Apple Silicon M1–M5 study, GPU/GUI evaluation, UEFI/Linux/Security/Testing research & validation evidence dir |
| `sbm` | https://github.com/smart-boot-menu/sbm | *(this commit)* | Central coordination, `VISION.md`, `ARCHITECTURE.md`, `TECHNOLOGY_STACK.md`, `ROADMAP.md`, `REPOSITORIES.md`, `REQUIREMENTS.md`, `agents/01..09.md`, `HANDOFF.md` |
| `sbm-common` | https://github.com/smart-boot-menu/sbm-common | `28d3845` (`28d38450954f0b93815e12f31da92370b13a7462`) | Compiled & verified Rust 2024 workspace: `sbm-types` (`#![no_std]`+`alloc`), `sbm-protocol` (`#![no_std]`+`alloc`), `sbm-schema` (`std`), 18 exported JSON Schemas, 4 golden test vectors |
| `sbm-uefi` | https://github.com/smart-boot-menu/sbm-uefi | `506ed2a` (`506ed2abc145d85de1ad953415fdb62377721b97`) | Native Rust graphical UEFI boot manager (`x86_64` & `aarch64`) |
| `sbm-as` | https://github.com/smart-boot-menu/sbm-as | `98c077e` (`98c077ee91e50336522b70d709af52e5f303493b`) | Apple Silicon bootstrap (`m1n1` + Asahi U-Boot -> shared `sbm-uefi`), light Asahi profile, APFS guardrails, external boot |
| `sbm-core` | https://github.com/smart-boot-menu/sbm-core | `3bdcbe3` (`3bdcbe3bf6125a8d065f9c28987b8eb56344dce5`) | Minimal immutable Linux management & recovery OS (`mkosi`: Fedora Minimal + light Fedora Asahi Minimal) |
| `install` | https://github.com/smart-boot-menu/install | `89d8a15` (`89d8a156af046e5a447bef67f2d800dc0f6d8975`) | Cross-platform installer, updater, uninstaller & removable USB media creator for SBM |
| `sbm-server` | https://github.com/smart-boot-menu/sbm-server | `7c73555` (`7c735554b80d478d0abd661df9135da91087c459`) | Optional self-hosted management server (`axum`/`sqlx`/SvelteKit/`noVNC`) |
| `sbm-catalog` | https://github.com/smart-boot-menu/sbm-catalog | `e055839` (`e05583991653a27483cc3ef6b600d79d4109ee15`) | TUF-signed declarative OS catalog & verified recipes |
| `sbm-agent` | https://github.com/smart-boot-menu/sbm-agent | `9821b2b` (`9821b2b05760eb203a5bc0155b9f63a9e35e6d6f`) | Optional guest OS background daemon (boot-success confirmation & remote reboot) |
| `sbm-lab` | https://github.com/smart-boot-menu/sbm-lab | `62c25af` (`62c25afcb27ff889baf24105b35c99b312692f82`) | QEMU/OVMF/AAVMF/U-Boot/`swtpm` virtual hardware lab, fixtures, benchmarks & fault injection |
| `smart-boot-menu.github.io` | https://github.com/smart-boot-menu/smart-boot-menu.github.io | `3301e39` (`3301e39f8ae38d9566333a9b7e4be690e3943900`) | Official website, docs portal & verified downloads |

*Zero repositories failed creation or push.*

---

## 2. Local Workspace Structure

```text
~/gh/smart-boot-menu/
├── .github/                  # Org profile, universal AGENTS.md, agent-reference.md, templates
├── docs/                     # Canonical ADRs (001–008), Specs (01–07), Threat Model, Hardware, Testing, Diagrams
├── research/                 # Primary-source ecosystem, Apple Silicon, GPU/GUI, UEFI, Linux, Security, Testing research
├── sbm/                      # Executive coordination, VISION, ARCHITECTURE, ROADMAP, agents/01..09.md, HANDOFF.md
├── sbm-common/               # Compiled Rust workspace (sbm-types, sbm-protocol, sbm-schema) + 18 schemas + test-vectors
├── sbm-uefi/                 # Agent 1 target
├── sbm-core/                 # Agent 2 target
├── sbm-lab/                  # Agent 3 target
├── sbm-as/                   # Agent 4 target
├── sbm-server/               # Agent 5 target
├── sbm-catalog/              # Agent 6 target
├── install/                  # Agent 7 target
├── sbm-agent/                # Agent 8 target
└── smart-boot-menu.github.io/# Agent 9 target
```

---

## 3. Summary of Architectural Decisions (ADRs 001–008)

1. **ADR-001 (Two-Tier Execution):** Strictly separate **Fast Path (`sbm-uefi`)** (native Rust UEFI menu/discovery/chainload — zero Linux boot for everyday OS startup) from **Management Path (`sbm-core`)** (minimal immutable Linux UKI for Wi-Fi, GPU/Wayland, GParted, OS installation, cloning, and remote recovery).
2. **ADR-002 (Graphics & GUI Separation):** UEFI GOP exposes ONLY a linear CPU framebuffer (no GPU hardware acceleration). Do not force Slint (`GPL-3.0-only` license conflict) across both tiers. Share design tokens/view-models in `sbm-common`; build a tiny custom `#![no_std]` double-buffered GOP software renderer in `sbm-uefi`; run **`labwc` Wayland + XWayland** (for GTK3 **GParted `1.8.1`**) + **`Iced`** (`MIT`, `wgpu` + `tiny-skia` CPU fallback) + **`wayvnc`** in `sbm-core`.
3. **ADR-003 (`sbm-core` OS Choice for x86/ARM64 PCs vs Apple Silicon — Both `< 1 GB`):** Standardize on **one unified `mkosi v27.1` build pipeline** producing signed UKIs + `dm-verity` EROFS (`zstd`) images:
   - **x86-64 & Generic ARM64 PCs:** **Fedora Minimal** (~420–650 MiB compressed — fresh mainline kernels, curated `.zst` `linux-firmware`, identical glibc/systemd/GParted/Wayland stack).
   - **Apple Silicon:** Super-light **Fedora Asahi Minimal** (`kernel-16k` `linux-asahi`, `mesa-asahi`, local `asahi-fwextract`, ~500–850 MiB compressed — far below the 4 GB ceiling!).
   - Adaptive RAM execution: copies EROFS to RAM (`sbm.toram=auto`) on ≥ 4 GiB machines; mounts EROFS + `zram` overlay on older 2 GiB laptops.
4. **ADR-004 (`sbm-uefi` Stack & ESP Persistence):** Rust 2024 + `uefi` `0.41.0` (`uefi::boot`/`uefi::system`), `crdyboot`-style trait mocking for host unit tests, UAPI BLS Type #1/#2 (UKI) discovery, timer-polled input (defending against `WaitForKeyEx` firmware hangs), bounded `smoltcp`+TLS SNP networking (≤ 4 s, instant keypress cancel), and **ESP-first atomic persistence** (avoiding UEFI NVRAM flash wear/bricking and working seamlessly on Apple Silicon U-Boot).
5. **ADR-005 (Apple Silicon Strategy):** Reuse upstream **`m1n1` + `AsahiLinux/u-boot` (`asahi-releng`)** to launch the **unmodified `aarch64-unknown-uefi` `sbm-uefi` binary**. Compact internal stub (~1.5–2 GB total) enables booting compatible `linux-asahi` OSes from external USB3 SSDs on supported generations (M1–M3 today). Hard-block Apple `iSCPreboot`/`RecoveryOS`/macOS APFS containers. Defer physical M5 (`T8142`) bare-metal boot past SBM 0.1 pending upstream Asahi USB3/PCIe/DART drivers.
6. **ADR-006 (Storage Safety & Wrapping Mature Tools):** Do NOT rewrite `e2fsprogs`, `ntfs-3g`, `btrfs-progs`, `cryptsetup 2.8.9` (LUKS2 + BitLocker `bitlk`), `partclone`, `ddrescue`, `testdisk`, `wimlib-imagex 1.14.5`, or `gparted` in Rust; invoke via `execve` (never shell) under a Rust safety planner enforcing stable `DiskIdentity`, partition-table hash locks, `PartitionProtectionClass` guardrails, and honest non-reversibility warnings.
7. **ADR-007 (Optional Self-Hosted Server & Auth):** `axum 0.8.9` + `tokio 1.54.1` + `sqlx 0.9.1` (SQLite WAL default + PostgreSQL) + embedded `SvelteKit 3.4.0` (`@novnc/novnc` + `xterm.js`), WebAuthn Passkeys (`webauthn-rs 0.6.2`), mTLS (`rcgen 0.14.10`/`rustls`), strict RBAC scopes, and Ed25519-signed replay-protected `CommandEnvelope`s.
8. **ADR-008 (Testing & Benchmarks):** `sbm-lab` runs QEMU (`x86_64` + `aarch64`), EDK2 `edk2-stable202611` OVMF/AAVMF, U-Boot `v2026.10` (`qemu_arm64`), and `swtpm v0.10.2`, using native-speed `-accel hvf` for ARM64 on the M5 dev Mac. Publish only measured user-perceived latency archived under `research/validation/evidence/`.

---

## 4. Key Research Findings (Saved in `research/`)

- **Apple Silicon M5 (`T8142`) Reality (Nov 2026):** Asahi Linux officially supports M1, M2, and M3 (M3 merged Sep 2026). M5 (`T8142`) has early `linux-asahi` (7.5 target) bring-up (devicetree, `simpledrm`, NVMe, keyboard), but **USB2/USB3, Thunderbolt, PCIe, DART, GPU, Wi-Fi, BT, Touchpad, and official installer are still `TBA`/`no`**. Additionally, macOS 27.3 Golden Gate Beta fixed `FB23916610` (single-core custom raw boot object bug on M5 Pro/Max/Ultra).
- **Microsoft UEFI Secure Boot 2011 -> 2023 CA Transition:** All three Microsoft 2011 Secure Boot CAs expired in June–October 2026; production signing now targets **Microsoft UEFI CA 2023** via **`rhboot/shim 16.1`** (requiring `.sbat` PE metadata and `MOK_POLICY_REQUIRE_NX`).
- **BitLocker PCR Hazards:** Inserting SBM into UEFI `BootOrder` alters TPM PCR 4 (and PCR 7 if Secure Boot authorities change), triggering a BitLocker 48-digit Recovery Key prompt — `install` enforces an explicit BitLocker safety gate.
- **`iGPU` & `uefi-wm` Verification:** Confirmed no Rust GUI framework named `igpu` or `uefi-wm` exists; `iGPU` refers to integrated GPU hardware, which UEFI GOP does NOT hardware-accelerate.

---

## 5. Shared Interfaces & `sbm-common` Validation Results

All 19 specified shared interfaces are documented in `docs/specifications/01..07` and implemented in `sbm-common`:

| Check | Result |
|---|---|
| `cargo fmt --all -- --check` | **PASS** (0 diffs) |
| `cargo clippy --workspace --all-targets -- -D warnings` | **PASS** (0 warnings) |
| `cargo test --workspace` | **PASS** (6/6 tests passed, incl. golden test vector round-trips & UEFI scope/replay rejection) |
| `cargo check -p sbm-types -p sbm-protocol --no-default-features --target x86_64-unknown-uefi` | **PASS** (0 warnings) |
| `cargo check -p sbm-types -p sbm-protocol --no-default-features --target aarch64-unknown-uefi` | **PASS** (0 warnings) |
| `cargo run -p sbm-schema -- schemas` | **PASS** (18 canonical `*.v1.schema.json` files exported) |

---

## 6. Dependency Graph & Agent Execution Order

Full Mermaid diagrams (all 10 required diagrams) live in [`docs/diagrams/architecture-diagrams.md`](https://github.com/smart-boot-menu/docs/blob/main/diagrams/architecture-diagrams.md).

**Recommended Parallel Launch Wave for SBM 0.1:**
1. **Wave 1 (Launch immediately in parallel):**
   - **Agent 3 (`sbm-lab`, `agents/03-lab.md`)** — install `brew install qemu swtpm`, build OVMF/AAVMF/U-Boot harness & golden QCOW2 fixtures.
   - **Agent 1 (`sbm-uefi`, `agents/01-uefi.md`)** — build dual-arch `x86_64` + `aarch64` graphical UEFI menu, OS/BLS/UKI discovery, chainloading & ESP policy engine.
   - **Agent 2 (`sbm-core`, `agents/02-core.md`)** — build `mkosi` Fedora Minimal (`x86_64` & `aarch64`) UKI + EROFS image with `labwc` + XWayland + GParted + `sbm-cored` + `wayvnc`.
   - **Agent 5 (`sbm-server`, `agents/05-server.md`)** — build `axum` + SQLite + SvelteKit server with enrollment, Ed25519 signed `boot_select` commands, and `noVNC`.
2. **Wave 2 (Start once Wave 1 artifacts are testable):**
   - **Agent 7 (`install`, `agents/07-installer.md`)** — dual-arch bootable USB image builder + BitLocker safety gate.
   - **Agent 6 (`sbm-catalog`, `agents/06-catalog.md`)** — curated OS catalog + TUF signing validator.
   - **Agent 4 (`sbm-as`, `agents/04-apple-silicon.md`)** — `qemu_arm64` U-Boot validation + light Fedora Asahi `mkosi` profile (`< 900 MiB`).
3. **Wave 3:**
   - **Agent 8 (`sbm-agent`, `agents/08-os-agent.md`)** & **Agent 9 (`smart-boot-menu.github.io`, `agents/09-website.md`)**.

---

## 7. Unresolved Technical Questions, Blockers & Limitations

1. **Older x86 HP Laptop Unprobed (`EXP-HW-HP01`):** Exact model, RAM, UEFI bitness (x64 vs IA32), Secure Boot CA state (2011 vs 2023), Wi-Fi chip, and firmware input quirks are unknown until read-only probe is run.
2. **Apple Silicon M5 (`T8142`) Upstream Blocker:** Bare-metal M5 Linux/external USB boot is blocked on upstream Asahi Linux DART, PCIe, USB2/USB3, GPU, and Wi-Fi drivers. Do not modify the M5 dev Mac.
3. **Local Virtualization Tools Missing on Dev Mac:** `qemu-system-x86_64`, `qemu-system-aarch64`, and `swtpm` are not yet installed via Homebrew (Agent 3 should install via `brew install qemu swtpm`).
4. **Windows BCD Generation Without WinPE:** Applying `install.wim` via `wimlib-imagex` works natively on Linux, while clean UEFI BCD creation is safest via WinPE stage-1 handoff vs `hivex` template generation — needs validation in SBM 0.2 (`sbm-core`).
5. **Production Secure Boot Signing (`shim-review`):** Obtaining Microsoft UEFI CA 2023 signature via `rhboot/shim-review` is a multi-month governance/reproducibility process deferred to SBM 0.3; SBM 0.1/0.2 use custom Secure Boot keys in OVMF and Secure Boot opt-in documentation.
