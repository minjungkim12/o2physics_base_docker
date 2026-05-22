#!/bin/bash
# ============================================================
# NERSC Perlmutter — INCREMENTAL O2Physics BUILD
#
# Rebuilds only O2Physics (and nothing else).
# All dependencies (ROOT, O2, ...) are already in $SCRATCH/sw
# from the first-time setup.sh run.
#
# Typical use:
#   1. Edit your task in $SCRATCH/alice/O2Physics/
#   2. sbatch nersc/build_o2physics.sh
#   3. sbatch nersc/run_analysis.sh
#
# Build time after a small change: ~10-30 minutes
# ============================================================

#SBATCH --job-name=o2physics-build
#SBATCH --image=docker:YOURDOCKERHUBID/o2physics-builder:latest
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --time=01:00:00
#SBATCH --account=YOUR_NERSC_PROJECT
#SBATCH --volume="/global/cfs/cdirs/alice/mjkim:/scratch"
#SBATCH --output=logs/build_%j.out
#SBATCH --error=logs/build_%j.err

# ── Configuration ───────────────────────────────────────────

ALICE_DIR="/scratch/alice"
export ALIBUILD_WORK_DIR="$ALICE_DIR/sw"
export HOME="$ALICE_DIR"

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
