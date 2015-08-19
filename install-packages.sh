#!/bin/bash

set -e

declare -i -r debug=0
#declare -i -r debug=1
declare -r wrap_cmd=()
#declare -r wrap_cmd=(':')

declare -r -a purge_packages=(
    'iceweasel'
    'icedove'
)

declare -r -a install_packages=(
    # Managing /etc in Git.
    'git' 'git-doc'
    'etckeeper'

    # See function add_webupd8team_java_repository for details.
    'oracle-java7-installer'

    # Requested tools
    'smb4k'
    'flashplugin-nonfree'
    'mplayer2'
    'wine'
    'yakuake'
    'seamonkey-mozilla-build'
    'thunderbird-mozilla-build'
    'firefox-mozilla-build'
    'bluedevil' # KDE Bluetooth integration.

    # Everpad dependencies
    #
    # Based on: https://github.com/nvbn/everpad/wiki/how-to-install
    'python-pyside.qtcore' 'python-pyside.qtgui' 'python-dbus'
    'python-beautifulsoup' 'python-pysqlite2' 'python-keyring' 'python-support'
    'python-sqlalchemy' 'python-oauth2client' 'python-magic'
    'python-pyside.qtwebkit' 'python-html2text' 'gtk2-engines-pixbuf'
    'python-regex' 'python-setuptools' 'build-essential' 'cmake' 'qt4-qmake'
    'libqt4-dev' 'python-dev'

    # Some commonly used utilities
    'curl'
    'vlc'

    # Used to query SSD disk capabilities.
    'hdparm'
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
    local -r sources_list='/etc/apt/sources.list.d/webupd8team-java.list'

    # Check if repository is already installed, if yes, then short circuit.
    [[ -e "$sources_list" ]] && return

    local -r repo_url='http://ppa.launchpad.net/webupd8team/java/ubuntu'
    local -r key_server='hkp://keyserver.ubuntu.com:80'
    local -r repo_key='7B2C3B0889BF5709A105D03AC2518248EEA14886'

    # See https://wiki.ubuntu.com/DevelopmentCodeNames for list of code names.
    local -r ubuntu_code_name='vivid'

    printf "Creating \`%s' file with following content:\n\n" "$sources_list"
    printf "deb %s %s main\ndeb-src %s %s main\n" \
        "$repo_url" "$ubuntu_code_name" \
        "$repo_url" "$ubuntu_code_name" \
    | sudo_wrap tee "$sources_list" | sed 's/^/    /g'
    sudo_wrap apt-key adv --keyserver "$key_server" --recv-keys "$repo_key"
    sudo_wrap apt-get update
}

install_everpad()
{
    # Check if everpad is present, if yes, then short circuit.
    hash everpad && return

    printf "\nInstalling Everpad, this will take a while...\n\n"

    wrap git clone https://github.com/nvbn/everpad.git
    (
        wrap cd everpad
        sudo_wrap python setup.py install
    )

    printf "\nEverpad installed.\n"
}

add_ubuntuzilla_repository()
{
    local -r sources_list='/etc/apt/sources.list.d/ubuntuzilla.list'

    # Check if repository is already installed, if yes, then short circuit.
    [[ -e "$sources_list" ]] && return

    local -r repo_url='http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt'
    local -r key_server='hkp://keyserver.ubuntu.com:80'
    local -r repo_key='C1289A29'
    local -r suite='all'

    printf "Creating \`%s' file with following content:\n\n" "$sources_list"
    printf "deb %s %s main\n" "$repo_url" "$suite" \
    | sudo_wrap tee "$sources_list" | sed 's/^/    /g'
    sudo_wrap apt-key adv --keyserver "$key_server" --recv-keys "$repo_key"
    sudo_wrap apt-get update
}

main()
{
    add_webupd8team_java_repository
    add_ubuntuzilla_repository

    printf "\nPurge packages...\n\n"
    wrap sleep 1
    sudo_wrap apt-get purge "${purge_packages[@]}"
    printf "\nPackages purged.\n"

    printf "\nInstalling packages...\n\n"
    wrap sleep 1
    sudo_wrap apt-get install "${install_packages[@]}"
    printf "\nPackages installed.\n"

    install_everpad
}

main "${0##*/}" "$@"
