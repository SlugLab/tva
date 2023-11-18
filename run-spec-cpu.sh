#!/bin/bash

use_default(){
	if [ "${!1}" = "" ]
	then
		eval $1="$2"
	fi
	echo "[$1] = \"${!1}\""
}
use_default "SPEC"  "/opt/cpu2017/"
use_default "MULTIVERSE" "/home/bwzhao/research/multiverse-slug/multiverse/"
use_default "ARCH" "x86-64"
use_default "TEST_ID" "502"
use_default "TEST_PREFIX" "cpu"
use_default "TEST_NAME" "gcc_r"
use_default "TEST_BINARY" "$TEST_NAME"
use_default "CONFIG" "bwzhao-multiverse"
use_default "TEST_BASE" "bwzhao1-m64"
use_default "TEST_COUNT" "3"
use_default "TEST_COPIES" "4"


echo ===========================================
echo "Done initializing variables"
echo ===========================================
echo

pushd $SPEC
source $SPEC/shrc
popd

echo $SPEC

buildall(){
# build all benchmarks
runcpu --action build --config=$SPEC/config/$CONFIG intrate
}

runall(){
# run all benchmarks
echo runcpu --nobuild --config=$SPEC/config/$CONFIG intrate
runcpu --nobuild --config=$SPEC/config/$CONFIG intrate
}

build(){
# build the benchmark
runcpu --action build --config=$SPEC/config/$CONFIG ${TEST_ID}.${TEST_NAME}
}

# instrument with push pop instrumentation
i(){
BINARY=$SPEC/benchspec/CPU/${TEST_ID}.${TEST_NAME}/exe/${TEST_PREFIX}${TEST_BINARY}_base.${TEST_BASE}
echo i
cmd="./addpp.py $BINARY"
pushd $MULTIVERSE
echo $cmd
$cmd
popd
}

run(){
# run the benchmark
echo runcpu --nobuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n $TEST_COUNT --copies $TEST_COPIES
runcpu --nobuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n $TEST_COUNT --copies $TEST_COPIES
}

rwb(){
#run with build
echo runcpu --rebuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n $TEST_COUNT --copies $TEST_COPIES
runcpu --rebuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n $TEST_COUNT --copies $TEST_COPIES
}


# just run the first arg passed in
$1

#ding when we finish
echo $'\a'
