#!/bin/bash
set -e

# Path
SCRIPT_DIR="$(dirname "$(realpath $0)")"
BINARY="${SCRIPT_DIR}/../build/analytical/AnalyticalAstra/bin/AnalyticalAstra"
RESULT_DIR="${SCRIPT_DIR}/log/"

# Inputs
NETWORK="${SCRIPT_DIR}/inputs/network/fullyconnected.json"
SYSTEM="${SCRIPT_DIR}/inputs/system/fullyconnected.txt"
WORKLOAD_DIR="${SCRIPT_DIR}/inputs/workload/"

# Run ASTRA-sim
WORKLOAD_LIST=(allgather allreduce alltoall broadcast reducescatter)
WORKLOAD_CNT=${#WORKLOAD_LIST[@]}

SIZE_LIST=(8 16 32 64 128 256 512 1024 2048 4096 8192 16384 32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216 33554432 67108864 134217728 268435456 536870912 1073741824 2147483648)
SIZE_CNT=${#SIZE_LIST[@]}

for i in `seq 0 $[${WORKLOAD_CNT}-1]`; do
    WORKLOAD_NAME=${WORKLOAD_LIST[$i]}
    WORKLOAD=${WORKLOAD_DIR}/${WORKLOAD_NAME}.txt

    rm -rf "${RESULT_DIR}/${WORKLOAD_NAME}/"
    mkdir -p "${RESULT_DIR}/${WORKLOAD_NAME}/"

    for j in `seq 0 $[${SIZE_CNT}-1]`; do
        SIZE=${SIZE_LIST[$j]}
        "${BINARY}" \
            --run-name="Ascend_910B_${SIZE}" \
            --network-configuration="${NETWORK}" \
            --system-configuration="${SYSTEM}" \
            --workload-configuration="${WORKLOAD}" \
            --comm-scale="${SIZE}.0" \
            --path="${RESULT_DIR}/${WORKLOAD_NAME}/" \
            --total-stat-rows=${SIZE_CNT} \
            --stat-row=${j}
    done
done
