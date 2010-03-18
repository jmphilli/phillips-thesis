#lang frtime

(define (perform analysed-stream)
  ;#(sync-and-play) use this if its so slow that it needs to synch up as the melodic ideas are not being performed when they were intended.
  
  ;(write-out-to-midi (...)))
  (notes->midi analysed-stream)

#|
write-out-to-midi : 
This takes a piece of structured data (music, the same stuff that the analyser
spits out[this time constructed by the system though, not other performers]) and
turns it into midi.
|#
(define (write-out-to-midi ))

#|
switch-melodic-transformers :
This has a lot of potential for weird reactivity effects
chooses (? somehow) a transformation to use on a melody, applies that 
transformation in such a way that it makes sense for the next x measures. 
returns that melodic piece of structured data so that it can be written out to 
midi and heard.
|#
(define (switch-melodic-transformers))

(define (retrograde melody))

(define (invert melody))

...