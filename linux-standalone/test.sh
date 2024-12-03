#!/bin/bash
# File: test.sh
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

debian="bullseye"

function build_standalone() {
    arch="$1"
    debianarch="$2"
    debian="$3"
    chroot="build-$debian-$arch-chroot"
    mkdir "$chroot" || exit 1
    if [[ "$debian" == "stable" ]] ; then
        sudo debootstrap --arch="$debianarch" \
            "$debian" "$chroot" || exit 1
    else
        sudo debootstrap --variant=minbase --include sysvinit-core --foreign \
            --arch="$debianarch" "$debian" "$chroot" || exit 1
        sudo sed -i -e 's/systemd systemd-sysv //g' \
            "$chroot/debootstrap/required" || exit 1
        sudo chroot "$chroot" debootstrap/debootstrap --second-stage || exit 1
    fi
    sudo cp -v cards-x86_64.tar "$chroot/root/"
}

build_standalone x86_64 amd64 $debian || exit 1

exit 0
