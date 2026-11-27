# Smart Boot Menu — Workspace Task Runner
#
# Thin orchestration over existing tools (`cargo`, `sbm-lab`, `mkosi` scripts).
# Canonical location: `sbm/justfile` (optionally symlinked at workspace root).
#
# Principles:
#   - Default to the cheapest validation level (Level 0 host -> Level 1 native EFI
#     -> Level 2 incremental Linux -> Level 3 integration -> Level 4 release).
#   - Native host architecture is the default for local development.
#   - Heavy VM / full-image / release recipes are explicit and never run by default.
#   - Cleanup recipes are dry-run by default and never delete caches, release
#     evidence, backing images, or active builds automatically.

set shell := ["bash", "-euo", "pipefail", "-c"]

root := env_var_or_default("SBM_ROOT", if path_exists(source_directory() / "sbm-lab") == "true" { source_directory() } else { parent_directory(source_directory()) })
sbm_lab_bin := root / "sbm-lab/target/release/sbm-lab"

# Show available recipes grouped by development level.
[default]
help:
    @just --list --justfile "{{justfile()}}" --unsorted

# ── Status, Diagnostics & Storage (Level 0, read-only) ───────────────────────

# Check host toolchain, QEMU resource manager, memory pressure, and disk space.
[group('0-status')]
doctor:
    @echo "Workspace: {{root}} (host arch: $(uname -m))"
    @echo ""
    @echo "== Tools =="
    @for tool in cargo rustc just qemu-system-aarch64 qemu-system-x86_64 sccache cargo-nextest cargo-zigbuild limactl; do \
        if command -v "$tool" >/dev/null 2>&1; then \
            printf "  %-20s %s\n" "$tool" "$(command -v "$tool")"; \
        else \
            printf "  %-20s (not installed)\n" "$tool"; \
        fi; \
    done
    @echo ""
    @echo "== Host Resources =="
    @if [ -x "{{sbm_lab_bin}}" ]; then \
        "{{sbm_lab_bin}}" resources status; \
    else \
        echo "  sbm-lab release binary not built yet (build with: cargo build --release --manifest-path sbm-lab/Cargo.toml)"; \
    fi
    @echo ""
    @echo "== Disk Free =="
    @df -h "{{root}}"

# Show VM reservations, disk space, and compact git status across all repos.
[group('0-status')]
status:
    @if [ -x "{{sbm_lab_bin}}" ]; then "{{sbm_lab_bin}}" resources status; fi
    @echo ""
    @for repo in .github docs install research sbm sbm-agent sbm-as sbm-catalog sbm-common sbm-core sbm-lab sbm-server sbm-uefi smart-boot-menu.github.io; do \
        if [ -d "{{root}}/$repo/.git" ]; then \
            branch="$(git -C "{{root}}/$repo" status -sb | head -n 1)"; \
            dirty="$(git -C "{{root}}/$repo" status --porcelain | wc -l | tr -d ' ')"; \
            printf "  %-26s %-34s dirty=%s\n" "$repo" "$branch" "$dirty"; \
        fi; \
    done

# Report allocated vs apparent storage across SBM repos and caches (read-only).
[group('0-status')]
storage:
    @echo "== Per-repo allocated vs apparent disk usage =="
    @printf "  %-26s %10s %10s %10s\n" "REPO" "ALLOC" "APPARENT" "TARGET"
    @for repo in .github docs install research sbm sbm-agent sbm-as sbm-catalog sbm-common sbm-core sbm-lab sbm-server sbm-uefi smart-boot-menu.github.io; do \
        dir="{{root}}/$repo"; \
        if [ -d "$dir" ]; then \
            alloc="$(du -sh "$dir" 2>/dev/null | cut -f1)"; \
            app="$(du -shA "$dir" 2>/dev/null | cut -f1)"; \
            tgt="-"; \
            if [ -d "$dir/target" ]; then tgt="$(du -sh "$dir/target" 2>/dev/null | cut -f1)"; fi; \
            printf "  %-26s %10s %10s %10s\n" "$repo" "$alloc" "$app" "$tgt"; \
        fi; \
    done
    @echo ""
    @echo "== Key image & builder paths =="
    @for p in \
        "sbm-core/build/builder" \
        "sbm-core/build/images" \
        "sbm-core/build/evidence" \
        "install/build" \
        "sbm-lab/var" \
        "sbm-catalog/cache"; do \
        if [ -e "{{root}}/$p" ]; then \
            printf "  %-30s alloc=%-8s apparent=%s\n" "$p" "$(du -sh "{{root}}/$p" | cut -f1)" "$(du -shA "{{root}}/$p" | cut -f1)"; \
        fi; \
    done
    @echo ""
    @df -h "{{root}}"

