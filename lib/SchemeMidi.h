#include "escheme.h"
#include <CoreMIDI/MIDIServices.h>
#include <stdio.h>
#include <unistd.h>

/*
 *This struct keeps references used in establishing midi connections
 *Later they are used to disconnect
 */

typedef struct{
  MIDIPortRef* inPort;
  int numSrcs;
  MIDIEndpointRef* srcList;
} MIDIConnectionList;

typedef struct{
  Scheme_Object so;
  int hasBeenRead;
  MIDIPacketList* pktlist;
} SchemeMIDIPacketList;

/* I really don't want globals, but I don't see any other way around*/
int hasBeenRead;
MIDIConnectionList* connectionList;
MIDIPacketList* pkts;

/*
 *These first three functions are required to get Scheme functionality
 */


Scheme_Object* scheme_initialize(Scheme_Env *env);

Scheme_Object* scheme_reload(Scheme_Env *env);

Scheme_Object* scheme_module_name();

MIDIConnectionList* midiInit();

void midiShutdown(MIDIConnectionList* connList);

/*
 * A procedure that gets called in CoreMIDI's high priority thread
 * Uses semaphores to communicate new midi data to scheme
 */
void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon); 


void initEvt();

//Scheme_Object** initStruct(Scheme_Object* instance, Scheme_Object* instanceBool);

bool connect();

void initSchemeMidiObject();

void initNewType(Scheme_Type* type);

MIDIPacket* getMidi(MIDIPacket* pktlist);

void schemeHasRead();

bool readyToRead();

UInt32 getListSize();
