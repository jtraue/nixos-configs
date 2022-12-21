#!/usr/bin/env bash

## Things to keep in mind - not yet supported here
# Booting a guest test requires --boot=multiboot
# For now use: ./result/bin/qemu-svp -k /var/lib/tftp/bootfiles/share/supernova/test/guest/cpuid_guesttest-elf32 --snargs "--boot=multiboot --serial --nointrospection" -i ""

set -o errexit   # abort on nonzero exitstatus
set -o nounset   # abort on unbound variable
set -o pipefail  # don't hide errors within pipes

# Default values
KARGS="${DEFAULT_KERNEL_ARGS:-""}"
USE_SUPERNOVA=1
DRY_RUN=0
BENDER="${DEFAULT_BENDER:-""}"
INITRD="${DEFAULT_INITRD:-""}"
KERNEL="${DEFAULT_KERNEL:-""}"
NOVA="${DEFAULT_NOVA:-""}"
ROOTTASK="${DEFAULT_ROOTTASK:-""}"
VMM="${DEFAULT_VMM:-""}"
QARGS="${DEFAULT_QEMU_ARGS:-""}"
SNARGS="${DEFAULT_SUPERNOVA_ARGS:-""}"


function print_usage {
    echo "usage: $0"
    echo "    --kargs args           arguments for linux kernel (quote them as single parameter), default=${KARGS}"
    echo "    --snargs args          arguments for supernova (quote them as single parameter), default=${DEFAULT_SUPERNOVA_ARGS}"
    echo "    --no-supernova         disable supernova"
    echo "    --qargs                additional qemu arguments, default=${QARGS}"
    echo "    -b|--bender file       path to bender, default=${BENDER}"
    echo "    -d|--disk file         path to img"
    echo "    -i|--initrd file       path to linux initial ramdisk, default=${INITRD}"
    echo "    -k|--kernel file       path to linux kernel, default=${KERNEL}"
    echo "    -n|--nova file         path to nova, default=${NOVA}"
    echo "    -r|--roottask file     path to roottask, default=${ROOTTASK}"
    echo "    -v|--vmm file          path to vmm, default=${VMM}"
    echo "    --debug                print all commands"

    echo " "
    echo "Run roottask test: "
    echo "qemu_helper -k ./build/test/roottask/thesis-impl_roottasktest -v ' ' -r ' ' --snargs ' '"
    exit 0
}

POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        --kargs)
            KARGS="$2"
            shift # past key
            shift # past value
        ;;
        --snargs)
            SNARGS="$2"
            shift # past key
            shift # past value
        ;;
        --no-supernova)
            USE_SUPERNOVA=0
            shift
        ;;
        --qargs)
            QARGS="$2"
            shift # past key
            shift # past value
        ;;
        -b|--bender)
            BENDER="$2"
            shift # past key
            shift # past value
        ;;
        -i|--initrd)
            INITRD="$2"
            shift # past key
            shift # past value
        ;;
        -k|--kernel)
            KERNEL="$2"
            shift # past key
            shift # past value
        ;;
        -n|--nova)
            NOVA="$2"
            shift # past key
            shift # past value
        ;;
        -r|--roottask)
            ROOTTASK="$2"
            shift # past key
            shift # past value
        ;;
        -v|--vmm)
            VMM="$2"
            shift # past key
            shift # past value
        ;;
        --debug)
            set -x
            shift # past key
        ;;
        --dry-run)
            DRY_RUN=1
            shift
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

set -- "${POSITIONAL[@]}" # restore positional parameters

echo "kargs: ${KARGS}"
echo "use supernova: ${USE_SUPERNOVA}"
echo "initrd: ${INITRD}"
echo "kernel: ${KERNEL}"

if [[ ${USE_SUPERNOVA} -gt 0 ]]; then
  echo "bender: ${BENDER}"
  echo "nova: ${NOVA}"
  echo "roottask: ${ROOTTASK}"
  echo "vmm: ${VMM}"
fi

QEMU_ARGS=""
QEMU_ARGS+=" -m 4096 -smp 2"
QEMU_ARGS+=" -M q35 -cpu host -enable-kvm"
QEMU_ARGS+=" -serial stdio -serial tcp::5556,server,nowait"
QEMU_ARGS+=" -display none -k en-us"
QEMU_ARGS+=" ${QARGS[*]}"

NOVA_ARGS="iommu novga serial"
ROOTTASK_ARGS="--serial"

CMD="qemu-system-x86_64"
if [[ ${USE_SUPERNOVA} -gt 0 ]]; then
    CMD+="${QEMU_ARGS[*]}"
    CMD+=" -kernel ${BENDER}"
    CMD+=" -initrd "'"${NOVA} ${NOVA_ARGS},${ROOTTASK} ${ROOTTASK_ARGS},${VMM} ${SNARGS},${KERNEL} ${KARGS},${INITRD}"'
else
    qemu-system-x86_64 \
    "${QEMU_ARGS[@]}" \
    -kernel "${KERNEL}" \
    -append "${KARGS}" \
    -initrd "${INITRD}"
fi

if [[ ${DRY_RUN} -gt 0 ]]; then
    echo "${CMD}"
else
    ${CMD}
fi
