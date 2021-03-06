#!/bin/bash

set -e

# Allow the container to be started with `--user`
if [[ "$1" = 'zkServer.sh' && "$(id -u)" = '0' ]]; then
    chown -R "$ZOO_USER" "$ZOO_DATA_DIR" "$ZOO_DATA_LOG_DIR"
    exec su-exec "$ZOO_USER" "$0" "$@"
fi

# Generate the config only if it doesn't exist
if [[ ! -f "$ZOO_CONF_DIR/zoo.cfg" ]]; then
    CONFIG="$ZOO_CONF_DIR/zoo.cfg"

    echo "dataDir=$ZOO_DATA_DIR" >> "$CONFIG"
    echo "dataLogDir=$ZOO_DATA_LOG_DIR" >> "$CONFIG"

    echo "tickTime=$ZOO_TICK_TIME" >> "$CONFIG"
    echo "initLimit=$ZOO_INIT_LIMIT" >> "$CONFIG"
    echo "syncLimit=$ZOO_SYNC_LIMIT" >> "$CONFIG"

    echo "maxClientCnxns=$ZOO_MAX_CLIENT_CNXNS" >> "$CONFIG"
    echo "standaloneEnabled=$ZOO_STANDALONE_ENABLED" >> "$CONFIG"
    echo "reconfigEnabled=$ZOO_RECONFIG_ENABLED" >> "$CONFIG"
    
    echo "skipACL=$ZOO_SKIP_ACL" >> "$CONFIG"

    if [[ ! -z $ZOO_4LW_COMMANDS_WHITELIST ]]; then
      echo "4lw.commands.whitelist=$ZOO_4LW_COMMANDS_WHITELIST" >> "$CONFIG"
    fi

    if [[ -z $ZOO_SERVERS ]]; then
      ZOO_SERVERS="server.1=localhost:2888:3888;$ZOO_PORT"
    fi

    for server in $ZOO_SERVERS; do
        echo "$server" >> "$CONFIG"
    done
fi

# Write myid only if it doesn't exist
if [[ ! -f "$ZOO_DATA_DIR/myid" ]]; then
    echo "${ZOO_MY_ID:-1}" > "$ZOO_DATA_DIR/myid"
fi

exec "$@"
