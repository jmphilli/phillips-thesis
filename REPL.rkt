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
(define midi-behavior (hold scheme-to-frtime-evt '()))
(define master-signal
  (proc->signal (lambda () (cond [(not (void? (value-now midi-behavior))) 
                                  (begin
                                    (set-box! analysed-piece (analyse (parse (value-now midi-behavior) (unbox tempo)) (unbox analysed-piece)))
                                    (let ([music (perform (unbox analysed-piece))])
                                      (cond [music (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))])))])
                midi-behavior)))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (let ([pkt (read-midi-packet)])
                                                           (cond [(not (void? pkt)) (begin
                                                                                      (printf "~a~n" pkt)
                                                                                      (printf "~a hour? ~n" (second (first pkt)))
                                                                                      (send-event scheme-to-frtime-evt (read-midi-packet)))])))])
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