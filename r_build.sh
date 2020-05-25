#!/bin/bash

ISJ="${1:0:2}"
if [ $ISJ == '-j' ] ; then
    shift
fi

DEV_SERVER=(none mtlog-perftest01j.yandex.ru mtlog-perftest02j.yandex.ru mtlog-perftest03j.yandex.ru chertus-dev.sas.yp-c.yandex.net)

# needs 'git remote add pf1 ssh://$USER@mtlog-perftest01j.yandex.ru/home/$USER/ClickHouse.git'
DEV_REPO=(none pf1 pf2 pf3 qyp)

USER=`id -un`

CH_PATH=/home/$USER/src/ClickHouse
CH_BUILD_DIR=_build
CH_BUILD_PATH=$CH_PATH/$CH_BUILD_DIR
PATH_TO_BIN=$CH_BUILD_PATH/programs
CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
PATCH_CACHED=r_cached.patch
PATCH_DIFF=r_diff.patch

CLANG_8='-DCMAKE_CXX_COMPILER=`which clang++-8` -DCMAKE_C_COMPILER=`which clang-8`'
CLANG_9='-DCMAKE_CXX_COMPILER=`which clang++-9` -DCMAKE_C_COMPILER=`which clang-9`'
GCC_8='-DCMAKE_CXX_COMPILER=`which g++-8` -DCMAKE_C_COMPILER=`which gcc-8`'
GCC_9='-DCMAKE_CXX_COMPILER=`which g++-9` -DCMAKE_C_COMPILER=`which gcc-9`'

TARGET="clickhouse"
#MAKE="nice -10 ninja"
MAKE="nice make -j 56"
#CMAKE_ENABLED="-DENABLE_OPENCL=1"
CMAKE_ENABLED="-DENABLE_CUDA=1 -DUSE_LIBCXX=0"
CMAKE_DISABLED="-DENABLE_EMBEDDED_COMPILER=0"
NO_STATIC="-DUSE_STATIC_LIBRARIES=0 -DENABLE_JEMALLOC=0"
DEBUG="-DCMAKE_BUILD_TYPE=Debug"
ASAN="-DSANITIZE=address"
TSAN="-DSANITIZE=thread"
UBSAN="-DSANITIZE=undefined"
ASAN_SYMBOLIZER_PATH="/usr/lib/llvm-6.0/bin/llvm-symbolizer"

#OVERRIDED_SETTINGS="--compile_expressions=1"
#OVERRIDED_SETTINGS="--experimental_use_processors=0"

CTEST_OPTS="TEST_SERVER_CONFIG_PARAMS='$OVERRIDED_SETTINGS'"
TEST_RUN_OPTS="TEST_OPT0='--no-long --skip \
    compile_sizeof_packed shard_secure cancel_http_readonly url_engine fix_extra_seek live_view \
    01231_distributed_aggregation_memory_efficient_mix_levels \
    01223_dist_on_dist \
    01201_drop_column_compact_part_replicated \
    01200_mutations_memory_consumption \
    01104_distributed \
    01103_check_cpu_instructions_at_startup \
    01099_parallel_distributed_insert_select \
    01092_memory_profiler \
    01091_num_threads \
    01086_odbc_roundtrip \
    01088_benchmark_query_id \
    01083_log_family_disk_memory \
    01083_expressions_in_engine_arguments \
    01080_check_for_error_incorrect_size_of_nested_column \
    01071_force_optimize_skip_unused_shards \
    01062_alter_on_mutataion \
    01057_http_compression_prefer_brotli \
    01050_clickhouse_dict_source_with_subquery \
    01040_dictionary_invalidate_query_switchover \
    01040_dictionary_invalidate_query_failover \
    01043_dictionary 01041_create_dictionary_if_not_exists \
    01042_system_reload_dictionary_reloads_completely \
    01038_dictionary_lifetime_min_zero_sec \
    01037_polygon_dict_multi_polygons \
    01037_polygon_dict_simple_polygons \
    01036_no_superfluous_dict_reload_on_create_database \
    01036_no_superfluous_dict_reload_on_create_database_2 \
    01033_dictionaries_lifetime \
    01023_materialized_view_query_context \
    01018_dictionaries_from_dictionaries \
    01018_Distributed__shard_num distributed_directory \
    01018_ddl_dictionaries \
    01016_macros \
    00990_metric_log 00974_query 00974_distr 00974_text_log \
    00956_sensitive_data_masking \
    00952_insert_into_distributed_with_materialized_column \
    00505_secure 00634_performance_introspection_and_logging'"

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
    DYNLIB=`echo "$@" | grep dynlib | wc -l`

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
    if [ $DYNLIB -ne 0 ] ; then
        CMAKE_OPTIONS="$CMAKE_OPTIONS $NO_STATIC"
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
    ssh -t $SERVER "cd $CH_BUILD_PATH && env ASAN_SYMBOLIZER_PATH=$ASAN_SYMBOLIZER_PATH $CTEST_OPTS $TEST_RUN_OPTS ctest -V"
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
"1")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"2")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"3")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"4")
    remote_build ${DEV_SERVER[$1]} ${DEV_REPO[$1]}
    ;;
"cmake")
    remote_cmake ${DEV_SERVER[$2]} ${DEV_REPO[$2]} "$CLANG_9" $@
    ;;
"cmake-gcc")
    remote_cmake ${DEV_SERVER[$2]} ${DEV_REPO[$2]} "$GCC_9" $@
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
