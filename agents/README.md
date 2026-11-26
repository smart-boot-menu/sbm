# Smart Boot Menu — Autonomous Engineering Agent Prompts

Each file below is a self-contained launch prompt for a specialized autonomous engineering agent working in parallel across the Smart Boot Menu repositories.

Every agent follows the same 10-step disciplined engineering workflow:
1. Read central project docs (`sbm`, `docs`, `research`, `.github/AGENTS.md`).
2. Inspect relevant existing codebases and upstream references.
3. Conduct targeted domain-specific research (saving reusable findings to `research/`).
4. Write a concise implementation plan before coding.
5. Implement a clean, working proof of concept (respecting `sbm-common` contracts).
6. Write comprehensive automated tests (`cargo test`, integration tests, fuzz/property tests).
7. Run documented benchmarks where applicable (archiving evidence in `research/validation/evidence/`).
8. Document known limitations and open questions explicitly.
9. Commit and push changes (or present exact push steps per repo rules) without AI attribution trailers.
10. Report cross-repository integration requirements cleanly.

## Agent Roster

| Agent | Prompt File | Assigned Repository | Primary SBM 0.1 Milestone Role |
|---|---|---|---|
| **Agent 1** | [01-uefi.md](01-uefi.md) | `sbm-uefi` | Native Rust graphical UEFI boot manager (`x86_64` & `aarch64`) |
| **Agent 2** | [02-core.md](02-core.md) | `sbm-core` | Minimal immutable Linux recovery & management OS (`mkosi`) |
| **Agent 3** | [03-lab.md](03-lab.md) | `sbm-lab` | QEMU/OVMF/AAVMF/U-Boot/`swtpm` virtual hardware & integration lab |
| **Agent 4** | [04-apple-silicon.md](04-apple-silicon.md) | `sbm-as` | Apple Silicon `m1n1`/U-Boot integration, light Asahi profile & external boot |
| **Agent 5** | [05-server.md](05-server.md) | `sbm-server` | Optional self-hosted management server (`axum`/`sqlx`/SvelteKit/`noVNC`) |
| **Agent 6** | [06-catalog.md](06-catalog.md) | `sbm-catalog` | TUF-signed declarative OS catalog, recipes & schema validation |
| **Agent 7** | [07-installer.md](07-installer.md) | `install` | Cross-platform SBM installer, updater, uninstaller & USB media creator |
| **Agent 8** | [08-os-agent.md](08-os-agent.md) | `sbm-agent` | Optional guest OS daemon (boot-success confirmation & remote reboot) |
| **Agent 9** | [09-website.md](09-website.md) | `smart-boot-menu.github.io` | Official public website, docs portal & download index |
