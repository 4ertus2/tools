#!/bin/bash

ISJ="${1:0:2}"
if [ $ISJ == '-j' ] ; then
    shift
fi

DEV_SERVER=(chertus-dev.sas.yp-c.yandex.net)

# it needs 'git remote add qyp ssh://$USER@chertus-dev.sas.yp-c.yandex.net/home/$USER/ClickHouse.git'
DEV_REPO=(qyp)

USER=`id -un`

CH_PATH=/home/$USER/src/ClickHouse
CH_BUILD_DIR=_build
CH_BUILD_PATH=$CH_PATH/$CH_BUILD_DIR
PATH_TO_BIN=$CH_BUILD_PATH/programs
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
PATCH_CACHED=r_cached.patch
PATCH_DIFF=r_diff.patch

CLANG_SYS='-DCMAKE_CXX_COMPILER=`which clang++` -DCMAKE_C_COMPILER=`which clang`'
CLANG_15='-DCMAKE_CXX_COMPILER=`which clang++-15` -DCMAKE_C_COMPILER=`which clang-15`'
GCC_SYS='-DCMAKE_CXX_COMPILER=`which g++` -DCMAKE_C_COMPILER=`which gcc`'
#GCC_9='-DCMAKE_CXX_COMPILER=`which g++-9` -DCMAKE_C_COMPILER=`which gcc-9`'

TARGET="clickhouse"
#MAKE="nice -10 ninja"
MAKE="nice make -j 64"
#CMAKE_ENABLED="-DENABLE_OPENCL=1"
CMAKE_ENABLED="-DENABLE_CLANG_TIDY=1"
#CMAKE_ENABLED="-DENABLE_CUDA=1 -DUSE_LIBCXX=0"
CMAKE_DISABLED="-DENABLE_HDFS=0 -DENABLE_AWS_S3=0 -DENABLE_AZURE_BLOB_STORAGE=0 \
    -DENABLE_KAFKA=0 -DENABLE_AMQPCPP=0 -DENABLE_CASSANDRA=0 -DENABLE_KRB5=0 -DENABLE_CYRUS_SASL=0 -DENABLE_AVRO=0 \
    -DENABLE_CLICKHOUSE_OBFUSCATOR=0 -DENABLE_CLICKHOUSE_COPIER=0 -DENABLE_CLICKHOUSE_COMPRESSOR=0 \
    -DENABLE_CLICKHOUSE_FORMAT=0 -DENABLE_CLICKHOUSE_LIBRARY_BRIDGE=0 -DENABLE_CLICKHOUSE_INSTALL=0 \
    -DENABLE_CLICKHOUSE_KEEPER=0  -DENABLE_CLICKHOUSE_KEEPER_CONVERTER=0 -DENABLE_CLICKHOUSE_KEEPER_CLIENT=0 -DENABLE_CLICKHOUSE_SU=0 \
    -DENABLE_CLICKHOUSE_DISKS=0 -DENABLE_CLICKHOUSE_GIT_IMPORT=0"
UNBUNDLED="-DUNBUNDLED=1"
DEBUG="-DCMAKE_BUILD_TYPE=Debug"
ASAN="-DSANITIZE=address"
TSAN="-DSANITIZE=thread"
UBSAN="-DSANITIZE=undefined"
#ASAN_SYMBOLIZER_PATH="/usr/lib/llvm-6.0/bin/llvm-symbolizer"

remote_patch()
{
    SERVER=$USER@$1
    REPO=$2

    git push $REPO
    ssh $SERVER "cd $CH_PATH && git clean -f && git reset --hard HEAD && git fetch && git checkout $CURRENT_BRANCH && git pull"
    if [ $? -ne 0 ] ; then
        exit
    fi

    git diff --cached > $PATCH_CACHED
    if [ -s $PATCH_CACHED ] ; then
        scp $PATCH_CACHED $SERVER:$CH_PATH/
        ssh $SERVER "cd $CH_PATH && git apply $PATCH_CACHED && git add -u && rm $PATCH_CACHED"
    fi

    git diff > $PATCH_DIFF
    if [ -s $PATCH_DIFF ] ; then
        scp $PATCH_DIFF $SERVER:$CH_PATH/
        ssh $SERVER "cd $CH_PATH && git apply $PATCH_DIFF && rm $PATCH_DIFF"
    fi
    rm $PATCH_CACHED $PATCH_DIFF

    ssh $SERVER "cd $CH_PATH && git status"
}

remote_build()
{
    SERVER=$USER@$1

    remote_patch $@
    ssh $SERVER "cd $CH_BUILD_PATH && $MAKE $TARGET"
}

remote_build_nopatch()
{
    SERVER=$USER@$1

    ssh $SERVER "cd $CH_BUILD_PATH && $MAKE -k $TARGET"
}

remote_build_nopatch_slow()
{
    SERVER=$USER@$1

    ssh $SERVER "cd $CH_BUILD_PATH && $MAKE_SLOW -k $TARGET"
}

