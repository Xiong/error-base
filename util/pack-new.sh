#!/bin/bash
#       pack.sh
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org>    =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =
#
# Purpose: 
#   * rm -r /hold/pack/*    ! NO FOLLOWING
#   * Copy top/*            to hold/pack/
#   * Copy lib/             to hold/pack/
#   * Copy t/go/*           to hold/pack/t/
#   * cd to hold/pack/
#   * /run/bin/perl Build.PL
#   * ./Build manifest
#   * ./Build dist
#   * Copy the tarball      to hold/tarball/
#   * Extract the tarball   to hold/unpack/
#   * cd to hold/unpack
#   * /run/bin/perl Build.PL
#   * ./Build 
#   * ./Build test
#   * ./Build fakeinstall
#

#----------------------------------------------------------------------------#

# Annouce thyself
echo "& Running..."

# Check to see that we're in a Git-controlled project folder.
if [ ! -d .git ]
then
    echo "& Not in a Git repo. You must cd to project root first."
    echo "& ...Aborting."
    exit 1
fi

projectfolder=`pwd`
echo "& Project folder is $projectfolder."

# Get my command line argument, if any
if [ "$1" = "-v" ]
then
    verbose="--verbose"
fi
#~ echo $verbose

# Erase previous contents of hold/pack/
contents=`ls hold/pack`
if [ -n "$contents" ]
then
    rm --recursive $verbose hold/pack/*
    if (( $? ))
    then
        echo "& Error clearing hold/pack/."
        echo "& ...Aborting."
        exit 1
    fi
else
    echo "& Nothing in hold/pack/ to rm."
fi

# Copy top/* to hold/pack/
cp --no-dereference --preserve=mode,ownership,timestamps \
$verbose \
top/* \
hold/pack/

if (( $? ))
then
    echo "& Error copying top/* to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy lib/ to hold/pack/
cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
$verbose \
lib/ \
hold/pack/

if (( $? ))
then
    echo "& Error copying lib/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy inc/ to hold/pack/               # 2011-10-25 02:12:17
if [ -d inc ]
then
    cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
    $verbose \
    inc/ \
    hold/pack/
else
    echo "& No inc/ found."
fi

if (( $? ))
then
    echo "& Error copying inc/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy xt/ to hold/pack/                # 2011-11-18 14:32:49
if [ -d xt ]
then
    cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
    $verbose \
    xt/ \
    hold/pack/
else
    echo "& No xt/ found."
fi

if (( $? ))
then
    echo "& Error copying xt/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy demo/ to hold/pack/              # 2011-11-18 14:32:49
if [ -d demo ]
then
    cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
    $verbose \
    demo/ \
    hold/pack/
else
    echo "& No demo/ found."
fi

if (( $? ))
then
    echo "& Error copying demo/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy setup/ to hold/pack/             # 2011-10-25 02:13:17
if [ -d setup ]
then
    cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
    $verbose \
    setup/ \
    hold/pack/
else
    echo "& No setup/ found."
fi

if (( $? ))
then
    echo "& Error copying setup/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy t/ to hold/pack/t/               # 2011-10-25 02:14:33
# New rule is to symlink t/ -> xt/go
cp --recursive --dereference --preserve=mode,ownership,timestamps \
$verbose \
t/ \
hold/pack/

if (( $? ))
then
    echo "& Error copying t/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# cd to hold/pack/
cd hold/pack/

if (( $? ))
then
    echo "& Error cd to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# /usr/bin/env perl Build.PL
/usr/bin/env perl Build.PL

if (( $? ))
then
    echo "& Error creating Build (creating distribution)."
    echo "& ...Aborting."
    exit 1
fi

#./Build manifest
# note that an initial MANIFEST is required (?)
./Build manifest

if (( $? ))
then
    echo "& Error updating MANIFEST."
    echo "& ...Aborting."
    exit 1
fi

#./Build dist           # Hmmm... Seems when this dies, it exits 0.
./Build dist

if (( $? ))
then
    echo "& Error Building distribution."
    echo "& ...Aborting."
    exit 1
fi

# Remember tarball
tarball=`ls *.tar.gz`

if [ -z "$tarball" ]
then
    echo "& No tarball found."
    echo "& ...Aborting."
    exit 1
fi

# cd to project base
cd $projectfolder

if (( $? ))
then
    echo "& Error cd to $projectfolder."
    echo "& ...Aborting."
    exit 1
fi

# Copy the tarball to hold/unpack/
# For immediate untarballing and testing.
cp --preserve=mode,ownership,timestamps \
$verbose \
hold/pack/*.tar.gz \
hold/unpack/

if (( $? ))
then
    echo "& Error copying tarball to hold/unpack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy the tarball to hold/tarball/
# This is the archival copy.
cp --preserve=mode,ownership,timestamps \
--backup=numbered \
$verbose \
hold/pack/*.tar.gz \
hold/tarball/

if (( $? ))
then
    echo "& Error copying tarball to hold/tarball/."
    echo "& ...Aborting."
    exit 1
fi

# Lock the archive.
chmod 0444 hold/tarball/$tarball

if (( $? ))
then
    echo "& Failed to lock archive hold/tarball/$tarball."
    echo "& ...Aborting."
    exit 1
else
    echo "& Locked archive hold/tarball/$tarball."
fi

#----------------------------------------------------------------------------#
# Now, pretend to be a user of the distribution.                             #
#----------------------------------------------------------------------------#

# cd to hold/unpack/
cd hold/unpack/
unpackfolder=`pwd`

if (( $? ))
then
    echo "& Error cd to hold/unpack/."
    echo "& ...Aborting."
    exit 1
fi

# Figure out build folder
buildfolder=${tarball%.tar.gz}

# rm any old build folder
contents=`ls $buildfolder`
if [ -n "$contents" ]
then
    echo "& Removing old $unpackfolder/$buildfolder:"
    echo "$contents"
    #~ rm --recursive --force --interactive=once $verbose $buildfolder
    rm --recursive -I $verbose $buildfolder
    if (( $? ))
    then
        echo "& Error clearing old $buildfolder."
        echo "& ...Aborting."
        exit 1
    fi
else
    echo "& No old $buildfolder to rm."
fi

# Untarball
tar --extract --file=$tarball

if (( $? ))
then
    echo "& Error untarballing hold/unpack/$tarball."
    echo "& ...Aborting."
    exit 1
fi

# cd to build folder
cd $buildfolder

if (( $? ))
then
    echo "& Error cd to $buildfolder."
    echo "& ...Aborting."
    exit 1
fi

#   ls -l --color=always

# /usr/bin/env perl Build.PL
/usr/bin/env perl Build.PL

if (( $? ))
then
    echo "& Error creating Build (installing as user)."
    echo "& ...Aborting."
    exit 1
fi

# ./Build
# Called with no args, will run the build action, 
# which will run Build code, Build manpages, Build html
./Build

if (( $? ))
then
    echo "& Error Building distribution (as user)."
    echo "& ...Aborting."
    exit 1
fi

./Build test

if (( $? ))
then
    echo "& Error testing distribution (as user)."
    echo "& ...Aborting."
    exit 1
fi

echo "Fakeinstalling..."
./Build fakeinstall

if (( $? ))
then
    echo "& Error fakeinstalling distribution (as user)."
    echo "& ...Aborting."
    exit 1
fi








# Say goodbye
echo "& ...Done."
