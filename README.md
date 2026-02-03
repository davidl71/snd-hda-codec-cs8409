# snd-hda-codec-cs8409

Linux kernel driver for Cirrus Logic CS8409 HDA bridge chip, commonly found in Apple MacBook Pro and iMac systems (2017-2020).

## Supported Devices

- Apple MacBook Pro (2017-2019)
- Apple iMac (2017-2020)
- Dell systems with CS8409/CS42L42

## Quick Install (Debian/Ubuntu)

```bash
curl -fsSL https://raw.githubusercontent.com/davidl71/snd-hda-codec-cs8409/master/scripts/install-repo.sh | sudo bash
```

## Manual Installation

### Option 1: DKMS (Recommended)

DKMS automatically rebuilds the module when you update your kernel.

```bash
# Install dependencies
sudo apt install dkms build-essential linux-headers-$(uname -r)

# Run DKMS installer
sudo ./dkms-install.sh
```

### Option 2: Build Debian Package

```bash
# Install build dependencies
./install-build-deps.sh

# Build the package
dpkg-buildpackage -us -uc -b

# Install
sudo dpkg -i ../snd-hda-codec-cs8409-dkms_1.0-1_all.deb
```

### Option 3: Manual Build

```bash
# Install dependencies
sudo apt install build-essential linux-headers-$(uname -r)

# Build
make

# Install
sudo make install

# Load the module
sudo modprobe snd-hda-codec-cs8409
```

## Kernel Compatibility

This driver supports:
- Linux kernel 5.x
- Linux kernel 6.x (including 6.17+ with new HDA API)

Backward compatibility is maintained through preprocessor conditionals.

## Uninstall

### DKMS
```bash
sudo ./dkms-uninstall.sh
```

### Debian Package
```bash
sudo apt remove snd-hda-codec-cs8409-dkms
```

## Development

### Creating a Release

```bash
# Setup GPG signing (one-time)
./scripts/setup-gpg-signing.sh

# Build and release
GPG_KEY_ID=YOUR_KEY_ID ./scripts/build-and-release.sh 1.0
```

## License

GPL-2.0-or-later

Copyright (C) 2021 Cirrus Logic, Inc. and Cirrus Logic International Semiconductor Ltd.

## Credits

- Original driver by Cirrus Logic
- Apple hardware support by the community
- Kernel 6.17+ compatibility patches
