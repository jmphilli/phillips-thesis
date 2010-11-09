#lang racket
(require "../Lib/utility.rkt")
;scalar motion. moving up or down randomly in the possible key signatures.
;every note is 1/8 duration

#|
with the first change, start ascending or descending scalar like for the given duration
|#
(define (make-music keys changes length-of-performance)
  (cons ':+: (cons `(note (,(first changes) 4) 1/8) (recur keys (first changes) (- (* length-of-performance 8) 1)))))

(define (recur keys start-note recursions-left)
  (if (<= recursions-left 0)
      '()
      (let ([new-note (go-go-gadget-randomness keys start-note)])
        (cons new-note (recur keys (first (second new-note)) (- recursions-left 1))))))

(define (go-go-gadget-randomness keys start-note)
  (let ([seed (random 2)])
    (cond [(equal? seed 0) (get-next-note-in-scales keys start-note)]
          [(equal? seed 1) (get-prev-note-in-scales keys start-note)]
          [else (raise 'go-go-gadget)])))

(define (get-next-note-in-scales scales note)
  (let ([half-step (get-note note 1)]
        [whole-step (get-note note 2)])
    (cond [(ormap (lambda (x) (or (music-in-key? `(note (,half-step 2) 1) x MAJOR_LST)
                                  (music-in-key? `(note (,half-step 2) 1) x MINOR_LST))) scales) `(note (,half-step 4) 1/8)]
          [(ormap (lambda (x) (or (music-in-key? `(note (,whole-step 2) 1) x MAJOR_LST)
                                  (music-in-key? `(note (,whole-step 2) 1) x MINOR_LST))) scales) `(note (,whole-step 4) 1/8)]
          [else (raise 'get-next-note-error)])))

(define (get-prev-note-in-scales scales note)
  (let ([half-step (get-note note -1)]
        [whole-step (get-note note -2)])
    (cond [(ormap (lambda (x) (or (music-in-key? `(note (,half-step 2) 1) x MAJOR_LST)
                                  (music-in-key? `(note (,half-step 2) 1) x MINOR_LST))) scales) `(note (,half-step 4) 1/8)]
          [(ormap (lambda (x) (or (music-in-key? `(note (,whole-step 2) 1) x MAJOR_LST)
                                  (music-in-key? `(note (,whole-step 2) 1) x MINOR_LST))) scales) `(note (,whole-step 4) 1/8)]
          [else (raise 'get-next-note-error)])))

(define (get-note note distance)
  (let ([new-note (+ distance (skore:pitch-class->offset note))])
    (cond [(> 0 new-note) (let ([new-note (+ new-note 12)])
                            (skore:offset->pitch-class new-note))]
          [(< 11 new-note) (let ([new-note (- new-note 12)])
                            (skore:offset->pitch-class new-note))]
          [else (skore:offset->pitch-class new-note)])))
;  (skore:offset->pitch-class (+ distance (skore:pitch-class->offset note))))

(provide make-music)