#lang FrTime
(require "Parser/Parser.rkt"
         "HardwareLink/Connect.rkt"
         "Analyser/Analyser.rkt"
         "Performer/Performer.rkt"
         "Lib/utility.rkt"
         "Lib/box-requires.rkt"
         "Lib/racket-requires.rkt"
         frtime/core/frp)

(define analysed-piece (box EMPTY_PIECE))
(define tempo (box 1))
(define clock (- seconds (value-now seconds)))

(define scheme-to-frtime-evt (event-receiver))
(define master-signal
  (map-e (lambda (x) (cond [(not (void? x))
                            (begin
                              (set-box! analysed-piece (analyse (parse x (unbox tempo)) (unbox analysed-piece)))
                              (let ([music (perform (unbox analysed-piece))])
                                (cond [music (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))])))]))
         scheme-to-frtime-evt))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (let ([pkt (read-midi-packet)])
                                                           (send-event scheme-to-frtime-evt pkt)))])
              (#f)
              (cond [(sync (midi-event-to-be-synced)) (send-scheme-event-to-frtime)])))))

(define (go tempo_) 
  (set-box! tempo tempo_)
  (init-performer clock tempo)
  (let-midi-flow))

(define (j) (begin
              (connect)
              (go 1)))

;how-to : (connect) (go 1)