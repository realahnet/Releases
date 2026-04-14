#!/bin/bash

# Setup tlto
mkdir -p tlto || exit 1

export USE_THINLTO_CACHE=true
export THINLTO_CACHE_DIR=$(pwd)/tlto

if [[ "$1" == "-i" || "$1" == "-c" || "$1" == "-b" ]]; then
    TARGET="$2"
else
    TARGET="$1"
fi

if [ -z "$TARGET" ]; then
    echo "Please specify a proper build target."
    echo "e.g. ./build.sh yaap_giulia-user"
    exit 1
fi

device=$(echo "$TARGET" | sed -E 's/^yaap_//; s/-user$|-userdebug$|-eng$//')

case $device in
    giulia | giuliac)
        CURRENT_CO="OP"
    ;;
    pdx203 | pdx206)
        CURRENT_CO="sony"
    ;;

    *)
        CURRENT_CO="unknown" ;;
esac

if [ "$CURRENT_CO" = "unknown" ]; then
    echo -e
    echo "[WARNING]: Brand of phone could not be determined. OUT swapping skipped."
    echo -e
else

    if [ ! -f .last_build ]; then
        echo "$CURRENT_CO" > .last_build
        LAST_CO="$CURRENT_CO"
    else
        LAST_CO=$(cat .last_build)
    fi

    if [ "$LAST_CO" == "OP" ] && [ "$CURRENT_CO" == "sony" ]; then
            echo "Switching build environment: OnePlus -> Sony"
            if [ -d out ]; then mv out out-op || exit 1; fi
            if [ -d tlto ]; then mv tlto tlto-op || exit 1; fi
            if [ -d out-sony ]; then mv out-sony out || exit 1; fi
            if [ -d tlto-sony ]; then mv tlto-sony tlto || exit 1; fi
            echo "sony" > .last_build || exit 1
        elif [ "$LAST_CO" == "sony" ] && [ "$CURRENT_CO" == "OP" ]; then
            echo "Switching build environment: Sony -> OnePlus"
            if [ -d out ]; then mv out out-sony || exit 1; fi
            if [ -d tlto ]; then mv tlto tlto-sony || exit 1; fi
            if [ -d out-op ]; then mv out-op out || exit 1; fi
            if [ -d tlto-op ]; then mv tlto-op tlto || exit 1; fi
            echo "OP" > .last_build || exit 1
        fi
fi

if [ "$1" = "-i" ]; then
    if [ -z "$2" ]; then
        echo "Please specify a proper build target when using the installclean flag."
        echo "e.g. ./build.sh -i yaap_giulia-user"
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
        echo "e.g. ./build.sh -c yaap_giulia-user"
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
        echo "e.g. ./build.sh -b yaap_giulia-user"
        exit 1
    fi

    echo -e
    echo 'Running make bootimage'
    echo -e
    . build/envsetup.sh || exit 1
    lunch "$2" || exit 1
    m bootimage initbootimage || exit 1
    exit 0
fi

# Check inputs
threads=$2

if [ -z "$1" ]; then
    echo "Please specify a proper build target."
    echo "e.g. ./build.sh yaap_giulia-user 16 gapps"
    echo "              ^^^^^^^^^^^^^^^^         "
    exit 1
fi

if [ -z "$3" ]; then
    echo "Please specify a proper variant target."
    echo "e.g. ./build.sh yaap_giulia-user 16 gapps"
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
mkdir -p Releases/$device/$BUILD_TYPE/OTA &> /dev/null || exit 1
cp out/target/product/$device/$device.json Releases/$device/$BUILD_TYPE/OTA || exit 1

# Extract Recoveries
echo -e
echo 'Extracting Images'
echo -e
mkdir -p Releases/$device/temp &> /dev/null || exit 1

case $device in
    giulia | giuliac)
        otaripper -n -p init_boot,vendor_boot Releases/$device/$BUILD_OUT_NAME -o Releases/$device/temp || exit 1
        mv Releases/$device/temp/extracted_*/*.img Releases/$device/temp || exit 1
        rm -rf Releases/$device/temp/extracted_* || exit 1
    ;;
esac

otaripper -n -p boot,recovery Releases/$device/$BUILD_OUT_NAME -o Releases/$device/temp || exit 1

mv Releases/$device/temp/extracted_*/*.img Releases/$device/temp || exit 1
rm -rf Releases/$device/temp/extracted_* || exit 1

mkdir -p Releases/$device/$BUILD_TYPE/images &> /dev/null || exit 1

case $device in
    giulia | giuliac)
        mv Releases/$device/temp/init_boot.img "Releases/$device/$BUILD_TYPE/images" || exit 1
        mv Releases/$device/temp/vendor_boot.img "Releases/$device/$BUILD_TYPE/images" || exit 1
    ;;
esac

mv Releases/$device/temp/boot.img "Releases/$device/$BUILD_TYPE/images" || exit 1
mv Releases/$device/temp/recovery.img "Releases/$device/$BUILD_TYPE/images" || exit 1

rm -rf Releases/$device/temp || exit 1

echo -e
echo 'Done, dont forget about the changelogs!'
