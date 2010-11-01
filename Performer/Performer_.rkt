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
  (let ([upcoming-form (find-patterns (piece-changes piece))])
      (begin
        (printf "~a~n" upcoming-form)
        upcoming-form)))

(define (make-music keys changes length-of-performance)
  (cond [(cadential? keys changes)
         (cond [(half-cadence? keys changes) (make-half-cadential-melody (make-tail-list-for-patterns changes length-of-performance))]
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

#|The point here, justin, is to not have to read the whole piece everytime.. find some patterns and move on.|# 

(define-struct saved-piece (length patterns))
(define already-seen 'a)
;look for patterns repeating based modulo 4 symbols
;e.g. C F G C C F should return G C
;C G C G C should return G C G 
;C a d F C d F G C a d F C d  should return G/NC C based on half cadence TODO depends on already knowing i'm in a key?
;list of symbols -> in
;list of symbols <- out
(define (find-patterns changes)
    (let ([spl (if (saved-piece? already-seen)
                   (if (< 10 (- (length changes) (saved-piece-length already-seen)))
                       (- (length changes) 10)
                       (saved-piece-length already-seen)) ;this seems wrong
                   0)])
    (begin
      (if (and (saved-piece? already-seen) (< 10 (length (saved-piece-patterns already-seen))))
          (let ([sp (make-patterns already-seen (list-tail changes spl))])
            (set! already-seen (make-saved-piece (saved-piece-length sp) (list-tail (saved-piece-patterns sp) 5))))
          (set! already-seen (make-patterns already-seen (list-tail changes spl))))
      (string->chord-symbol-list (get-pattern already-seen (list-tail changes spl))))))

(define (string->chord-symbol-list str)
  (if (string? str)
      (if (<= 1 (string-length str))
          (if (<= 2 (string-length str))
              (if (accidental-string? (substring str 0 2))
                  (cons (accidental-string->symbol (substring str 0 2)) (string->chord-symbol-list (substring str 2 (string-length str))))
                  (cons (string->symbol (substring str 0 1)) (string->chord-symbol-list (substring str 1 (string-length str)))))
              (cons (string->symbol (substring str 0 1)) (string->chord-symbol-list (substring str 1 (string-length str)))))
          '())
      '()))

;tested.
(define (get-pattern saved lst)
  (if (saved-piece? saved)
      (look-for-matching-pattern (saved-piece-patterns saved) (convert-list-to-string lst))
      (look-for-matching-pattern '() (convert-list-to-string lst))))

;; need to change this so it starts looking for patterns with the last two chords and works it way into bigger lists? TODO
(define (look-for-matching-pattern patterns lst)
  (if (empty? patterns)
      '()
      (if (matching-pattern?_string (first patterns) lst)
          (first patterns);TODO return this? or upcoming changes?
          (look-for-matching-pattern (rest patterns) lst))))

(define (matching-pattern?_string st str)
  (if (equal? st str)
      #t
      (if (< (string-length st) (string-length str))
          (equal? st (substring str 0 (string-length st)))
          (equal? (substring st 0 (string-length str)) str))))

(define (matching-pattern? test-pat comp-pat)
  (matching-pattern?_ (reverse test-pat) (reverse comp-pat))
  #;(if (and (empty? comp-pat) (empty? test-pat))
      #t
      (if (empty? comp-pat)
          #t
          (if (empty? test-pat)
              #f
              (if (equal? (first test-pat) (first comp-pat))
                  (matching-pattern? (rest test-pat) (rest comp-pat))
                  #f)))))

(define (matching-pattern?_ test comp)
  (if (empty? comp)
      #f
      (if (equal? (first test) (first comp))
          (matching-pattern?_test (rest test) (rest comp))
          (matching-pattern?_ test (rest comp)))))

(define (matching-pattern?_test test comp)
  (if (or (empty? test) (empty? comp))
      #t
      (if (equal? (first test) (first comp))
          (matching-pattern?_test (rest test) (rest comp))
          #f)))

(define (non-chord? lst)
  (equal? #f (regexp-match #px".*N+.*" lst)))

(define (remove-non-chords pats)
  (if (not (empty? pats))
      (if (non-chord? (first pats))
          (remove-non-chords (rest pats))
          (cons (first pats) (remove-non-chords (rest pats))))
      '()))

;length of 2 lst -- the lst must be repeated.
;looking for repeating forms
(define (make-patterns saved lst)
  (let ([new-patterns (remove-non-chords (remove-duplicates (find-all-patterns '() lst)))])
    (if (empty? new-patterns)
        saved
        ;add the new pattens to the list, add the number to the length
        (if (saved-piece? saved)
            #;(make-saved-piece (+ (saved-piece-length saved) (length lst)) (remove-duplicates (append new-patterns (saved-piece-patterns saved))))
            (make-saved-piece (length lst) (remove-duplicates (append new-patterns (saved-piece-patterns saved))))
            (make-saved-piece (length lst) new-patterns)))))

(define (convert-list-to-string lst)
  (foldr string-append "" (map (lambda (x) (if (equal? x 'NC)
                                               "N@"
                                               (if (accidental-symbol? x)
                                                   (accidental-symbol->string x)
                                                   (symbol->string x)))) lst)))

(define (accidental-string? x)
  (and (<= 2 (string-length x))
       (or (equal? "#" (substring x 1 2))
           (equal? "%" (substring x 1 2))
           (equal? "N@" (substring x 0 2)))))

(define (accidental-symbol? x)
  (or (equal? 'Cf x)
      (equal? 'cf x)
      (equal? 'Cs x)
      (equal? 'cs x)
      (equal? 'Df x)
      (equal? 'df x)
      (equal? 'Ds x)
      (equal? 'ds x)
      (equal? 'Ef x)
      (equal? 'ef x)
      (equal? 'Es x)
      (equal? 'es x)
      (equal? 'Ff x)
      (equal? 'ff x)
      (equal? 'Fs x)
      (equal? 'fs x)
      (equal? 'Gf x)
      (equal? 'gf x)
      (equal? 'Gs x)
      (equal? 'gs x)
      (equal? 'Af x)
      (equal? 'af x)
      (equal? 'As x)
      (equal? 'as x)
      (equal? 'Bf x)
      (equal? 'bf x)
      (equal? 'Bs x)
      (equal? 'bs x)))

(define (accidental-symbol->string x)
  (match x
    ['Cf "C%"]
    ['cf "c%"]
    ['Cs "C#"]
    ['cs "c#"]
    ['Df "D%"]
    ['df "d%"]
    ['Ds "D#"]
    ['ds "d#"]
    ['Ef "E%"]
    ['ef "e%"]
    ['Es "E#"]
    ['es "e#"]
    ['Ff "F%"]
    ['ff "f%"]
    ['Fs "F#"]
    ['fs "f#"]
    ['Gf "G%"]
    ['gf "g%"]
    ['Gs "G#"]
    ['gs "g#"]
    ['Af "A%"]
    ['af "a%"]
    ['As "A#"]
    ['as "a#"]
    ['Bf "B%"]
    ['bf "b%"]
    ['Bs "B#"]
    ['bs "b#"]
    [_ (raise 'error)]))

;i bet theres a sweet way to do this.. macros?
(define (accidental-string->symbol x)
  (match x
    ["C%" 'Cf]
    ["c%" 'cf]
    ["C#" 'Cs]
    ["c#" 'cs]
    ["D%" 'Df]
    ["d%" 'df]
    ["D#" 'Ds]
    ["d#" 'ds]
    ["E%" 'Ef]
    ["e%" 'ef]
    ["E#" 'Es]
    ["e#" 'es]
    ["F%" 'Ff]
    ["f%" 'ff]
    ["F#" 'Fs]
    ["f#" 'fs]
    ["G%" 'Gf]
    ["g%" 'gf]
    ["G#" 'Gs]
    ["g#" 'gs]
    ["A%" 'Af]
    ["a%" 'af]
    ["A#" 'As]
    ["a#" 'as]
    ["B%" 'Bf]
    ["b%" 'bf]
    ["B#" 'Bs]
    ["b#" 'bs]
    ["N@" 'NC]
    [_ (raise 'error)]))

(define (find-all-patterns pat lst)
  (let ([new-pat (regexp-match #px"(.*)\\1" (convert-list-to-string lst))])
    (cond [(empty? new-pat) pat]
          [else (append new-pat pat)]))
  #;(if (empty? lst)
      pat
      (let ([new-pat (find-patterns_lst lst)]) ;(regexp-match #px"(.*)\\1" "aabbaabbaabbaab")
        (cond [(empty? new-pat) (find-all-patterns pat (rest lst))]
              [else (find-all-patterns (append (find-patterns_lst lst) pat) (rest lst))]))))

;given this list, anything that repeats? take first 2 chords. do they repeat? 
(define (find-patterns_lst lst)
  (pattern-compare (list-taker lst 2)
                   (make-rest-of-lists lst)))

(define (pattern-compare heads tails)
  (if (empty? tails)
      '()
      (if (pattern-equal? (first heads) tails)
          (cons (first heads) (pattern-compare (rest heads) (rest tails)))
          (pattern-compare (rest heads) (rest tails)))))

(define (pattern-equal? hd tls)
  (ormap (lambda (x y) (matching-pattern? x y)) tls (list-repeater (length tls) hd)))

(define (list-repeater times lst)
  (if (equal? times 0)
      '()
      (cons lst (list-repeater (- times 1) lst))))

(define (list-taker lst grab)
  (if (< (length lst) grab)
      '()
      (cons (take lst grab) (list-taker lst (+ 1 grab)))))

(define (make-rest-of-lists lst)
  (if (and (not (empty? (rest lst)))
           (not (empty? (rest (rest lst)))))
      (make-rest-of-lists_recur (rest (rest lst)))
      '()))

(define (make-rest-of-lists_recur lst)
  (if (empty? lst)
      '()
      (cons lst (make-rest-of-lists_recur (rest lst)))))

#|***************|#
(define (make-tail-list-for-patterns lst size)
  (if (< 0 size)
      (make-tail-list-for-patterns (rest lst) (- size 1))
      lst))

(provide perform make-music)