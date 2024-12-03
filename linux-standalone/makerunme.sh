#!/bin/bash
# File: makerunme.sh
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
# Generate the architecture-independent wrapper scripts that set the library
# path and move to the correct directory when run
#

function makerunme() {
    echo '#!/bin/bash'
    echo
    echo 'path="$(dirname ${BASH_SOURCE[0]})"'
    echo '[ -n "$ARCH" ] && arch="$ARCH" || arch="$(uname -m)"'
    echo
    echo 'cd "$path/$arch" || { echo "error changing directory (unsuppported architecture?)" >&2 ; exit 1 ; }'
    echo 
    echo 'LD_LIBRARY_PATH="./libs" "./bin/$0"'
}

makerunme > "$1" && chmod +x "$1"
