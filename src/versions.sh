# Ensure command is available and within version range
#
# declares the global variables:
# - command
# - version_required
# - command_path
# - version_installed
# - version_in_range
#
# @param {string} command
# @param {string} version template string
# @returns {number} 0 = true, 1 = false
is_command_installed() {
    command="$1"
    version_required="$2"
    local logical_operator="${3:-==}"
    command_path=
    version_installed=
    version_in_range=

    echo "Checking if" "$command" "is installed..."
    if ! command_path="$(get_command_path "$command")"; then
        echo "Missing command -> '$command'"
        return 1
    else
        echo "$command" "command path ->" "$command_path"
    fi

    if ! version_installed="$(get_version "$command")"; then
        echo "Failed to get version -> '$command'"
        return 1
    else
        echo "$command" "installed version ->" "$version_installed"
    fi

    if ! compare_versions "$version_installed" "$logical_operator" "$version_required"; then
        echo "$command" "matches version -> false"
        version_in_range=false
        return 1
    else
        echo "$command" "matches version -> true"
        version_in_range=true
    fi
}


# Resolve command's path
#
# @param {string} command
# @returns {string|exit code} path
get_command_path() {
    local command="$1"
    local path=
    path="$(which "$command" 2>/dev/null)" || return 1
    echo "$path"
}

# Find installed programs version
#
# @param {string} program
# @returns {string|exit code} version
get_version() {
    local program=$1
    local version=
    version="$($program --version | head -n 1 | grep -Eo '[0-9]+\.[0-9]+\.([0-9]+)?')" || return 1
    echo "$version"
}

# Compare two versions
#
# @param {string} semantic version - major.minor.patch
# @param {string} version template string
# @returns {number} 0 = true, 1 = false
#
# Where the version template string
# is a semantic version string with the asterisk (*) character
# interpreted as any.
#
# @example
# 1.*.3 > 1.2.2 -> true
# 1.*.3 > 1.5.3 -> false
# 1.*.* > 1.1.1 -> true
# 1.*.* > 2.1.1 -> false
compare_versions() {
    read -a version_installed < <(echo "$1" | cut -d'.' -f1-3 | tr '.' ' ')
    local logical_operator="$2"
    read -a version_required < <(echo "$3" | cut -d'.' -f1-3 | tr '.' ' ')

    # major = 0, minor = 1, patch = 2
    for i in 0 1 2; do
        [[ "${version_required[i]:-*}" == '*' ]] && continue
        (( "${version_installed[i]}" $logical_operator "${version_required[i]}" )) || return 1
    done
}

