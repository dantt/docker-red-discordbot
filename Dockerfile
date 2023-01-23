FROM python:3.11-slim as base

# Add PhasecoreX user-entrypoint script
ADD https://raw.githubusercontent.com/PhasecoreX/docker-user-image/master/user-entrypoint.sh /bin/user-entrypoint
RUN chmod +x /bin/user-entrypoint && /bin/user-entrypoint --init
ENTRYPOINT ["/bin/user-entrypoint"]

RUN set -eux; \
# Install Red-DiscordBot dependencies
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # Red-DiscordBot
        build-essential \
        git \
        # Required for building PyNaCl
        libsodium-dev \
        # Required for building CFFI
        libffi-dev \
        # start-redbot.sh
        jq \
        # ssh repo support
        openssh-client \
        # Audio
        openjdk-11-jre-headless \
        # NotSoBot
        libmagickwand-dev \
        libaa1-dev \
        # CrabRave
        ffmpeg \
        imagemagick \
        # RSS \
        gfortran \
        libopenblas-dev \
        liblapack-dev \
        # ReTrigger
        tesseract-ocr \
        # PyLav Local files
        libaio1  \
        libaio-dev \
    ; \
    rm -rf /var/lib/apt/lists/*; \
# Set up all three config locations
    mkdir -p /root/.config/Red-DiscordBot; \
    ln -s /data/config.json /root/.config/Red-DiscordBot/config.json; \
    mkdir -p /usr/local/share/Red-DiscordBot; \
    ln -s /data/config.json /usr/local/share/Red-DiscordBot/config.json; \
    mkdir -p /config/.config/Red-DiscordBot; \
    ln -s /data/config.json /config/.config/Red-DiscordBot/config.json; \
    # CrabRave needs this policy removed
    sed -i '/@\*/d' /etc/ImageMagick-6/policy.xml;

VOLUME /data

ENV SODIUM_INSTALL system

#######################################################################################

FROM base as pylav

ARG PCX_DISCORDBOT_BUILD
ARG PCX_DISCORDBOT_COMMIT

ENV PCX_DISCORDBOT_BUILD ${PCX_DISCORDBOT_BUILD}
ENV PCX_DISCORDBOT_COMMIT ${PCX_DISCORDBOT_COMMIT}
ENV PCX_DISCORDBOT_TAG pylav
ENV PYLAV__DATA_FOLDER /data/pylav
ENV PYLAV__YAML_CONFIG /data/pylav/pylav.yaml

COPY root/ /

CMD ["/app/start-redbot.sh"]

######################################################