# ============================================================
# O2Physics BUILD ENVIRONMENT for NERSC Perlmutter / Shifter
#
# This image is a BUILD TOOLCHAIN, not a pre-built binary image.
#
# What's inside:
#   - AlmaLinux 9 (aliBuild officially supported)
#   - alice-o2-full-deps  (all O2 system-level dependencies)
#   - alibuild + alienv   (ALICE build & environment tool)
#
# What's NOT inside:
#   - Compiled O2Physics or its dependencies (ROOT, O2, ...)
#
# Those live on NERSC $SCRATCH, mounted at runtime with --volume.
# This keeps the image small (~2-3 GB) and lets you freely
# modify O2Physics source and do incremental rebuilds.
#
# Workflow on NERSC:
#   First time : sbatch nersc/setup.sh        (hours, one-time)
#   After edit : sbatch nersc/build_o2physics.sh  (minutes)
#   Run analysis: sbatch nersc/run_analysis.sh
# ============================================================

FROM almalinux:9

LABEL maintainer="minjung.kim.hi@gmail.com"
LABEL description="O2Physics build environment — Shifter compatible, source on NERSC scratch"

# ------------------------------------------------------------
# 1. System packages + aliBuild
# ------------------------------------------------------------
COPY alice-system-deps.repo /etc/yum.repos.d/alice-system-deps.repo

RUN dnf install -y epel-release dnf-plugins-core && \
    dnf update -y && \
    dnf config-manager --set-enabled crb && \
    dnf group install -y 'Development Tools' && \
    dnf update -y && \
    # alice-o2-full-deps: single meta-package for all O2 system deps
    # alibuild: ALICE build & environment management tool
    dnf install -y alice-o2-full-deps alibuild git && \
    dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum

# ------------------------------------------------------------
# 2. Create 'alice' user
#    aliBuild refuses to run as root.
#    Home → /opt/alice (safe from Shifter overwrite).
#    Shifter remaps this to the NERSC user at runtime anyway.
# ------------------------------------------------------------
RUN useradd -m -d /opt/alice -s /bin/bash alice && \
    # Allow any NERSC user to use the alice home dir structure
    chmod 755 /opt/alice

# ------------------------------------------------------------
# 3. Verify aliBuild is working (fast sanity check)
# ------------------------------------------------------------
RUN aliBuild --version && alienv --help > /dev/null

# ------------------------------------------------------------
# 4. Copy helper scripts into the image
# ------------------------------------------------------------
COPY --chmod=755 entrypoint.sh     /usr/local/bin/entrypoint.sh
COPY --chmod=755 nersc/setup.sh    /usr/local/bin/o2-setup
COPY --chmod=755 nersc/build_o2physics.sh /usr/local/bin/o2-build

# Ensure scripts are world-executable (Shifter root-squash)
RUN chmod a+rx /usr/local/bin/entrypoint.sh \
               /usr/local/bin/o2-setup \
               /usr/local/bin/o2-build

# ------------------------------------------------------------
# 5. Runtime defaults
#    ALIBUILD_WORK_DIR is intentionally NOT set here.
#    It must point to a writable $SCRATCH path at runtime.
# ------------------------------------------------------------
USER alice
ENV HOME=/opt/alice

WORKDIR /opt/alice

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["bash"]
