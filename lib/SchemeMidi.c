#include "SchemeMidi.h"

Scheme_Object* scheme_initialize(Scheme_Env *env){
  Scheme_Type* type;
  Scheme_Env* mod_env;

  mod_env = scheme_primitive_module(scheme_intern_symbol("SchemeMidi"), env);
  scheme_finish_primitive_module(mod_env);

  type = malloc(sizeof(Scheme_Type));
  //free(type);

  return scheme_void;
}

bool connect(){
/*connectionList defined in SchemeMidi.h malloced in midiInit*/
  connectionList = midiInit();
  if(connectionList->numSrcs <= 0){
    return false;
  }
  //initNewType(type);
  initSchemeMidiObject();
  //initEvt(type);
  return true;
}

Scheme_Object* scheme_reload(Scheme_Env *env){
  midiShutdown(connectionList);
  return scheme_initialize(env);
}

Scheme_Object* scheme_module_name(){
  return scheme_intern_symbol("SchemeMidi");
}

MIDIConnectionList* midiInit(){
  MIDIConnectionList* connList;
  MIDIEndpointRef* srcList;

  MIDIPortRef* inPort;
  MIDIClientRef* client;

  CFStringRef portName;
  ItemCount nSrcs;
  int iSrc;

  connList = (MIDIConnectionList*)malloc(sizeof(MIDIConnectionList));
  inPort = (MIDIPortRef*)malloc(sizeof(MIDIPortRef));
  client = (MIDIClientRef*)malloc(sizeof(MIDIClientRef));

  nSrcs = MIDIGetNumberOfSources();
  srcList = (MIDIEndpointRef*)malloc(nSrcs * sizeof(MIDIEndpointRef));

  portName = CFStringCreateWithCString(NULL, "my port", kCFStringEncodingMacRoman);
  MIDIClientCreate(portName, NULL, NULL, client);
  MIDIInputPortCreate(*client, portName, (MIDIReadProc)schemeMidiReadProc, client, inPort);

  for (iSrc = 0; iSrc < nSrcs; ++iSrc) {
    MIDIEndpointRef src;
    void *srcConnRefCon;

    src = MIDIGetSource(iSrc);
    srcConnRefCon = src;
    srcList[iSrc] = src;
    MIDIPortConnectSource(*inPort, src, srcConnRefCon);
  }

  connList->inPort = inPort;
  connList->numSrcs = nSrcs;
  connList->srcList = srcList;

  //free(client);

  return connList;
}

void midiShutdown(MIDIConnectionList* connList){
  int i;

  for(i = 0; i < connList->numSrcs; i++){
    OSStatus stat;

    stat = MIDIPortDisconnectSource(*(connList->inPort), connList->srcList[i]);

    if(stat != 0){
      printf("Could not disconnect source number %d\nError from MIDIPortDisconnectSource call was %d\n", i, (int)stat);
    }
  }

  free(connList->srcList);
  free(connList->inPort);
}

void initNewType(Scheme_Type* type){
  Scheme_Type new;
  new = scheme_make_type("SchemeMidiPacketType");
  *type = new;
  return;
}

void initSchemeMidiObject(){
  //MIDIPacketList* midiPktList;
  //midiPktList = (MIDIPacketList*)malloc(sizeof(MIDIPacketList));

  hasBeenRead = true;
  //schemeMidis->so.type = *type;
  //schemeMidis->hasBeenRead = t;
  //schemeMidis->pktlist = midiPktList;
}

void schemeMidiReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon){
  if(hasBeenRead){
    //it has been consumed by the user, set it with new data
    //ready to be consumed
    pkts = pktlist;
    hasBeenRead = false;
    //scheme_signal_received();
  }
}

int readyProc(Scheme_Object* data){
  return !hasBeenRead;
}

void initEvt(Scheme_Type* type){
  scheme_add_evt(*type, 
                 readyProc,
                 NULL,//wakeup depends only on scheme actions, so null
                 NULL,//filter not necessary
                 0);
}

MIDIPacket* getMidi(MIDIPacket* pkt){
  MIDIPacket* packet;
  int i;

  if(pkt == NULL){
    packet = &pkts->packet[0];
  }
  else{
    /*for (i = 0; i < pktlist->numPackets; ++i) {
      size_t byteSize;
      MIDIPacket* pkt;

      byteSize = sizeof(MIDITimeStamp) + sizeof(UInt16) + packet->length;
      pkt = malloc(byteSize);

      packet = MIDIPacketNext(packet);
    }*/
    packet = MIDIPacketNext(pkt);
  }
  return packet;
}

UInt32 getListSize(){
  return pkts->numPackets;
}

void schemeHasRead(){
 //schemeMidis->hasBeenRead = t; 
 hasBeenRead = true; 
}

bool readyToRead(){
  return !hasBeenRead;
}
