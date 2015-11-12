**Gotchas**

.git dir shouldn't be in php-X.X.X/

Same goes for .\*.swp files by vim

upload to launchpad might fail:

-   if the *exception* is from closing the ftp connection, ignore
-   otherwise, just keep repeating

**Deps (Ubuntu)**

[https://help.ubuntu.com/community/GnuPrivacyGuardHowto](https://help.ubuntu.com/community/GnuPrivacyGuardHowto)

-   aptitude install gnupg randomsound
-   gpg --gen-key (defaults, same email as in the changelog and
    launchpad)

**Howtos/Manuals**

-   [http://wiki.ubuntu.com/PackagingGuide/Complete](http://wiki.ubuntu.com/PackagingGuide/Complete)
-   [http://blog.theroux.ca/devel/creating-ubuntu-packages-for-launchpad/](http://blog.theroux.ca/devel/creating-ubuntu-packages-for-launchpad/)
-   [http://wiki.ubuntuusers.de/pbuilder](http://wiki.ubuntuusers.de/pbuilder)


**Quick & dirty notes**

**First run:**

-   apt-get install build-essential devscripts ubuntu-dev-tools
    debhelper dh-make diff patch cdbs quilt gnupg fakeroot lintian
    pbuilder piuparts vim ccache

.pbuilderrc anlegen (see below, vagrantfile does this automatically

mkdir:

-   ~/pbuilder/build
-   ~/pbuilder/lucid-i386
-   ~/pbuilder/lucid-amd64
-   ~/pbuilder/precise-i386
-   ~/pbuilder/precise-amd64
-   ~/.ccache\_ubuntu

sudo pbuilder create for all needed DIST and ARCH:

-   sudo ARCH=i386 pbuilder create

To update the base image, which is i.e. needed if the ppa package list
has been changed:

-   pbuilder-dist \$DIST \$ARCH update

**Every time:**

-   download php-source, rename to php5-easybib_$version.orig.tar.gz
-   cd php5-easybib
-   adjust debian/changelog
    - copy changelog.$DISTNAME to changelog
    - add new entry with new version number
-   sudo DIST=precise ARCH=amd64 pdebuild #local testing
-   debuild -S -sa 
-   dput -fd ppa:easybib/test
    ../php5-easybib_$longversion_source.changes
-   move changelog back to changelog.$DISTNAME 

Done :)

**add new php-source based module:**

-   add module name to debian/modulelist
-   add package description to debian/control
-   add configure params to debian/rules (modify PHP\_EXTS)

**pbuilderrc**

[https://wiki.ubuntu.com/PbuilderHowto](https://wiki.ubuntu.com/PbuilderHowto)

AUTO\_DEBSIGN=yes

UBUNTU\_SUITES=("precise" "oneiric" "natty" "maverick" "lucid" "karmic"
"jaunty" "hardy")

UBUNTU\_MIRROR="mirrors.kernel.org"

\# precise is no dist set

: ${DIST:="precise"}

\# Architektur amd64 setzen, falls keine angegeben ist

: ${ARCH:="amd64"}


NAME="$DIST"

\#include easybib-ppa in mirrors list to build with dependencies to
php5-easybib packages

\# XXX You might want to change this ppa

OTHERMIRROR="deb [trusted=yes]
http://ppa.launchpad.net/easybib/test/ubuntu \$DIST main"


if [ -n "${ARCH}" ]; then

    NAME="$NAME-$ARCH"

    DEBOOTSTRAPOPTS=("--arch" "$ARCH" "${DEBOOTSTRAPOPTS[@]}")

fi

BASETGZ="$HOME/pbuilder/$NAME-base.tgz"

DISTRIBUTION="$DIST"

BUILDRESULT="$HOME/pbuilder/$NAME/result/"

APTCACHE="$HOME/pbuilder/$NAME/aptcache/"

BUILDPLACE="$HOME/pbuilder/build/"


echo $BASETGZ


if $(echo ${UBUNTU\_SUITES[@]} | grep -q $DIST); then

    MIRRORSITE="http://$UBUNTU\_MIRROR/ubuntu/"

    COMPONENTS="main restricted universe multiverse"

else

    echo "Unknown distribution: $DIST"

    exit 1

fi

if [ -f /usr/bin/ccache ]; then

    export PATH="/usr/lib/ccache:$PATH"

    export CCACHE\_DIR="$HOME/.ccache\_ubuntu"

    EXTRAPACKAGES="ccache ${EXTRAPACKAGES}"

    BINDMOUNTS="${CCACHE\_DIR} ${BINDMOUNTS}"

    \#if [ -n "${BUILDUSERID}" ]; then

       \#chown "${BUILDUSERID}":"${BUILDUSERID}" "${CCACHE\_DIR}" ||
true

    \#fi

    \#export CCACHE\_PREFIX="distcc"

fi

##Hints

* Update pbuilder package config (run it after you modified ~/.pbuilderrc): sudo pbuilder update --override-config
* Enter build image (handle with care when using param save-after-login):  sudo pbuilder --login --save-after-login
* pdebuilder sometimes fails building the packages locally because of an unknown key for the easybib-ppa (usually complaining about an unavailable gpg key for php5-easybib). To fix this: 
  * sudo pbuilder --login --save-after-login
  * apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 540810F766E3A9B7

