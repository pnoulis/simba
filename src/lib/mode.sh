simba_mode_in_dev() {
    return $(test __MODE__ == dev || test __MODE__ == development)
}

simba_mode_in_test() {
    return $(test __MODE__ == test)
}

simba_mode_in_stag() {
    return $(test __MODE__ == stag || test __MODE__ == staging)
}

simba_mode_in_prod() {
    return $(test __MODE__ == prod || test __MODE__ == production)
}

simba_mode_in_debug() {
    return $(test -n "${DEBUG+x}" && (test "$DEBUG" == true || test "$DEBUG" == "0"))
}
