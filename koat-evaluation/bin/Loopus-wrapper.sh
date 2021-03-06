#!/bin/bash
set -e
export LD_LIBRARY_PATH=`pwd`/lib

TIMEOUT=$1
EXAMPLE_FILE=`pwd`/$2
TIME_FILE=`pwd`/$3

LOOPUS=`pwd`/provers/loopus
KOATCCONV=`pwd`/bin/koatCConv
CLANG=`pwd`/clang-2.9/bin/clang

STDOUT_FILE=$(echo "${TIME_FILE}" | sed -e 's/.time$/.stdout.txt/')
STDERR_FILE=$(echo "${TIME_FILE}" | sed -e 's/.time$/.stderr.txt/')
INPUT_FILE=$(echo "${TIME_FILE}" | sed -e 's/.time$/.input.txt/')

TEMPDIR=$(mktemp -d)
cd "${TEMPDIR}"
cp "${EXAMPLE_FILE}" main.koat
"${KOATCCONV}" main.koat > main.koat.Loopus.c 2>"${STDERR_FILE}"
"${CLANG}" -g -emit-llvm -c main.koat.Loopus.c -o main.koat.Loopus.o 2>"${STDERR_FILE}"
"${LOOPUS}" -zT "${TIMEOUT}" -zDisableFunctions -zExpressBoundsInFunctionParameters -zPrintFunctionBoundOnly -zPrintComplexity -zAllowContextualization main.koat.Loopus.o > "${STDOUT_FILE}" 2> "${STDERR_FILE}" || :
cp main.koat.Loopus.c "${INPUT_FILE}" || true
cd - >/dev/null
rm -rf "$TEMPDIR"
