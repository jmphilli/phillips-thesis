#lang scheme

(require scheme/foreign)

(unsafe!)

(provide new-midi-handle
         dispose-midi-handle
         with-midi-handle
         midi-command!
         ;jmp
         ;constants
         K-CF-STRING-ENCODING-MAC-ROMAN
         _midi-endpoint-ref
         _midi-client-ref
         _midi-port-ref
         ;foreign functions
         cf-string-create-with-c-string
         midi-packet-list-init
         midi-packet-list-add
         midi-client-create
         midi-source-create
         midi-input-port-create
         midi-get-source
         midi-port-connect-source
         midi-port-disconnect-source
         midi-received
         midi-endpoint-dispose
         ;higher order foreign functions
         point-to
         ;native functions
         )

;; find the dylib corresponding to a framework name.
;; I'm just guessing at how this should work...
(define (framework->dylib fname)
  (build-path "/System/Library/Frameworks/"(string-append fname ".framework")"Versions/Current/"fname))

;; TYPES DEFINED BY APPLE

(define _os-status _sint32)
(define _os-type _uint32)
(define _au-node _sint32)
(define _component-result _sint32)
;jmp
(define _item-count _uint32)
(define _midi-obj-ref _uint32)
(define _byte-count _uint32)
(define _midi-time-stamp _uint64)
(define _midi-endpoint-ref _midi-obj-ref)
(define _midi-port-ref _midi-obj-ref)
(define _midi-client-ref _midi-obj-ref)
(define _midi-device-ref _midi-obj-ref)
(define _midi-entity-ref _midi-obj-ref)
(define _cfstring-encoding _uint32)
(define _const-char-ptr _string) ; don't you dare mutate this string you c programmer you...

(define-cpointer-type _midi-port-ref-ptr)
(define-cpointer-type _midi-client-ref-ptr)
(define-cpointer-type _void-ptr)
(define-cpointer-type _cfallocator-ref) ; since i only need it in one place and it works with a null, don't worry about it...
(define-cpointer-type _midi-notify-proc) ; since i only need it in one place and it works with a null, don't worry about it...
(define-cpointer-type _cfstring-ref)
(define-cpointer-type _midi-packet-ptr)
(define-cpointer-type _byte-array-ptr)

(define-cstruct _midi-packet ([time-stamp _midi-time-stamp] [length _uint16] [data _byte-array-ptr]))
(define-cstruct _midi-packet-list ([num-packets _uint32] [packets _midi-packet-ptr]))

;jbc
(define-cpointer-type _au-graph)
(define-cpointer-type _audio-unit)

(define-cstruct _component-description
  ([component-type _os-type]
   [component-subtype _os-type]
   [component-manufacturer _os-type]
   [component-flags _ulong]
   [component-flags-mask _ulong]))

;jmp
;(define-cstruct _cfstring)

