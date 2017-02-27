
OBP_PATH="./otsimopb"
export IMPORT_PATH=${OBP_PATH}:${GOPATH}/src:${GOPATH}/src/github.com/gogo/protobuf/protobuf

export GRPC_OUTPUT_DIR=./Grpc/services
export PROTO_OUTPUT_DIR=./Grpc/Protos
export PROTO_FILES="./otsimopb/*.proto"

protoc --proto_path=${IMPORT_PATH} --swift_out=Visibility=Public:${PROTO_OUTPUT_DIR} ${PROTO_FILES}
protoc --proto_path=${IMPORT_PATH} --grpc-swift_out=Visibility=Public:${GRPC_OUTPUT_DIR} ${PROTO_FILES}
