#include "SchemeMidi.h"

Queue* newQueue(){
  Queue* q;
  MIDIPacket** pktlist;

  q = (Queue*)malloc(sizeof(Queue));
  pktlist = (MIDIPacket**)malloc(MAX_QUEUE_SIZE * sizeof(MIDIPacket*));
  
  q->size = 0;
  q->pkts = pktlist;

  return q;
}

void freeQueue(){
  free(q->pkts);
  free(q);
}

bool isEmpty(){
  return q->size == 0;
}

void enqueue(Queue* q, MIDIPacketList* packetList)
 XFORM_SKIP_PROC
{
  int i;
  MIDIPacket* packet;
  MIDIPacket* tmp;
  //Byte* data;

  packet = &packetList->packet[0];
  tmp = malloc(sizeof(MIDIPacket));
  //data = malloc(256 * sizeof(Byte));

  for(i = 0; (packet != NULL && i < packetList->numPackets); i++){
    if (packet->data[0] != 254 && packet->data[0] != 248) {
      memcpy(tmp, packet, sizeof(MIDIPacket));
      memcpy(tmp->data, packet->data, sizeof(Byte) * 256);
      q->pkts[q->size] = tmp;
      /*memcpy(data, packet->data, 256 * sizeof(Byte));
      q->pkts[q->size]->timeStamp = packet->timeStamp;
      q->pkts[q->size]->length = packet->length;*/
      //q->pkts[q->size]->data = data;
      q->size++;
    }
  }
}

MIDIPacket* dequeue(){
  MIDIPacket* packet;
  int i;

  packet = NULL;

  if(q->size > 0){
    packet = q->pkts[0];

    for(i = 0; i < q->size - 1; i++){
      q->pkts[i] = q->pkts[i+1];
    }

    q->size--;
  }

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

  savedSrc = malloc(sizeof(MIDIEndpointRef));
  
//  MIDIPacketList* end;
  b = midiInit();
  q = newQueue();

//  end = makeQueueEnd();
//  enqueue(q, makeQueueEnd());

  initNewType();
  return b;
}

/*MIDIPacketList* makeQueueEnd(){
  Byte* buffer;
  MIDIPacketList* pktlist;

  buffer = malloc(sizeof(Byte) * 2048);
  pktlist = (MIDIPacketList *)buffer;
  MIDIPacketListInit(pktlist);

  return pktlist;
}*/

Scheme_Object* scheme_reload(Scheme_Env *env){
  freeAll();
  MIDIEndpointDispose(*savedSrc);
  freeQueue();
  return scheme_initialize(env);
}

Scheme_Object* scheme_module_name(){
  return scheme_intern_symbol("SchemeMidi");
}

void freeAll(){
  int i;
  int qSize;
  MIDIPacket* pkt;

  i = 0;
  qSize = q->size;

  for(i; i < qSize; i++){
    pkt = dequeue();
    schemeFree(pkt);
  }
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

    //todo fix this for multiple intsruments
    *savedSrc = src;

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

Scheme_Object* getQueueForWaiting(){
  return (Scheme_Object*)q;
}

void schemeMidiReadProc(const MIDIPacketList *packetList, void *readProcRefCon, void *srcConnRefCon)
XFORM_SKIP_PROC
{
  enqueue(q, packetList);
}

int readyProc(Scheme_Object* data){
  if(isEmpty()){
    return false;
  }

  return true;
}

void schemeFree(MIDIPacket* pkt){
  free(pkt);
}
