#include "escheme.h"
#include <stdio.h>
#include <unistd.h>
#include <CoreMIDI/MIDIServices.h>

#define MAX_QUEUE_SIZE 10000

typedef struct{
  Scheme_Type t;
  int size;
  MIDIPacket** pkts; /*timestamp is a uint64*/
} Queue;

Queue* newQueue();

void freeQueue();

bool isEmpty();

void enqueue(Queue* q, MIDIPacketList* p);

MIDIPacket* dequeue();

//MIDIPacketList* makeQueueEnd();

Scheme_Object* getQueueForWaiting();

Queue* q;

MIDIEndpointRef* savedSrc;
MIDIPortRef* inPort;

/*
You should set up an evt through the C API using scheme_add_evt(),
where the evt's polling function checks something to be set by the MIDI
callback. In addition, the MIDI callback should call
scheme_signal_received() (ok to call from any OS-level thread or signal
handler) to ensure that the evt's polling operation is called by the
runtime system.
*/

/*
 *These first three functions are required to get Scheme functionality
 */

Scheme_Object* scheme_initialize(Scheme_Env *env);

Scheme_Object* scheme_reload(Scheme_Env *env);

Scheme_Object* scheme_module_name();

bool connect();

bool midiInit();

/*
 * A procedure that gets called in CoreMIDI's high priority thread
 * Uses semaphores to communicate new midi data to scheme
 */
void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon); 

//MIDIPacket* readyProc(Scheme_Object* data);
int readyProc(Scheme_Object* data);

int ready(Scheme_Object* data);

void initNewType();
