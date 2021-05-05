# BDK Linux Live Image

This repo contains the Debian `live-build` tree for a relatively small Linux live distro that has a basic graphical environment (XFCE) and bundles `rusty-paper-wallet` and `bdk-cli`. It can be used to generate
keys or paper wallets from an air-gapped computer with no persistent memory.

For convenience we release signed pre-built ISO images, but since the build is not reproducible we strongly encourage users to re-build their own image before using it with real keys and real money.

## How to build the image

The build process is only supported on a Debian system. Unfortunately running it inside of a Docker container is not easy, since the build scripts need to perform mounts inside the chroot.

### Install `live-build`

You can install `live-build` from the Debian repositories:

```shell
sudo apt update
sudo apt install -y live-build live-config
```

### Run the `build.sh` Script

Run as `root` the `build.sh` script. Make sure `cargo` is installed for `root` as well.

The default architecture is `amd64`, you can change it to `i386` by setting the `BDK_LIVE_ARCH` env variable to `i386`.

```
BDK_LIVE_ARCH=amd64 sudo build.sh
BDK_LIVE_ARCH=i386 sudo build.sh
```

## How to run the image

You can burn the `live-image-${BDK_LIVE_ARCH}.hybrid.iso` image to a CD or a DVD and boot from it. This is the recommended storage media to use, because it is read-only after the initial image is burned on it.
For extra safety you should also consider unplugging any kind of persistent memory from your computer, like your hard drive/SSD, before using the CD to generate keys.

Unfortunately CD/DVD drives are not very popular anymore: an alternative is booting off of a USB drive by flashing the ISO image to it with something like:

```
sudo dd if=live-image-XXXX.hybrid.iso of=/dev/sdX conv=sync status=progress
```
