init() {
    cmd-export-ns jump "Jump namespace"
    cmd-export jump-run
}

jump-run() {
    declare desc="Downloads and runs a Gunfile module from http://j.mp/ALIAS"
    declare url=$1

    : ${url:? required}

    local tmpfile=$(mktemp /tmp/XXXXX 2>/dev/null || mktemp)
    curl -sLko $tmpfile "http://j.mp/$url"

    module-load $tmpfile
    jump-start
}

