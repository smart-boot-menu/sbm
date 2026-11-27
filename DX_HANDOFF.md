# Agent 16 Handoff — Developer Experience, Build Systems & Resource Optimization (Track B)

**Date:** 2026-11-26  
**Owner Role:** Agent 16 — Lead Developer Tooling, Build Systems, Performance & Resource Efficiency Engineer  
**Tracking Issue:** [`smart-boot-menu/sbm#4`](https://github.com/smart-boot-menu/sbm/issues/4)  
**Coordinated With:** Agent 11 (`docs` / `sbm` ADR-009, ADR-011, Spec 07), Agent 13 (`sbm-core` / `sbm-lab` graphical recovery), Agent 18 (`sbm#3` Track A interactive native UI preview)  
**Host Measured:** Fanless Apple M5 MacBook Air (`aarch64`, 10 CPUs, 16 GiB RAM, 460 GiB APFS, macOS Darwin 27.0.0, `rustc`/`cargo` `1.100.0`, QEMU `11.1.3`)

---

## 1. Summary of Landed Commits

| Repository | Commit(s) | Scope |
|---|---|---|
| [`sbm-uefi`](https://github.com/smart-boot-menu/sbm-uefi) | `e397e34` | Level 0 static host `sbm-gfx` software-renderer preview (`xtask preview`, `166.9 ms`, labeled `MOCK`) and native-arch default for `xtask build` / `qemu`. |
| [`install`](https://github.com/smart-boot-menu/install) | `af37d98`, `b11c427` | Prune duplicate `check-reproducible.sh` images after SHA-256 verification; add `--no-compress` / `SBM_COMPRESS=0` dev option to `build-media.sh`; fix `e2e.rs` `OnceLock<TempDir>` leak and make `shared_media` process-safe for `cargo-nextest`; re-export `FatType` in `sbm-media::esp`. |
| [`sbm-core`](https://github.com/smart-boot-menu/sbm-core) | `098921f` | Add `SBM_BUILD_PROFILE=dev\|integration\|release` (default `dev`: native arch, `mkosi --incremental=yes`, uncompressed), skip unchanged `.zst` recompression in `finalize-image.py`, add QCOW2 `discard=unmap` + `start-builder.sh trim`, and boot disposable QCOW2 overlays in `boot-smoke.sh`. |
| [`sbm-lab`](https://github.com/smart-boot-menu/sbm-lab) | `0794b0c`, `142a0bb`, `c3448d9` | Consolidate duplicated `gpt.rs` and `fatimg.rs` onto `install/crates/sbm-media` (**net −269 LOC**, drops `crc32fast` + `fatfs`, eliminates ~1.5 GiB peak heap copy in `integration.rs`); add experimental `os-autoinst` (`isotovideo:qemu-kvm`) Linux CI prototype while preserving all existing test tiers. |
| [`.github`](https://github.com/smart-boot-menu/.github) | `aa22b6e` | Document tiered Levels 0–4 workflow, native-arch default, `just`, `sbm-lab resources`, Agent 18 preview ownership, and dry-run cleanup in `AGENTS.md` and `agent-reference.md` (also removed duplicated §4). |
| [`sbm`](https://github.com/smart-boot-menu/sbm) | `de40351`, this handoff | Add thin workspace [`justfile`](justfile) composing `cargo`, `cargo-nextest`, `cargo-zigbuild`, `xtask`, `sbm-core` scripts, and `sbm-lab` (with `just preview` hook for Agent 18); clean stray line in `RELEASE_GATES.md`. |
| [`docs`](https://github.com/smart-boot-menu/docs) | `9c5a62d` (with Agent 11), workflow commit | Align ADR-009 & Spec 07 (single-arch recommended, dual-arch experimental/optional, native-arch dev default); add [`testing/development-workflow.md`](https://github.com/smart-boot-menu/docs/blob/main/testing/development-workflow.md) and link from `docs/README.md`. |
| [`research`](https://github.com/smart-boot-menu/research) | `a8af50b`, evidence commit | Open-source dev infrastructure landscape & `sbm-lab` (9,805 LOC) build-vs-reuse audit (`ecosystem/dev-infrastructure-and-testing-landscape-2026-11-26.md`) and full measured before/after benchmarks (`validation/evidence/sbm-dev-resource-audit-2026-11-26.md`). |

---

## 2. Measured Before-and-After Results

| Area | Before | After | Evidence / Notes |
|---|---:|---:|---|
| Host SSD allocated (workspace) | `54.53 GiB` (`154 GiB` free) | `46.45 GiB` (`166.8 GiB` free) | **`13.24 GiB` safely reclaimed** (`fstrim -3.63 GiB`, `repro/{a,b} -6.69 GiB`, APFS CoW `cp -c -2.56 GiB`, leaked tempdirs + merged worktrees `-0.35 GiB`). |
| `sbm-uefi` visual UI feedback | Full QEMU boot | **`166.9 ms`** (`just preview-uefi`) | Level 0 software renderer (`MOCK`; Agent 18 owns interactive Track A preview via `just preview`). |
| `install` full test suite (61 tests) | `85.05 s` (`cargo test`) | **`46.33 s`** (`cargo nextest`) | **`1.84×` faster**, `−56%` sys CPU after process-safe `shared_media` (`b11c427`). |
| `sbm-cored` ARM64 Linux incremental build | `5.09 s` inside `4 GiB` Linux VM | **`0.50 s` on macOS (`0 MiB` VM RAM)** via `just core-zigbuild` | `cargo-zigbuild 0.24.1` (`9.14 s` cold, `262 MiB` target); in-VM warm rebuild is `0.31 s` once VM is running. |
| `sbm-core` default dev image pipeline | Dual-arch + `zstd -19` (`659 s`: 39% zstd, 33% x86 TCG) | Single-arch native `arm64`, `mkosi --incremental=yes`, uncompressed | Removes the 260 s zstd and 215 s x86-64 TCG bottlenecks from ordinary dev loops (`098921f`). |
| `sbm-lab` GPT/FAT duplication | Duplicate `gpt.rs` (324 LOC) + `fatimg.rs` (80 LOC) + `1.5 GiB` ESP RAM copy | Thin `sbm-media` adapter (**−269 LOC**) + direct `File` reads | Verified green in Linux CI: [`runs/45946390386`](https://github.com/smart-boot-menu/sbm-lab/actions/runs/45946390386) (`1m 45s`). |
| `os-autoinst` Linux KVM CI prototype | None (custom Rust QMP harness only) | Live `isotovideo:qemu-kvm` UEFI probe workflow | Verified green in Linux CI: [`runs/45946390417`](https://github.com/smart-boot-menu/sbm-lab/actions/runs/45946390417) (`1m 14s`); existing `sbm-lab` tiers preserved. |

---

## 3. Evidence-Backed Build-vs-Reuse Decisions

1. **Lima `2.3.0` + `krunkit 1.3.2` (`libkrun 1.19.8`) vs QEMU HVF Builder -> DEFER MIGRATION:**
   - Lima + `krunkit` booted **`1.85×` faster** (`8.83 s` vs `16.32 s`), mounted sources at `0.00 s` via `virtiofs`, matched `0.31 s` warm incremental Cargo builds, and supported `fstrim` + `unshare -r`.
   - **Blocking gap verified empirically:** `lima 2.3.0` + `krunkit 1.3.2` do not attach a `virtio-balloon` device yet (upstream `krunkit#121`), so host memory climbed to `2018 MiB` (after 1 GiB `/dev/urandom` alloc + free) and `3782 -> 3756 MiB` (after `dnf` + `cargo` + clean), reclaiming **0 MiB** — no better than QEMU HVF on our 16 GiB Mac.
   - Keep `sbm-core/scripts/start-builder.sh` (with native `sbm-lab resources` admission) as default for `mkosi`, use `just core-zigbuild` (`0 MiB` VM RAM) for pure-Rust daemon iteration, keep QEMU for firmware testing, and re-trial Lima + `krunkit` once `krunkit#121` lands balloon reclaim.
2. **`sccache 0.20.1` (`SCCACHE_ALLOW_INCREMENTAL=1`) -> OPT-IN ONLY:**
   - Improved fresh-worktree `sbm-server` rebuilds by `24%` (`25.85 s -> 19.64 s`, `85.5%` hit rate), but regressed cold builds by `+27%` (`32.89 s`) and cross-repo `sbm-core` builds by `+29%` (`14.86 s -> 19.15 s`, `13.8%` hit rate) while adding `519 MiB` of cache.
   - Recommend Cargo `1.100.0` `build-dir = "{cargo-cache-home}/build/{workspace-path-hash}"` locally and `sccache` only in CI or repeated fresh `sbm-server` worktrees.
3. **Root `justfile` (`sbm/justfile`) -> ADOPTED:** Replaces any bespoke `sbm-dev` CLI with ~250 lines of thin declarative recipes grouped by Levels 0–4.
4. **`labgrid` -> DEFERRED:** Wait until Tier 3 physical hardware testing requirements justify it.
5. **`sbm-lab` Naming & Scope:** Kept un-renamed; narrowed toward thin host resource admission (`resources.rs`), firmware smoke, and macOS HVF integration while prototyping `os-autoinst` in Linux CI.

---

## 4. Coordination & Remaining Follow-Ups

- **Agent 18 (`sbm#3` Track A):** `sbm/justfile` includes `just preview` (checks `SBM_PREVIEW_CMD`, `sbm-preview/`, or `sbm-core` `sbm-ui --features preview`, falling back with guidance to `just preview-uefi`). Agent 18 can update the `preview` recipe directly when Track A lands.
- **Agent 11 (`docs` / `sbm`):** ADR-009, Spec 07, ADR-011, and `RELEASE_GATES.md` are aligned on single-arch recommended / dual-arch optional experimental / native-arch dev defaults.
- **Deferred safe cleanup candidates (require explicit confirmation):**
  - Inside `sbm-core/build/builder/disk.qcow2`: guest `build/images` (`5.9 GiB`) + `target/debug` (`2.4 GiB`), followed by `just builder-trim` (up to `~8.3 GiB` reclaimable).
  - `sbm-core/build/images/*-software.raw` (`2.56 GiB`) if no longer referenced by Agent 13's `ramfb` checks.
  - Non-`int-*` historical runs in `sbm-lab/var/runs/` (`251 MiB`).
- **Next engineering milestones for Track B:**
  - Re-benchmark Lima + `krunkit` once `krunkit#121` ships `libkrun` Replace-mode balloon wiring.
  - Expand `sbm-lab/prototypes/os-autoinst/` with visual needles for `sbm-uefi` menu and `sbm-ui` screens before deciding whether to retire `sbm-lab`'s custom QMP test harness in Linux CI.
  - Evaluate `mkosi --format=sysext` / `systemd-sysext --mutable=ephemeral` on a running `sbm-core` dev overlay once iterative `sbm-ui`/`sbm-cored` Linux testing volume grows.
