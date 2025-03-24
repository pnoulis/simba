#!/bin/bash
set -o errexit

m4_include(./lib/debug.sh)
m4_include(./lib/mode.sh)
m4_include(./lib/utils.sh)
m4_include(./lib/array.sh)
m4_include(./dirs.sh)

usage() {
    cat<<EOF
NAME
    ${0} - generate build system foundation

SYNOPSIS
    ${0} [...OPTIONS] destination

EOF
}

DEBUG=0
main() {
    # Default values for user options
    dependency_resolution_strategy=bundle
    copy_lib_destination=
    simba_debugv DATADIR
    simba_debugv SHAREDLIBDIR
    simba_debugv TEMPLATESDIR

    # Parse user options
    simba_cli_parse_options "$@"
    set -- "${POSARGS[@]}"
    destination="$(realpath -m "${1:-.}")"
    simba_debugv destination
    APP_ID="${destination##*/}"
    APP_NAME="$APP_ID"
    APP_PRETTY_NAME="$APP_ID"
    if ! test -d "$destination"; then
        mkdir -p "$destination"
    fi

    read_simba_conf
    apply_dependency_resolution_strategy
    create_configure
    create_configure_dev
    create_makefile_in
}

apply_dependency_resolution_strategy() {
    dependencies=""
    case $dependency_resolution_strategy in
        bundle)
            while IFS= read -r -d '' file; do
                dependencies+="include($file) "
            done < <(find "${SHAREDLIBDIR}" -type d -iname 'templates' -prune -o -type f -print0)
            define_btime_envar DEPENDENCY_RESOLUTION_BUNDLE "${dependencies[@]}"
            define_btime_envar DEPENDENCY_RESOLUTION_SOURCE ""
            ;;
        system-lib)
            while IFS= read -r -d '' file; do
                dependencies+="source '$file'
"
            done < <(find "${SHAREDLIBDIR}" -type d -iname 'templates' -prune -o -type f -print0)
            define_btime_envar DEPENDENCY_RESOLUTION_SOURCE "${dependencies[@]}"
            define_btime_envar DEPENDENCY_RESOLUTION_BUNDLE ""
            ;;
        local-lib)
            if ! test -d "${destination}/${copy_lib_destination}"; then
                mkdir -p "${destination}/${copy_lib_destination}"
            fi
            while IFS= read -r -d '' file; do
                basename="${file##*/}"
                cp "$file" "${destination}/${copy_lib_destination}"
                dependencies+="source '${copy_lib_destination}/${basename}'
"
            done < <(find "${SHAREDLIBDIR}" -type d -iname 'templates' -prune -o -type f -print0)
            define_btime_envar DEPENDENCY_RESOLUTION_SOURCE "${dependencies[@]}"
            define_btime_envar DEPENDENCY_RESOLUTION_BUNDLE ""
            ;;
    esac
}

read_simba_conf() {
    local simbaconf="${USRCONFDIR}/simba.conf"
    local simbaconf_template="${TEMPLATESDIR}/simba.conf"

    if ! test -f "$simbaconf"; then
        if ! test -d "$USRCONFDIR"; then
            USRCONFDIR="${XDG_CONFIG_HOME:-${HOME}/.config}/simba"
            simbaconf="${USRCONFDIR}/simba.conf"
        fi
        cp "$simbaconf_template" "$USRCONFDIR"
    fi
    source "$simbaconf"

    define_btime_envar APP_NAME "$APP_NAME"
    define_btime_envar APP_ID "$APP_ID"
    define_btime_envar APP_PRETTY_NAME "$APP_PRETTY_NAME"
    define_btime_envar APP_AUTHOR_NAME "$APP_AUTHOR_NAME"
    define_btime_envar APP_AUTHOR_ID "$APP_AUTHOR_ID"
    define_btime_envar APP_AUTHOR_EMAIL "$APP_AUTHOR_EMAIL"
    define_btime_envar APP_AUTHOR_HOME_URL "$APP_AUTHOR_HOME_URL"
    define_btime_envar APP_REPO_TYPE "$APP_REPO_TYPE"
    define_btime_envar APP_REPO_URL "$APP_REPO_URL"
    define_btime_envar APP_HOME_URL "$APP_HOME_URL"
    define_btime_envar APP_DOCUMENTATION_URL "$APP_DOCUMENTATION_URL"
    define_btime_envar APP_BUG_REPORT_URL "$APP_BUG_REPORT_URL"
    define_btime_envar APP_SUPPORT_URL "$APP_SUPPORT_URL"
}

