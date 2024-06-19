#!/bin/bash

SCRIPT_DIR=$(dirname "$(realpath $0)")
BUILD_DIR=${SCRIPT_DIR}/../build
ROOT_DIR=${SCRIPT_DIR}/../astra-sim

NS3_DIR=${ROOT_DIR}/extern/network_backend/ns-3
CHARA_DIR=${ROOT_DIR}/extern/graph_frontend/chakra

protoc et_def.proto\
    --proto_path ${CHARA_DIR}/et_def/ \
    --cpp_out ${CHARA_DIR}/et_def/

cd ${NS3_DIR}
./ns3 configure --enable-mpi
./ns3 build AstraSimNetwork -j 12

mkdir -p ${BUILD_DIR}
mv ${NS3_DIR}/build/scratch/* ${BUILD_DIR}/
