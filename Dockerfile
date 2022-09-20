# Set image
ARG ALPINE_VERSION=3.15
FROM alpine:$ALPINE_VERSION

# APP Env Variables
ENV CONFIG_DIR=/etc/scriptor-conf
ENV SQL_SCRIPTS_DIR=${CONFIG_DIR}/sql
ENV MYSQL_CLIENT_CONFIG=/etc/mysql/my.cnf
ENV CUSTOM_CLIENT_CONFIG=${CONFIG_DIR}/my.cnf
ENV APP_SCRIPTS_DIR=${CONFIG_DIR}/scripts
ENV BACKUP_DIR=${CONFIG_DIR}/backups
ENV USER=mysql-user

# Update and Install myslq-client
# and create user
RUN apk add --no-cache mysql-client \
    && adduser -D -H -s /bin/sh ${USER}

WORKDIR ${APP_SCRIPTS_DIR}
COPY --chown=${USER} ./src/entrypoint.sh ./src/config.sh ${APP_SCRIPTS_DIR}

# Make scripts executable and
# config file writable
RUN chmod +x *.sh \
    && touch ${MYSQL_CLIENT_CONFIG} \
    && chgrp ${USER} ${MYSQL_CLIENT_CONFIG} \
    && chmod g+rw ${MYSQL_CLIENT_CONFIG}

# Install minio client
RUN wget https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
    && mv mc /usr/local/bin

USER ${USER}
WORKDIR ${SQL_SCRIPTS_DIR}

ENTRYPOINT /bin/sh ${APP_SCRIPTS_DIR}/entrypoint.sh
