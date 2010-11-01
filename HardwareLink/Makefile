# Justin Phillips
# Makefile for Mac OS X midi scheme bit

compiled/native/i386-macosx/3m/SchemeMidi_ss.dylib: SchemeMidi.c SchemeMidi.h
	mzc --xform SchemeMidi.c
	mzc --3m --cc SchemeMidi.3m.c
	mkdir -p compiled/native/i386-macosx/3m
	mzc --3m --ccf-show --ld compiled/native/i386-macosx/3m/SchemeMidi_ss.dylib ++ldl "/System/Library/Frameworks/CoreMIDI.framework/Versions/Current/CoreMidi" SchemeMidi_3m.o

clean: 
	rm -rf compiled
