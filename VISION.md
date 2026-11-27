# Smart Boot Menu — Project Vision

## The Problem

Installing, multibooting, recovering, and managing operating systems on personal computers, homelab machines, and bare-metal servers remains stuck in a 1990s workflow: hunt for ISO downloads, flash disposable USB drives, juggle separate tools for boot menus (rEFInd/GRUB), partitioning (GParted Live), recovery (SystemRescue), imaging (Clonezilla/Rescuezilla), network installs (netboot.xyz), and remote access (RustDesk/PiKVM/MAAS).

## The Vision

**Install Smart Boot Menu once; manage your hardware for life.**

Smart Boot Menu unifies the capabilities of:
- **rEFInd / systemd-boot** — ultra-fast, polished graphical boot selection & automatic OS discovery,
- **PINN / netboot.xyz** — declarative, verified OS catalog and multi-OS installation without flashing USBs,
- **Ventoy (without opaque binary blobs)** — clean installation from verified ISOs, WIMs, OCI `bootc` images, and rootfs archives,
- **GParted / SystemRescue** — safe disk/partition management, boot repair, and hardware diagnostics,
- **Clonezilla / Rescuezilla** — smart block-level backup, migration, and restoration,
- **noVNC / RustDesk / MAAS / PiKVM / JetKVM** — optional self-hosted remote boot policies, browser-native remote desktop/terminal, and optional out-of-band BMC/IP-KVM integration.

## Non-Negotiable Core Principles

1. **Fast Everyday Boot:** Normal OS booting executes natively in UEFI (`sbm-uefi`) in milliseconds — NEVER initializing Linux just to chainload Windows or Linux.
2. **Offline-First Autonomy:** Every core local feature works with zero internet, zero accounts, zero cloud services, and zero telemetry.
3. **Safety Over Convenience:** Privileged bare-metal software must default to read-only discovery, stable disk identity checks, platform-critical partition guardrails, honest non-reversibility warnings, and zero arbitrary remote code execution in pre-OS UEFI.
4. **Honest Engineering & Open-Source Reuse:** Clearly distinguish verified capabilities from experimental work (especially on bleeding-edge hardware like Apple Silicon M5), do not recreate inferior versions of existing software (reuse the best available open-source implementations and write original software only where justified per [ADR-010](https://github.com/smart-boot-menu/docs/blob/main/architecture-decisions/ADR-010-open-source-reuse-and-engineering-principles.md)), and publish only measured benchmarks.
