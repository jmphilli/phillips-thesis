#lang Racket
(require "SchemeMidi.rkt" 
         scheme/foreign)
(unsafe!)

#|For Mac OS X and Linux |#
(define midi-scheme-lib (ffi-lib (build-path "/Users/justinphillips/Documents/School/Thesis/Music/src/HardwareLink/compiled/native/i386-macosx/3m/SchemeMidi_ss")))

(define connect_
  (get-ffi-obj 'connect midi-scheme-lib
               (_fun -> _bool)))

(define get-midi
  (get-ffi-obj 'getMidi midi-scheme-lib
               (_fun -> _pointer)))

(define get-q-size
  (get-ffi-obj 'getQSize midi-scheme-lib
               (_fun -> _int)))

(define get-queue-for-waiting
  (get-ffi-obj 'getQueueForWaiting midi-scheme-lib
               (_fun -> _racket)))

(define (midi-packet-unpacker scheme-midi-ptr)
  (let ([data (ptr-ref scheme-midi-ptr (_list-struct _uint64
                                                     _uint16
                                                     (_list-struct _byte _byte _byte)))]);gotta be a smart way to read this right TODO
    data))

(define (read-midi-packet)
  (midi-packet-unpacker (get-midi)))

;this returns the right stuff now, but what i want is to have the result of sync be the actual midi packet. go change the c code to get that to happen. the return statement i want is unreachable due to my current return
#;(define midi-sync
  (lambda () (begin
               (sync (get-queue-for-waiting))
               (read-midi-packet))))

#;(begin
    (sync (midi-event-to-be-synced))
    (printf "~a~n" (get-q-size))
    (read-midi-packet))

(define midi-event-to-be-synced get-queue-for-waiting)

(define (connect)
  (if (connect_)
      "Connected!"
      "Not Connected! Is a MIDI source connected to your computer? Email jjustinphillipss@gmail.com for assistance."))

(provide connect
         midi-event-to-be-synced
         read-midi-packet)


;#|These two things, while they may be appropriate for my keyboard, do not belong here TODO|#
;;some midi commands like the command xF8 mean absolutely nothing. throw them away. *my keyboard seems to barf out xF8 all the time. this will make my life easier...
;#;(define (remove-junk-midi lst)
;  (map (lambda (x) (cond [(not (or
;                                (equal? #xF8 (second x))
;                                (equal? #xFE (second x)))) x]
;                         [else 'junk]))lst))
;
;;seems like delta time isn't used as per the spec... at least with my keyboard
;#;(define (separate-delta-time lst)
;  (map (lambda (x) (cond [(list? x) (list (first x) (rest x))])) lst))
;
;#;(define (read-midi)
;  (begin 
;    (let* ([pkt (box #f)]
;           [lst (for/list ([i (list-pkt-list-length)])
;                  (let ([new-ptr (get-midi (unbox pkt))])
;                    (begin
;                      (set-box! pkt new-ptr)
;                      (midi-packet-unpacker new-ptr))))])
;      (scheme-has-read!)
;      (separate-delta-time (remove-junk-midi lst)))))

