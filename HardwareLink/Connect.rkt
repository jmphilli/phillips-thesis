#lang Racket
(require "SchemeMidi.rkt" 
         scheme/foreign)
(unsafe!)

#|For Mac OS X and Linux |#
(define midi-scheme-lib (ffi-lib (build-path "/Users/justinphillips/Documents/School/Thesis/Music/src/HardwareLink/compiled/native/i386-macosx/3m/SchemeMidi_ss")))

(define connect_
  (get-ffi-obj 'connect midi-scheme-lib
               (_fun -> _bool)))

(define dequeue
  (get-ffi-obj 'dequeue midi-scheme-lib
               (_fun -> _pointer)))

(define get-q-size
  (get-ffi-obj 'getQSize midi-scheme-lib
               (_fun -> _int)))

(define get-queue-for-waiting
  (get-ffi-obj 'getQueueForWaiting midi-scheme-lib
               (_fun -> _racket)))

(define (midi-packet-unpacker scheme-midi-ptr)
  (cond [scheme-midi-ptr 
          (let ([data (ptr-ref scheme-midi-ptr (_list-struct _uint64
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
  (let ([midi (dequeue)])
    (cond [midi (let ([val (midi-packet-unpacker midi)])
                  (cond [(not (or (equal? (first (third val)) 254) (equal? (first (third val)) 248))) (printf "~a ~a ~a ~n" (first (third val)) (second (third val)) (third (third val)))]
                        [else 'boo])
                  #;(begin (cond [(not (or (equal? (first (third val)) 254) (equal? (first (third val)) 248))) (printf "~a ~a ~a ~n" (first (third val)) (second (third val)) (third (third val)))])
                         val))])))

(define midi-event-to-be-synced get-queue-for-waiting)

(define (connect)
  (if (connect_)
      "Connected!"
      "Not Connected! Is a MIDI source connected to your computer? Email jjustinphillipss@gmail.com for assistance."))

;assuming that the tempo is 120 and 4/4 time sig (defaults) then convert the detla time that my keyboard puts out into 'real' delta time
(define (filter data)
      (fix-time data))

(define (fix-time data) 
  (cons (delta-time-fix (first data)) (rest data)))

(define saved-time 'a)

(define (delta-time-fix time)
  (match saved-time
    ['a (begin
          (set! saved-time (quotient time 100))
          0)]
    [_ (let ([val (- (quotient time 100) saved-time)])
         (begin
           (set! saved-time (quotient time 100))
           ;(printf "timeval ~a~n" (quotient time 100))
           val))]))

(provide connect
         midi-event-to-be-synced
         read-midi-packet
         get-q-size
         filter)

(define (go)
  (do ([val (get-q-size)])
    (#f)
    (cond [(> (get-q-size) 0)
           (read-midi-packet)])))

#|
My device uses SMPTE Time - 25 frames * 40 subframes. BPM from device is 120. Sends a MIDI clock signal 2 times every second.
So the time coming across is milliseconds at the end 
|#
