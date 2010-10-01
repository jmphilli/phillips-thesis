#lang FrTime
(require "./Performer_.rkt"
         "../Lib/signal-interface.rkt"
         "../Lib/utility.rkt")

#|
To solve the problem of notes happening on top of each other because of unique values in the queue (i.e. note at beat 1 plays for duration 2 then note at beat 1.01 plays for duration 3)
I will force every piece of music to be a measure long and start at the top of a measure. 
|#
(define clock 1)
(define tempo 1)
(define music-signal (new-cell))

(define (init-performer clk tmpo)
  (begin
    (set! clock clk)
    (set! tempo tmpo)
    (init-sig clock music-signal music-function `(rest 1))))

(define (update-music-signal keys upcoming-changes length-of-performance)
  (let ([music (make-music keys upcoming-changes length-of-performance)])
    (begin
      (printf "~a~n" upcoming-changes)
      (add-music-to-queue clock music))))

(define (add-music-to-queue time music)
  (cond [(not (empty? music))
         (begin
           (add-to-signal-queue time (get-music-for-duration music 1))
           (add-music-to-queue (+ 1 time) (get-music-after-duration music 1)))]))
;set each music to have a clock val and add it to the queue

(define (music-function a . tl) a)

(map-e (lambda (x)
           (begin
             (printf "~a~n" (value-now music-signal))
             (skore:play-music (value-now music-signal)))) (changes music-signal))

#|(define-syntax (music-function syntax-object)
  (syntax-case syntax-object ()
    ((_ a ...)
     (skore:play-music a))))
(define-syntax (bar syntax-object)
      (syntax-case syntax-object ()
        ((_ a ...)
         #'(printf "~a\n" (list a ...)))))|#

(provide perform
         update-music-signal
         init-performer)