#lang Racket
(require "../Lib/utility.rkt")

;given a piece of music (from the analyser) 
;the analyser can run parallel to help me know what i'm doing // dealing with, this module can use older versions of the piece and get new ones updated whenever possible via reactivity

;TODO add melody stuff pulled from the piece.

;when to perform -- 
;given : the piece is constantly updating
;when i see a pattern that appears to be repeating
;assume it's going in the same direction as the pattern I already see given some caveats (half cadences, pac cadences)

#|(define (perform piece)
  (let ([upcoming-form (predict-form (piece-changes piece) 4)])
    (cond [upcoming-form (perform_ (piece-key-signature piece) upcoming-form (modulo (length (piece-changes piece)) (length upcoming-form)))])))

(define (perform_ keys upcoming-changes length-of-performance)
  (skore:play-music (make-music keys upcoming-changes length-of-performance)))|#

(define (perform piece)
  (let ([upcoming-form (predict-form (piece-changes piece) 4)])
    upcoming-form))

(define (make-music keys changes length-of-performance)
  (cond [(cadential? keys changes) (cond [(half-cadence? keys changes) (make-half-cadential-melody (make-tail-list-for-patterns changes length-of-performance))]
                                         [(authentic-cadence? keys changes) (make-authentic-melody (make-tail-list-for-patterns changes length-of-performance))]
                                         [(deceptive-cadence? keys changes) (make-deceptive-melody (make-tail-list-for-patterns changes length-of-performance))])]
        [else
         (cons ':+: (map (lambda (x) (cond [(equal? 'NC x) `(rest 1)]
                                           [(seventh-chord? x) `(note (,(peel-off-seventh x) 4) 1)]
                                           [else `(note (,x 4) 1)])) (make-tail-list-for-patterns changes length-of-performance)))]))

(define (cadential? keys changes)
  (or (authentic-cadence? keys changes)
      (half-cadence? keys changes)
      (deceptive-cadence? keys changes)))

(define-syntax cadential-predicate-macro
  (syntax-rules ()
    [(cadential-predicate cadential-predicate keys changes) (ormap (lambda (x) (cadential-predicate x changes)) keys)]))

(define-syntax authentic-cadence?
  (syntax-rules ()
    [(authentic-cadence? keys changes) (cadential-predicate-macro authentic-cadence?_ keys changes)]))

(define-syntax half-cadence?
  (syntax-rules ()
    [(half-cadence? keys changes) (cadential-predicate-macro half-cadence?_ keys changes)]))

(define-syntax deceptive-cadence?
  (syntax-rules ()
    [(authentic-cadence? keys changes) (cadential-predicate-macro deceptive-cadence?_ keys changes)]))

;authentic cadence defined as any number of V followed by any number of i/I
#;(define (authentic-cadence?_ key changes)
  (let ([changes-recur (reverse (chords-to-degrees changes key))])
    (letrec ([recur (lambda (x) (cond [(not (empty? x)) (if (or (equal? 'i (first x))
                                                                (equal? 'I (first x)))
                                                            (recur (rest x))
                                                            (and #;(equal? (length x) 1)
                                                                   (equal? 'V (first x))))]
                                      [else #f]))])
      (recur changes-recur))))
(define (authentic-cadence?_ key changes)
  (cadential-predicate-maker-macro key changes (lambda (x) (or (equal? 'i (first x))
                                                                (equal? 'I (first x))))
                                   (lambda (x) (equal? 'V (first x)))))

;half cadence defined as anything followed by and ending with a V chord
(define (half-cadence?_ key changes)
  (cadential-predicate-maker-macro key changes '(V)))

;deceptive cadence defined as any number of V followed by anything not I/i for either one or two measures
#;(define (deceptive-cadence?_ key changes)
  (let ([changes-recur (reverse (chords-to-degrees changes key))])
    (letrec ([recur (lambda (x) (cond [(not (empty? x)) (if (or (equal? 'V (first x))
                                                                (equal? 'v (first x)))
                                                            (recur (rest x))
                                                            (and (not (equal? 'I (first x)))
                                                                 (not (equal? 'i (first x)))
                                                                 (not (equal? 'NC (first x)))))]
                                      [else #f]))])
      (recur changes-recur))))
(define (deceptive-cadence?_ key changes)
  (cadential-predicate-maker-macro key changes (lambda (x) (and (not (equal? 'I (first x)))
                                                                (not (equal? 'i (first x)))
                                                                (not (equal? 'NC (first x)))))
                                   (lambda (x)
                                     (or (equal? 'V (first x))
                                         (equal? 'v (first x))))))

(define-syntax cadential-predicate-maker-macro
  (syntax-rules ()
    [(cadential-predicate-maker-macro key changes cadential-chords)
     (ormap (lambda (x) (equal? x (last (chords-to-degrees changes key)))) cadential-chords)]
    [(cadential-predicate-maker-macro key changes cadential-test final-test)
     (let ([changes-recur (reverse (chords-to-degrees changes key))])
       (letrec ([recur (lambda (x) (cond [(not (empty? x)) (if (cadential-test x)
                                                               (recur (rest x))
                                                               (final-test x))]
                                         [else #f]))])
         (recur changes-recur)))]))

(define (make-half-cadential-melody changes)
  (cons ':+: (make-melody_ changes (length changes) (make-half-cadential-ending (get-cadential-ending changes)))))

(define (make-authentic-melody changes)
  (cons ':+: (make-melody_ changes (length changes) (make-authentic-ending (get-cadential-ending changes)))))

(define (make-deceptive-melody changes)
  (cons ':+: (make-melody_ changes (length changes) (make-deceptive-ending (get-cadential-ending changes)))))

;ending with a 7 or 2 in the key; 3 and 5 in the chord (5 chord)
(define (make-half-cadential-ending changes)
  (make-ending (map (lambda (x y) (get-note-lst-from-degrees x y)) changes (make-list-of-length-with (length changes) `(,MAJOR_THIRD ,PERFECT_FIFTH)))))

