#!/usr/bin/env bash

# Copy this file into a directory which is in your PATH, and run it.
# It will rename itself to .cces-wrapper.sh, and create a symlink
# for each 

# Fill these with the correct values (see setup.sh)
orb_machine_name=
cces_version=
bin_name=$(basename $0)

all_bins=(
    adi_securebootsim
    adi_signtool
    cc21k
    ccblkfn
    chipfactory
    dyndump
    dynreloc
    easm21k
    easmblkfn
    elf2dyn
    elfar
    elfdump
    elfloader
    elfpatch
    elfspl21k
    elfsyms
    hexutil
    instrprof
    linker
    mem21k
    meminit
    pp
    securebootsim
    signtool
)

if [ "$bin_name" == "generate-cces-wrappers.sh" ] ; then
    echo "Installing CCES bin wrappers into $(dirname $0)"

    cd "$(dirname "${0}")" || exit 1
    mv "$0" .cces-wrapper.sh
    for bin in "${all_bins[@]}" ; do
        ln -s .cces-wrapper.sh "$bin"
        echo "    $bin"
    done

    exit 0
fi

orb -m "$orb_machine_name" "/opt/analog/cces/$cces_version/$bin_name" "$@"
