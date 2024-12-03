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
# Clean up the results of build.sh (both the intermediate and result files)
#

function clean() {
    arch="$1"
    debian="$2"
    sudo rm -rf "build-$debian-$arch-chroot"
}

clean x86_64 stable
clean x86_64 bullseye
clean i386 stable
clean i386 bullseye
rm -rf cards-linux-standalone-stable
rm -rf cards-linux-standalone-bullseye


