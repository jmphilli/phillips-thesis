#lang FrTime
(require "./Performer-Interface.rkt")

#|
(define (sum . xs)
    (if (null? xs)
        0
        (+ (car xs) (apply sum (cdr xs)))))
|#

(define (music-value-function . tl)
  (thread (lambda () (skore:play-music (first (first tl))))))

(provide perform
         music-value-function
         update-music-signal
         init-performer)