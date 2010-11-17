#lang Racket
(require "../Lib/utility.rkt"
         "user.rkt"
         ;"user2.rkt"
         )

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
      #;(printf "saved-piece-pats ~a~n" (saved-piece-patterns already-seen))
      upcoming-form)))


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
  (not (equal? #f (regexp-match #px".*N+.*" lst))))

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

(provide perform
         make-music)