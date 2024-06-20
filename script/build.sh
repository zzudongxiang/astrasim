#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath $0)")
BUILD_DIR=${SCRIPT_DIR}/../build
ASTRA_SIM_DIR=${SCRIPT_DIR}/../astra-sim

NS3_SCRIPT=${ASTRA_SIM_DIR}/build/astra_ns3/build.sh
ANALYTICAL_SCRIPT=${ASTRA_SIM_DIR}/build/astra_analytical/build.sh

function setup {
    mkdir -p ${BUILD_DIR}
}

function compile {
    bash ${NS3_SCRIPT} -c
    bash ${ANALYTICAL_SCRIPT}
    cp ${ASTRA_SIM_DIR}/extern/network_backend/ns-3/build/scratch/* ${BUILD_DIR}
    cp ${ASTRA_SIM_DIR}/build/astra_analytical/build/bin/* ${BUILD_DIR}
}

function clean {
    bash ${NS3_SCRIPT} -l
    bash ${ANALYTICAL_SCRIPT} -l
    rm -rf ${BUILD_DIR}/*
}

# Main Script
case "$1" in
-l|--clean)
    clean;;
-c|--compile)
    setup
    compile;;
-h|--help|*)
    printf "use bash <script_path>/build.sh -c to compile\n"
    printf "use bash <script_path>/build.sh -l to clean\n";;
esac

