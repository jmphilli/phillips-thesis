#lang FrTime
(require "Parser/Parser.rkt"
         "HardwareLink/Connect.rkt"
         "Analyser/Analyser.rkt"
;         "Performer/Performer.rkt"
 ;        "Performer/Performer2.rkt"
         "Performer/Performer3.rkt"
         "Lib/utility.rkt"
         "Lib/box-requires.rkt"
         "Lib/racket-requires.rkt"
         frtime/core/frp)

#|

TODO:

remove 'NC's if i can

I think that the modulo call below is unneccessary, should just be length of music i think... 

try '3:4

|#

(define analysed-piece (box EMPTY_PIECE))
(define tempo (box 'a))
;(define clock (- milliseconds (value-now milliseconds)))
(define clock (- seconds (value-now seconds)))
;(define clock (- (/ milliseconds 100) (/ (value-now milliseconds) 100)))
(define scheme-to-frtime-evt (event-receiver))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (let ([pkt (read-midi-packet)])
                                                           (send-event scheme-to-frtime-evt pkt)))])
              (#f)
              (cond [(sync (midi-event-to-be-synced)) (send-scheme-event-to-frtime)])))))

(define (run tempo_) 
  (set-box! tempo tempo_)
  (init-performer music-value-function clock (unbox tempo))
  (let-midi-flow))

(define (j t) (begin
              (connect)
              (run t)))

(map-e 
 (lambda (pkt) 
   (begin
     (set-box! analysed-piece (analyse (parse pkt (unbox tempo)) (unbox analysed-piece)))
     (let ([music (perform (unbox analysed-piece))])
         (begin
           ;(printf "upcoming ~a~n" music)
           (cond [(not (empty? music)) (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))])))
     )
   )
 scheme-to-frtime-evt)