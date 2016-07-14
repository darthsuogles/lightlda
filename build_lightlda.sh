#!/bin/bash

_script_dir_="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

set -ex

(cd ${_script_dir_}
 [ -d multiverso ] || git clone -b multiverso-initial git@github.com:Microsoft/multiverso.git
 (cd multiverso
  # git checkout -b qphi || echo "okay"
  # git pull origin multiverso-initial
  # git submodule update --init --recursive
  # (cd third_party
  #  chmod +x install.sh && ./install.sh)
  cmake .
  make -j64 all)
 make -j64
)
