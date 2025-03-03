#!/usr/bin/env nu

def get_active_connections [] {
    # returns UUID of active ethernet and wifi connections

    let connections = (
        nmcli -t -f NAME,UUID,TYPE connection show --active
        | from csv --separator ":" --noheaders --no-infer
        | rename NAME UUID TYPE
        | where TYPE in [
            '802-3-ethernet',
            '802-11-wireless'
            'bluetooth'
            ]
    )

    return $connections
}

def check_metered [uuid: string] {
    let is_metered = (
        nmcli -t connection show $uuid
        | parse 'connection.metered:{value}'
        | where value == "yes"
        | is-not-empty
    )

    return $is_metered
}

def main [] {
    let connections = (get_active_connections)

    if ($connections | is-empty) {
        print "No active ethernet or wifi connections"
        exit 1
    }

    for con in $connections {
        if ( ( $con | get TYPE ) == "bluetooth" ) {
            print $"Bluetooth tethering network is connected - ( $con | get NAME )"
            exit 1
        }

        if (check_metered ( $con | get UUID )) {
            print $"Metered network is connected - ( $con | get NAME)"
            exit 1
        }
    }

    exit 0
}
