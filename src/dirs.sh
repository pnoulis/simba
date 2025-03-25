if simba_mode_in_prod; then
    DATADIR=__DATADIR__
    SHAREDLIBDIR=__DATADIR__/__PROGRAM_NAME__
    TEMPLATESDIR=${SHAREDLIBDIR}/templates
    USRCONFDIR="${XDG_CONFIG_HOME:-${HOME}/.config}/simba"
else
    DATADIR=__DATADIR__
    SHAREDLIBDIR=__DATADIR__/lib
    TEMPLATESDIR=__DATADIR__/templates
    USRCONFDIR=__SRCDIR_ABS__
fi

