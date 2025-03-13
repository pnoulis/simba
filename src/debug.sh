simba_debug() {
    echo "$1":"$2"
}

simba_debugv() {
    echo $1:"${!1}"
}

simba_print() {
    echo -e "$@"
}
