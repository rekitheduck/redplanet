#!/usr/bin/env bash

# Build the Red Planet toolchain :)

# Versions of software we need (update when needed)
BINUTILS_VERSION=2.42
GCC_VERSION=13.2.0

TARGET=i686-elf-redplanet

META_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
PREFIX="${META_DIR}/toolchain"

# A bunch of random stuff
BINUTILS=binutils-${BINUTILS_VERSION}
BINUTILS_PACKAGE=${BINUTILS}.tar.xz
GCC=gcc-${GCC_VERSION}
GCC_PACKAGE=${GCC}.tar.xz

RED="\033[0;31m"
GREEN="\033[0;32m"
NC="\033[0m"

echo -e "${RED}Welcome to the Red Planet toolchain build script. Hang on for a while we get the toolchain ready :)\n"

cat << "EOF"

                                            #################
                                       ##########################
                                    ################################%
                                 %###########################################################
                               #################################################################
                              ####################################################################
                            ################################################    ##################
                           ###################################################     ###############
                          #####################################################     #############
                         ######################################################%    ############
                        ########################################################   ############
                       ########################################################## ###########
                   %######################################################################%
                ########################################################################
              #######################################################################
           ########### ############################################################
         ###########   ########################################################
       ###########     #####################################################
     ############      #################################################       %##
    ############       #############################################         ####
   #############        #######################################          ########
  ################      ##################################            ##########
  ###################################################             #############%
   ###########################################               ##################
     #################################%                 ######################
           ################                      ###########################
                                       ####################################
                               ##########################################
                                 ######################################
                                    ################################%
                                       ##########################
                                            #################

EOF

# Make build and source directories if they don't exist
mkdir -p "${META_DIR}/toolchain-src"
mkdir -p "${META_DIR}/toolchain-build"
mkdir -p "${META_DIR}/toolchain-build/binutils"
mkdir -p "${META_DIR}/toolchain-build/gcc"

# Download sources (if they don't exist already)
pushd "${META_DIR}/toolchain-src"

if ! test -f $BINUTILS_PACKAGE; then
    echo -e "${RED}Acquiring ${BINUTILS}${NC} ..."
    wget https://ftpmirror.gnu.org/gnu/binutils/$BINUTILS_PACKAGE || exit 1
    echo -e "${GREEN}${BINUTILS_PACKAGE} acquired${NC}"
else
    echo -e "${GREEN}${BINUTILS_PACKAGE} found, skipping${NC}..."
fi

if ! test -f $GCC_PACKAGE; then
    echo -e "${RED}Acquiring ${GCC}${NC} ..."
    wget https://ftpmirror.gnu.org/gnu/gcc/${GCC}/${GCC_PACKAGE} || exit 1
    echo -e "${GREEN}${GCC_PACKAGE} acquired${NC}"
else
    echo -e "${GREEN}${GCC_PACKAGE} found, skipping${NC}..."
fi

popd

# Prepare binutils
pushd "${META_DIR}/toolchain-src"
if ! test -d $BINUTILS; then
    echo -e "Extracting ${GREEN}${BINUTILS_PACKAGE}${NC} ..."
    tar -xf $BINUTILS_PACKAGE || exit 1
    echo -e "Patching ${GREEN}${BINUTILS_PACKAGE}${NC} ..."
    pushd $BINUTILS
    patch -p1 < "${META_DIR}/toolchain-patches/binutils/RedPlanet-target.patch" || exit 1
    popd
else
    echo -e "Skipping extracting ${GREEN}${BINUTILS_PACKAGE}${NC} as it is already extracted"
fi
popd

pushd "${META_DIR}/toolchain-build/binutils"
echo -e "Configuring ${GREEN}${BINUTILS_PACKAGE}${NC} ..."
${META_DIR}/toolchain-src/$BINUTILS/configure --target=$TARGET --prefix=$PREFIX --with-sysroot --disable-nls --enable-shared || exit 1
echo -e "Building ${GREEN}${BINUTILS_PACKAGE}${NC} ..."
make MAKEINFO=true || exit 1
make install || exit 1

echo $PREFIX
