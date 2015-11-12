#!/bin/sh

# stop asking questions!
export DEBIAN_FRONTEND=noninteractive

# fix mirrors for us
US_COUNT=$(cat /etc/apt/sources.list|grep -a 'us.'|wc -l)
if [ $US_COUNT -gt 0 ]; then
    sed -i 's/us.archive.ubuntu.com/de.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get -f -qq -y update
else
    echo "Skipping - seems OK already!"
fi

# install packages

apt-get update -y
apt-get install -y software-properties-common
add-apt-repository ppa:imagineeasy/php7
apt-get install -y build-essential devscripts ubuntu-dev-tools debhelper dh-make patch cdbs quilt gnupg fakeroot lintian pbuilder piuparts ccache 
apt-get install -y git-core gnupg vim

####begin pbuilderrc
cat << 'EOF' >/home/vagrant/.pbuilderrc
AUTO_DEBSIGN=yes

UBUNTU_SUITES=("trusty")
UBUNTU_MIRROR="de.archive.ubuntu.com"

# trusty falls keine Angabe verwendet wird
: ${DIST:="trusty"}
# Architektur amd64 setzen, falls keine angegeben ist
: ${ARCH:="amd64"}

NAME="$DIST"
#include easybib-ppa in mirrors list to build with dependencies to php7-ies packages
OTHERMIRROR="deb [trusted=yes] http://ppa.launchpad.net/imagineeasy/php7/ubuntu $DIST main"

if [ -n "${ARCH}" ]; then
    NAME="$NAME-$ARCH"
    DEBOOTSTRAPOPTS=("--arch" "$ARCH" "${DEBOOTSTRAPOPTS[@]}")
fi

BASETGZ="$HOME/pbuilder/$NAME-base.tgz"
DISTRIBUTION="$DIST"
BUILDRESULT="$HOME/pbuilder/$NAME/result/"
APTCACHE="$HOME/pbuilder/$NAME/aptcache/"
BUILDPLACE="$HOME/pbuilder/build/"
HOOKDIR="$HOME/pbuilder/hooks/"

if $(echo ${UBUNTU_SUITES[@]} | grep -q $DIST); then
    MIRRORSITE="http://$UBUNTU_MIRROR/ubuntu/"
    COMPONENTS="main restricted universe multiverse"
else
    echo "Unknown distribution: $DIST"
    exit 1
fi
EOF
##############
##end pbuilderrc
##############

mkdir -p /home/vagrant/pbuilder/hooks

cat << 'EOF' >/home/vagrant/pbuilder/hooks/D05deps
#!/bin/sh
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 540810F766E3A9B7
apt-get update
EOF

chmod a+x /home/vagrant/pbuilder/hooks/D05deps

mkdir -p /home/vagrant/pbuilder/build
mkdir -p /home/vagrant/pbuilder/lucid-i386
mkdir -p /home/vagrant/pbuilder/lucid-amd64

chown -R vagrant /home/vagrant/pbuilder

su -c "mkdir ~/.gnupg && cp /packaging/vagrant/gnupg/* ~/.gnupg" vagrant 

echo " *********************************************** "
echo " * Do not forget to run 'sudo pbuilder create' for all ARCH and DIST you want to use with pdebuild"
echo " * e.g. 'sudo DIST=trusty ARCH=amd64 pbuilder create'"
