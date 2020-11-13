#!/bin/bash
set -e

startTimestamp=$(date +%Y%m%d%H%M%S)

# cleanup unnecessary files
rm -rf .nwnpid currentgame.* temp.*

# handle auto-rotating logs
if [ $NWS_ROTATE_LOGS = true -a -w $NWS_LOGS_DIR ]; then

    logsDir=$NWS_LOGS_DIR/logs-$startTimestamp
    mkdir $logsDir
    ln -sfn $logsDir logs.0
fi

# handle auto-rotating (versioning) modules
# mark new modules with start timestamp
moduleToStart=$NWS_MODULE
if [ $NWS_ROTATE_MODULES = true ]; then

    # mark all modules with timestamp prefix
    for f in $(find modules -maxdepth 1 -name "$NWS_MODULE-[0-9]*\.[0-9]*\.[0-9]*\.mod"); do
        mv $f modules/$startTimestamp-$(basename $f)
    done

    # resolve newest version
    moduleToStart=$(find modules -maxdepth 1 -name "[0-9]*-$NWS_MODULE-[0-9]*\.[0-9]*\.[0-9]*\.mod" | sort -r | head -1 | xargs -i basename {} .mod)
    if [ -e $moduleToStart ]; then
        echo 'no module to start'
        exit 1
    fi
fi

exec dockerize -template ./nwnplayer.ini.tmpl:./nwnplayer.ini ./nwserver -module $moduleToStart
