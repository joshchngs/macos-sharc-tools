#!/usr/bin/env bash

# Run this scipt on an Ubuntu host

set -o pipefail

# See setup-macos.sh for sensible values
cces_version="$1"
toolchain_timestamp="$2"

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
    zip

# For the pain enjoyers who wish to use Eclipse, you will need these packages
sudo apt install -y \
    libgtk2.0-0:i386 \
    libxtst6:i386 \
    gtk2-engines-murrine:i386 \
    libcanberra-gtk-module:i386 \
    gtk2-engines:i386

# Some of the compiler components live in the main IDE package, for no particular reason
curl "https://download.analog.com/tools/CrossCoreEmbeddedStudio/Releases/Release_${cces_version}/adi-CrossCoreEmbeddedStudio-linux-x86-${cces_version}.deb" > "/tmp/cces-${cces_version}.deb"
sudo dpkg -i "/tmp/cces-${cces_version}.deb"


# The following code does the same thing as clicking the tedious buttons which you inexplicably need to click in that godawful hunk of bugware they call an IDE

curl "http://www.analog.com/static/ccesupdatesite/blackfin_sharc_linux/${cces_version}-SNAPSHOT/plugins/com.analog.crosscore.incubation.blackfin_sharc_linux.stage_${cces_version}.${toolchain_timestamp}.jar" > /tmp/sharc-toolchain-archive.jar

cd /tmp || exit 1 ; unzip /tmp/sharc-toolchain-archive.jar support_files.tar.gz
sudo mkdir -p "${install_dir}"

cd "${install_dir}" || exit 1 ; sudo tar -zxf /tmp/support_files.tar.gz

echo "Adding ${install_dir} to your PATH with ${profile_entry}"
echo "export PATH=\"\$PATH:${install_dir}\"" | sudo tee "$profile_entry"