(define (fourcharcode bytes)
  (integer-bytes->integer bytes #f #t))


;; APPLE "FOUR-CHAR" CONSTANTS


(define kAudioUnitType_Output (fourcharcode #"auou"))
(define kAudioUnitSubType_HALOutput (fourcharcode #"ahal"))
(define kAudioUnitSubType_DefaultOutput (fourcharcode #"def "))
(define kAudioUnitSubType_SystemOutput (fourcharcode #"sys "))
(define kAudioUnitSubType_GenericOutput (fourcharcode #"genr"))

(define kAudioUnitType_MusicDevice (fourcharcode #"aumu"))
(define kAudioUnitSubType_DLSSynth (fourcharcode #"dls "))

(define kAudioUnitType_MusicEffect (fourcharcode #"aumf"))

(define kAudioUnitType_FormatConverter (fourcharcode #"aufc"))
(define kAudioUnitSubType_AUConverter (fourcharcode #"conv"))
(define kAudioUnitSubType_Varispeed (fourcharcode #"vari"))
(define kAudioUnitSubType_DeferredRenderer (fourcharcode #"defr"))
(define kAudioUnitSubType_TimePitch (fourcharcode #"tmpt"))
(define kAudioUnitSubType_Splitter (fourcharcode #"splt"))
(define kAudioUnitSubType_Merger (fourcharcode #"merg"))

(define kAudioUnitType_Effect (fourcharcode #"aufx"))
(define kAudioUnitSubType_Delay (fourcharcode #"dely"))
(define kAudioUnitSubType_LowPassFilter (fourcharcode #"lpas"))
(define kAudioUnitSubType_HighPassFilter (fourcharcode #"hpas"))
(define kAudioUnitSubType_BandPassFilter (fourcharcode #"bpas"))
(define kAudioUnitSubType_HighShelfFilter (fourcharcode #"hshf"))
(define kAudioUnitSubType_LowShelfFilter (fourcharcode #"lshf"))
(define kAudioUnitSubType_ParametricEQ (fourcharcode #"pmeq"))
(define kAudioUnitSubType_GraphicEQ (fourcharcode #"greq"))
(define kAudioUnitSubType_PeakLimiter (fourcharcode #"lmtr"))
(define kAudioUnitSubType_DynamicsProcessor (fourcharcode #"dcmp"))
(define kAudioUnitSubType_MultiBandCompressor (fourcharcode #"mcmp"))
(define kAudioUnitSubType_MatrixReverb (fourcharcode #"mrev"))
(define kAudioUnitSubType_SampleDelay (fourcharcode #"sdly"))
(define kAudioUnitSubType_Pitch (fourcharcode #"tmpt"))
(define kAudioUnitSubType_AUFilter (fourcharcode #"filt"))
(define kAudioUnitSubType_NetSend (fourcharcode #"nsnd"))
(define kAudioUnitSubType_Distortion (fourcharcode #"dist"))
(define kAudioUnitSubType_RogerBeep (fourcharcode #"rogr"))

(define kAudioUnitType_Mixer (fourcharcode #"aumx"))
(define kAudioUnitSubType_StereoMixer (fourcharcode #"smxr"))
(define kAudioUnitSubType_3DMixer (fourcharcode #"3dmx"))
(define kAudioUnitSubType_MatrixMixer (fourcharcode #"mxmx"))
(define kAudioUnitSubType_MultiChannelMixer (fourcharcode #"mcmx"))

(define kAudioUnitType_Panner (fourcharcode #"aupn"))
(define kAudioUnitSubType_SphericalHeadPanner (fourcharcode #"sphr"))
(define kAudioUnitSubType_VectorPanner (fourcharcode #"vbas"))
(define kAudioUnitSubType_SoundFieldPanner (fourcharcode #"ambi"))
(define kAudioUnitSubType_HRTFPanner (fourcharcode #"hrtf"))

(define kAudioUnitType_OfflineEffect (fourcharcode #"auol"))

(define kAudioUnitType_Generator (fourcharcode #"augn"))
(define kAudioUnitSubType_ScheduledSoundPlayer (fourcharcode #"sspl"))
(define kAudioUnitSubType_AudioFilePlayer (fourcharcode #"afpl"))
(define kAudioUnitSubType_NetReceive (fourcharcode #"nrcv"))

(define kAudioUnitManufacturer_Apple (fourcharcode #"appl"))



;; load the libraries

(define audiounit-lib (ffi-lib (framework->dylib "AudioUnit")))
(define audiotoolbox-lib (ffi-lib (framework->dylib "AudioToolbox")))
(define coreservices-lib (ffi-lib (framework->dylib "CoreServices")))
;jmp
(define CoreMIDI-lib (ffi-lib (framework->dylib "CoreMIDI")))
(define CoreFoundation-lib (ffi-lib (framework->dylib "CoreFoundation"))) ; for CFStrings

#;(define j-lib (ffi-lib (build-path "/Users/justinphillips/Documents/School/Thesis/Music/midi-test/cScheme/build/Debug/cScheme")))

#;(define connect-me-to-c
  (get-ffi-obj "connectMeToC" j-lib
               (_fun (client : _midi-client-ref) 
                     (portName : _cfstring-ref)
                     (outPort : _pointer);(_ptr i _midi-port-ref-ptr)) ; has tag 'midi-port-ref-ptr
                     -> _os-status)))


;; error checking for FFI calls :

;; BTW, apple's error codes are littered throughout the framework header files.  Maybe I should paste them all in here? Ugh.

(define no-err 0)

(define (check-no-err errno result)
  (unless (= errno no-err)
    (error 'check-no-err
           "received a non-zero error code ~v from call"
           errno))
  result)

;; this type crops up a lot:
(define graph->void-type (_fun _au-graph -> (errno : _os-status) -> (check-no-err errno (void))))

;; FOREIGN FUNCTIONS:

;; allocate a new au-graph:
(define new-au-graph (get-ffi-obj "NewAUGraph" audiotoolbox-lib 
                                  (_fun (graph : (_ptr o _au-graph/null))
                                        -> (errno : _os-status)
                                        -> (check-no-err errno graph))))



;; dispose of an au-graph (essentially, a 'free'):
(define dispose-au-graph (get-ffi-obj "DisposeAUGraph" audiotoolbox-lib graph->void-type))

;; "This creates a node in the graph that is an AudioUnit, using the supplied
;; ComponentDescription to find and open that unit."
(define au-graph-add-node
  (get-ffi-obj "AUGraphAddNode" audiotoolbox-lib
               (_fun _au-graph
                     _component-description-pointer
                     (node : (_ptr o _au-node))
                     -> (errno : _os-status)
                     -> (check-no-err errno node))))

;; "Open a graph.
;; AudioUnits are open but not initialized (no resource allocation occurs here)."
(define au-graph-open (get-ffi-obj "AUGraphOpen" audiotoolbox-lib graph->void-type))

(define au-graph-connect-node-input 
  (get-ffi-obj "AUGraphConnectNodeInput" audiotoolbox-lib
               (_fun _au-graph _au-node _uint32 _au-node _uint32 -> (errno : _os-status)
                     -> (check-no-err errno (void)))))


;; "Returns information about a particular AUNode.
;; You can pass in NULL for any of the out parameters if you're not interested
;; in that value."

;; this is called in a funny way: if the input pointers are non-null, this call fills them out.  
;; there's probably a nice abstraction for this, but I don't see it.

;; instead, it seems simpler just to split it into two functions (only one of which I'll write)
(define au-graph-node-info/unit
  (get-ffi-obj "AUGraphNodeInfo" audiotoolbox-lib
               (_fun _au-graph 
                     _au-node 
                     (_pointer = #f)
                     (unit : (_ptr o _audio-unit/null)) -> (errno : _os-status)
                     -> (check-no-err errno unit))))


;; "Initialise a graph.
;; AudioUnitInitialize() is called on each opened node/AudioUnit
;; (get ready to render) and SubGraph that are involved in a
;; interaction. If the node is not involved, it is initialised
;; after it becomes involved in an interaction."
(define au-graph-initialize (get-ffi-obj "AUGraphInitialize" audiotoolbox-lib graph->void-type))

;; this one appears entirely undocumented...
;; commented out pending a better understanding of how to pass stdout to a C function.
#;(define ca-show-file
  (get-ffi-obj "CAShowFile" audiotoolbox-lib (_fun _pointer _FILE* -> _void)))

;; "Initialise a graph.
;; Start() is called on the "head" node(s) of the AUGraph	(now rendering starts) "                          
(define au-graph-start (get-ffi-obj "AUGraphStart" audiotoolbox-lib graph->void-type))

;; "Stop a graph.
;; Stop() is called on the "head" node(s) of the AUGraph	(rendering is stopped)"
(define au-graph-stop (get-ffi-obj "AUGraphStop" audiotoolbox-lib graph->void-type))


;; MIDI FUNCTIONS

(define music-device-midi-event
  (get-ffi-obj "MusicDeviceMIDIEvent" audiounit-lib
               (_fun (ci : _audio-unit) ; the audio unit to send the command to
                     (in-status : _uint32)
                     (in-data-1 : _uint32)
                     (in-data-2 : _uint32)
                     (in-offset-sample-frame : _uint32)
                     -> _component-result)))

;jmp
(define midi-source-create
  (get-ffi-obj "MIDISourceCreate" CoreMIDI-lib
               (_fun (client : _midi-client-ref)
                     (name : _cfstring-ref)
                     (out-src : _pointer)
                     -> _os-status)))

(define midi-endpoint-dispose
  (get-ffi-obj "MIDIEndpointDispose" CoreMIDI-lib
               (_fun (endpoint : _midi-endpoint-ref)
                     -> _os-status)))

(define midi-received
  (get-ffi-obj "MIDIReceived" CoreMIDI-lib
               (_fun (src : _midi-endpoint-ref)
                     (pkt-list-ptr : _pointer)
                     -> _os-status)))

(define midi-get-number-of-devices
  (get-ffi-obj "MIDIGetNumberOfDevices" CoreMIDI-lib
               (_fun -> _item-count)))

(define midi-get-device 
  (get-ffi-obj "MIDIGetDevice" CoreMIDI-lib
               (_fun (dev-idx : _item-count)
                     -> _midi-device-ref)))

(define midi-device-get-number-of-entities
  (get-ffi-obj "MIDIDeviceGetNumberOfEntities" CoreMIDI-lib
               (_fun (device : _midi-device-ref)
                     -> _item-count)))

(define midi-device-get-entity
  (get-ffi-obj "MIDIDeviceGetEntity" CoreMIDI-lib
               (_fun (dev : _midi-device-ref)
                     (entity-idx : _item-count)
                     -> _midi-entity-ref)))

(define midi-entity-get-number-of-sources
  (get-ffi-obj "MIDIEntityGetNumberOfSources" CoreMIDI-lib
               (_fun (entity : _midi-entity-ref)
                     -> _item-count)))

(define midi-get-number-of-sources
  (get-ffi-obj "MIDIGetNumberOfSources" CoreMIDI-lib
               (_fun -> _item-count)))

(define midi-entity-get-source
  (get-ffi-obj "MIDIEntityGetSource" CoreMIDI-lib
               (_fun (entity : _midi-entity-ref)
                     (src-idx : _item-count)
                     -> _midi-endpoint-ref)))

(define midi-get-source
  (get-ffi-obj "MIDIGetSource" CoreMIDI-lib
               (_fun (src-idx : _item-count)
                     -> _midi-endpoint-ref)))

(define _midi-read-proc
  (_fun (pktlist-ptr : _midi-packet-list)
        (read-proc-ref-con-ptr : _pointer);_void-ptr)
        (src-conn-ref-con : _pointer);_void-ptr)
        -> _void-ptr))

(define midi-packet-list-init
  (get-ffi-obj "MIDIPacketListInit" CoreMIDI-lib
               (_fun (pktlist-ptr : _pointer)
                     -> _midi-packet)))

(define midi-packet-list-add
  (get-ffi-obj "MIDIPacketListAdd" CoreMIDI-lib
               (_fun (pktlist-ptr : _pointer)
                     (list-size : _byte-count)
                     (cur-packet-ptr : _pointer)
                     (time : _midi-time-stamp)
                     (n-data : _byte-count)
                     (data-ptr : _pointer)
                     -> _pointer)))

(define midi-input-port-create
  (get-ffi-obj "MIDIInputPortCreate" CoreMIDI-lib
               (_fun (client : _midi-client-ref) 
                     (portName : _cfstring-ref) 
                     (readProc : _pointer)
                     ;(readProc : _midi-read-proc-ptr) 
                     (refCon : (_or-null _pointer));(_or-null _void-ptr))
                     (outPort : _pointer);(_ptr i _midi-port-ref-ptr)) ; has tag 'midi-port-ref-ptr
                     -> _os-status)))

(define midi-port-connect-source
  (get-ffi-obj "MIDIPortConnectSource" CoreMIDI-lib
               (_fun (port-ref : _midi-port-ref)
                     (endpoint-ref : _midi-endpoint-ref)
                     (conn-ref-con : _pointer);(_or-null _void-ptr))
                     -> _os-status )))

(define midi-port-disconnect-source
  (get-ffi-obj "MIDIPortDisconnectSource" CoreMIDI-lib
               (_fun (port : _midi-port-ref)
                     (src : _midi-endpoint-ref)
                     -> _os-status)))

(define midi-client-create
  (get-ffi-obj "MIDIClientCreate" CoreMIDI-lib
               (_fun (name : _cfstring-ref) 
                     (notifyProc : _pointer)
                     ;(notifyProc : (_or-null _midi-notify-proc))
                     (notifyRefCon : (_or-null _pointer))
                     (outClientptr : _pointer)
                     -> _os-status)))

(define cf-string-create-with-c-string
  (get-ffi-obj "CFStringCreateWithCString" CoreFoundation-lib
               (_fun (alloc : (_or-null _cfallocator-ref)) ; can be null
                     (cstrptr : _const-char-ptr) 
                     (encoding : _cfstring-encoding)
                     -> _cfstring-ref)))



;; library initialization; currently, this happens per-module-evaluation

;; allocate a new graph. 

#;(define (shutdown )
  (au-graph-stop g)
  (dispose-au-graph g))




;; describe an "apple" component
(define (apple-component type subtype)
  (make-component-description 
   type
   subtype
   kAudioUnitManufacturer_Apple
   0
   0))

(define-struct midi-handle (synth-unit au-graph) #:mutable)

(define (dispose-midi-handle the-midi-handle)
  (match the-midi-handle
    [(struct midi-handle (synth-unit au-graph))
     (when au-graph
       (au-graph-stop au-graph)
       (dispose-au-graph au-graph)
       (set-midi-handle-au-graph! the-midi-handle #f))
     ;; need to dispose the synth-unit handle too?
     (when synth-unit
       (set-midi-handle-synth-unit! the-midi-handle #f))]))

(define (new-midi-handle)
  (let* ([g (new-au-graph)]
         ;; create a synth node, add it to the graph
         [synth-node (au-graph-add-node g (apple-component kAudioUnitType_MusicDevice
                                                           kAudioUnitSubType_DLSSynth))]
         ;; create a limiter, add it to the graph
         [limiter-node (au-graph-add-node g (apple-component kAudioUnitType_Effect
                                                             kAudioUnitSubType_PeakLimiter))]
         
         ;; create an output node, add it to the graph
         [output-node (au-graph-add-node g (apple-component kAudioUnitType_Output
                                                            kAudioUnitSubType_DefaultOutput))])
    ;; (?)
    (au-graph-open g)
    ;; connect the output of the synth to the input of the limiter
    (au-graph-connect-node-input g synth-node 0   limiter-node 0)
    ;; connect the output of the limiter to the input of the output-node
    (au-graph-connect-node-input g limiter-node 0 output-node 0)
    
    (let* ([synth-unit (au-graph-node-info/unit g synth-node)]
           [midi-handle (make-midi-handle synth-unit g)])
      (au-graph-initialize g)
      (au-graph-start g)

      ;; JBC: I've never actually seen this happen automatically...
      (register-finalizer midi-handle
                          dispose-midi-handle)
      midi-handle)))




;; midi-command! : audio-unit? number? number? number? -> (void)
;; it would be nifty to use a type system to ensure that the command lives in the top four bits...
(define (midi-command! handle status data-1 data-2)
  (let ([synth-unit (midi-handle-synth-unit handle)])
    (when (not synth-unit)
      (error 'midi-command! "attempt to send commands to an already-closed midi handle"))
    (music-device-midi-event synth-unit status data-1 data-2 0))) ;; sample offset is always zero?



;; bind a new midi handle to the given name for the duration of the evaluation of the 
;; bodies.  On any kind of exit, shut down the audio stuff.
(define-syntax (with-midi-handle stx)
  (syntax-case stx ()
    [(_ id body ...)
     #`(let ([id (new-midi-handle)])
         (dynamic-wind (lambda () #t)
                       (lambda () (let () body ...))
                       ;; kill the midi handle if aborted.
                       (lambda () (dispose-midi-handle id))))]))



;; didn't port this part of the example code (I don't believe I have any "sample banks" to try).

#|
int main (int argc, char * argv[]) {
        AUGraph graph = 0;
        AudioUnit synthUnit;
        OSStatus result;
        char* bankPath = 0;
        
        UInt8 midiChannelInUse = 0; //we're using midi channel 1...
        
                // this is the only option to main that we have...
                // just the full path of the sample bank...
                
                // On OS X there are known places were sample banks can be stored
                // Library/Audio/Sounds/Banks - so you could scan this directory and give the user options
                // about which sample bank to use...
        if (argc > 1)
                bankPath = argv[1];

// if the user supplies a sound bank, we'll set that before we initialize and start playing
        if (bankPath) 
        {
                FSRef fsRef;
                require_noerr (result = FSPathMakeRef ((const UInt8*)bankPath, &fsRef, 0), home);
                
                printf ("Setting Sound Bank:%s\n", bankPath);
                
                require_noerr (result = AudioUnitSetProperty (synthUnit,
                                                                                        kMusicDeviceProperty_SoundBankFSRef,
                                                                                        kAudioUnitScope_Global, 0,
                                                                                        &fsRef, sizeof(fsRef)), home);
    
        }

        
        // ok we're set up to go - initialize and start the graph
|#


#|
jmp
pg 79&80 of coreaudio.pdf
|#

(define K-CF-STRING-ENCODING-MAC-ROMAN 0)
(define void-ptr _pointer)

(define (point-to c-type val)
  (let ([ptr (malloc c-type)])
    (begin
      (ptr-set! ptr c-type val)
      ptr)))

(define (make-list-of-length n)
  (reverse (make-list-of-length-innards n)))

(define (make-list-of-length-innards n)
  (if (equal? n 0)
      '()
      (cons (- n 1) (make-list-of-length-innards (- n 1)))))

(define (my-midi-read-proc pkt-lst read-proc-ref-con src-conn-ref-con)
    src-conn-ref-con)

#;(define (connect-me)
  (let ([num-devices (midi-get-number-of-devices)])
    (for ([i-dev (make-list-of-length num-devices)])
      (let* ([device-ref (midi-get-device i-dev)]
             [num-entities (midi-device-get-number-of-entities device-ref)])
        (for ([i-ent (make-list-of-length num-entities)])
          (let* ([entity (midi-device-get-entity device-ref i-ent)]
                 [in-port (malloc _midi-port-ref)]
                 [client (malloc _midi-client-ref)]
                 [port-name (cf-string-create-with-c-string #f "my port" K-CF-STRING-ENCODING-MAC-ROMAN)]
                 [os-stat-1 (midi-client-create port-name #f #f client)]
                 ;[os-stat-2 (connect-me-to-c (ptr-ref client _midi-client-ref) port-name  in-port)]
                 [os-stat-2 (midi-input-port-create (ptr-ref client _midi-client-ref) port-name my-midi-read-proc client in-port)];TODO maybe need 'function pointer' (function-ptr my-midi-read-proc _midi-read-proc)
                 [num-sources (midi-entity-get-number-of-sources entity)])
            (for ([i-src (make-list-of-length num-sources)])
                  (let* ([src (midi-entity-get-source entity i-src)]
                         [src-conn-ref-con (point-to _uint32 src)]; TODO want/need this to be _void not _uint32
                         [os-stat-3 (midi-port-connect-source (ptr-ref in-port _midi-port-ref) src src-conn-ref-con)])
                    (begin 
                      (printf "dev ~a ent ~a src ~a\n" i-dev i-ent i-src)
                      (sleep 2)
                      (printf "final status ~a" (midi-port-disconnect-source (ptr-ref in-port _midi-port-ref) src)))))))))))


#;(define (connect-me)
    (let* ([in-port (malloc _midi-port-ref)]
           [client (malloc _midi-client-ref)]
           [port-name (cf-string-create-with-c-string #f "my port" K-CF-STRING-ENCODING-MAC-ROMAN)]
           [os-stat-1 (midi-client-create port-name #f #f client)];
           
                 ;[os-stat-2 (connect-me-to-c (ptr-ref client _midi-client-ref) port-name  in-port)]
           [os-stat-2 (midi-input-port-create (ptr-ref client _midi-client-ref) port-name my-midi-read-proc client in-port)];TODO maybe need 'function pointer' (function-ptr my-midi-read-proc _midi-read-proc)
           [num-sources (midi-get-number-of-sources)])
      (for ([i-src (make-list-of-length num-sources)])
        (let* ([src (midi-get-source i-src)]
               [src-conn-ref-con (point-to _uint32 src)]; TODO want/need this to be _void not _uint32
               [os-stat-3 (midi-port-connect-source (ptr-ref in-port _midi-port-ref) src src-conn-ref-con)])
          (begin 
            (printf "src ~a\n" i-src)
            (sleep 2)
            (printf "final status ~a\n" (midi-port-disconnect-source (ptr-ref in-port _midi-port-ref) src)))))))


(define (connect-me)
  (let* ([in-port (malloc _midi-port-ref)]
         [client (malloc _midi-client-ref)]
         
         [port-name (cf-string-create-with-c-string #f "my port" K-CF-STRING-ENCODING-MAC-ROMAN)]
         [status0 (midi-client-create port-name #f #f client)];todo
         [status (midi-input-port-create (ptr-ref client _midi-client-ref) port-name (function-ptr my-midi-read-proc _midi-read-proc) client in-port)];check types in func def
         
         [src-no (midi-get-number-of-sources)])
    (for ([i-src (make-list-of-length src-no)])
          (let* ([src (midi-get-source i-src)]
                 [src-conn-ref-con (point-to _midi-endpoint-ref src)]; TODO FIRST
                 [status2 (midi-port-connect-source (ptr-ref in-port _midi-port-ref) src src-conn-ref-con)]);check types in func def
            (begin 
              (sleep 2)
              (printf "out ~a\n" (midi-port-disconnect-source (ptr-ref in-port _midi-port-ref) src)))))));check types in func def



;null is #f in scheme