# ── Level 0: Native Host Development & Unit Tests ────────────────────────────

# Run fast host unit tests. Target: 'fast' (default, <10s), 'all', or a repo name.
[group('1-level0-host')]
test target="fast" *args:
    @case "{{target}}" in \
        fast) \
            for repo in sbm-common sbm-as sbm-uefi sbm-core sbm-catalog sbm-server; do \
                echo "== Level 0 test: $repo =="; \
                (cd "{{root}}/$repo" && cargo test --offline {{args}}); \
            done ;; \
        all) \
            for repo in sbm-common sbm-as sbm-uefi sbm-core sbm-catalog sbm-server sbm-lab install; do \
                echo "== Level 0 test: $repo =="; \
                (cd "{{root}}/$repo" && cargo test --offline {{args}}); \
            done ;; \
        *) \
            test -d "{{root}}/{{target}}" || { echo "Unknown repo: {{target}}" >&2; exit 2; }; \
            echo "== Level 0 test: {{target}} =="; \
            if [ "{{target}}" = "install" ] && command -v cargo-nextest >/dev/null 2>&1 && [ "${SBM_NO_NEXTEST:-0}" != "1" ]; then \
                (cd "{{root}}/{{target}}" && cargo nextest run --offline {{args}}); \
            else \
                (cd "{{root}}/{{target}}" && cargo test --offline {{args}}); \
            fi ;; \
    esac

# Run fmt + clippy + unit tests for a single Rust repo.
[group('1-level0-host')]
check repo:
    @test -d "{{root}}/{{repo}}" || { echo "Unknown repo: {{repo}}" >&2; exit 2; }
    cd "{{root}}/{{repo}}" && cargo fmt --all -- --check
    cd "{{root}}/{{repo}}" && cargo clippy --all-targets -- -D warnings
    cd "{{root}}/{{repo}}" && cargo test --offline

# Level 0 static host preview of sbm-uefi software renderer (MOCK, not qualification).
[group('1-level0-host')]
preview-uefi *args:
    cd "{{root}}/sbm-uefi" && cargo run -p xtask -- preview {{args}}

# Level 0 interactive native SBM preview (owned by Agent 18; delegates when present).
[group('1-level0-host')]
preview *args:
    @if [ -n "${SBM_PREVIEW_CMD:-}" ]; then \
        exec ${SBM_PREVIEW_CMD} {{args}}; \
    elif [ -d "{{root}}/sbm-preview" ]; then \
        cd "{{root}}/sbm-preview" && cargo run -- {{args}}; \
    elif grep -q '"preview"' "{{root}}/sbm-core/crates/sbm-ui/Cargo.toml" 2>/dev/null; then \
        cd "{{root}}/sbm-core" && cargo run -p sbm-ui --features preview -- {{args}}; \
    else \
        echo "Interactive native preview (Agent 18) is not wired in this workspace yet."; \
        echo "Set SBM_PREVIEW_CMD or use 'just preview-uefi' for the static sbm-gfx mock render."; \
        exit 1; \
    fi

# ── Level 1: Minimal Native EFI Smoke Test ───────────────────────────────────

# Build sbm-uefi EFI binary (defaults to native host arch; pass 'all' for both).
[group('2-level1-efi')]
efi-build arch="native":
    cd "{{root}}/sbm-uefi" && cargo run -p xtask -- build "{{arch}}"

# Boot sbm-uefi in QEMU EFI smoke mode (defaults to native host arch / HVF).
[group('2-level1-efi')]
efi-smoke arch="native":
    cd "{{root}}/sbm-uefi" && cargo run -p xtask -- qemu "{{arch}}"

# ── Level 2: Incremental Linux Development (sbm-core) ────────────────────────

# Start the persistent ARM64 Linux builder VM (respects sbm-lab resource manager).
[group('3-level2-linux')]
builder-start:
    "{{root}}/sbm-core/scripts/start-builder.sh" start

# Stop the persistent Linux builder VM cleanly.
[group('3-level2-linux')]
builder-stop:
    "{{root}}/sbm-core/scripts/start-builder.sh" stop

