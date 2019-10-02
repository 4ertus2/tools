#!/bin/bash

ISJ="${1:0:2}"
if [ $ISJ == '-j' ] ; then
    shift
fi

DEV_SERVER=(none mtlog-perftest01j.yandex.ru mtlog-perftest02j.yandex.ru mtlog-perftest03j.yandex.ru mtdev04t.yandex.ru)

# needs 'git remote add pf1 ssh://$USER@mtlog-perftest01j.yandex.ru/home/$USER/ClickHouse.git'
DEV_REPO=(none pf1 pf2 pf3 dev4)

USER=`id -un`

CH_PATH=/home/$USER/src/ClickHouse
CH_BUILD_DIR=_build
CH_BUILD_PATH=$CH_PATH/$CH_BUILD_DIR
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
PATCH_CACHED=r_cached.patch
PATCH_DIFF=r_diff.patch

CLANG_6='-DCMAKE_CXX_COMPILER=`which clang++-6.0` -DCMAKE_C_COMPILER=`which clang-6.0`'
CLANG_7='-DCMAKE_CXX_COMPILER=`which clang++-7` -DCMAKE_C_COMPILER=`which clang-7`'
GCC_7='-DCMAKE_CXX_COMPILER=`which g++-7` -DCMAKE_C_COMPILER=`which gcc-7`'
GCC_8='-DCMAKE_CXX_COMPILER=`which g++-8` -DCMAKE_C_COMPILER=`which gcc-8`'

TARGET="clickhouse"
MAKE="nice -10 ninja"
NO_EMBEDDED="-DENABLE_EMBEDDED_COMPILER=0"
NO_KAFKA="-DENABLE_RDKAFKA=0"
NO_STATIC="-DUSE_STATIC_LIBRARIES=0"
UNBUNDLED="-DUNBUNDLED=1"
DEBUG="-DCMAKE_BUILD_TYPE=Debug"
ASAN="-DSANITIZE=address"
TSAN="-DSANITIZE=thread"
UBSAN="-DSANITIZE=undefined"
ASAN_SYMBOLIZER_PATH="/usr/lib/llvm-6.0/bin/llvm-symbolizer"

#OVERRIDED_SETTINGS="--compile_expressions=1"
#OVERRIDED_SETTINGS="--enable_optimize_predicate_expression=1"

CTEST_OPTS="TEST_SERVER_CONFIG_PARAMS='$OVERRIDED_SETTINGS'"
TEST_RUN_OPTS="TEST_OPT0='--no-long --skip compile_sizeof_packed shard_secure cancel_http_readonly url_engine fix_extra_seek \
    00634_performance_introspection_and_logging 00965 00974_query 00974_distr 00974_text_log 00990_metric_log live_view \
    00956_sensitive_data_masking'"

remote_build()
{
    SERVER=$USER@$1
    REPO=$2
    CMAKE_OPTIONS=$3
    shift 3

    RELEASE=`echo "$@" | grep release | wc -l`
    WITH_ASAN=`echo "$@" | grep asan | wc -l`
    WITH_TSAN=`echo "$@" | grep tsan | wc -l`
    WITH_UBSAN=`echo "$@" | grep ubsan | wc -l`
    WITH_EMBEDDED=`echo "$@" | grep embedded | wc -l`
    NO_LIBCXX=`echo "$@" | grep nolibcxx | wc -l`
    IS_UNBUNDLED=`echo "$@" | grep unbundled | wc -l`

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
    if [ $WITH_EMBEDDED -eq 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $NO_EMBEDDED"
    fi
    if [ $IS_UNBUNDLED -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $UNBUNDLED"
    fi
    echo "cmake options:" $CMAKE_OPTIONS

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
    ssh $SERVER "mkdir -p $CH_BUILD_PATH && cd $CH_BUILD_PATH && rm -f CMakeCache.txt && cmake -G Ninja $CMAKE_OPTIONS $CH_PATH && $MAKE $TARGET"
}

clear_build()
{
    SERVER=$USER@$1
    ssh $SERVER "rm -rf $CH_BUILD_PATH"
    ssh $SERVER "mkdir $CH_BUILD_PATH"
}

fetch_some()
{
    scp -r $1:/$CH_BUILD_PATH/$2 ./_build/$2
}

fetch_build()
{
    NAME=clickhouse
    PATH_TO_BIN=./_build/dbms/programs
    REMOTE_PATH=$CH_BUILD_PATH/dbms/programs

    LOCAL_CRC=`md5sum -b $PATH_TO_BIN/$NAME | cut -f 1 -d " "`
    REMOTE_CRC=`ssh $1 md5sum -b $REMOTE_PATH/$NAME | cut -f 1 -d " "`
    echo $LOCAL_CRC $REMOTE_CRC

    if [ "$LOCAL_CRC" != "$REMOTE_CRC" ] ; then
        rm $PATH_TO_BIN/$NAME
        scp -r $1:/$REMOTE_PATH/$NAME $PATH_TO_BIN/
    fi
}

fetch()
{
    SERVER=$USER@$1

    if [ "x$2" == "x" ] ; then
        fetch_build $SERVER
    else
        fetch_some $SERVER $2
    fi
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
    ssh -t $SERVER "cd $CH_BUILD_PATH && env ASAN_SYMBOLIZER_PATH=$ASAN_SYMBOLIZER_PATH $CTEST_OPTS $TEST_RUN_OPTS ctest -V"
}

run_tests_local()
{
    cd $CH_BUILD_PATH && env ASAN_SYMBOLIZER_PATH=$ASAN_SYMBOLIZER_PATH $CTEST_OPTS "$TEST_RUN_OPTS" ctest -V
}

#

case "$1" in
"local")
    cd $CH_BUILD_PATH && ninja
    ;;
"1")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$CLANG_6" $@
    ;;
"2")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$CLANG_7" $@
    #remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$GCC_8" $@
    ;;
"3")
    #remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$CLANG_7" $@
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$GCC_8" $@ "embedded"
    ;;
"4")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$CLANG_7" $@
    #remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]} "$GCC_8" $@
    ;;
"clear")
    clear_build ${DEV_SERVER[$2]}
    ;;
"fetch")
    fetch ${DEV_SERVER[$2]} $3
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
