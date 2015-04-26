#!/bin/bash

set -e

declare -i -r debug=0
#declare -i -r debug=1
declare -r wrap_cmd=()
#declare -r wrap_cmd=(':')

declare -r -a install_packages=(
    # See function add_webupd8team_java_repository for details.
    'oracle-java7-installer'
    'smb4k'
    'flashplugin-installer'
)

wrap()
{
    (( debug )) && echo "$@"
    "${wrap_cmd[@]}" "$@"
}

sudo_wrap()
{
    wrap sudo "$@"
}

# See http://www.webupd8.org/2012/06/how-to-install-oracle-java-7-in-debian.html
# for details.
add_webupd8team_java_repository()
{
    local -r repo_url='http://ppa.launchpad.net/webupd8team/java/ubuntu'
    local -r sources_list='/etc/apt/sources.list.d/webupd8team-java.list'
    local -r key_server='hkp://keyserver.ubuntu.com:80'
    local -r repo_key='7B2C3B0889BF5709A105D03AC2518248EEA14886'

    # See https://wiki.ubuntu.com/DevelopmentCodeNames for list of code names.
    local -r ubuntu_code_name='vivid'

    if [[ ! -e "$sources_list" ]]; then
        printf "Creating \`%s' file with following content:\n\n" "$sources_list"
        printf "deb %s %s main\ndeb-src %s %s main\n" \
            "$repo_url" "$ubuntu_code_name" \
            "$repo_url" "$ubuntu_code_name" \
        | sudo_wrap tee "$sources_list" | sed 's/^/    /g'
        sudo_wrap apt-key adv --keyserver "$key_server" --recv-keys "$repo_key"
        sudo_wrap apt-get update
    fi
}

main()
{
    add_webupd8team_java_repository

    printf "\nInstalling packages...\n\n"
    wrap sleep 1

    sudo_wrap apt-get install "${install_packages[@]}"
}

main "${0##*/}" "$@"
