#Justin Phillips
#the jack flags are found using pkg-config

#linux
ifeq "$(PLATFORM)" "Linux"
compiled/native/i386-linux/3m/SchemeMidi_ss.so: SchemeMidi.c
	mzc --xform SchemeMidi.c
	mzc --3m --cc SchemeMidi.3m.c
	mkdir -p compiled/native/i386-linux/3m/
	mzc --3m --ld compiled/native/i386-linux/3m/SchemeMidi_ss.so \
++ccf -I/usr/local/include \
++ldf -L/usr/local/lib \
++ldl -ljack \
++ldl -lm \
SchemeMidi_3m.o

#Mac OS X
ifeq "$(PLATFORM)" "Darwin"
compiled/native/i386-macosx/3m/SchemeMidi_ss.dylib: SchemeMidi.c SchemeMidi.h
	mzc --xform SchemeMidi.c
	mzc --3m --cc SchemeMidi.3m.c
	mkdir -p compiled/native/i386-macosx/3m
	mzc --3m --ld compiled/native/i386-macosx/3m/SchemeMidi_ss.dylib \
++ldl /System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMidi \
SchemeMidi_3m.o
endif

clean:
	rm -rf compiled
