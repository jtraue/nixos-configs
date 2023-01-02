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
    echo "    -b | --bios  Use UEFI (uefi is default)"
    echo "    -m | --mem   Specify memory  (in bytes)"
    echo "    -v           Verbose"
    echo ""
    echo "Configuration via environment variables:"
    echo "    TFTP_ROOT:   Folder containing ipxe boot files (ipxe.kpxe or ipxe.efi)"
    echo "    OVMF_FOLDER: Folder firmware files for UEFI boot (OVMF_CODE.fd)"
    exit 0
}

# default values
UEFI=1
MEM=2048
## use different mac addresses for uefi and bios boot for easier ipxe configuration
MAC_UEFI=52:54:00:12:34:57
MAC_BIOS=52:54:00:12:34:56

# parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -b|--bios)
            UEFI=0
            shift # past key
        ;;
        -m|--mem)
            MEM="$2"
            shift # past key
            shift # past value
        ;;
        -h|--help)
            print_usage
        ;;
        -v)
            set -x
            shift # past key
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
        -M q35 \
        -m ${MEM} \
        -cpu host \
        -smp 2 \
        -boot n \
        -netdev user,id=my1,tftp="${TFTP_ROOT}",bootfile=ipxe.efi,hostfwd=tcp::2221-:22 \
        -device e1000,netdev=my1,mac="${MAC_UEFI}" \
        -bios "${OVMF_FOLDER}" \
        -drive if=pflash,format=raw,readonly=on,file="${OVMF_FOLDER}"/OVMF_CODE.fd \
        -serial stdio  \
        -display none
else
    qemu-system-x86_64 \
        -enable-kvm \
        -M q35 \
        -m ${MEM} \
        -cpu host \
        -smp 2 \
        -boot n \
        -display none \
        -netdev user,id=my1,tftp="${TFTP_ROOT}",bootfile=ipxe.kpxe,hostfwd=tcp::2221-:22 \
        -device e1000,netdev=my1,mac="${MAC_BIOS}" \
        -serial stdio \
        ${@}
fi

