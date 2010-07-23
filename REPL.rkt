#lang FrTime
(require "Parser/Parser.rkt"
         "HardwareLink/Connect.rkt"
         "Analyser/Analyser.rkt"
         "Performer/Performer.rkt"
         "Lib/utility.rkt"
         frtime/core/frp
         racket/base)

(define analysed-piece (box EMPTY_PIECE))
(define tempo (box 1))

(define scheme-to-frtime-evt (event-receiver))
(define midi-behavior (hold scheme-to-frtime-evt '()))
(define master-signal
  (proc->signal (lambda () (begin
                             (set-box! analysed-piece (analyse (parse (value-now midi-behavior) (unbox tempo)) (unbox analysed-piece)))
                             (perform (unbox analysed-piece)))) midi-behavior))

(define (let-midi-flow)
  (thread (lambda ()
            (do ([send-scheme-event-to-frtime (lambda () (send-event scheme-to-frtime-evt (read-midi-packet)))])
              (#f)
              (cond [(sync (midi-event-to-be-synced)) (send-scheme-event-to-frtime)])))))
(define (go tempo_) 
  (set-box! tempo tempo_)
  (let-midi-flow))

;how-to : (connect) (go 1)

#|
(define c-on-chord '(1 3 (144 60 23)))
(define e-on-chord '(0 3 (144 64 23)))
(define g-on-chord '(0 3 (144 67 23)))
(define c-off-chord '(5 3 (144 60 0)))
(define e-off-chord '(0 3 (144 64 0)))
(define g-off-chord '(0 3 (144 67 0)))

(define c-on-arp '(1 3 (144 60 23)))
(define e-on-arp '(0 3 (144 64 23)))
(define g-on-arp '(0 3 (144 67 23)))
(define c-off-arp '(1 3 (144 60 0)))
(define e-off-arp '(1 3 (144 64 0)))
(define g-off-arp '(1 3 (144 67 0)))

;check!

(define (run)
  (begin 
    (set-box! analysed-piece (analyse (parse c-on-chord 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse e-on-chord 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse g-on-chord 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse c-off-chord 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse e-off-chord 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse g-off-chord 1) (unbox analysed-piece)))
    (perform (unbox analysed-piece))))
(define (run2)
  (begin 
    (set-box! analysed-piece (analyse (parse c-on-arp 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse c-off-arp 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse e-on-arp 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse e-off-arp 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse g-on-arp 1) (unbox analysed-piece)))
    (set-box! analysed-piece (analyse (parse g-off-arp 1) (unbox analysed-piece)))
    (perform (unbox analysed-piece))))
|#