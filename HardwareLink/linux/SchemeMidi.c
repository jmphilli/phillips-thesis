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
#include "SchemeMidi.h"

/*linux only*/
/*
jack_port_t *input_port;
jack_port_t *output_port;
jack_default_audio_sample_t ramp=0.0;
jack_default_audio_sample_t note_on;
unsigned char note = 0;
jack_default_audio_sample_t note_frqs[128];

jack_client_t *client;
*/
/*both*/
Queue* q;

/*linux only*/
/*
static void signal_handler(int sig)
{
	jack_client_close(client);
	fprintf(stderr, "signal received, exiting ...\n");
	exit(0);
}

static void calc_note_frqs(jack_default_audio_sample_t srate)
{
	int i;
	for(i=0; i<128; i++)
	{
		note_frqs[i] = (2.0 * 440.0 / 32.0) * pow(2, (((jack_default_audio_sample_t)i - 9.0) / 12.0)) / srate;
	}
}

static int process(jack_nframes_t nframes, void *arg)
{
	int i;
	void* port_buf;
	jack_default_audio_sample_t *out;
	jack_nframes_t event_count;
	jack_nframes_t event_index;
	jack_midi_event_t in_event;

	port_buf = jack_port_get_buffer(input_port, nframes);
	out = (jack_default_audio_sample_t *) jack_port_get_buffer (output_port, nframes);
	event_index = 0;
	event_count = jack_midi_get_event_count(port_buf);
	if(event_count > 1)
	{
		printf(" midisine: have %d events\n", event_count);
		for(i=0; i<event_count; i++)
		{
			jack_midi_event_get(&in_event, port_buf, i);
			printf("    event %d time is %d. 1st byte is 0x%x\n", i, in_event.time, *(in_event.buffer));
		}
	}
	jack_midi_event_get(&in_event, port_buf, 0);
	for(i = 0; i < nframes; i++)
	{
		if ((in_event.time == i) && (event_index < event_count))
		{
			if (((*(in_event.buffer) & 0xf0)) == 0x90)
			{   
                		note = *(in_event.buffer + 1);
               			if (*(in_event.buffer + 2) == 0) {
                    			note_on = 0.0;
                		} else {
                    			note_on = (float)(*(in_event.buffer + 2)) / 127.f;
                		}
			}
			else if (((*(in_event.buffer)) & 0xf0) == 0x80)
			{
				note = *(in_event.buffer + 1);
				note_on = 0.0;
			}
			event_index++;
			if(event_index < event_count)
				jack_midi_event_get(&in_event, port_buf, event_index);
		}
		ramp += note_frqs[note];
		ramp = (ramp > 1.0) ? ramp - 2.0 : ramp;
		out[i] = note_on*sin(2*M_PI*ramp);
	}
	return 0;      
}

static int srate(jack_nframes_t nframes, void *arg)
{
	printf("the sample rate is now %" PRIu32 "/sec\n", nframes);
	calc_note_frqs((jack_default_audio_sample_t)nframes);
	return 0;
}

static void jack_shutdown(void *arg)
{
	exit(1);
}*/

char* connect()
{
  /*Linux*/
  /*
	if ((client = jack_client_open("DrScheme", JackNullOption, NULL)) == 0)
	{
		fprintf(stderr, "jack server not running?\n");
		return "Could Not Connect!";
	}
	
	calc_note_frqs(jack_get_sample_rate (client));

	jack_set_process_callback (client, process, 0);

	jack_set_sample_rate_callback (client, srate, 0);

	jack_on_shutdown (client, jack_shutdown, 0);

	input_port = jack_port_register (client, "midi_in", JACK_DEFAULT_MIDI_TYPE, JackPortIsInput, 0);
	output_port = jack_port_register (client, "audio_out", JACK_DEFAULT_AUDIO_TYPE, JackPortIsOutput, 0);

	if (jack_activate (client))
	{
		fprintf(stderr, "cannot activate client");
		return "Could Not Connect!";
	}
    
  signal(SIGQUIT, signal_handler);
	signal(SIGTERM, signal_handler);
	signal(SIGHUP, signal_handler);
	signal(SIGINT, signal_handler);
  */

  /*Mac OS X*/
  midiInit();
  
	return "Connected!";
}

/*Mac OS X*/
int midiInit(){
  MIDIPortRef* inPort;
  MIDIClientRef* client;

  CFStringRef portName;
  ItemCount nSrcs;
  int iSrc;

  inPort = (MIDIPortRef*)malloc(sizeof(MIDIPortRef));
  client = (MIDIClientRef*)malloc(sizeof(MIDIClientRef));

  nSrcs = MIDIGetNumberOfSources();

  portName = CFStringCreateWithCString(NULL, "my port", kCFStringEncodingMacRoman);
  MIDIClientCreate(portName, NULL, NULL, client);
  MIDIInputPortCreate(*client, portName, (MIDIReadProc)schemeMidiReadProc, client, inPort);

  for (iSrc = 0; iSrc < nSrcs; ++iSrc) {
    MIDIEndpointRef src;
    void *srcConnRefCon;

    src = MIDIGetSource(iSrc);
    srcConnRefCon = src;
    MIDIPortConnectSource(*inPort, src, srcConnRefCon);
  }

  return nSrcs - 0;
}

void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon,
                          void *srcConnRefCon){
  //i've never seen a pktlist of longer than 1 but if you get one, firstly 
  // i apologise, secondly good luck getting a for loop to work in here..
  SchemeMidi* data;
  MIDIPacket* packet;

  packet = &pktlist->packet[0];

  //convert
  data->time = (uint32_t)packet->timeStamp;
  data->size = (size_t)packet->length;
  data->buffer = (unsigned char*)packet->data;
  //enqueue
  q->midiList[q->size] = data;
  q->size++;
}

/*Both OS's*/
Scheme_Object* scheme_initialize(Scheme_Env *env){
	Scheme_Env* mod_env;

	mod_env = scheme_primitive_module(scheme_intern_symbol("SchemeMidi"), env);
	scheme_finish_primitive_module(mod_env);

	q = newQueue();

	return scheme_make_utf8_string("ok");
}

Scheme_Object* scheme_reload(Scheme_Env *env){
	return scheme_initialize(env);
}

Scheme_Object* scheme_module_name(){
	return scheme_intern_symbol("SchemeMidi");
}

/*Queue Stuff*/
Queue* newQueue(){
	Queue* q;
	SchemeMidi** midiList;

	q = (Queue*)malloc(sizeof(Queue));
	midiList = (SchemeMidi**)malloc(sizeof(SchemeMidi*) * MAX_QUEUE_SIZE);

	q->size = 0;
	q->midiList = midiList;

	return q;
}

int isEmpty(Queue* q){
	return q->size == 0;
}

void enqueue(Queue* q, SchemeMidi* data){
	q->midiList[q->size] = data;
	q->size++;
}

SchemeMidi* dequeue(Queue* q){
	SchemeMidi* data;
	int i;

	data = q->midiList[0];

	for(i = 0; i < q->size; i++){
		q->midiList[i] = q->midiList[i+1];
	}

	q->size--;

	return data;
}

SchemeMidi* getMidi(){
	return dequeue(q);
}
