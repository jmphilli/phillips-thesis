#lang FrTime
(require "Parser/Parser.rkt"
         "HardwareLink/Connect.rkt"
         "Analyser/Analyser.rkt"
         "Performer/Performer.rkt"
;         "Performer/Performer2.rkt"
;         "Performer/Performer3.rkt"
         "Lib/utility.rkt"
         "Lib/box-requires.rkt"
         "Lib/racket-requires.rkt"
         frtime/core/frp)

#|

TODO:

then add the 'make music' bit back in:: hardcode some upcoming changes to run into it.

finally add the upcoming changes bit
|#

(define analysed-piece (box EMPTY_PIECE))
(define tempo (box 'a))
(define clock (- milliseconds (value-now milliseconds))) ;; need to change to a microsecond clock ;;TODO
(define scheme-to-frtime-evt (event-receiver))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (let ([pkt (read-midi-packet)])
                                                           (send-event scheme-to-frtime-evt pkt)))])
              (#f)
              (cond [(sync (midi-event-to-be-synced)) (send-scheme-event-to-frtime)])))))

(define (run tempo_) 
  (set-box! tempo tempo_)
  (init-performer music-value-function clock tempo)
  (let-midi-flow))

(define (j) (begin
              (connect)
              (run 120)))

(map-e 
 (lambda (pkt) 
   (begin
     (set-box! analysed-piece (analyse (parse pkt (unbox tempo)) (unbox analysed-piece)))
     (let ([music (perform (unbox analysed-piece))])
       (cond [(not (empty? music)) (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))])
       #;(update-music-signal `(C) music 1))
     )
   )
 scheme-to-frtime-evt)