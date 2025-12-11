#!/bin/bash

# Setup tlto
mkdir -p tlto || exit 1

export USE_THINLTO_CACHE=true
export THINLTO_CACHE_DIR=$(pwd)/tlto

if [ "$1" = "-i" ]; then
    if [ -z "$2" ]; then
        echo "Please specify a proper build target when using the installclean flag."
        echo "e.g. ./build.sh -i yaap_pdx206-user"
        exit 1
    fi

    echo -e
    echo 'Running make installclean'
    echo -e
    . build/envsetup.sh || exit 1
    lunch "$2" || exit 1
    m installclean || exit 1
    exit 0
fi

if [ "$1" = "-c" ]; then
    if [ -z "$2" ]; then
        echo "Please specify a proper build target when using the clean flag."
        echo "e.g. ./build.sh -c yaap_pdx206-user"
        exit 1
    fi

    echo -e
    echo 'Running make clean'
    echo -e
    . build/envsetup.sh || exit 1
    lunch "$2" || exit 1
    m clean || exit 1
    exit 0
fi

if [ "$1" = "-b" ]; then
    if [ -z "$2" ]; then
        echo "Please specify a proper build target when using the make bootimage flag."
        echo "e.g. ./build.sh -b yaap_pdx206-user"
        exit 1
    fi

    echo -e
    echo 'Running make bootimage'
    echo -e
    . build/envsetup.sh || exit 1
    lunch "$2" || exit 1
    m bootimage || exit 1
    exit 0
fi

# Check inputs

threads=$2

if [ -z "$1" ]; then
    echo "Please specify a proper build target."
    echo "e.g. ./build.sh yaap_pdx206-user gapps 16"
    echo "              ^^^^^^^^^^^^^^^^         "
    exit 1
fi

if [ -z "$3" ]; then
    echo "Please specify a proper varaint target."
    echo "e.g. ./build.sh yaap_pdx206-user gapps 16"
    echo "                               ^^^^^   "
    exit 1
fi

if [ -z "$threads" ]; then
    threads=$(nproc --all)
    echo "No. of threads not specified. Defaulting to $threads"
fi

case $3 in
    "gapps")
            echo -e
            echo "Building $3 Variant!"
            echo -e
            export TARGET_BUILD_GAPPS=true
	    export BUILD_TYPE="GMS"
            ;;
  "vanilla")
            echo -e
            echo "Building $3 Variant!"
            echo -e
            export TARGET_BUILD_GAPPS=false
            export BUILD_TYPE="Vanilla"
            ;;
          *)
            echo -e
            echo 'Invalid variant specified. Defaulting to Vanilla'
            echo -e
            export TARGET_BUILD_GAPPS=false
            export BUILD_TYPE="Vanilla"
            ;;
esac

input_string="$1"
device=$(echo "$input_string" | sed -E 's/^yaap_//; s/-user$|-userdebug$|-eng$//')
timestamp=$(date +"%Y%m%d")

export FORCE_JSON=1

# Setup env
. build/envsetup.sh || exit 1

# Select device
lunch $1 || exit 1

# Make package
mka yaap -j$threads || exit 1

export BUILD_IN_NAME="YAAP-16-HOMEMADE-$device-$timestamp.zip"
export BUILD_OUT_NAME="YAAP-16-HOMEMADE-$device-$timestamp-$BUILD_TYPE.zip"
export BUILD_PATH_DIR="out/target/product/$device"

echo -e
echo 'Creating Releases folder structure'
mkdir -p Releases/$device &> /dev/null || exit 1

# Rename file in output for correct OTA GEN
mv "$BUILD_PATH_DIR/$BUILD_IN_NAME" "$BUILD_PATH_DIR/$BUILD_OUT_NAME" || exit 1
mv "$BUILD_PATH_DIR/$BUILD_IN_NAME.sha256sum" "$BUILD_PATH_DIR/$BUILD_OUT_NAME.sha256sum" || exit 1

# Generate OTA
./vendor/yaap/tools/generate_json_build_info.sh $BUILD_PATH_DIR/$BUILD_OUT_NAME

# Copy builds from out
cp "$BUILD_PATH_DIR/$BUILD_OUT_NAME" "Releases/$device/" || exit 1
cp "$BUILD_PATH_DIR/$BUILD_OUT_NAME.sha256sum" "Releases/$device/" || exit 1

# OTA JSON
mkdir -p Releases/$device/$BUILD_TYPE &> /dev/null || exit 1
cp out/target/product/$device/$device.json Releases/$device/$BUILD_TYPE/$device.json || exit 1

# Extract Recoveries
echo -e
echo 'Extracting Recovery'
echo -e
mkdir -p Releases/$device/temp &> /dev/null || exit 1
7z e Releases/$device/$BUILD_OUT_NAME payload.bin -oReleases/$device/temp || exit 1
payload-dumper-go -p recovery -o Releases/$device/temp Releases/$device/temp/payload.bin || exit 1
mv Releases/$device/temp/recovery.img "Releases/$device/YAAP-16-recovery-HOMEMADE-$device-$timestamp-$BUILD_TYPE.img" || exit 1
rm -rf Releases/$device/temp || exit 1

echo -e
echo 'Done, dont forget about the changelogs!'
