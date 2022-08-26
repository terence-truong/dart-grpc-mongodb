#!/bin/bash

protoc_file ()
{
    protoc -I protos/ protos/$1 --dart_out=grpc:lib/src/generated
    echo "Generated protobuf file(s) for ${1}"
}

if [ $# -gt 0 ]
then
    for arg in "$@"
    do
        protoc_file "${arg}.proto"
    done
else
    protoc_file "*.proto"
fi