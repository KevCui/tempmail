#!/usr/bin/env bash
#
# A script to use temp-mail service in terminal
#
#/ Usage:
#/   ./gettempmail.sh [-i <inbox>|-c <inbox>|-d <uid>|-s]
#/
#/ Options:
#/   no option        Optional, randamly get an inbox
#/   -i <inbox>       Optional, get an inbox by its mail address
#/   -c <inbox>       Optional, delete inbox
#/   -d <uid>         Optional, delete mail by its uid
#/   -s               Optional, show available domains
#/   -h | --help      Display this help message
#/
#/ Examples:
#/   \e[32m- Generate a random inbox:\e[0m
#/     ~$ ./gettempmail.sh
#/
#/   \e[32m- Get mails in test@temp-link.net:\e[0m
#/     ~$ ./gettempmail.sh \e[33m-i test@temp-link.net\e[0m
#/
#/   \e[32m- Delete inbox test@temp-link.net: \e[0m
#/     ~$ ./gettempmail.sh \e[33m-c test@temp-link.net\e[0m
#/
#/   \e[32m- Delete mail uUa4V5Hjmkqf9O: \e[0m
#/     ~$ ./gettempmail.sh \e[33m-d uUa4V5Hjmkqf9O\e[0m
#/
#/   \e[32m- Show all available domains: \e[0m
#/     ~$ ./gettempmail.sh \e[33m-s\e[0m

set -e
set -u

usage() {
    # Display usage message
    printf "\n%b\n" "$(grep '^#/' "$0" | cut -c4-)" && exit 0
}

set_var() {
    # Declare variables
    _HOST="https://api4.temp-mail.org/request"
    _INBOX_URL="$_HOST/mail/id"
    _DELETE_INBOX_URL="$_HOST/delete_address/id"
    _DELETE_MESSAGE_URL="$_HOST/delete/id"
    _DOMAIN_URL="$_HOST/domains/format/json"
}

set_command() {
    # Declare commands
    _CURL="$(command -v curl)" || command_not_found "curl" "https://curl.haxx.se/download.html"
    _JQ="$(command -v jq)" || command_not_found "jq" "https://stedolan.github.io/jq/"
    _FAKER="$(command -v faker-cli)" || command_not_found "faker-cli" "https://github.com/lestoni/faker-cli"
}

set_args() {
    # Declare arguments
    expr "$*" : ".*--help" > /dev/null && usage
    while getopts ":hsi:c:d:" opt; do
        case $opt in
            i)
                _INBOX="$OPTARG"
                ;;
            c)
                _INBOX="$OPTARG"
                _FLAG_DELETE_INBOX=true
                ;;
            d)
                _MESSAGE_UID="$OPTARG"
                _FLAG_DELETE_MESSAGE=true
                ;;
            s)
                _FLAG_SHOW_DOMAIN=true
                ;;
            h)
                usage
                ;;
            \?)
                echo "Invalid option: -$OPTARG" >&2
                usage
                ;;
        esac
    done
}

command_not_found() {
    # Show command not found message
    # $1: command name
    # $2: installation URL
    printf "%b\n" '\033[31m'"$1"'\033[0m command not found!'
    [[ -n "${2:-}" ]] && printf "%b\n" 'Install from \033[31m'"$2"'\033[0m'
    exit 1
}

jq_format() {
    # Show result formated by jq
    # $1: response
    if $_JQ -e . >/dev/null 2>&1 <<<"$1"; then
        echo "$1" | $_JQ
    else
        echo "$1"
    fi
}

fake_username () {
    # Create a fake user
    echo "$($_FAKER -n firstName).$($_FAKER -n lastName)" | sed -E 's/"//g' | tr '[:upper:]' '[:lower:]'
}

get_inbox() {
    # Get inbox by mailbox address
    # $1: address
    local md5address
    md5address=$(echo -n "$1" | md5sum | awk '{print $1}')
    jq_format "$($_CURL -sSX GET "$_INBOX_URL/$md5address/format/json")"
}

delete_inbox() {
    # Delete inbox by address
    # $1: adderss
    local md5address
    md5address=$(echo -n "$1" | md5sum | awk '{print $1}')
    jq_format "$($_CURL -sSX GET "$_DELETE_INBOX_URL/$md5address/format/json")"
}

delete_message() {
    # Delete message by uid
    # $1: uid
    jq_format "$($_CURL -sSX GET "$_DELETE_MESSAGE_URL/$1/format/json")"
}

show_domain() {
    # Show available domains
    $_CURL -sSX GET "$_DOMAIN_URL" | $_JQ -r '.[]'
}

show_random_domain() {
    # Show available domains in a random order
    show_domain | shuf
}

get_random_inbox() {
    # Get a randam inbox
    local u d
    u=$(fake_username)
    d=$(show_random_domain | tail -1)

    get_inbox "$u$d"
    echo "$u$d"
}

main() {
    set_args "$@"
    set_command
    set_var

    if [[ -z "$*" ]]; then
        get_random_inbox
    else
        [[ -n "${_FLAG_SHOW_DOMAIN:-}" ]] && show_domain
        [[ -n "${_INBOX:-}" ]] && get_inbox "$_INBOX"
        [[ "${_FLAG_DELETE_INBOX:-}" == true ]] && delete_inbox "${_INBOX:-}"
        [[ "${_FLAG_DELETE_MESSAGE:-}" == true ]] && delete_message "${_MESSAGE_UID:-}"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
