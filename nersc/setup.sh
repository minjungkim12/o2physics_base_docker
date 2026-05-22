#!/bin/bash
# ============================================================
# NERSC Perlmutter — FIRST-TIME SETUP
#
# Clones O2Physics (or your fork) and builds the full stack
# (ROOT, O2, and all dependencies) into CFS.
#
# Run ONCE. Takes 2-5 hours (downloads precompiled binaries
# for most packages on AlmaLinux 9).
# After this, only 'build_o2physics.sh' is needed for updates.
#
# Usage:
#   sbatch nersc/setup.sh
# ============================================================

#SBATCH --job-name=o2physics-setup
#SBATCH --image=docker:mjkim1212/o2physics-builder:latest
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --time=06:00:00
#SBATCH --account=alice
# CFS is globally accessible inside Shifter — no --volume needed.
#SBATCH --output=logs/setup_%j.out
#SBATCH --error=logs/setup_%j.err

# ── User configuration ──────────────────────────────────────

# Your O2Physics fork (or the official repo)
O2PHYSICS_REPO="https://github.com/AliceO2Group/O2Physics"
# Branch to build (master = latest daily)
O2PHYSICS_BRANCH="master"

# Install directory on CFS (writable, persistent)
ALICE_DIR="/global/cfs/cdirs/alice/mjkim/alice"

# ── Setup ───────────────────────────────────────────────────

mkdir -p "$ALICE_DIR"
cd "$ALICE_DIR"

# aliBuild needs a writable HOME (Docker sets HOME=/opt/alice which is
# read-only in Shifter — override it here to the CFS path)
export HOME="$ALICE_DIR"
export ALIBUILD_WORK_DIR="$ALICE_DIR/sw"

# Pre-create analytics disable file so aliBuild doesn't ask interactively
mkdir -p "$HOME/.config/alibuild"
touch "$HOME/.config/alibuild/disable-analytics"

echo "=== Initialising O2Physics source ==="
echo "ALICE_DIR          = $ALICE_DIR"
echo "ALIBUILD_WORK_DIR  = $ALIBUILD_WORK_DIR"

# aliBuild init clones O2Physics + alidist (build recipes)
if [[ ! -d "$ALICE_DIR/O2Physics" ]]; then
    aliBuild init "O2Physics@${O2PHYSICS_BRANCH}"
else
    echo "O2Physics already cloned — pulling latest..."
    cd "$ALICE_DIR/O2Physics"
    git fetch --all --tags
    git checkout "$O2PHYSICS_BRANCH"
    git pull --rebase
    cd "$ALICE_DIR"
fi

echo "=== Building O2Physics (full stack) ==="

# AlmaLinux 9: aliBuild downloads precompiled binaries for most
# packages. Only O2Physics itself is compiled from source.
aliBuild build O2Physics \
    --defaults o2 \
    --jobs "$(nproc)"

echo "=== Done! ==="
echo ""
echo "Verify your build:"
echo "  alienv q"
echo ""
echo "Next steps:"
echo "  - Edit source in $ALICE_DIR/O2Physics/"
echo "  - Run sbatch nersc/build_o2physics.sh to rebuild"
echo "  - Run sbatch nersc/run_analysis.sh to run analysis"
