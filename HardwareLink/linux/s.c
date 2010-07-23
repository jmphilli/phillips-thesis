#include "SchemeMidi.h"

Queue* q;

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
  return 0 - q->size;
}

void enqueue(Queue* q, SchemeMidi* data){
  //q->midiList[q->size] = data;
  //q->size++;
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

Scheme_Object* scheme_initialize(Scheme_Env *env){
  Scheme_Env* mod_env;

  mod_env = scheme_primitive_module(scheme_intern_symbol("SchemeMidi"), env);
  scheme_finish_primitive_module(mod_env);

  return scheme_void;
}

char* connect(){
  midiInit();
  q = newQueue();
  return "Connecter!";
}

Scheme_Object* scheme_reload(Scheme_Env *env){
  return scheme_initialize(env);
}

Scheme_Object* scheme_module_name(){
  return scheme_intern_symbol("SchemeMidi");
}

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

  return 0 - nSrcs;
}

void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon){
  SchemeMidi* data;
  MIDIPacket* packet;

  packet = &pktlist->packet[0];

  data->time = (uint32_t)packet->timeStamp;
  data->size = (size_t)packet->length;
  data->buffer = (unsigned char*)packet->data;
  //enqueue(q, data);
  q->midiList[q->size] = data;
  q->size++;
}

int readyProc(Scheme_Object* data){
  return dequeue(q);
  //return !isEmpty(q);
}

SchemeMidi* getMidi(){
  return dequeue(q);
}

