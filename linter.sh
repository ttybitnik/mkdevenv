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

# Linter to ensure compliance with guidelines, see "./boilerplates/README.md".

# shellcheck disable=SC2016
shopt -s extglob
failure_count=0

assert_files() {
    local dir="$1"
    local files=("README.md" "Containerfile" "Makefile")

    for file in "${files[@]}"; do
	if [[ ! -e "$dir/$file" ]]; then
	    printf "%s: Missing file: %s.\n" "$dir" "$file"
	    ((failure_count++))
	fi
    done
}

makefiles_assert_sections() {
    local file="$1"
    local -A sections

    sections=(
	["Host"]="# Host targets/commands"
	["Container"]="# Container targets/commands"
	[".PHONY"]=".PHONY: dev start stop clean serestore"
	[".PHONY"]=".PHONY: lint test build run deploy debug distclean"
    )

    for sec in "${!sections[@]}"; do
	local expected="${sections[$sec]}"
	if ! grep -qe "^${expected}$" "$file" 2>/dev/null; then
	    printf "%s: missing or incorrect section: %s. Expected: %s.\n" \
		   "$file" "$sec" "$expected"
	    ((failure_count++))
	fi
    done
}

makefiles_assert_infos() {
    local file="$1"
    local -A infos

    infos=(
	["dev"]='$(info Building development container image...)'
	["start"]='$(info Starting development container...)'
	["stop"]='$(info Stopping development container...)'
	["clean"]='$(info Removing development container and image...)'
	["serestore"]='$(info Restoring project SELinux context and permissions...)'
	["lint"]='$(info Running linters...)'
	["test"]='$(info Running tests...)'
	["build"]='$(info Building...)'
	["run"]='$(info Running...)'
	["deploy"]='$(info Deploying...)'
	["debug"]='$(info Debugging tasks...)'
	["distclean"]='$(info Cleaning artifacts...)'
    )

    for inf in "${!infos[@]}"; do
	local expected="${infos[$inf]}"
	if ! grep -qe "${expected}$" "$file" 2>/dev/null; then
	    printf "%s: missing or incorrect info: %s. Expected: %s.\n" \
		   "$file" "$inf" "$expected"
	    ((failure_count++))
	fi
    done
}

makefiles_assert_targets() {
    local file="$1"
    local -A targets

    targets=(
	["dev"]="dev:"
	["start"]="start:"
	["stop"]="stop:"
	["clean"]="clean: distclean"
	["serestore"]="serestore:"
	["lint"]="lint:"
	["test"]="test: lint"
	["build"]="build: test"
	["run"]="run: build"
	["deploy"]="deploy: build"
	["debug"]="debug: test"
	["distclean"]="distclean:"
    )

    for tgt in "${!targets[@]}"; do
	local expected="${targets[$tgt]}"
	if ! grep -qe "^${expected}$" "$file" 2>/dev/null; then
	    printf "%s: missing or incorrect target: %s. Expected: %s.\n" \
		   "$file" "$tgt" "$expected"
	    ((failure_count++))
	fi
    done
}

makefiles_assert_variables() {
    local file="$1"
    local type="$2"
    local -A variables

    if [[ "$type" == "project" ]]; then
	variables=(
	    ["PROJECT_NAME"]="changeme"
	    ["CONTAINER_ENGINE"]="changeme"
	    ["__USER"]='$(or $(USER),$(shell whoami))'
	)
    elif [[ "$type" == "omni" ]]; then
	variables=(
	    ["OMNI_NAME"]="changeme"
	    ["CONTAINER_ENGINE"]="changeme"
	    ["__USER"]='$(or $(USER),$(shell whoami))'
	    ["__AFFIX"]='omni-$(OMNI_NAME)'
	)
    else
	printf "Unknown type: %s\n" "$type" >&2
	exit 1
    fi

    for var in "${!variables[@]}"; do
	local expected="${variables[$var]}"
	if ! grep -qe "^${var} = ${expected}$" "$file" 2>/dev/null; then
	    printf "%s: missing or incorrect variable: %s. Expected: %s.\n" \
		   "$file" "$var" "$expected"
	    ((failure_count++))
	fi
    done
}

containerfiles_assert_instructions() {
    local file="$1"
    local -A instructions

    instructions=(
	["ARG"]="USERNAME=mkdev"
	["LABEL"]="mkdev.name="
	["WORKDIR"]='/home/$USERNAME/workspace'
	["USER"]='$USERNAME'
	["CMD"]='["/bin/bash", "-l"]'
    )

    for ins in "${!instructions[@]}"; do
	local expected="${instructions[$ins]}"
	if ! grep -qe "^${ins} ${expected}" "$file" 2>/dev/null; then
	    printf "%s: missing or incorrect instruction: %s. Expected: %s.\n" \
		   "$file" "$ins" "$expected"
	    ((failure_count++))
	fi
    done
}

ci_output() {
    if [ -n "$CI" ]; then
	local status_linter="$1"

	if [[ "$status_linter" == "failure" ]]; then
	    local word="issue"
	    (( failure_count > 1 )) && word+="s"
	    printf "::error title=%s::checks failed: %d %s found.\n" \
		   "$0" \
		   "$failure_count" \
		   "$word"
	fi

	printf "checks=%s\n" "$status_linter" >> "$GITHUB_OUTPUT"
    fi
}

check_failures() {
    if (( failure_count > 0 )); then
	local word="issue"
	(( failure_count == 1 )) && word+="s"
	printf "%s: checks failed: %d %s found.\n" \
	       "$0" \
	       "$failure_count" \
	       "$word"
	ci_output "failure"
	exit 1
    fi
}

# Critical path
for dir in ./boilerplates/*/*; do
    assert_files "$dir"
done

for mk in ./*.mk; do
    makefiles_assert_sections "$mk"
    makefiles_assert_infos "$mk"
    makefiles_assert_targets "$mk"

    if [[ "$mk" == "./Dev.mk" ]]; then
        makefiles_assert_variables "$mk" "project"
    elif [[ "$mk" == "./Omni.mk" ]]; then
        makefiles_assert_variables "$mk" "omni"
    fi
done

check_failures

# Makefiles
for mk in ./boilerplates/*/*/Makefile; do
    makefiles_assert_sections "$mk"
    makefiles_assert_infos "$mk"
    makefiles_assert_targets "$mk"
done

for mk in ./boilerplates/!(*omni)/*/Makefile; do
    makefiles_assert_variables "$mk" "project"
done

for mk in ./boilerplates/omni/*/Makefile; do
    makefiles_assert_variables "$mk" "omni"
done

# Containerfiles
for cf in ./boilerplates/*/*/Containerfile; do
    containerfiles_assert_instructions "$cf"
done

check_failures

printf "%s: all checks passed successfully.\n" "$0"
ci_output "success"
exit 0
