#!/usr/bin/env bash

# MKDEV - Boilerplates for isolated development environments
# Copyright (C) 2024 Vinícius Moraes <vinicius.moraes@eternodevir.com>
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
# along with this program. If not, see <http://www.gnu.org/licenses/>.

# Update Makefiles within the boilerplates directory.

shopt -s extglob

update_makefiles() {
    local stop_pattern
    local content
    local existing_content
    stop_pattern="# Container targets\/commands"
    content=$(awk "NR == 1 {next} /$stop_pattern/ {print; exit} 1" "$1")

    if [[ "$1" == "Dev.mk" ]]; then
	for mk in ./boilerplates/!(*omni)/*/Makefile; do
	    existing_1stline=$(head -1 "$mk")
	    existing_content=$(awk "/$stop_pattern/ {rest=1; next} rest" "$mk")
	    printf "%s\n%s\n%s\n" \
		   "$existing_1stline" "$content" "$existing_content" \
		   > "$mk"
	done
    fi

    if [[ "$1" == "Omni.mk" ]]; then
	for mk in ./boilerplates/omni/*/Makefile; do
	    existing_1stline=$(head -1 "$mk")
	    existing_content=$(awk "/$stop_pattern/ {rest=1; next} rest" "$mk")
	    printf "%s\n%s\n%s\n" \
		   "$existing_1stline" "$content" "$existing_content" \
		   > "$mk"
	done
    fi
}

ci_output() {
    if [ -n "$CI" ]; then
	local status_makefiles="$1"
	if [[ "$status_makefiles" == "true" && "$RUN_MODE" == "push" ]]; then
	    printf "::notice title=%s::boilerplates updated successfully.\n" \
		   "$0"
	fi
	printf "makefiles=%s\n" "$status_makefiles" >> "$GITHUB_OUTPUT"
    fi
}

source_of_truh="Dev.mk"
update_makefiles "$source_of_truh"

source_of_truh="Omni.mk"
update_makefiles "$source_of_truh"

if git status --porcelain | grep -q 'Makefile'; then
    printf "%s: boilerplates updated successfully.\n" "$0"
    ci_output "true"
else
    printf "%s: nothing to update, no boilerplate changes.\n" "$0"
    ci_output "false"
fi