# Check Linux builder VM status.
[group('3-level2-linux')]
builder-status:
    "{{root}}/sbm-core/scripts/start-builder.sh" status

# Reclaim unused QCOW2 blocks inside the Linux builder VM via fstrim.
[group('3-level2-linux')]
builder-trim:
    "{{root}}/sbm-core/scripts/start-builder.sh" trim

# Incremental Linux Core build (default: dev profile, native arch, uncompressed).
[group('3-level2-linux')]
core-build profile="dev" arches="":
    SBM_BUILD_PROFILE="{{profile}}" SBM_ARCHES="{{arches}}" "{{root}}/sbm-core/scripts/sync-and-build.sh"

# Fast single-crate Cargo build inside the running Linux builder (~5s warm).
[group('3-level2-linux')]
core-cargo pkg="sbm-cored" *args:
    "{{root}}/sbm-core/scripts/start-builder.sh" ssh -- \
        "cd ~/src/sbm-core && cargo build -p {{pkg}} {{args}}"

# Zero-VM macOS->Linux cross-build via cargo-zigbuild (~0.5s warm for sbm-cored/sbm-runtime).
[group('3-level2-linux')]
core-zigbuild pkg="sbm-cored" target="aarch64-unknown-linux-gnu" *args:
    cd "{{root}}/sbm-core" && cargo zigbuild -p "{{pkg}}" --target "{{target}}" {{args}}

# Boot a disposable QCOW2 overlay of the local sbm-core image.
[group('3-level2-linux')]
core-smoke arch="arm64":
    "{{root}}/sbm-core/scripts/boot-smoke.sh" "{{arch}}"

# ── Level 3: Full-System Integration (explicit, heavy) ───────────────────────

# Run sbm-lab firmware smoke tier (checks resource manager).
[group('4-level3-integration')]
lab-smoke:
    @test -x "{{sbm_lab_bin}}" || (cd "{{root}}/sbm-lab" && cargo build --release)
    "{{sbm_lab_bin}}" test --tier smoke

# Run full graphical recovery integration gate on a raw image (explicit).
[group('4-level3-integration')]
lab-integration image *args:
    @test -x "{{sbm_lab_bin}}" || (cd "{{root}}/sbm-lab" && cargo build --release)
    "{{sbm_lab_bin}}" test --tier integration --image "{{image}}" {{args}}

# ── Level 4: Release Qualification (explicit, heavy, dual-arch) ──────────────

# Build full dual-arch compressed sbm-core release artifacts (heavy!).
[group('5-level4-release')]
release-core:
    SBM_BUILD_PROFILE=release "{{root}}/sbm-core/scripts/sync-and-build.sh"

# Assemble release media from lockfile (set SBM_COMPRESS=0 for uncompressed dev check).
[group('5-level4-release')]
release-media lock="media/0.0.1.lock.toml" *args:
    cd "{{root}}/install" && ./scripts/build-media.sh "{{lock}}" {{args}}

# Verify bit-for-bit media reproducibility (prunes duplicate images automatically).
[group('5-level4-release')]
release-repro lock="media/0.0.1.lock.toml" *args:
    cd "{{root}}/install" && ./scripts/check-reproducible.sh "{{lock}}" {{args}}

# ── Safe Maintenance (Dry-Run Default) ───────────────────────────────────────

# Inspect reclaimable Cargo target and scratch space without deleting anything.
[group('6-maintenance')]
clean-dry-run:
    @echo "== Dry-run storage report (NO files will be deleted) =="
    @for repo in sbm-common sbm-as sbm-uefi sbm-core sbm-catalog sbm-server sbm-lab install; do \
        if [ -d "{{root}}/$repo/target" ]; then \
            printf "  %-14s target/ = %s\n" "$repo" "$(du -sh "{{root}}/$repo/target" | cut -f1)"; \
        fi; \
    done
    @echo ""
    @echo "Protected paths (never auto-cleaned): sbm-core/build/evidence, install/build/out/release,"
    @echo "sbm-lab/var/runs/int-*, sbm-catalog/cache, ~/.cargo/registry."
    @echo ""
    @echo "Safe manual actions when needed:"
    @echo "  just builder-trim                  # Reclaim deleted guest blocks in builder disk.qcow2"
    @echo "  cargo clean --dry-run              # Inspect per-repo Cargo artifacts before cleaning"
