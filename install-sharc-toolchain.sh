#!/usr/bin/env bash

# Run this scipt on an Ubuntu host

set -o pipefail
set -x

# See setup-macos.sh for sensible values
cces_version="$1"
toolchain_timestamp="$2"
deb_file="$3"

if [ -z "${cces_version}" ] || [ -z "${toolchain_timestamp}" ] || [ ! -f "${deb_file}" ] ; then
    this_script=$(basename "$0")
    echo "Usage: ${this_script} <cces_version> <toolchain_timestamp> <deb_file>"
    exit 1
fi

install_dir="/opt/analog/cces/${cces_version}"
profile_entry="/etc/profile.d/sharc-toolchain-${cces_version}.${toolchain_timestamp}.sh"

# Analog Devices don't build for amd64, because apparently 2 decades isn't long enough to figure out the new compiler flags
sudo dpkg --add-architecture i386
sudo apt update
sudo apt install -y \
    build-essential \
    libc6:i386 \
    libncurses5:i386 \
    libstdc++6:i386 \
    zlib1g:i386 \
    libncursesw5 \
    unzip \
    zip

# For the pain enjoyers who wish to use Eclipse, you will need these packages
sudo apt install -y \
    libgtk2.0-0 \
    libxtst6 \
    gtk2-engines-murrine \
    libcanberra-gtk-module \
    gtk2-engines

# Some of the compiler components live in the main IDE package, for no particular reason
sudo dpkg -i "${deb_file}"


# The following code does the same thing as clicking the tedious buttons which you inexplicably need to click in that godawful hunk of bugware they call an IDE

curl "https://www.analog.com/static/ccesupdatesite/sharc_linux/${cces_version}-SNAPSHOT/plugins/com.analog.crosscore.incubation.sharc_linux.stage_${cces_version}.${toolchain_timestamp}.jar" > /tmp/sharc-toolchain-archive.jar

cd /tmp || exit 1 ; unzip /tmp/sharc-toolchain-archive.jar support_files.tar.gz
sudo mkdir -p "${install_dir}"

cd "${install_dir}" || exit 1 ; sudo tar -zxf /tmp/support_files.tar.gz

echo "Adding ${install_dir} to your PATH with ${profile_entry}"
echo "export PATH=\"\$PATH:${install_dir}\"" | sudo tee "$profile_entry"
