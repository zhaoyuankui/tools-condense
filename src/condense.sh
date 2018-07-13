#!/bin/bash

source $MYSHELLIB/utils.sh;
source $MYSHELLIB/echoc.sh;

# If the parent directory of the conterpart of a compress file that not modified
# more than $MIN_UNCHANGED_TIME, then the conterpart would be removed.
declare -i MIN_UNCHANGED_TIME=$((30 * 24 * 3600));
declare -i now_time=`date +%s`;
declare -i yes_all=0;
declare -A should_remove;

function processor() {
    declare path="$1";
    if [ ! -e "$path" ]; then
        echoc Yellow "[NOTICE] Path '$path' already removed.";
        return;
    fi
    if is_compress_file "$path"; then
        check "$path";
    fi
}

function is_compress_file() {
    declare suffix="${path##*.}";
    if [ "$suffix" == 'zip' -o "$suffix" == 'tgz' -o "$suffix" == 'gz' -o "$suffix" == 'rar' -o "$suffix" == '7z' ]; then
        return 0;
    fi
    return 1;
}

function check() {
    declare path="$1";
    echo -e "\n--------------------------------------------------------------------------------";
    echo "Check '$path'";
    declare conterpart="`get_conterpart "$path"`";
    if [ ! "$conterpart" ]; then
        return;
    fi;
    declare parent_dir="`dirname "$conterpart"`";
    # To do. Modify time would be changed if a file removed.
    
    if [ ! "${should_remove[$parent_dir]}" ]; then
        declare -i modify_time=`stat -s "$parent_dir" | grep -o 'st_mtime=[0-9]*' | awk -F= '{print $NF}'`;
        declare -i elapsed_time=$((now_time - modify_time));
        if [ $elapsed_time -le $MIN_UNCHANGED_TIME ]; then
            return;
        fi
        should_remove["$parent_dir"]=1;
    fi
    declare choice;
    if [ 1 -eq $yes_all ]; then
        choice='Y';
    else
        echoc Yellow "Find counterpart '$conterpart'. Remove it? (Y/N) ";
        read choice;
    fi
    if [ "$choice" != 'Y' ]; then
        echoc Red 'Abort!';
        return;
    fi
    rm -rf "$conterpart";
    echoc Red "Conterpart '$conterpart' removed!";
}

function get_conterpart() {
    declare path="$1";
    declare dir_name="`dirname "$path"`";
    # like aaa.zip
    declare file_name="${path%.*}";
    if [ -d "$file_name" ]; then
        echo "$file_name";
        return;
    fi
    # like aaa.tar.gz => aaa
    file_name="${file_name%.*}";
    if [ -d "$file_name" ]; then
        echo "$file_name";
        return;
    fi
    # like aaa.version1.tar.gz => aaa 2
    if [ "$file_name" != "${file_name%%.*}" ]; then
        file_name="${file_name%%.*}";
        for real_file_name in `ls -d "$file_name"* | tr ' ' '?'`; do
            if [ ! -d "$real_file_name" ]; then
                continue;
            fi
            echo "$real_file_name";
            return;
        done
    fi
    # like aaa-version1.tar.gz => aaa 2
    if [ "$file_name" != "${file_name%-*}" ]; then
        file_name="${file_name%-*}";
        for real_file_name in `ls -d "$file_name"* | tr ' ' '?'`; do
            if [ ! -d "$real_file_name" ]; then
                continue;
            fi
            echo "$real_file_name";
            return;
        done
    fi
    # like aaa_20170822.tar.gz => aaa 2
    if [ "$file_name" != "${file_name%-*}" ]; then
        file_name="${file_name%-*}";
        for real_file_name in `ls -d "$file_name"* | tr ' ' '?'`; do
            if [ ! -d "$real_file_name" ]; then
                continue;
            fi
            echo "$real_file_name";
            return;
        done
    fi
    # like aaa(1).tar.gz => aaa 2
    if [ "$file_name" != "${file_name%(*}" ]; then
        file_name="${file_name%(*}";
        for real_file_name in `ls -d "$file_name"* | tr ' ' '?'`; do
            if [ ! -d "$real_file_name" ]; then
                continue;
            fi
            echo "$real_file_name";
            return;
        done
    fi
    # To be extended here.
}

function show_help() {
    echoc Red 'Usage:';
    echo '    condense <PATH1> [PATH2 [PATH3 ... ]]';
}

function run() {
    if [ "$1" == '-y' ]; then
        yes_all=1;
        shift;
    fi
    if [ $# -lt 1 ]; then
        show_help;
        exit 1;
    fi
    for path in "${@}"; do
        if [ ! -e "$path" ]; then
            echoc Yellow "Path '$path' doesn't exist. Ignored!";
            continue;
        fi
        traverse "$path" processor;
    done
}

run "${@}";
