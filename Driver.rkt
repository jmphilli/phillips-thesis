#lang FrTime
(require "Parser/Parser.rkt"
         "HardwareLink/Connect.rkt"
         "Analyser/Analyser.rkt"
;         "Performer/Performer.rkt"
;         "Performer/Performer2.rkt"
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
(define clock (- seconds (value-now seconds)))

(define scheme-to-frtime-evt (event-receiver))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (let ([pkt (read-midi-packet)])
                                                           (send-event scheme-to-frtime-evt pkt)))])
              (#f)
              (cond [(sync (midi-event-to-be-synced)) (send-scheme-event-to-frtime)])))))

(define (run_ tempo_) 
  (set-box! tempo tempo_)
  (init-performer music-value-function clock (unbox tempo))
  (let-midi-flow))

(define (run t) (begin
              (connect)
              (run_ t)))

(map-e 
 (lambda (pkt) 
   (begin
     (set-box! analysed-piece (analyse (parse pkt (unbox tempo)) (unbox analysed-piece)))
     (let ([music (perform (unbox analysed-piece))])
       (cond [(not (empty? music)) (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))]))
     )
   )
 scheme-to-frtime-evt)

(define (just-play-music)
  (begin
    (define generator (event-receiver))
    (set-box! tempo 120)
    (init-performer music-value-function clock (unbox tempo))
    (define my-piece (box '(:+: )))

    (if (equal? 1 (modulo seconds 2))
        (begin
          (set-box! my-piece (append (unbox my-piece) '((:=: (note (C 3) 1) (note (E 3) 1) (note (G 3) 1)))))
          (send-event generator (unbox my-piece)))
        (begin
          (set-box! my-piece (append (unbox my-piece) '((:=: (note (G 3) 1) (note (B 3) 1) (note (D 3) 1)))))
          (send-event generator (unbox my-piece))))

    (map-e
     (lambda (pkt) 
       (begin
         (set-box! analysed-piece (analyse pkt (unbox analysed-piece)))
         (let ([music (perform (unbox analysed-piece))])
           (cond [(not (empty? music)) (update-music-signal (piece-key-signature (unbox analysed-piece)) music (modulo (length (piece-changes (unbox analysed-piece))) (length music)))]))
         )
       )
     generator)
    )
  )