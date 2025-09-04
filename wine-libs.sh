#!/usr/bin/env bash

action="$1"
arch="$2"
librarys=("xact" "d3d" "xinput")
target=()
PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "$action" in
    list)
	echo "${librarys[@]}"
	exit 1
	;;
    install)
    ;;
    uninstall)
    ;;
    *)
	echo "Unrecognized action: $action"
	echo "Usage: $0 [install|uninstall] [64/32] lib1 lib2 ..."
	echo "Usage: $0 list"
	exit 1
esac
shift

case "$arch" in
    32)
    ;;
    64)
    ;;
    *)
	echo "Unrecognized Arch: $arch"
	echo "Usage: $0 [install|uninstall] [64/32] lib1 lib2 ..."
	exit 1
esac
shift




while (( $# > 0 )); do
    if [[ " ${librarys[*]} " =~ " $1 " ]]; then
	target+=($1)
    else
        echo "$1 is not exist"
	exit 1
    fi
    shift
done
echo "install ${target[@]}"


if [ -n "$WINEPREFIX" ] && ! [ -f "$WINEPREFIX/system.reg" ]; then
    echo "$WINEPREFIX:"' WINEPREFIX 不存在' >&2
    exit 1
fi


export WINEDEBUG=-all
export WINEDLLOVERRIDES="mscoree,mshtml="
wine="wine"
wine64="wine64"
wineboot="wineboot"

install_wine_libs() {
    echo "install from ${PATH} into ${WINEPREFIX}"
    for libs in "${target[@]}"; do
	/usr/bin/cp -vr ${PATH}/${arch}/${libs}/* ${WINEPREFIX}/drive_c/windows/system32
    done
    
}


uninstall_wine_libs() {
    echo "uninstall from ${PATH} into ${WINEPREFIX}"
    files=()
    
    for libs in "${target[@]}"; do
	for file in "${PATH}/${arch}/${libs}"/*; do
            files+=( "${file##*/}" )
	done
    done
    

    for libs_files in "${files[@]}"; do
    	/usr/bin/rm -vr ${WINEPREFIX}/drive_c/windows/system32/${libs_files}
    done
    
}


if [ "$action" == "install" ]; then
    install_wine_libs
else
    uninstall_wine_libs
fi
