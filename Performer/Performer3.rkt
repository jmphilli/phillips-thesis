#lang FrTime
(require "./Performer-Interface.rkt")

#|
This function tries to draw melodic curves. At the beginning, going up and going down are given even weight. Passages with notes are chosen over passages without. Once a direction is taken (up or
down) then the passages that continue in that direction are given more weight compared to passages that counter that direction. That is true until three passages have been selected. Then the process 
repeats so that going up or down is evenly weighted again.
|#

#| State-y stuff |#
(define direction 'none)
(define count 0)
(define note-number -1)
#|***************|#

#| Worker functions |#
(define (increment-count)
  (cond [(equal? count 2) (begin
                            (set! count 0)
                            (set! direction 'none))]
        [else (set! count (+ 1 count))]))

;if we're going up, the new note number is the highest note in the passage. down? then lowest.
(define (reset-note-number music)
  (let ([val (get-distance-from-note-number music)])
    (set! note-number (+ val note-number))))

; get distance from note for each passage. the smallest distance which is in the correct direction wins
(define (has-notes? lst)
  (let ([note-lst (get-notes lst)])
    (has-notes?_ note-lst)))

(define (has-notes?_ note-lst)
  (if (empty? note-lst)
      #f
      (or (equal? 'note (first note-lst)) (has-notes?_ (rest note-lst)))))

(define (choose-passage musics)
  (let ([musics-w-notes (map (lambda (x) (if (has-notes? x)
                                             x
                                             '())) musics)])
    (if (empty? musics-w-notes)
        '(rest 1)
        (foldl (lambda (x result)
                 (cond [(same-direction? x) (cond [(< (get-distance-from-note-number x) (get-distance-from-note-number result)) x]
                                                  [else result])]
                       [else result])) '(rest 1) musics-w-notes))))

(define (same-direction? music)
  (let ([val (get-distance-from-note-number music)])
    (or (and (equal? 'up direction) (positive? val))
        (and (equal? 'down direction) (negative? val))
        (equal? direction 'none))))

;the passage's direction is defined as the most extreme note-number.
(define (get-distance-from-note-number note-num music)
  (let ([lst (convert-music-to-note-numbers music)])
    (if (empty? lst)
        1000
        (get-distance-recur note-num lst))))

(define (get-distance-recur note-num lst)
  (if (or (equal? note-num -1) (empty? lst))
      0
      (find-greater-distance (get-note-distance note-num (first lst)) (get-distance-recur note-num (rest lst)))))

(define (convert-music-to-note-numbers music)
  (let ([note-lst (get-notes music)])
    (convert-notes-to-note-numbers note-lst)))

(define (get-notes music)
  (if (empty? music)
      '()
      (cond [(or (equal? ':+: (first music)) (equal? ':=: (first music))) (get-notes (rest music))]
            [(list? (first music)) (cond [(equal? 'note (first (first music))) (cons (first music) (get-notes (rest music)))]
                                         [(equal? 'rest (first (first music))) (get-notes (rest music))]
                                         [else (append (get-notes (first music)) (get-notes (rest music)))])]
            [else 'unsupported-get-notes])))

(define (convert-notes-to-note-numbers notes)
  (if (empty? notes)
      '()
      (cons (note-to-note-num (first notes)) (convert-notes-to-note-numbers (rest notes)))))

(define (note-to-note-num note)
  (skore:pitch->pitch-num (second note)))

(define (get-note-distance a b)
  (- b a))

(define (find-greater-distance a b)
  (if (< (abs a) (abs b))
      b
      a))
#|******************|#

#| Interface stuff |#
(define (music-value-function . lst)
  (let ([val (choose-passage lst)])
    (begin
      (increment-count)
      (reset-note-number val)
      val)))

#|*****************|#

(provide perform
         update-music-signal
         music-value-function
         init-performer)