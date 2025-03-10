undefined() {
    return $(test -z "${!1+x}")
}

defined() {
    return $(test -n "${!1+x}")
}

empty() {
    return $(test -z "${1}")
}

nempty() {
    return $(test -n "${1}")
}

true() {
    return $(test "$1" == true || test "$1" == "0")
}

false() {
    return $(test "$1" == false || test "$1" == "1")
}

print() {
    echo -e "${0}: $@"
}

debug() {
    echo "$1":"$2"
}

debugv() {
    echo $1:"${!1}"
}

fatal() {
    echo "$0:" "$@"
    exit 1
}

parse_param() {
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
        fatal "${param:-$1} requires an argument"
    fi

    _param="${arg:-}"
    return $toshift
}
