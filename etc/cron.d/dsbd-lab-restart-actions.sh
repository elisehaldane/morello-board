#!/bin/sh

# shellcheck disable=SC2046

get_timestamp() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') ###"
}

# Where necessary, clear the old set of runners and replace them
old_set=$(sysrc -n -q gh_actions_pots)
new_set=$(pot ls -p -q | grep -i "$RUNNER_PREFIX" | \
    grep -Ev "arm64-aarch64c|ephemeral|sibling")
if [ ! "$old_set" = "$new_set" ]; then
    echo "$(get_timestamp) Adding new runners to rc.conf: $new_set"
    sysrc -q -x gh_actions_pots
    echo "gh_actions_pots="\"$new_set\" >> /etc/rc.conf
fi

# Restart the host's GitHub Actions service
if [ "$(sysrc -n gh_actions_enable)" = "YES" ]; then
    echo "$(get_timestamp) Starting all available runners"
    service gh_actions start
fi