create_configure() {
    local template_configure="${TEMPLATESDIR}/configure"
    simba_print "${0}: Creating configure"
    if ! test -f "$template_configure"; then
        simba_fatal "${0}: Missing template path: ${template_configure}"
    fi
    m4 "${btime_macros[@]}" "$template_configure" > "${destination}/configure"
    chmod 744 "${destination}/configure"
}

create_configure_dev() {
    local template_configure="${TEMPLATESDIR}/configure.dev"
    simba_print "${0}: Creating configure.dev"
    if ! test -f "$template_configure"; then
        simba_fatal "${0}: Missing template path: ${template_configure}"
    fi
    cp "$template_configure" "${destination}/configure.dev"
    chmod 744 "${destination}/configure.dev"
}

create_makefile_in() {
    local template_makefile_in="${TEMPLATESDIR}/Makefile.in"
    simba_print "${0}: Creating Makefile.in"
    if ! test -f "$template_makefile_in"; then
        simba_fatal "${0}: Missing template path: ${template_makefile_in}"
    fi
    cp "$template_makefile_in" "${destination}/Makefile.in"
}

define_btime_envar_respectfully() {
    local name="$1"
    local value="${!name:-$2}"
    define_btime_envar "$name" "$value"
}

define_btime_envar() {
    if simba_undefined btime_macros; then
        btime_macros=()
    fi
    local name="$1"
    local value="${2:-${!name}}"
    local name_uppercase="$(echo "$name" | tr [a-z] [A-Z])"
    btime_macros+=(-D__${name}__="$value")
}

simba_cli_parse_param() {
    _param=
    local param arg
    local -i toshift=0

    if (($# == 0)); then
        return $toshift
    elif [[ "$1" =~ .*=.* ]]; then
        param="${1%%=*}"
        arg="${1#*=}"
    elif [[ "${2-}" =~ ^[^-].+ ]]; then
        param="$1"
        arg="$2"
        ((toshift++))
    fi


    if [[ -z "${arg-}" && ! "${OPTIONAL-}" ]]; then
        simba_fatal "${param:-$1} requires an argument"
    fi

    _param="${arg:-}"
    return $toshift
}

simba_cli_parse_options() {
    declare -ga POSARGS=()
    _param=
    while (($# > 0)); do
        case "${1:-}" in
            --bundle)
                dependency_resolution_strategy=bundle
                ;;
            --system-lib)
                dependency_resolution_strategy=system-lib
                ;;
            --local-lib | --local-lib=*)
                OPTIONAL=true simba_cli_parse_param "$@" || shift $?
                dependency_resolution_strategy=local-lib
                copy_lib_destination="${_param:-.simba}"
                if [[ "$copy_lib_destination" =~ ^/*$ ]]; then
                    simba_fatal "Library copy destination must be a relative path"
                fi
                ;;
            -h | --help)
                usage
                exit 0
                ;;
            -v | --version)
                simba_print __APP_VERSION__
                exit 0
                ;;
            -[a-zA-Z][a-zA-Z]*)
                local i="${1:-}"
                shift
                local rest="$@"
                set --
                for i in $(echo "$i" | grep -o '[a-zA-Z]'); do
                    set -- "$@" "-$i"
                done
                set -- $@ $rest
                continue
                ;;
            --)
                shift
                POSARGS+=("$@")
                ;;
            -[a-zA-Z]* | --[a-zA-Z]*)
                simba_fatal "Unrecognized argument ${1:-}"
                ;;
            *)
                POSARGS+=("${1:-}")
                ;;
        esac
        shift
    done
    unset _param
}

main "$@"
