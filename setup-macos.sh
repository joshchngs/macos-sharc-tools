#!/usr/bin/env bash

hostname="$1"

bindir="$HOME/.local/bin/$hostname"

cces_version=3.0.1
toolchain_timestamp=202403270419
deb_file=$(realpath "adi-cces-linux-amd64-${cces_version}.deb")

if [ -z "${hostname}" ] ; then
    echo "Usage: ./setup-macos.sh <hostname>"
    echo "Hostname should match your CCES license requirements"
    exit 1
fi

if [[ ! -x "$(which orb)" ]] ; then
    echo "Couldn't find the 'orb' CLI"
    echo "Get Orbstack from https://orbstack.dev or 'brew install orbstack'" 
    exit 1
fi

if orbctl info "$hostname" 2>/dev/null ; then
    echo "Orb machine already created - skipping this step"
else
    orb create -a amd64 ubuntu:focal "$hostname"
    orb -m "$hostname" "$(dirname $0)/install-sharc-toolchain.sh" "$cces_version" "$toolchain_timestamp" "$deb_file"
fi

if [ -d "$bindir" ] ; then
    echo "$bindir already exists, assuming it's set up correctly. Skipping."
else
    mkdir -p "$bindir"
    cat "$(dirname $0)/generate-cces-wrappers.sh" | \
        sed -e "
            s|^orb_hostname=$|orb_hostname=${hostname}|g ;
            s|^cces_version=$|cces_version=${cces_version}|g ;" \
        > "$bindir/generate-cces-wrappers.sh"
    chmod +x "$bindir/generate-cces-wrappers.sh"
    "$bindir/generate-cces-wrappers.sh"
    echo "$bindir" | sudo tee "/etc/paths.d/$hostname" > /dev/null
fi

license_dat="$(dirname $0)/license.dat"
orb_license_dir="/home/$USER/.analog/cces"
mac_license_dir="$HOME/OrbStack/${hostname}${orb_license_dir}"


if [ -f  "$license_dat" ] ; then
    echo "Installing $license_dat into VM"
    mkdir -p "$mac_license_dir"
    cp "$license_dat" "$mac_license_dir"
else
    echo "Copy your license.dat here: "
    echo "    (in the VM) $orb_license_dir/license.dat"
    echo "    (in macOS) $mac_license_dir/license.dat"
fi