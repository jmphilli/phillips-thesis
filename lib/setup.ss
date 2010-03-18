#lang scheme

(require scheme/foreign)

(unsafe!)

(provide new-midi-handle
         dispose-midi-handle
         with-midi-handle
         midi-command!)

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
(define _item_count _uint32)
(define _midi_obj_ref _uint32)
(define _midi_endpoint_ref _midi_obj_ref)
(define _midi_port_ref _midi_obj_ref)
(define _midi_client_ref _midi_obj_ref)
(define _cfstring_encoding _uint32)
(define _const_char_ptr _string/ucs-4) ; don't you dare mutate this string you c programmer you...

;fix this
(define _midi_packet_list _uint32)

(define-cpointer-type _midi_port_ref_ptr)
(define-cpointer-type _midi_client_ref_ptr)
(define-cpointer-type _void_ptr)
(define-cpointer-type _cfallocator_ref) ; since i only need it in one place and it works with a null, don't worry about it...
(define-cpointer-type _midi_notify_proc) ; since i only need it in one place and it works with a null, don't worry about it...
(define-cpointer-type _cfstring_ref)

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
(define midi-get-number-of-destinations
  (get-ffi-obj "MIDIGetNumberOfDestinations" CoreMIDI-lib
               (_fun -> _item_count)))

(define midi-get-number-of-sources
  (get-ffi-obj "MIDIGetNumberOfSources" CoreMIDI-lib
               (_fun -> _item_count)))

(define midi-get-destination
  (get-ffi-obj "MIDIGetDestination" CoreMIDI-lib
               (_fun (dest-index : _item_count) ; The index (0...MIDIGetNumberOfDestinations()-1) of the destination to return
                     -> _midi_endpoint_ref)))

(define midi-get-source
  (get-ffi-obj "MIDIGetSource" CoreMIDI-lib
               (_fun (dest-index : _item_count) ; The index (0...MIDIGetNumberOfSources()-1) of the destination to return
                     -> _midi_endpoint_ref)))

(define _midi_read_proc
  (_fun (pktlist-ptr : _midi_packet_list)
        (read-proc-ref-con-ptr : _void_ptr)
        (src-conn-ref-con : _void_ptr)
        -> _void_ptr))

(define (midi-read a b c)
  (printf "working\n"))

(define midi-input-port-create
  (get-ffi-obj "MIDIInputPortCreate" CoreMIDI-lib
               (_fun (client : _midi_client_ref) 
                     (portName : _cfstring_ref) 
                     (readProc : _midi_read_proc) 
                     (refCon : (_or-null _void_ptr))
                     (outPort : _midi_port_ref_ptr)
                     -> _os-status)))

(define midi-port-connect-source
  (get-ffi-obj "MIDIPortConnectSource" CoreMIDI-lib
               (_fun (port-ref : _midi_port_ref)
                     (endpoint-ref : _midi_endpoint_ref)
                     (conn-ref-con : (_or-null _void_ptr))
                     -> _os-status )))

(define midi-client-create
  (get-ffi-obj "MIDIClientCreate" CoreMIDI-lib
               (_fun (name : _cfstring_ref) 
                     (notifyProc : (_or-null _midi_notify_proc))  ; can be null
                     (notifyRefCon : (_or-null _void_ptr))
                     (outClientptr : (_or-null _midi_client_ref_ptr))
                     -> _os-status)))

(define cfstring-create-with-c-string
  (get-ffi-obj "CFStringCreateWithCString" CoreFoundation-lib
               (_fun (alloc : (_or-null _cfallocator_ref)) ; can be null
                     (cstrptr : _const_char_ptr) 
                     (encoding : _cfstring_encoding)
                     -> _cfstring_ref)))



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



;jmp
(define new-void-ptr (malloc (max (ctype-sizeof _uint32) (ctype-sizeof _pointer))))

;pg 79&80 of coreaudio.pdf
(define (setup-one-instrument in-port)
  (let* ([src (midi-get-source 0)]
         [src-conn-ref-con (point-to _uint32 src _uint32)])
    (midi-port-connect-source (ptr-ref in-port _midi_port_ref)
                              src
                              src-conn-ref-con)))
(define (make-client-name)
  (cfstring-create-with-c-string #f
                                 "my-client"
                                 0))

(define (make-input-port)
  (let* ([client-name (make-client-name)]
         [client (make-client client-name)]
         [out-port (point-to _uint32 0 _uint32)]
         [status (midi-input-port-create (ptr-ref client _midi_client_ref)
                                         client-name
                                         (function-ptr midi-read _midi_read_proc)
                                         #f;(point-to _uint32 1 _uint32) ; i'm assuming thats what refCon is short for... this value can be non zero apparently..
                                         (ptr-ref out-port _midi_port_ref))])
    out-port))


(define (make-client client-name)
  (let ([client-ref (point-to (_or-null _midi_client_ref_ptr) #f (_or-null _midi_client_ref_ptr))])
    (begin (midi-client-create client-name
                               #f
                               #f
                               client-ref))
    client-ref))


(define (point-to type val ptr-type)
  (let ([cptr (malloc type)])
    (begin
      (ptr-set! cptr ptr-type val)
      cptr)))

(define (connect-to-instrument)
  (setup-one-instrument (make-input-port)))