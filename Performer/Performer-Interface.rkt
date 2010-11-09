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
(define (music-function a . tl) 'reset-this)

(define delayed-computation-duration 1)
(define time-for-one-beat 1)

;(define delayed-computation-duration (/ 1 100))
;(define time-for-one-beat (/ 1 100))

(define (init-performer func clk tmpo)
  (begin
    (set! clock clk)
    (set! tempo tmpo)
    (set! music-function func)
    (init-sig clock music-signal music-function `(rest 1))))

(define (update-music-signal keys upcoming-changes length-of-performance)
  (let ([music (make-music keys upcoming-changes length-of-performance)])
    (add-music-to-queue (+ delayed-computation-duration (value-now clock)) music)))

(define (add-music-to-queue time music)
  (cond [(not (empty? music))
         (begin
           (add-to-signal time (get-music-for-duration music .5)) ;; TODO this .5 is equivalent to one second. 
           (printf "time adding at ~a music ~a~n" time (get-music-for-duration music 1))
           (add-music-to-queue (+ time-for-one-beat time) (get-music-after-duration music 1)))]))

(provide perform
         update-music-signal
         init-performer
         skore:pitch->pitch-num
         skore:play-music
         box
         unbox
         set-box!)