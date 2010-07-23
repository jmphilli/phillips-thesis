#lang scheme
(require "SchemeMidi.ss"
         scheme/foreign)
(unsafe!)
(define midi-scheme-lib (ffi-lib "/home/Justin/Documents/scheme/compiled/native/i386-linux/3m/SchemeMidi_ss"))

(define connect
    (get-ffi-obj 'connect midi-scheme-lib
                 (_fun -> _string/utf-8)))

(define get-midi
  (get-ffi-obj 'getMidi midi-scheme-lib
               (_fun -> _pointer)))

(define (midi-packet-unpacker scheme-midi-ptr)
  (let ([data (ptr-ref scheme-midi-ptr (_list-struct _ulong _int
                                                     _uint
                                                     (_list-struct _byte _byte _byte)))]);gotta be a smart way to read this right TODO
    (list (first data)
          (first (fourth data)) (second (fourth data)) (third (fourth data))))) 