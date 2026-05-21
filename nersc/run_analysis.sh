#!/bin/bash
# ============================================================
# NERSC Perlmutter — RUN O2Physics ANALYSIS
#
# Runs your analysis task using the O2Physics build in $SCRATCH.
# The entrypoint automatically loads alienv before the command.
#
# Prerequisites:
#   setup.sh must have been run at least once.
# ============================================================

#SBATCH --job-name=o2physics-run
#SBATCH --image=docker:mjkim1212/o2physics-builder:latest
#SBATCH --qos=regular
#SBATCH --constraint=cpu
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --time=12:00:00
#SBATCH --account=ALICE
# Mount both alice dir (build) and data dir
#SBATCH --output=logs/run_%j.out
#SBATCH --error=logs/run_%j.err

# ── Configuration ───────────────────────────────────────────

ALICE_DIR="/scratch/alice"
DATA_DIR="/scratch/data"          # put your AO2D.root here
OUTPUT_DIR="/scratch/output"

export ALIBUILD_WORK_DIR="$ALICE_DIR/sw"
export HOME="$ALICE_DIR"

mkdir -p "$OUTPUT_DIR"
cd "$OUTPUT_DIR"

# ── Run analysis ────────────────────────────────────────────
# The entrypoint loads 'alienv setenv O2Physics/latest'
# automatically, so your task binary is on PATH.

shifter o2-analysis-trackselection \
    --aod-file "$DATA_DIR/AO2D.root" \
    --configuration json:///"$DATA_DIR/dpl-config.json" \
    --aod-writer-json "$DATA_DIR/writer-config.json" \
    -b

echo "=== Output files ==="
ls -lh "$OUTPUT_DIR"
