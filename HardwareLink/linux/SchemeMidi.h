/*
    Copyright (C) 2004 Ian Esten
	modified by justin phillips
    
    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
*/
/*if its linux*/
/*
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <math.h>

#include <jack/jack.h>
#include <jack/midiport.h>
*/

/*if its mac os x*/
#include <CoreMIDI/MIDIServices.h>

/*both*/
#include <unistd.h>
#include <stdio.h>
#include "escheme.h"


/*if its linux*/
/*
#define SchemeMidi jack_midi_event_t
*/
/*if its mac os x*/
typedef struct{
  uint32_t time;
  size_t size;
  unsigned char* buffer;
} SchemeMidi;

#define MAX_QUEUE_SIZE 100

typedef struct{
	int size;
	SchemeMidi** midiList;
} Queue;


/*linux functions*/
/*JACK functions*/
/*
static void signal_handler(int sig);
static void calc_note_frqs(jack_default_audio_sample_t srate);
static int process(jack_nframes_t nframes, void *arg);
static int srate(jack_nframes_t nframes, void *arg);
static void jack_shutdown(void *arg);
*/

/*Mac OS X functions*/
void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon,
                          void *srcConnRefCon);
int midiInit();

/*Both OS's functions*/
char* connect();
SchemeMidi* getMidi();

/*Scheme functions*/
Scheme_Object* scheme_initialize(Scheme_Env *env);
Scheme_Object* scheme_reload(Scheme_Env *env);
Scheme_Object* scheme_module_name();

//TODO add these two for the scheme sync to work
//int readyProc(Scheme_Object* data);
//void initNewType();

/*Queue functions*/
Queue* newQueue();
int isEmpty(Queue* q);
void enqueue(Queue* q, SchemeMidi* data);
SchemeMidi* dequeue(Queue* q);
