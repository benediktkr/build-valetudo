#!/bin/bash
#

ss=0

manifest="dist/valetudo_release_manifest.json"

exp_armv7=$(jq -r ".sha256sums | .[\"valetudo-armv7\"]" $manifest)
exp_armv7_lowmem=$(jq -r ".sha256sums | .[\"valetudo-armv7-lowmem\"]" $manifest)
exp_aarch64=$(jq -r ".sha256sums | .[\"valetudo-aarch64\"]" $manifest)

hash_armv7=$(sha256sum dist/armv7/valetudo | awk '{ print $1 }')
hash_armv7_lowmem=$(sha256sum dist/armv7/valetudo-lowmem | awk '{ print $1 }')
hash_aarch64=$(sha256sum dist/aarch64/valetudo | awk '{ print $1 }')

bin_armv7=$(ls --color=always -1 dist/armv7/valetudo)
bin_armv7_lowmem=$(ls --color=always -1 dist/armv7/valetudo-lowmem)
bin_aarch64=$(ls --color=always -1 dist/aarch64/valetudo)

echo "[ ] Comparing SHA256 checksum hashes to release manifest"

for item in "armv7" "armv7-lowmem" "aarch64"; do
    unset exp hash bin_f
    if [[ -n "$exp" || -n "$hash" || -n "$bin_f" ]]; then
        exit 2
    fi
    case $item in
        armv7)
            exp=$exp_armv7
            hash=$hash_armv7
            bin_f=$bin_armv7
            ;;
        armv7-lowmem)
            exp=$exp_armv7_lowmem
            hash=$hash_armv7_lowmem
            bin_f=$bin_armv7_lowmem
            ;;
        aarch64)
            exp=$exp_aarch64
            hash=$hash_aarch64
            bin_f=$bin_aarch64
            ;;
        *)
            exit 1
            ;;
    esac

    echo -n "    [>] ${bin_f}: "
    if [[ -z "$hash" ]]; then
        echo "ERROR"
        echo "        [!] No/empty hash!"
        ((ss++))
    elif [[ "${exp}" == "${hash}" ]]; then
        echo "OK"
    else
        echo "FAILED"
        echo "        [!] sha256sum: $hash"
        echo "        [!] Expected:  $exp"
        ((ss++))
    fi
done
exit $ss
