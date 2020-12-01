#!/usr/bin/env bash

set -euxo pipefail

KIELE_VERSION="$1"
UBUNTU_RELEASE="$2"
KIELE_REVISION="$3"

sudo apt-get update && sudo apt-get upgrade --yes
sudo apt-get install --yes opam netcat
sudo apt-get install --yes ./kiele_${KIELE_VERSION}_amd64_${UBUNTU_RELEASE}.deb
sudo bash -c 'OPAMROOT=/usr/lib/kframework/opamroot k-configure-opam'
sudo bash -c 'OPAMROOT=/usr/lib/kframework/opamroot opam install --yes ocaml-protoc rlp yojson zarith hex uuidm cryptokit'
export OPAMROOT=/usr/lib/kframework/opamroot
eval $(opam config env)

git clone 'https://github.com/runtimeverification/iele-semantics'
cd iele-semantics
git checkout "$KIELE_REVISION"
git submodule update --init --recursive

iele-vm 0 127.0.0.1 > port &
sleep 3
export PORT=$(cat port | awk -F ':' '{print $2}')
make test -j`nproc` -k
make coverage
kill %1
