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

#;(define get-q-size
  (get-ffi-obj 'getQSize midi-scheme-lib
               (_fun -> _int)))

(define get-queue-for-waiting
  (get-ffi-obj 'getQueueForWaiting midi-scheme-lib
               (_fun -> _racket)))

(define (midi-packet-unpacker scheme-midi-ptr)
  (cond [scheme-midi-ptr 
          (let ([data (ptr-ref scheme-midi-ptr (_list-struct (_list-struct _byte _byte _byte _byte _byte _byte _byte _byte);_uint64
                                                             _uint16
                                                             (_list-struct _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte
                                                                           _byte _byte _byte _byte _byte _byte _byte _byte)))]);gotta be a smart way to read this right TODO
            (filter data))]))

(define (read-midi-packet)
  (midi-packet-unpacker (get-midi)))

(define midi-event-to-be-synced get-queue-for-waiting)

(define (connect)
  (if (connect_)
      "Connected!"
      "Not Connected! Is a MIDI source connected to your computer? Email jjustinphillipss@gmail.com for assistance."))

;assuming that the tempo is 120 and 4/4 time sig (defaults) then convert the detla time that my keyboard puts out into 'real' delta time
(define (filter data)
  (cond 
    [(not (or
               (equal? #xF8 (first (third data)))
               (equal? #xFE (first (third data))))) (fix-time data)]))

(define (fix-time data) data)
  ;(cons (quotient (quotient (delta-time-fix (first data)) 12) 1000000) (rest data)))

(define saved-time -1)

(define (delta-time-fix time)
  (match saved-time
    [-1 (begin
          (set! saved-time time)
          0)]
    [_ (let ([val (- time saved-time)])
         (begin
           (set! saved-time time)
           (printf "~a val here ~n" val)
           val))]))

(provide connect
         midi-event-to-be-synced
         read-midi-packet
         filter)

;163140453741712 -- 12:40:17:526
;13:16:09:292 -- 52 210 234 14 85 150 0 0 
#|
My device uses SMPTE Time - 25 frames * 40 subframes. BPM from device is 120. Sends a MIDI clock signal 2 times every second.
So the time coming across is milliseconds at the end 
|#
