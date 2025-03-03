#!/usr/bin/env nu

def get_active_connections [] {
    # returns UUID of active ethernet and wifi connections

    let connections = (
        nmcli -t -f UUID,TYPE connection show --active
        | from csv --separator ":" --noheaders
        | where column1 in [
            '802-3-ethernet',
            '802-11-wireless'
            ]
        | get column0
    )

    return $connections
}

def check_metered [connection: string] {
    let is_metered = (
        nmcli -t connection show $connection
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
        if (check_metered $con) {
            print $"Metered network is connected - ($con)"
            exit 1
        }
    }

    exit 0
}
