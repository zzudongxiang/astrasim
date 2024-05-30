#!/bin/bash
set -e

# Path
RUN_NAME="ASCEND_910B"
SCRIPT_DIR="$(dirname "$(realpath $0)")"
CONGESTION_AWARE_BIN="${SCRIPT_DIR}/../astra-sim/build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Aware"
CONGESTION_UNAWARE_BIN="${SCRIPT_DIR}/../astra-sim/build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Unaware"
RESULT_DIR="${SCRIPT_DIR}/log"

# Inputs
NETWORK="${SCRIPT_DIR}/inputs/network.yml"
SYSTEM="${SCRIPT_DIR}/inputs/system.json"
WORKLOAD="${SCRIPT_DIR}/inputs/two_comp_nodes_independent"
MEMORY="${SCRIPT_DIR}/inputs/memory.json"

# 1. Setup
rm -rf "${RESULT_DIR}"
mkdir -p "${RESULT_DIR}"

# 2. Run ASTRA-sim
"${CONGESTION_UNAWARE_BIN}" \
    --run-name="${RUN_NAME}" \
    --network-configuration="${NETWORK}" \
    --system-configuration="${SYSTEM}" \
    --workload-configuration="${WORKLOAD}" \
    --remote-memory-configuration="${MEMORY}" \
    --path="${RESULT_DIR}/"
