#!/bin/bash
set -e

SCRIPT_DIR=$(dirname "$(realpath $0)")
ROOT_DIR=${SCRIPT_DIR}/../

source ${ROOT_DIR}/.env
cd ${ROOT_DIR}

NS3_SCRIPT=${ASTRASIM_DIR}/build/astra_ns3/build.sh

function compile {
    mkdir -p ${BUILD_DIR}
    bash ${NS3_SCRIPT} -c
    cp ${ASTRASIM_DIR}/extern/network_backend/ns-3/build/scratch/${ASTRASIM_NS3_BIN_NAME} ${ASTRASIM_NS3_BIN}
    echo -e "\033[32mcompile done\033[0m"
}

function clean {
    bash ${NS3_SCRIPT} -l
    rm -f ${ASTRASIM_NS3_BIN}
    echo -e "\033[32mclean done\033[0m"
}

function check_bin {
    BIN_LIST=(${ASTRASIM_NS3_BIN})
    for BIN_FILE in "${BIN_LIST[@]}"; do
        if [ ! -f "$BIN_FILE" ]; then
            echo -e "\033[0;31mError: File $BIN_FILE does not exist.\033[0m"
            exit 1
        fi
    done
}

function verify_astrasim_ns3 {
    RESULT_DIR=${ROOT_DIR}/log/verify_astrasim_ns3
    mkdir -p ${RESULT_DIR}

    "${ASTRASIM_NS3_BIN}" \
        --workload-configuration="${WORKLOAD}" \
        --system-configuration="${SYSTEM}" \
        --network-configuration="${ASTRASIM_NS3_NETWORK}" \
        --logical-topology-configuration="${ASTRASIM_NS3_LOGICAL_TOPOLOGY}" \
        --remote-memory-configuration="${MEMORY}" \
        --comm-group-configuration=\"empty\"
    echo -e "\033[32mrun verify_astrasim_ns3 done\033[0m"
}

case "$1" in
-c|--compile)
    compile;;
-l|--clean)
    clean;;
-v|--verify)
    check_bin
    verify_astrasim_ns3;;
-a|--all)
    clean
    compile
    check_bin
    verify_astrasim_ns3;;
-h|--help|*)
    echo "use -c|--compile  to compile project"
    echo "use -l|--clean    to clean build product"
    echo "use -v|--verify   to run test case"
    echo "use -a|--all      to compile and run test case"
    echo "use -h|--help     to get help info";;
esac

cd -
