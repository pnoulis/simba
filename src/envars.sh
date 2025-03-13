# use utils.sh

if simba_undefined SIMBA_CONFIG_TIME_ENV; then
    declare -gx SIMBA_CONFIG_TIME_ENV=""
    declare -gx SIMBA_BUILD_TIME_ENV=""
    declare -gx SIMBA_BUILD_TIME_M4_DEFINES=""
fi

# simba_define_envar_respectfully() {
#     local name="$1"
#     local value="${!name:-$2}"
#     simba_define_envar "$name" "$value"
# }

# simba_define_envar() {
#     local name="$1"
#     local value="${2:-${!name}}"
#     local name_uppercase="$(echo "$name" | tr [a-z] [A-Z])"

#     declare -gx "${name}=${value}"
#     simba_print "Defined environment variable...|$name=${value}"

#     case "$name" in
#         SIMBA_*)
#             SIMBA_CONFIG_TIME_ENV="${SIMBA_CONFIG_TIME_ENV:+$SIMBA_CONFIG_TIME_ENV
# }@${name}@=${value}"
#             ;;
#         *)
#             SIMBA_CONFIG_TIME_ENV="${SIMBA_CONFIG_TIME_ENV:+$SIMBA_CONFIG_TIME_ENV
# }@${name}@=${value}"
#             SIMBA_BUILD_TIME_ENV_M4_DEFINES="${SIMBA_BUILD_TIME_ENV_M4_DEFINES:+$SIMBA_BUILD_TIME_ENV_M4_DEFINES }-D@${name_uppercase}@='\$($name)'"
#             SIMBA_BUILD_TIME_ENV="${SIMBA_BUILD_TIME_ENV:+$SIMBA_BUILD_TIME_ENV\n}${name_uppercase}='\$($name)'"
#             ;;
#     esac
# }

simba_define_btime_envar_respectfully() {
    local name="$1"
    local value="${!name:-$2}"
    simba_define_btime_envar "$name" "$value"
}
simba_define_btime_envar() {
    local name="$1"
    local value="${2:-${!name}}"
    local name_uppercase="$(echo "$name" | tr [a-z] [A-Z])"

    SIMBA_CONFIG_TIME_ENV="${SIMBA_CONFIG_TIME_ENV:+$SIMBA_CONFIG_TIME_ENV
}__${name}__=${value}"
    SIMBA_BUILD_TIME_ENV_M4_DEFINES="${SIMBA_BUILD_TIME_ENV_M4_DEFINES:+$SIMBA_BUILD_TIME_ENV_M4_DEFINES }-D__${name_uppercase}__='\$($name)'"
    SIMBA_BUILD_TIME_ENV="${SIMBA_BUILD_TIME_ENV:+$SIMBA_BUILD_TIME_ENV\n}${name_uppercase}='\$($name)'"

    declare -gx "${name}=${value}"
    simba_print "Defined build time environment variable...|${name}=${value}"
}

simba_define_ctime_envar_respectfully() {
    local name="$1"
    local value="${!name:-$2}"
    simba_define_ctime_envar "$name" "$value"
}
simba_define_ctime_envar() {
    local name="$1"
    local value="${2:-${!name}}"
    local name_uppercase="$(echo "$name" | tr [a-z] [A-Z])"

    SIMBA_CONFIG_TIME_ENV="${SIMBA_CONFIG_TIME_ENV:+$SIMBA_CONFIG_TIME_ENV
}__${name}__=${value}"

    declare -gx "${name}=${value}"
    simba_print "Defined configuration time environment variable...|${name}=${value}"
}