(define (make-list-of-length-with x y)
  (if (equal? 0 x)
      '()
      (cons y (make-list-of-length-with (- x 1) y))))

(define (get-cadential-ending lst)
  (if (<= (length lst) 2)
      lst
      (take-right lst 2)))

;ending with a 1 in the key preceeded by a 7 or a 2 to attempt to make PAC (this can be changed if it's too icky/classical/traditional/boring.
;3 and 5 of 5 are 2 and 7 of 1.
;a squid eating dough in a polyethelene bag is fast and bulbous got me?
(define (make-authentic-ending changes) 
  (make-ending (map (lambda (x y) (get-note-lst-from-degrees x y)) changes (if (>= (length changes) 2)
                                                                               `((,MAJOR_THIRD ,PERFECT_FIFTH) (,UNISON))
                                                                               `((,UNISON))))))

;7 or 2 in the key resolving to 1 or 3 at the end
(define (make-deceptive-ending changes) 
  (make-ending (map (lambda (x y) (get-note-lst-from-degrees x y)) changes `((,(if (major-key-symbol? (first changes))
                                                                                   MAJOR_THIRD
                                                                                   MINOR_THIRD) ,PERFECT_FIFTH) (,UNISON ,(if (major-key-symbol? (second changes))
                                                                                                                            MAJOR_THIRD
                                                                                                                            MINOR_THIRD))))))

(define (make-ending note-lst)
  ;todo
  (make-melody-with-notes note-lst (length note-lst)))
;  make an ending of duration (length note-lst) using the notes in note-lst for their respective beat durations
;  note-lst)

(define (get-note-lst-from-degrees chord degree-lst)
  (map (lambda (x) (cond 
                     [(equal? x UNISON) chord]
                     [(equal? x MAJOR_THIRD) (skore:offset->pitch-class (modulo (+ (skore:pitch-class->offset chord) MAJOR_THIRD) 12))]
                     [(equal? x MINOR_THIRD) (skore:offset->pitch-class (modulo (+ (skore:pitch-class->offset chord) MINOR_THIRD) 12))]
                     [(equal? x PERFECT_FIFTH) (skore:offset->pitch-class (modulo (+ (skore:pitch-class->offset chord) PERFECT_FIFTH) 12))])) degree-lst))

#;(define (get-cadential-duration changes)
  (if (<= 2(length changes))
      (if (equal? )(+ 1 (get-cadential-duration (rest changes))))
      2))

(define (make-melody_ changes remaining-duration ending)
  (if (<= (- remaining-duration (get-musical-duration (cons ':+: ending))) 0)
      ending
      ;make a note for some duration
      (let ([note (make-note-in-chord (first changes))])
        (cond [(equal? 'rest (first note)) (if (not (empty? (rest changes)))
                                               (cons note (make-melody_ (rest changes) (- remaining-duration (second note)) ending))
                                               (cons note (make-melody_ changes (- remaining-duration (second note)) ending)))]
              [(equal? 'note (first note)) (if (and (change-chord? remaining-duration (third note))
                                                    (not (empty? (rest changes))))
                                               (cons note (make-melody_ (rest changes) (- remaining-duration (third note)) ending))
                                               (cons note (make-melody_ changes (- remaining-duration (third note)) ending)))]))))

(define (make-melody-with-notes note-lst remaining-duration)
  (if (>= 0 remaining-duration)
      '()
      (let ([note (make-note-from-note-options (first note-lst))])
        (if (and (not (empty? (rest note-lst)))
                 (change-chord? remaining-duration (third note)))
            (cons note (make-melody-with-notes (rest note-lst) (- remaining-duration (third note))))
            (cons note (make-melody-with-notes note-lst (- remaining-duration (third note))))))))

(define (make-note-from-note-options note-options)
  (let* ([note-val (get-random-lst-member note-options)]
         [note-octave (get-random-melodic-octave)]
         [duration (get-random-melodic-duration)])
    `(note (,note-val ,note-octave) ,duration)))

(define (get-random-lst-member lst)
  (let ([seed (random (length lst))])
    (list-ref lst seed)))

;is there a better way to do the var args bit? TODO
(define (make-note-in-chord chord . note-val)
  (if (not (empty? note-val))
      (first note-val)
      (if (equal? chord 'NC)
          `(rest 1)
          (let* ([note-val (get-random-note-in-chord chord)]
                 [note-octave (get-random-melodic-octave)]
                 [duration (get-random-melodic-duration)])
            `(note (,note-val ,note-octave) ,duration)))))

(define (get-random-note-in-chord chord)
  (let ([seed (random 2)])
    (if (major-key-symbol? chord)
      (cond [(equal? seed 0) chord];root
            [(equal? seed 1) (first (skore:pitch-num->pitch (+ 4 (skore:pitch-class->offset chord))))];third
            [(equal? seed 2)(first (skore:pitch-num->pitch (+ 7 (skore:pitch-class->offset chord))))]);fifth
      (cond [(equal? seed 0) chord];root
            [(equal? seed 1) (first (skore:pitch-num->pitch (+ 3 (skore:pitch-class->offset chord))))];third
            [(equal? seed 2)(first (skore:pitch-num->pitch (+ 7 (skore:pitch-class->offset chord))))];fifth
            ))))

(define (get-random-melodic-octave)
  (let ([seed (random)])
    (if (equal? 1 seed)
        5
        6)))

(define (get-random-melodic-duration)
  (let ([seed (random 8)])
    (match seed
      [0 1];whole note...
      [1 3/4]
      [2 2/3]
      [3 1/2]
      [4 3/8]
      [5 1/3]
      [6 1/4]
      [7 1/8])))

(define (change-chord? total-left less-this)
  (equal? 1 (- (floor total-left) (floor (- total-left less-this)))))

;look for patterns repeating based modulo 4 symbols
;e.g. C F G C C F should return G C
;C G C G C should return G C G 
;C a d F C d F G C a d F C d  should return G/NC C based on half cadence TODO depends on already knowing i'm in a key?
;list of symbols -> in
;list of symbols <- out
(define (predict-form changes length)
  (let ([pattern-lst (make-patterns changes length)])
    (get-first-pattern-to-match pattern-lst changes)))

(define (get-first-pattern-to-match pattern-lst changes)
  (if (empty? pattern-lst)
      #f
      (let ([pattern-to-match (make-tail-list-for-patterns changes (* (length (first pattern-lst)) (quotient (length changes) (length (first pattern-lst)))))])
        (if (empty? pattern-to-match)
            #f
            (match? pattern-to-match pattern-lst)))))

(define (match? pattern lst)
  (ormap (lambda (x) (matcher pattern x x)) lst))

(define (matcher pattern element untouched-element)
  (if (empty? pattern)
      untouched-element
      (if (equal? (first pattern) (first element))
          (matcher (rest pattern) (rest element) untouched-element)
          #f)))

(define (make-patterns lst size)
  (if (< size (length lst))
      (cons (take lst size) (make-patterns (make-tail-list-for-patterns lst size) size))
      '()))

(define (make-tail-list-for-patterns lst size)
  (if (< 0 size)
      (make-tail-list-for-patterns (rest lst) (- size 1))
      lst))


#|
switch-melodic-transformers :
This has a lot of potential for weird reactivity effects
chooses (? somehow) a transformation to use on a melody, applies that 
transformation in such a way that it makes sense for the next x measures. 
returns that melodic piece of structured data so that it can be written out to 
midi and heard.

melodic nuggets need to be provided by the analyser with some context to know where to use them in the form
|#
#;(define (switch-melodic-transformers))

#;(define (retrograde melody))

#;(define (invert melody))
#|
(define half-test (make-piece '(C) 4/4 '(C d F G C)))
(define half-test2 (make-piece '(C) 4/4 '(C d F G C d)))
(define half-test3 (make-piece '(C) 4/4 '(C d F G C d F)))

(define authentic-test (make-piece '(C) 4/4 '(C d G C C)))
(define authentic-test2 (make-piece '(C) 4/4 '(C d G C C d)))
(define authentic-test3 (make-piece '(C) 4/4 '(C d G C C d G)))

(define deceptive-test (make-piece '(C) 4/4 '(C d G a C)))
(define deceptive-test2 (make-piece '(C) 4/4 '(C d G a C d)))
(define deceptive-test3 (make-piece '(C) 4/4 '(C d G a C d G)))

(define tricky-piece (make-piece '(C D d e F f G g A a) 4/4 '(NC NC NC NC NC NC NC)))
|#

;(define nothing-piece (make-piece '(C) 4/4 '(C d G C)))
;(define something-piece (make-piece '(C) 4/4 '(C NC G C C)))

(provide perform make-music)