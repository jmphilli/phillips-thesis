#include <CoreMIDI/MIDIServices.h>

#define MAX_QUEUE_SIZE 100

typedef struct{
  int size;
  MIDIPacket** pkts;
} Queue;

Queue* newQueue();

bool isEmpty(Queue* q);

void enqueue(Queue* q, MIDIPacketList* p);

MIDIPacket* dequeue(Queue* q);
