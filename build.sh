#!/bin/bash

# export PREFIX="/usr/local/i386elfgcc"
# export TARGET=i386-elf

# confirm command from https://stackoverflow.com/questions/3231804/in-bash-how-to-add-are-you-sure-y-n-to-any-command-or-alias
confirm() {
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            ;;
    esac
}

clean() {
    echo "cleaning directory."
    rm *.tar.gz
    rm -R -- */
}

start_path=$PWD

if confirm "Are you sure you would like to continue? [Y/n]"; then
    clean
else
    echo "Exiting."
    exit 1
fi;

if [[ -z "${TARGET}" ]]; then
    echo "Error: TARGET environment variable not set."
    exit 1
else
    if [[ -z "${PREFIX}" ]]; then
        echo "Warning: PREFIX environment variable not set."
        export PREFIX=$(echo build/$TARGET | sed 's/-//')
        echo "setting PREFIX variable to '$PREFIX'"
    fi;
    if [[ ! $PREFIX = /* ]]; then
        echo "PREFIX path is not absolute. Prepending '$PWD'."
        export PREFIX="${PWD}/${PREFIX}"
    fi;
    echo "Prefix: $PREFIX"
    echo "Target: $TARGET"
fi;

binutils_folder=binutils-$VERSION_BINUTILS
binutils_tar=$binutils_folder.tar.gz
binutils_url=https://ftp.gnu.org/gnu/binutils/$binutils_tar
binutils_build=binutils-${VERSION_BINUTILS}_build

gcc_folder=gcc-$VERSION_GCC
gcc_tar=$gcc_folder.tar.gz
gcc_url=https://ftp.gnu.org/gnu/gcc/$gcc_folder/$gcc_tar
gcc_build=gcc-${VERSION_GCC}_build

# download binutils tar
echo $binutils_url
if curl --fail --progress-bar -O $binutils_url; then
    echo "binutils source version $VERSION_BINUTILS downloaded."
else
    echo "Error: failed to download binutils source (did you set VERSION_BINUTILS correctly?)"
    clean
fi;

# download gcc tar
echo $gcc_url
if curl --fail --progress-bar -O $gcc_url; then
    echo "gcc source version $VERSION_GCC downloaded."
else
    echo "Error: failed to download binutils source from (did you set VERSION_GCC correctly?)"
    clean
fi;

# build binutils
echo "building binutils."
tar xf $binutils_tar
mkdir $binutils_build && cd $binutils_build
../$binutils_folder/configure --target=$TARGET --enable-interwork --enable-multilib  --disable-nls --disable-werror --prefix=$PREFIX 2>&1 || exit 1
make all install 2>&1 || exit 1

cd $start_path

#build gcc
echo "building gcc."
tar xf $gcc_tar
mkdir $gcc_build && cd $gcc_build
../gcc-$VERSION_GCC/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers || exit 1
make all-gcc && make all-target-libgcc && make install-gcc && make install-target-libgcc || exit 1

echo "$TARGET binaries built to build/$PREFIX/bin"
