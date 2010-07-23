#include "Queue.h"

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

void enqueue(Queue* q, MIDIPacketList* p){
  MIDIPacket* packet;
  int i;

  packet = &p->packet[0];
  for(i = 0; i < p->numPackets; i++){
    q->pkts[q->size] = packet;
    q->size++;
    packet = MIDIPacketNext(packet);
  }
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
