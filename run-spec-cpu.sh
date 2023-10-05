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
use_default "CONFIG" "bwzhao-multiverse"
use_default "TEST_BASE" "bwzhao1-m64"


echo ===========================================
echo "Done initializing variables"
echo ===========================================
echo

pushd $SPEC
source $SPEC/shrc
popd

echo $SPEC

build(){
# build the benchmark
runcpu --action build --config=$SPEC/config/$CONFIG ${TEST_ID}.${TEST_NAME}
}

instrument(){
pushd $MULTIVERSE
# Instrument
if [ "${PRO_FILE}" != "" ]
then
	PROFILE ="python3 -m cProfile -o $PRO_FILE "
fi
echo ./multiverse.py --arch $ARCH $BINARY
$PROFILE ./multiverse.py --arch $ARCH $BINARY
#> last_run.out 2>last_run.err
if [ $? != 0 ]
then
	popd
	echo "Instrumentation Failed"
	return
fi
cp $BINARY $BINARY-orig
mv ${BINARY}-r $BINARY
popd
}

i(){
echo i
cmd="./addpp.py $BINARY"
pushd $MULTIVERSE
echo $cmd
$cmd
popd
}

run(){
# run the benchmark
echo runcpu --nobuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n 4
runcpu --nobuild --config=$SPEC/config/$CONFIG ${TEST_ID}.$TEST_NAME -n 4
}

#BINARY=$SPEC/benchspec/CPU/${TEST_ID}.${TEST_NAME}/build/build_base_${TEST_BASE}.0000/${TEST_NAME}
#BINARY=$SPEC/benchspec/CPU/${TEST_ID}.${TEST_NAME}/run/run_base_refrate_${TEST_BASE}.0000/${TEST_NAME}_base.${TEST_BASE}
BINARY=$SPEC/benchspec/CPU/${TEST_ID}.${TEST_NAME}/exe/${TEST_PREFIX}${TEST_NAME}_base.${TEST_BASE}

#build
#instrument
#i
#run
$1

#ding when we finish
echo $'\a'
