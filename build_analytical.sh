#!/bin/bash
set -e

SCRIPT_DIR="$(dirname "$(realpath $0)")"
BUILD_DIR="${SCRIPT_DIR}/build/analytical"
ANALYTICAL_DIR="${SCRIPT_DIR}/astra-sim/build/astra_analytical"
NUM_THREADS=$(nproc)

# Setup
mkdir -p "${BUILD_DIR}"

# Build
cd "${BUILD_DIR}" || exit
cmake "${ANALYTICAL_DIR}"
cmake --build . --parallel "${NUM_THREADS}"
