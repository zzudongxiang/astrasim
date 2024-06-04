#!/bin/bash
set -e

# path and paramters
NUM_THREADS=$(nproc)
SCRIPT_DIR=$(dirname "$(realpath $0)")

# build astra_analytical
BUILD_DIR="${SCRIPT_DIR}/build/analytical"
ANALYTICAL_DIR="${SCRIPT_DIR}/astra-sim/build/astra_analytical"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit
cmake "${ANALYTICAL_DIR}"
cmake --build . --parallel "${NUM_THREADS}"

# build astra_congestion
BUILD_DIR="${SCRIPT_DIR}/build/congestion"
CONGESTION_DIR="${SCRIPT_DIR}/astra-sim/build/astra_congestion"
mkdir -p "${BUILD_DIR}"
cd "${BUILD_DIR}" || exit
cmake "${CONGESTION_DIR}"
cmake --build . --parallel "${NUM_THREADS}"
