#!/usr/bin/env bash

hostname="$1"
machine_name="$(echo "$hostname" | tr '._' '--')"

bindir="$HOME/.local/bin"

cces_version=2.11.1
toolchain_timestamp=202210191423

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

orb create -a amd64 ubuntu:focal "$machine_name"
orb -m "$machine_name" sudo hostnamectl set-hosname "$hostname"
orb -m "$machine_name" "$(dirname $0)/install-sharc-toolchain.sh" "$cces_version" "$toolchain_timestamp"

if [[ ":$PATH:" == *":$bindir:"* ]] ; then
    cat "$(dirname $0)/generate-cces-wrappers.sh" | \
        sed -e "
            s|^orb_machine_name=$|orb_machine_name=${machine_name}|g ;
            s|^cces_version=$|cces_version=${cces_version}|g ;" \
        > "$bindir/generate-cces-wrappers.sh"
    chmod +x "$bindir/generate-cces-wrappers.sh"
    "$bindir/generate-cces-wrappers.sh"
else
    echo "$bindir doesn't appear in \$PATH - see generate-cces-wrappers.sh for manual installation"
    exit 1
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