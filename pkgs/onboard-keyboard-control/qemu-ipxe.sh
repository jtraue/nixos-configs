#!/usr/bin/env bash
#
# Qemu wrapper for iPXE boot.
#
# It expects environment variables to be set. See 'print_usage' for details.
#
# Keep in mind to build your IPXE with serial support or remove the
# '-display none' qemu option.

set -o errexit  # abort on nonzero exit status

function print_usage {
    echo "usage: $0"
    echo "    -h | --help  Print help"
    echo "    -u | --uefi  Use UEFI (legacy boot is default)"
    echo ""
    echo "Configuration via environment variables:"
    echo "    TFTP_ROOT:   Folder containing ipxe boot files (ipxe.kpxe or ipxe.efi)"
    echo "    OVMF_FOLDER: Folder firmware files for UEFI boot (OVMF_CODE.fd and OVMF_VARS.fd)"
    exit 0
}

# default values
UEFI=0

# parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -u|--uefi)
            UEFI=1
            shift # past key
        ;;
        -h|--help)
            print_usage
        ;;
        *) # unknown option
            POSITIONAL+=("$1") # save for later in array
            shift
        ;;
    esac
done

if [[ -z "${TFTP_ROOT}" ]]; then
    TFTP_ROOT="/var/lib/tftp"
    echo "Using default TFTP_ROOT: ${TFTP_ROOT}"
fi

if ((UEFI==1)) && [[ -z "${OVMF_FOLDER}" ]]; then
    echo "UEFI boot selected but OVMF_FOLDER environment variable is unset."
    echo "Please tell me where to find 'OVMF_CODE.fd'".
    exit 1
fi

if ((UEFI==1)) ; then
    qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -cpu host \
        -boot n \
        -netdev user,id=my1,tftp="${TFTP_ROOT}",bootfile=ipxe.efi \
        -device e1000,netdev=my1 \
        -bios "${OVMF_FOLDER}" \
        -drive if=pflash,format=raw,readonly=on,file="${OVMF_FOLDER}"/OVMF_CODE.fd \
        -drive if=pflash,format=raw,readonly=on,file="${OVMF_FOLDER}"/OVMF_VARS.fd \
        -serial stdio  \
        -display none
else
    qemu-system-x86_64 \
        -enable-kvm \
        -m 2048 \
        -cpu host \
        -boot n \
        -netdev user,id=my1,tftp="${TFTP_ROOT}",bootfile=ipxe.kpxe \
        -device e1000,netdev=my1 \
        -serial stdio \
        -display none
fi

