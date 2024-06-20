#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath $0)")
ROOT_DIR=${SCRIPT_DIR}/../
BUILD_DIR=${ROOT_DIR}/build
ASTRA_SIM_DIR=${ROOT_DIR}/astra-sim

ANALYTICAL_SCRIPT=${ASTRA_SIM_DIR}/build/astra_analytical/build.sh
ANALYTICAL_AWARE_BIN=${ROOT_DIR}/build/AstraSim_Analytical_Congestion_Aware
ANALYTICAL_UNAWARE_BIN=${ROOT_DIR}/build/AstraSim_Analytical_Congestion_Unaware

function compile {
    mkdir -p ${BUILD_DIR}
    bash ${ANALYTICAL_SCRIPT}
    cp -f ${ASTRA_SIM_DIR}/build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Aware ${ANALYTICAL_AWARE_BIN}
    cp -f ${ASTRA_SIM_DIR}/build/astra_analytical/build/bin/AstraSim_Analytical_Congestion_Unaware ${ANALYTICAL_UNAWARE_BIN}
    echo -e "\033[32mcompile done\033[0m"
}

function clean {
    bash ${ANALYTICAL_SCRIPT} -l
    rm ${ANALYTICAL_AWARE_BIN}
    rm ${ANALYTICAL_UNAWARE_BIN}
    echo -e "\033[32mclean done\033[0m"
}

function check_bin {
    BIN_LIST=(${ANALYTICAL_AWARE_BIN} ${ANALYTICAL_UNAWARE_BIN})
    for BIN_FILE in "${BIN_LIST[@]}"; do
        if [ ! -f "$BIN_FILE" ]; then
            echo -e "\033[0;31mError: File $BIN_FILE does not exist.\033[0m"
            exit 1
        fi
    done
}

function verify_analytical {
    RESULT_DIR=${ROOT_DIR}/log/verify_analytical

    SYSTEM="${ROOT_DIR}/astra-sim/inputs/system/Switch.json"
    WORKLOAD="${ROOT_DIR}/example/demo/workload/Resnet50_DataParallel"
    NETWORK="${ROOT_DIR}/astra-sim/inputs/network/analytical/FullyConnected.yml"
    MEMORY="${ROOT_DIR}/astra-sim/inputs/remote_memory/analytical/no_memory_expansion.json"

    mkdir -p ${RESULT_DIR}
    
    "${ANALYTICAL_AWARE_BIN}" \
        --run-name="verify_analytical_aware" \
        --network-configuration="${NETWORK}" \
        --system-configuration="${SYSTEM}" \
        --workload-configuration="${WORKLOAD}" \
        --remote-memory-configuration="${MEMORY}" \
        --path="${RESULT_DIR}/aware"
    echo -e "\033[32mrun verify_analytical_aware done\033[0m"

    "${ANALYTICAL_UNAWARE_BIN}" \
        --run-name="verify_analytical_unaware" \
        --network-configuration="${NETWORK}" \
        --system-configuration="${SYSTEM}" \
        --workload-configuration="${WORKLOAD}" \
        --remote-memory-configuration="${MEMORY}" \
        --path="${RESULT_DIR}/unaware"
    echo -e "\033[32mrun verify_analytical_unaware done\033[0m"
}

case "$1" in
-c|--compile)
    compile;;
-l|--clean)
    clean;;
-v|--verify)
    check_bin
    verify_analytical;;
-a|--all)
    clean
    compile
    check_bin
    verify_analytical;;
-h|--help|*)
    echo "use -c|--compile  to compile project"
    echo "use -l|--clean    to clean build product"
    echo "use -v|--verify   to run test case"
    echo "use -a|--all      to compile and run test case"
    echo "use -h|--help     to get help info";;
esac
