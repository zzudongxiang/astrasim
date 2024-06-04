#!/bin/bash
set -e

# build hccl_test
SCRIPT_DIR="$(dirname "$(realpath $0)")"
RESULT_DIR="${SCRIPT_DIR}/../log/hccl/"
HCCL_TEST=/usr/local/Ascend/ascend-toolkit/latest/tools/hccl_test
cd ${HCCL_TEST}
make ASCEND_DIR=/usr/local/Ascend/ascend-toolkit/latest
cd ${SCRIPT_DIR}

# clean folder
rm -rf ${RESULT_DIR}/
mkdir -p ${RESULT_DIR}/

# run hccl_test
HCCL_BIN=${HCCL_TEST}/bin/
HCCL_LIST=(all_gather_test all_reduce_test alltoall_test reduce_scatter_test)
HCCL_CNT=${#HCCL_LIST[@]}
for i in `seq 0 $[${HCCL_CNT}-1]`; do
    HCCL_TOOL=${HCCL_LIST[$i]}
    mpirun -n 8 ${HCCL_BIN}/${HCCL_TOOL} \
        -b 8 \
        -e 2048M \
        -f 2 \
        -p 8 > ${RESULT_DIR}/${HCCL_TOOL}.log
    echo ${HCCL_TOOL} test done...
done
