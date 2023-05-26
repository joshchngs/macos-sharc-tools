# ADI CCES for macOS

These scripts create a VM with [Orbstack](https://orbstack.dev), and install the Analog Devices [CrossCore® Embedded Studio](https://www.analog.com/en/design-center/evaluation-hardware-and-software/software/adswt-cces.html#software-overview) IDE, as well as the SHARC compiler toolchain.


## Usage

1. If you have a license.dat, copy it to this directory. If you don't have one you will have to register using the GUI somehow.
2. Run ./setup-macos.sh & click the buttons
3. That's it, you can now run `cc21k` & friends on macOS


## Caveats & Limitations

1. [No GUI](#running-the-ide)
2. [No Device Programming](https://docs.orbstack.dev/machines/#usb-devices) (yet)
3. Orb only mounts the non-conflicting Mac directories (`/Applications`, `/Library`, `/Users`, `/Volumes`, `/private`) into the VM at the same path, so only tool invocations in those directories will work.


### Running the IDE

I haven't tried it, and you can't make me. It's installed because it has to be. It's probably [possible](https://docs.orbstack.dev/machines/#graphical-apps) to make it work.
