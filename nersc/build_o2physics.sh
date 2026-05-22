#!/bin/bash
# ============================================================
# NERSC Perlmutter — INCREMENTAL O2Physics BUILD
#
# Rebuilds only O2Physics (and nothing else).
# All dependencies (ROOT, O2, ...) are already in CFS/sw
# from the first-time setup.sh run.
#
# Typical use:
#   1. Edit your task in $ALICE_DIR/O2Physics/
#   2. sbatch nersc/build_o2physics.sh
#   3. sbatch nersc/run_analysis.sh
#
# Build time after a small change: ~10-30 minutes
# ============================================================

#SBATCH --job-name=o2physics-build
#SBATCH --image=docker:mjkim1212/o2physics-builder:latest
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --time=01:00:00
#SBATCH --account=alice
# CFS is globally accessible inside Shifter — no --volume needed.
#SBATCH --output=logs/build_%j.out
#SBATCH --error=logs/build_%j.err

# ── Configuration ───────────────────────────────────────────

ALICE_DIR="/global/cfs/cdirs/alice/mjkim/alice"

export HOME="$ALICE_DIR"
export ALIBUILD_WORK_DIR="$ALICE_DIR/sw"

# Pre-create analytics disable file (safe to re-run)
mkdir -p "$HOME/.config/alibuild"
touch "$HOME/.config/alibuild/disable-analytics"

# ── Incremental build ───────────────────────────────────────

cd "$ALICE_DIR"

echo "=== Incremental O2Physics build ==="
echo "Source : $ALICE_DIR/O2Physics"
echo "Output : $ALIBUILD_WORK_DIR"
echo "Cores  : $(nproc)"

# aliBuild is smart: it hashes each package.
# If dependencies haven't changed, only O2Physics is rebuilt.
aliBuild build O2Physics \
    --defaults o2 \
    --jobs "$(nproc)"

echo "=== Build finished ==="
alienv q | grep O2Physics
