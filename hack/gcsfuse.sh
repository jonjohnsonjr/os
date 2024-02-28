#!/bin/bash

ARCH=$(uname -m)
if [ "${ARCH}" == "arm64" ]; then
	ARCH="aarch64"
fi
echo $ARCH


# yay wolfi!
apk add gcsfuse

# Set up a gcsfuse RO mount to the public bucket. This is a cheap and
# cheerful way to recreate the make targets (class A HEADs) locally
# without syncing the whole bucket (class A+B).
mkdir -p /gcsfuse/wolfi-registry
gcsfuse -o ro --implicit-dirs --only-dir os wolfi-production-registry-destination /gcsfuse/wolfi-registry

mkdir -p ./packages/${ARCH}
# Symlink the gcsfuse mount to ./packages/ to workaround the Makefile CWD assumptions
for f in /gcsfuse/wolfi-registry/${ARCH}/*.apk; do
  ln -s "$f" ./packages/${ARCH}/
done


# Make a copy of the APKINDEX.* since we'll need to write to it on package builds
cp /gcsfuse/wolfi-registry/${ARCH}/APKINDEX.* ./packages/${ARCH}/
