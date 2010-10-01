#include "SchemeMidi.h"

Queue* newQueue(){
  Queue* q;
  MIDIPacket** pktlist;

  q = (Queue*)malloc(sizeof(Queue));
  pktlist = (MIDIPacket**)malloc(sizeof(MIDIPacket*) * MAX_QUEUE_SIZE);

  q->size = 0;
  q->pkts = pktlist;

  return q;
}

bool isEmpty(Queue* q){
  return q->size == 0;
}

int getQSize(){
  return q->size;
}

void logger(UInt64 num){
  FILE* fptr;
  fptr = fopen("myFile.output", "a+");
  fprintf(fptr, "%X\n", num);
  fclose(fptr);
}

void enqueue(Queue* q, MIDIPacketList* p){
  MIDIPacket* packet;
  /*UInt64 num;*/
  int i;

  packet = &p->packet[0];
  for(i = 0; i < p->numPackets; i++){
    q->pkts[q->size] = packet;
    q->size++;
    packet = MIDIPacketNext(packet);
  }

  /*num = (*(MIDIPacket*)&p->packet[0]).timeStamp;

  logger(num);*/
}

MIDIPacket* dequeue(Queue* q){
  MIDIPacket* packet;
  int i;

  packet = q->pkts[0];

  for(i = 0; i < q->size; i++){
    q->pkts[i] = q->pkts[i+1];
  }

  q->size--;

  return packet;
}

Scheme_Object* scheme_initialize(Scheme_Env *env){
  Scheme_Env* mod_env;

  mod_env = scheme_primitive_module(scheme_intern_symbol("SchemeMidi"), env);
  scheme_finish_primitive_module(mod_env);

  return scheme_void;
}

bool connect(){
  bool b;
  MIDIPacketList* end;
  b = midiInit();
  q = newQueue();

  end = makeQueueEnd();
  enqueue(q, makeQueueEnd());

  initNewType();
  return b;
}

MIDIPacketList* makeQueueEnd(){
  Byte* buffer;
  MIDIPacketList* pktlist;

  buffer = malloc(sizeof(Byte) * 2048);
  pktlist = (MIDIPacketList *)buffer;
  MIDIPacketListInit(pktlist);

  return pktlist;
}

Scheme_Object* scheme_reload(Scheme_Env *env){
  return scheme_initialize(env);
}

Scheme_Object* scheme_module_name(){
  return scheme_intern_symbol("SchemeMidi");
}

bool midiInit(){
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

  return nSrcs > 0;
}

/*
typedef struct Scheme_Object
{
  Scheme_Type type; /* Anything that starts with a type field
           can be a Scheme_Object */

  /* For precise GC, the keyex field is used for all object types to
     store a hash key extension. The low bit is not used for this
     purpose, though. For string, pair, vector, and box values in all
     variants of Racket, the low bit is set to 1 to indicate that
     the object is immutable. Thus, the keyex field is needed even in
     non-precise GC mode, so such structures embed
     Scheme_Inclhash_Object */
/*
  MZ_HASH_KEY_EX
} Scheme_Object;
*/

void initNewType(){
  Scheme_Type type;
  type = scheme_make_type("SchemeMidiPacketType");
  q->t = type;
  scheme_add_evt(type, 
                 (Scheme_Ready_Fun)readyProc, //Ready
                 NULL,//nullOp,//getMidi, //Wakeup
                 NULL,//nullOpA,//filter not necessary
                 0);
  return;
}

void nullOp(Scheme_Object* data, void* fds){

}

void nullOpA(Scheme_Object* data){
}

Scheme_Object* getQueueForWaiting(){
  return (Scheme_Object*)q;
}

void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon){
  enqueue(q, pktlist);
  //scheme_signal_received();
}

/*MIDIPacket* readyProc(Scheme_Object* data){
  if(isEmpty((Queue*)data)){
    return NULL;
  }

  return 1;
}*/

int readyProc(Scheme_Object* data){
  if(isEmpty((Queue*)data)){
    return false;
  }

  return true;
}

MIDIPacket* getMidi(){
  return dequeue(q);
}

