#!/usr/bin/env bash
#
# Convert a sotest bundle to an ipxe configuration and serve it via http.
# This is handy in combination with an ipxe that tries your http server first.
#
# It unzips the sotest bundle to a temporary directory and builds an ipxe 
# configuration file based on the sotest project configuration.
# Thereafter, it starts a webserver on to serve the files.
#
set -o errexit  # abort on nonzero exit status

# Default values
DEFAULT_SOTEST_BUNDLE_DIR="${HOME}/src/dev/supernova-core/result"
PORT=8888
SERVER_URL="http://\${next-server}:${PORT}"
UEFI=1

# Avoid unbound variables.
SOTEST_BUNDLE_DIR="${SOTEST_BUNDLE_DIR:-""}"

function print_usage {
    echo "usage: $0"
    echo "    -h | --help  Print help"
    echo "    -b | --bios  Use UEFI (uefi is default)"
    echo "    -p | --port  Configure port"
    echo "    -d | --dir   Path to sotest bundle directory"
    exit 0
}

# parse arguments
POSITIONAL=()
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -b|--bios)
            UEFI=0
            shift # past key
        ;;
        -d|--dir)
            SOTEST_BUNDLE_DIR="$2"
            shift # past key
            shift # past value
        ;;
        -p|--port)
            PORT="$2"
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

if [[ -z "${SOTEST_BUNDLE_DIR}" ]]; then
    echo "Using default directory ${DEFAULT_SOTEST_BUNDLE_DIR}"
    SOTEST_BUNDLE_DIR=${DEFAULT_SOTEST_BUNDLE_DIR}
fi

if ((UEFI==1)) ; then
    PLATFORM="uefi"
else
    PLATFORM="bios"
fi

TMP_DIR=$(mktemp -d)
trap 'rm -rf "${TMP_DIR}"' EXIT

SOTEST_BUNDLE=${SOTEST_BUNDLE_DIR}/bundle.zip
SOTEST_CONFIG=${SOTEST_BUNDLE_DIR}/project-config.yaml
IPXE_CONFIG=${TMP_DIR}/ipxe-default.cfg

# Extract sotest bundle
unzip -d "${TMP_DIR}" "${SOTEST_BUNDLE}"

NUMBER_OF_BOOT_ITEMS=$(yq '.boot_items | length' "${SOTEST_CONFIG}")
if (( NUMBER_OF_BOOT_ITEMS > 1 )); then
    echo "Warning: Found ${NUMBER_OF_BOOT_ITEMS} boot items. Using only the first one."
fi

echo "#!ipxe" >> "${IPXE_CONFIG}"

# Use -r to eliminate quotes in each line.
EXEC=$(yq -r '.boot_items[0].boot_source.'"${PLATFORM}"'.exec' "${SOTEST_CONFIG}")
echo "kernel ${SERVER_URL}/${EXEC}" >> "${IPXE_CONFIG}"


# yq output contains multiple strings, each with spaces to separate args.
# We want an array where each element matches one "load" line.
IFS=$'\n' read -r -d '' -a LOAD < <(yq -r '.boot_items[0].boot_source.'"${PLATFORM}"'.load[]' "${SOTEST_CONFIG}" && printf '\0')

for LOAD_LINE in "${LOAD[@]}"; do
    echo "initrd ${SERVER_URL}/${LOAD_LINE}" >> "${IPXE_CONFIG}"
done

echo "boot" >> "${IPXE_CONFIG}"

echo ""
echo "ipxe configuration:"
cat "${IPXE_CONFIG}"
echo ""

python3 -m http.server --directory "${TMP_DIR}" "${PORT}"
