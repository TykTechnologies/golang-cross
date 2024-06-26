# golang-cross [![Actions Status](https://github.com/TykTechnologies/golang-cross/workflows/Publish%20Images/badge.svg)](https://github.com/TykTechnologies/golang-cross/actions)

Forked from https://github.com/gythialy/golang-cross. 

Docker container to do cross compilation (Linux, windows, macOS, ARM, ARM64) of go packages including support for cgo. Upstream had some optimisations for updating just go and goreleaser that is dispensed with in this repo. 

`Dockerfile.tapi` is checked in that can make the process of finding the correct apple-libtapi version. As of 2023, this is a historical artefact, osx builds are no longer supported by this image.

## Local Build
For example if you want to build a Go 1.16 image based on Debian buster,

``` shellsession
$ docker build --build-arg GO_VERSION=1.16 --build-arg DEB_VERSION=buster -f Dockerfile -t tykio/golang-cross:1.16 .
```

## Automation

[release.yml](.github/workflows/release.yml) builds images suitable for,
- OSes that do not have `GLIBC_2.23`
- the standard [golang build image](https://hub.docker.com/_/golang)

When creating the PR, it just builds. When committing to master, the images are pushed to <https://hub.docker.com/r/tykio/golang-cross>.
