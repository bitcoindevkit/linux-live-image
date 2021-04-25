#!/usr/bin/env sh

set -e
set -x

lb clean
lb config

mkdir -pv ./config/includes.chroot/usr/bin/

mkdir -pv ./rust-build

BDK_LIVE_ARCH=${BDK_LIVE_ARCH:-amd64}

case $BDK_LIVE_ARCH in
	amd64)
		RUST_TARGET="x86_64-unknown-linux-gnu"
		;;
	i386)
		RUST_TARGET="i686-unknown-linux-gnu"
		;;
	*)
		echo "Unknown BDK_LIVE_ARCH '${BDK_LIVE_ARCH}'"
		exit 1
		;;
esac

# Build rusty-paper-wallet
cd rust-build/rusty-paper-wallet
cargo build --release --target $RUST_TARGET
cd ../../

# Build bdk-cli
cd rust-build/bdk-cli
cargo build --release --target $RUST_TARGET
cd ../../

# Copy the binaries
cp -v ./rust-build/rusty-paper-wallet/target/$RUST_TARGET/release/rusty-paper-wallet ./config/includes.chroot/usr/bin
cp -v ./rust-build/bdk-cli/target/$RUST_TARGET/release/bdk-cli ./config/includes.chroot/usr/bin

# Strip the binaries
strip ./config/includes.chroot/usr/bin/*

# Copy the bootloader binary
cp -Rv /usr/share/live/build/bootloaders/isolinux/isolinux.bin ./config/bootloaders/isolinux

# From https://github.com/rust-cli/meta/issues/33#issuecomment-529796973
BDK_CLI_VERSION=`awk -F ' = ' '$1 ~ /version/ { gsub(/[\"]/, "", $2); printf("%s",$2) }' ./rust-build/bdk-cli/Cargo.toml`
RUSTY_PAPER_WALLET_VERSION=`awk -F ' = ' '$1 ~ /version/ { gsub(/[\"]/, "", $2); printf("%s",$2) }' ./rust-build/rusty-paper-wallet/Cargo.toml`

BDK_CLI_GIT_REV=`git --git-dir=./rust-build/bdk-cli/.git rev-parse --short HEAD`
RUSTY_PAPER_WALLET_GIT_REV=`git --git-dir=./rust-build/rusty-paper-wallet/.git rev-parse --short HEAD`

sed -ie "s/bdk-cli: \(.*\)<\/tspan/bdk-cli: $BDK_CLI_VERSION ($BDK_CLI_GIT_REV)<\/tspan/g" config/bootloaders/isolinux/splash.svg
sed -ie "s/rusty-paper-wallet: \(.*\)<\/tspan/rusty-paper-wallet: $RUSTY_PAPER_WALLET_VERSION ($RUSTY_PAPER_WALLET_GIT_REV)<\/tspan/g" config/bootloaders/isolinux/splash.svg

# Build
lb build
