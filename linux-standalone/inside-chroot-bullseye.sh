#!/bin/bash
# File: clean.sh
# Part of cards-pkg <github.com/rmkrupp/cards-pkg>
#
# Copyright (C) 2024 Noah Santer <n.ed.santer@gmail.com>
# Copyright (C) 2024 Rebecca Krupp <beka.krupp@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

#
# This is put inside the chroot by build.sh and runs there
#
# Note that Debian "bullseye" doesn't have a glslc package, so this downloads
# and builds it from Google's GitHub repo. This takes a bit.
#

arch="$1"
debian="bullseye"

apt install -y \
    build-essential \
    pkg-config \
    git \
    python3 \
    ninja-build \
    gperf \
    libevent-dev \
    libsqlite3-dev \
    libluajit-5.1-dev \
    libjansson-dev \
    libunistring-dev || exit 1

apt install -y \
    libglfw3-dev \
    liblzma-dev \
    cmake

cd ~ || exit 1
git clone https://github.com/rmkrupp/cards || exit 1
cd cards || exit 1
git submodule update --init || exit 1
cardsversion="$(git describe --always --dirty)"

echo "configure.py..."
./configure.py --build=release --enable-compatible \
    --cflags='-Wno-attributes -O2' || exit 1

ninja \
    cards \
    clients/rlcli \
    tools/cards_compile \
    tools/cards_inspect \
    tools/save_create || exit 1

echo "cards_compile..."
./tools/cards_compile data/cards.db data/cards/*.lua || exit 1

cp -v "/lib/$arch-linux-gnu/libevent-2.1.so.7" libs/ || exit 1
cp -v "/lib/$arch-linux-gnu/libluajit-5.1.so.2" libs/ || exit 1
cp -v "/lib/$arch-linux-gnu/libsqlite3.so.0" libs/ || exit 1
cp -v "/lib/$arch-linux-gnu/libunistring.so.2" libs/ || exit 1

cd .. || exit 1

git clone https://github.com/google/shaderc || exit 1
cd shaderc || exit 1
./utils/git-sync-deps || exit 1
cd .. || exit 1
mkdir shaderc-build
cd shaderc-build || exit 1
cmake -GNinja -DCMAKE_BUILD_TYPE=Release ../shaderc || exit 1
ninja || exit 1

cd .. || exit 1

git clone https://github.com/rmkrupp/cards-client || exit 1
cd cards-client || exit 1
git submodule update --init || exit 1
clientversion="$(git describe --always --dirty)"

echo "configure.py..."
./configure.py --build=release --enable-compatible \
    --glslc='../shaderc-build/glslc/glslc' \
    --cflags='$cflags -Wno-attributes -DSHADER_BASE_PATH=\"data/shaders\" -DTEXTURE_BASE_PATH=\"data\"' || exit 1

ninja || exit 1

cp -v '/lib/x86_64-linux-gnu/libglfw.so.3' libs/ || exit 1
cp -v '/lib/x86_64-linux-gnu/liblzma.so.5' libs/ || exit 1
cp -v '/lib/x86_64-linux-gnu/libvulkan.so.1' libs/ || exit 1

cd .. || exit 1

out="$arch"

mkdir -p "$out"
mkdir -p "$out/bin"
mkdir -p "$out/bin/clients"
mkdir -p "$out/bin/tools"
mkdir -p "$out/data"
mkdir -p "$out/data/shaders"
mkdir -p "$out/libs"
mkdir -p "$out/misc"

echo "cards $cardsversion ($arch-$debian) built $(date "+%Y-%m-%d %h:%M:%S %p")" > "$out/misc/version"
echo "cards-client $clientversion ($arch-$debian) built $(date "+%Y-%m-%d %h:%M:%S %p")" >> "$out/misc/version"

cp -v cards/cards "$out/bin" || exit 1
cp -v cards/clients/rlcli "$out/bin/clients" || exit 1
cp -v cards/tools/cards_compile "$out/bin/tools" || exit 1
cp -v cards/tools/cards_inspect "$out/bin/tools" || exit 1
cp -v cards/data/cards.db "$out/data" || exit 1
cp -v cards/libs/*.so.* "$out/libs" || exit 1

cp -v cards-client/cards-client "$out/bin" || exit 1
cp -v cards-client/out/shaders/* "$out/data/shaders" || exit 1
cp -v cards-client/tools/generate-dfield "$out/bin/tools" || exit 1
cp -v cards-client/libs/*.so.* "$out/libs" || exit 1

tar cvf "cards-$arch-$debian.tar" "$out" || exit 1

exit 0
