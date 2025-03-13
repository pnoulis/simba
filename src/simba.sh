#!/bin/bash
set -o errexit

usage() {
    cat<<EOF
NAME
    ${0} - generate build system foundation

SYNOPSIS
    ${0} [...OPTIONS] destination

EOF
}


include(./utils.sh)
include(./debug.sh)

if test __MODE__ == development; then
    DATADIR=__SRCDIR_ABS__
    USRCONFDIR=__SRCDIR_ABS__
else
    DATADIR=__DATADIR__/__PROGRAM_NAME__
    USRCONFDIR="${XDG_CONFIG_HOME:-${HOME}/.config}/__PROGRAM_NAME__"
fi

main() {
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
    build_m4_flags
    create_configure
    create_makefile_in
}

read_simba_conf() {
    local simbaconf="${USRCONFDIR}/simba.conf"
    local template_simbaconf="${DATADIR}/simba.conf"

    if test -f "$simbaconf"; then
        source "$simbaconf"
    elif test __MODE__ == production; then
        mkdir -p "$USRCONFDIR" 2>/dev/null
        cp "$template_simbaconf" "$USRCONFDIR"
        source "$simbaconf"
    fi
}

build_m4_flags() {
    M4FLAGS="-P -D__DATADIR__=$DATADIR -D__APP_AUTHOR_NAME__=$APP_AUTHOR_NAME -D__APP_AUTHOR_HOME_URL__=$APP_AUTHOR_HOME_URL -D__APP_AUTHOR_EMAIL__=$APP_AUTHOR_EMAIL -D__APP_AUTHOR_ID__=$APP_AUTHOR_ID -D__APP_REPO_TYPE__=$APP_REPO_TYPE -D__APP_HOME_URL__=$APP_HOME_URL -D__APP_DOCUMENTATION_URL__=$APP_DOCUMENTATION_URL -D__APP_BUG_REPORT_URL__=$APP_BUG_REPORT_URL -D__APP_SUPPORT_URL__=$APP_SUPPORT_URL -D__APP_REPO_URL__=$APP_REPO_URL -D__APP_NAME__=$APP_NAME -D__APP_ID__=$APP_ID -D__APP_PRETTY_NAME__=$APP_PRETTY_NAME"
}

create_configure() {
    local template_configure="${DATADIR}/templates/configure"
    simba_print "${0}: Creating configure"
    if ! test -f "$template_configure"; then
        simba_fatal "${0}: Missing template path: ${template_configure}"
    fi
    m4 $M4FLAGS "$template_configure" > "${destination}/configure"
    chmod 744 "${destination}/configure"
}

create_makefile_in() {
    local template_makefile_in="${DATADIR}/templates/Makefile.in"
    simba_print "${0}: Creating Makefile.in"
    if ! test -f "$template_makefile_in"; then
        simba_fatal "${0}: Missing template path: ${template_makefile_in}"
    fi
    cp "$template_makefile_in" "${destination}/Makefile.in"
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
            -h | --help)
                usage
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