remote_cmake()
{
    SERVER=$USER@$1
    REPO=$2
    CMAKE_OPTIONS=$3
    
    remote_patch $@
    
#   GENERATOR='-G Ninja'
#   GENERATOR='-G "Unix Makefiles"'
    
    RELEASE=`echo "$@" | grep release | wc -l`
    WITH_ASAN=`echo "$@" | grep asan | wc -l`
    WITH_TSAN=`echo "$@" | grep tsan | wc -l`
    WITH_UBSAN=`echo "$@" | grep ubsan | wc -l`
    WITH_DISABLED=`echo "$@" | grep disabled | wc -l`
    WITH_ENABLED=`echo "$@" | grep enabled | wc -l`
    NO_LIBCXX=`echo "$@" | grep nolibcxx | wc -l`

    if [ $RELEASE -eq 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $DEBUG"
    fi
    if [ $WITH_ASAN -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $ASAN"
    fi
    if [ $WITH_TSAN -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $TSAN"
    fi
    if [ $WITH_UBSAN -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $UBSAN"
    fi
    if [ $NO_LIBCXX -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS -DUSE_LIBCXX=0"
    fi
    if [ $WITH_ENABLED -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $CMAKE_ENABLED"
    fi
    if [ $WITH_DISABLED -eq 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $CMAKE_DISABLED"
    fi

    echo "cmake options:" $CMAKE_OPTIONS

    ssh $SERVER "mkdir -p $CH_BUILD_PATH && cd $CH_BUILD_PATH && rm -f CMakeCache.txt && cmake $GENERATOR $CMAKE_OPTIONS $CH_PATH"
}

clear_build()
{
    SERVER=$USER@$1
    ssh $SERVER "rm -rf $CH_BUILD_PATH"
    ssh $SERVER "mkdir $CH_BUILD_PATH"
}

fetch()
{
    SERVER=$USER@$1
    NAME=$2

    LOCAL_CRC=`sha1sum -b $NAME | cut -f 1 -d " "`
    REMOTE_CRC=`ssh $1 sha1sum -b $NAME | cut -f 1 -d " "`
    echo $LOCAL_CRC $REMOTE_CRC

    if [ "$LOCAL_CRC" != "$REMOTE_CRC" ] ; then
        rm $NAME
        scp -r $SERVER:$NAME $NAME
    fi
}

dyn_fetch()
{
    SERVER=$USER@$1

    DEPS=`ssh $SERVER "ldd $PATH_TO_BIN/clickhouse" | awk '{print $3}' | sort | grep $CH_BUILD_PATH`
    
    echo fetching binary
    fetch $1 $PATH_TO_BIN/clickhouse

    for LIB in $DEPS ; do
        echo fetching $LIB
        mkdir -p `dirname $LIB`
        fetch $1 $LIB
    done    
}

remove_branch()
{
    SERVER=$USER@$1
    BRANCH=$2
    ssh $SERVER "cd $CH_BUILD_PATH && git reset --hard HEAD && git co master && git branch -D $BRANCH"
    ssh $SERVER "cd ~/ClickHouse.git && git branch -D $BRANCH"
}

update_contrib()
{
    SERVER=$USER@$1
    ssh $SERVER "cd $CH_BUILD_PATH && rm -rf contrib && git submodule sync && git submodule update --init --recursive"
}

run_tests()
{
    SERVER=$USER@$1
    ssh -t $SERVER "cd $CH_BUILD_PATH && env ASAN_SYMBOLIZER_PATH=$ASAN_SYMBOLIZER_PATH $TEST_RUN_OPTS ctest -V"
}

run_tests_local()
{
    cd $CH_BUILD_PATH && env ASAN_SYMBOLIZER_PATH=$ASAN_SYMBOLIZER_PATH $CTEST_OPTS "$TEST_RUN_OPTS" ctest -V
}

#

case "$1" in
"local")
    #cd $CH_BUILD_PATH && rm -f CMakeCache.txt && cmake -G Ninja $CMAKE_OPTIONS $CH_PATH
    cd $CH_BUILD_PATH && $MAKE
    ;;
"0")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    #remote_build_nopatch ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"1")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"build")
    remote_build_nopatch ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"cmake")
    remote_cmake ${DEV_SERVER[$2]} ${DEV_REPO[$2]} "$CLANG_SYS" $@
    ;;
"cmake-gcc")
    remote_cmake ${DEV_SERVER[$2]} ${DEV_REPO[$2]} "$GCC_SYS" $@
    ;;
"clear")
    clear_build ${DEV_SERVER[$2]}
    ;;
"fetch")
    fetch ${DEV_SERVER[$2]} $PATH_TO_BIN/clickhouse
    ;;
"dyn-fetch")
    dyn_fetch ${DEV_SERVER[$2]}
    ;;
"rmb")
    remove_branch ${DEV_SERVER[$2]} $3
    ;;
"contrib")
    update_contrib ${DEV_SERVER[$2]}
    ;;
"test")
    if [ "x$2" == "xlocal" ] ; then
        run_tests_local
    else
        run_tests ${DEV_SERVER[$2]}
    fi
    ;;
*)
    echo "wrong argument: " $1
    ;;
esac
