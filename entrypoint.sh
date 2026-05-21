#!/bin/bash
# ============================================================
# Container entrypoint
#
# If O2Physics has been built on $SCRATCH (ALIBUILD_WORK_DIR
# is set and O2Physics/latest exists), load that environment.
# Otherwise just open a plain shell so the user can run
# o2-setup or o2-build first.
# ============================================================

set -e

ALIENV="$(command -v alienv 2>/dev/null)"

# Check whether an O2Physics build exists in ALIBUILD_WORK_DIR
if [[ -n "$ALIBUILD_WORK_DIR" ]] && \
   [[ -d "$ALIBUILD_WORK_DIR" ]] && \
   "$ALIENV" q 2>/dev/null | grep -q "^O2Physics/"; then

    echo "[entrypoint] Loading O2Physics from $ALIBUILD_WORK_DIR"
    exec "$ALIENV" setenv O2Physics/latest -c "${@:-bash}"

else
    if [[ -z "$ALIBUILD_WORK_DIR" ]]; then
        echo "[entrypoint] WARNING: ALIBUILD_WORK_DIR is not set."
        echo "             Set it to your \$SCRATCH path, e.g.:"
        echo "             export ALIBUILD_WORK_DIR=/scratch/alice/sw"
    else
        echo "[entrypoint] O2Physics not yet built in $ALIBUILD_WORK_DIR."
        echo "             Run 'o2-setup' for first-time installation,"
        echo "             or 'o2-build' for an incremental rebuild."
    fi
    exec "${@:-bash}"
fi
