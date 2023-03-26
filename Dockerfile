FROM i386/ubuntu:bionic

# nwserver working directory
RUN mkdir /nws \
    && chmod 0777 /nws
WORKDIR /nws

# installation tools
RUN apt-get -qq update \
    && apt-get -qq install wget unzip p7zip

# nwserver 1.69 installation
RUN wget --quiet https://neverwintervault.org/sites/all/modules/pubdlcnt/pubdlcnt.php?fid=2674 -O nwndedicatedserver1.69.zip \
    && unzip -q nwndedicatedserver1.69.zip \
    && tar xzf linuxdedserver169.tar.gz \
    && bash fixinstall

# remove unnecessary files
RUN rm -rf \
    *.zip \
    *.tar.gz \
    fixinstall \
    *.exe \
    *.dll \
    *.txt \
    *.ini \
    database/* \
    dmvault \
    docs \
    erf \
    localvault \
    logs \
    modules/* \
    nwm \
    portraits \
    utils

# create missing directory
RUN mkdir tlk

# patch 1.71 installation
RUN mkdir p171 \
    && wget --quiet https://neverwintervault.org/sites/all/modules/pubdlcnt/pubdlcnt.php\?fid\=1982 -O p171/nwnpatch171.exe \
    && 7zr e -bsp0 -bso0 -op171 p171/nwnpatch171.exe \
    && mv p171/patch171.bif data \
    && mv p171/xp2patch.key . \
    && rm -rf p171/

# dockerize installation
ENV DOCKERIZE_VERSION v0.6.1
RUN wget --quiet https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-linux-386-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzf dockerize-linux-386-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-linux-386-$DOCKERIZE_VERSION.tar.gz

# configuration template
COPY nwnplayer.ini.tmpl .

# demona installation
RUN wget --quiet https://demona.cz/download/inst-demona-06.02.x.7z \
    && 7zr x -bsp0 -bso0 inst-demona-06.02.x.7z \
    && rm inst-demona-06.02.x.7z

ENV NWS_MODULE demona
ENV NWS_ROTATE_LOGS true
ENV NWS_LOGS_DIR logs
ENV NWS_ROTATE_MODULES true

ENV GAME_OPTIONS_DIFFICULTY_LEVEL 3

ENV SERVER_OPTIONS_2DA_CACHE_SIZE 64
ENV SERVER_OPTIONS_ALLOW_LOCAL_CHARS 0
ENV SERVER_OPTIONS_DISABLE_AUTOSAVE 1
ENV SERVER_OPTIONS_DISALLOW_SHOUTING 1
ENV SERVER_OPTIONS_EXAMINE_EFFECTS_ON_CREATURES 0
ENV SERVER_OPTIONS_GAMESPY_ENABLED 0
ENV SERVER_OPTIONS_MAX_CHAR_LEVEL 30
ENV SERVER_OPTIONS_MAX_HIT_POINTS 1
ENV SERVER_OPTIONS_MAX_PLAYERS 64
ENV SERVER_OPTIONS_ONE_PARTY_ONLY 0
ENV SERVER_OPTIONS_PVP_SETTINGS 2
ENV SERVER_OPTIONS_RELOAD_MODULE_WHEN_EMPTY=1
ENV SERVER_OPTIONS_RESTORE_SPELL_USES_ON_LOGIN 1
ENV SERVER_OPTIONS_SERVER_NAME "Demona (https://demona.cz/)"
ENV SERVER_OPTIONS_SHOW_DM_JOINED_MESSAGE 0
ENV SERVER_OPTIONS_SUPPRESS_BASE_SERVERVAULT 1

COPY entrypoint.sh .

ENTRYPOINT [ "./entrypoint.sh" ]
