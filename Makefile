#!/bin/zsh -ef

set -x -v

PACKAGEDIR="$PWD"
PRODUCT="appswitch"

# gather information
cd $PACKAGEDIR/$PRODUCT
VERSION=`cat VERSION`
TARBALL="$PRODUCT-$VERSION.tar.gz"
DISTDIR="$PRODUCT-$VERSION"
EXCLUSIONS=("${(ps:\000:)$(git ls-files -zo --directory -x $PRODUCT/$PRODUCT)}")
EXCLUSIONS=($EXCLUSIONS) # remove empty items

# clean and build
find . -name \*~ -exec rm '{}' \;
rm -rf build/
xcodebuild -configuration Deployment DSTROOT=$PWD DEPLOYMENT_LOCATION=YES install
SetFile -c 'ttxt' -t 'TEXT' README VERSION $PRODUCT.1
chmod 755 $PRODUCT
chmod 644 $PRODUCT.1

# install locally
sudo -s <<EOF
umask 022
/bin/mkdir -p /usr/local/bin /usr/local/man/man1
/usr/bin/install $PRODUCT /usr/local/bin
/usr/bin/install -m 644 $PRODUCT.1 /usr/local/man/man1
EOF

# create tarball
cd ..
rm -f $DISTDIR $TARBALL
ln -s $PRODUCT $DISTDIR
tar -zcLf $TARBALL --exclude=${^EXCLUSIONS} $DISTDIR

# update Web presence
# scp $TARBALL ainaz:web/nriley/software/


CC = clang

MAIN = hello

SRCS = main.o Test.o

default: $(MAIN)

$(MAIN): $(SRCS)
 $(CC) -O0 -Wall -o $(MAIN) $(SRCS) -framework Foundation -framework Cocoa

clean:
 find . -name "*.o" -exec rm {} \;
 if [ -f "$(MAIN)" ]; then rm $(MAIN); fi

all: default


CC=clang

FRAMEWORKS:=	-framework Foundation\
				"

LIBRARIES:=		-lobjc\
				-all_load

SOURCE=NSObject+StrictProtocols.m

CFLAGS=-Wall -Werror -fobjc-arc -g -v $(SOURCE)
LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
OUT=
# -o main

O_FILES = $(SRC_FILES:%.cc=%.o)

all:
    $(CC) $(CFLAGS) $(LDFLAGS) $(OUT)