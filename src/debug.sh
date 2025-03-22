simba_in_debug_mode() {
    return $(test -n "${DEBUG+x}" && (test "$DEBUG" == true || test "$DEBUG" == "0"))
}

simba_debugv() {
    ! simba_in_debug_mode && return
    echo $1:"${!1}"
}

simba_debug() {
    ! simba_in_debug_mode && return
    echo -e "$@"
}

simba_debug_unless_pipe() {
    ! test -t 1 && return
    simba_debug "$@"
}

simba_debugv_unless_pipe() {
    ! test -t 1 && return
    simba_debugv "$@"
}

simba_print() {
    echo -e "$@"
}

simba_print_unless_pipe() {
    ! test -t 1 && return
    simba_print "$@"
}
