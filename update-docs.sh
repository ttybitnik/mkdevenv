#!/usr/bin/env bash

# MKDEV - Boilerplates for isolated development environments
# Copyright (C) 2025 Vinícius Moraes <vinicius.moraes@eternodevir.com>
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

# Update README.md files within the boilerplates directory.

OUTPUT_FILE=README.md

read_txt_files() {
    local txt_files=(*.txt)
    declare -gA packages
    declare -gA column_widths
    declare -gi max_rows=0

    if [ ${#txt_files[@]} -eq 0 ]; then
        printf "No .txt files found in the current directory.\n"
        exit 1
    fi

    for file in "${txt_files[@]}"; do
        local max_width=0

        mapfile -t temp_array < "$file"
        packages["$file"]="${temp_array[*]}"

        if [ ${#temp_array[@]} -gt "$max_rows" ]; then
            max_rows=${#temp_array[@]}
        fi

        for package in "${temp_array[@]}"; do
            if [ ${#package} -gt "$max_width" ]; then
                max_width=${#package}
            fi
        done
        column_widths["$file"]=$max_width
    done
}

generate_markdown() {
    local header_title="$1"
    local txt_files=(*.txt)

    {
        printf "# %s\n\n" "$header_title"

        printf "|"
        for file in "${txt_files[@]}"; do
            column_name="${file%.txt}"
            width=${column_widths["$file"]}
            if [ ${#column_name} -gt "$width" ]; then
                width=${#column_name}
            fi
            printf " %-${width}s |" "$column_name"
        done
        printf "\n"

        printf "|"
        for file in "${txt_files[@]}"; do
            width=${column_widths["$file"]}
            separator_width=$((width + 1))
            printf ":%-${separator_width}s|" | tr ' ' '-'
        done
        printf "\n"

        for ((i = 0; i < max_rows; i++)); do
            printf "|"
            for file in "${txt_files[@]}"; do
                IFS=' ' read -r -a package_list <<< "${packages["$file"]}"
                package="${package_list[$i]:-""}"
                width=${column_widths["$file"]}
                printf " %-${width}s |" "$package"
            done
            printf "\n"
        done

        printf "\n"
        printf "1. Create a \`.mkdev\` directory at the root of the project.\n"
        printf "2. Copy all the boilerplate files into the \`.mkdev\` directory.\n"
        printf "3. Move the \`Makefile\` to the root of the project.\n\n"
        printf "*For more information, see <https://github.com/ttybitnik/mkdev>.*\n"
    } > "$OUTPUT_FILE"
}

ci_output() {
    if [ -n "$CI" ]; then
        local status_readme="$1"
        if [[ "$status_readme" == "true" && "$RUN_MODE" == "push" ]]; then
            printf "::notice title=%s::boilerplates updated successfully.\n" \
                   "$0"
        fi
        printf "readme=%s\n" "$status_readme" >> "$GITHUB_OUTPUT"
    fi
}

for md in ./boilerplates/*/*/README.md; do
    dir_path=$(dirname "$md")
    header_title=$(printf "%s" "$dir_path" \
                   | sed 's|\./boilerplates/\([^/]*\)/\([^/]*\)$|\1-\2|')

    cd "$dir_path" || exit 1
    read_txt_files
    generate_markdown "$header_title"
    cd ../../../ || exit 1
done

if git status --porcelain | grep -q 'README'; then
    printf "%s: readme files updated successfully.\n" "$0"
    ci_output "true"
else
    printf "%s: nothing to update, no readme changes.\n" "$0"
    ci_output "false"
fi
