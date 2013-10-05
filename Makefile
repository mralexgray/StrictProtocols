		 CC=clang
FRAMEWORKS:= -framework Foundation -framework Cocoa
 LIBRARIES:= -lobjc -all_load

     SOURCE=NSObject+StrictProtocols.m

     CFLAGS=-Wall -Werror -fobjc-arc -g -v $(SOURCE)
	LDFLAGS=$(LIBRARIES) $(FRAMEWORKS)
		OUT=
# -o main

all:
    $(CC) $(CFLAGS) $(LDFLAGS) $(OUT)