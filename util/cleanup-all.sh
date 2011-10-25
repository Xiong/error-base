#!/bin/sh
#       cleanup-all.sh
#       = Copyright 2011 Xiong Changnian <xiong@cpan.org>    =
#       = Free Software = Artistic License 2.0 = NO WARRANTY =
#
# Purpose: 
#   rm every file created by untarring and Build install
#
#   * * * ONLY FOR TESTING BY AUTHOR OF ACME-TINYBEAR * * *

#----------------------------------------------------------------------------#

# Annouce thyself
echo "& Running..."

# Remove files installed by Build install
rm -fv /rig/lib/b/Acme/TinyBear.pm
rm -fv /rig/man/man3/Acme::TinyBear.3
rm -fv /rig/html/site/lib/Acme/TinyBear.html
rm -fv /rig/lib/a/auto/Acme/TinyBear/.packlist

# Say goodbye
echo "& ...Done."
exit 0

#----------------------------------------------------------------------------#


# Save current path.
untarballfolder=`pwd`

# Check to see that we (were) in hold/unpack.
cd ..
if [ ! -d unpack ]
then
    echo "& Not in hold/unpack. You must cd to hold/unpack."
    echo "& ...Aborting."
    exit 1
fi
echo "& Untarball folder is $untarballfolder."

cd unpack
if (( $? ))
then
    echo "& Error cd to hold/unpack/."
    echo "& ...Aborting."
    exit 1
fi






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

# Copy inc/ to hold/pack/           # 2011-10-17 14:31:48
cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
$verbose \
inc/ \
hold/pack/

if (( $? ))
then
    echo "& Error copying inc/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy setup/ to hold/pack/           # 2011-10-17 14:31:48
cp --recursive --no-dereference --preserve=mode,ownership,timestamps \
$verbose \
setup/ \
hold/pack/

if (( $? ))
then
    echo "& Error copying setup/ to hold/pack/."
    echo "& ...Aborting."
    exit 1
fi

# Copy t/go/* to hold/pack/t/
mkdir hold/pack/t/
if (( $? ))
then
    echo "& Error mkdir hold/pack/t/."
    echo "& ...Aborting."
    exit 1
fi

cp --dereference --preserve=mode,ownership,timestamps \
$verbose \
t/go/* \
hold/pack/t/

if (( $? ))
then
    echo "& Error copying t/go/* to hold/pack/t/."
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

# /run/bin/perl Build.PL
/run/bin/perl Build.PL

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

# /run/bin/perl Build.PL
/run/bin/perl Build.PL

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
