#lang Racket
(require (prefix-in skore: (lib "midi/user.ss")))

(define UNISON 0)
(define MINOR_SECOND 1)
(define MAJOR_SECOND 2)
(define MINOR_THIRD 3)
(define MAJOR_THIRD 4)
(define PERFECT_FOURTH 5)
(define DIMINISHED_FIFTH 6)
(define PERFECT_FIFTH 7)
(define AUGMENTED_FIFTH 8)
(define MINOR_SIXTH 8)
(define MAJOR_SIXTH 9)
(define DIMINISHED_SEVENTH 9)
(define MINOR_SEVENTH 10)
(define MAJOR_SEVENTH 11)

(define ALL_KEYS '(C c D d E e F f G g A a B b Cs cs Df df Ds ds Ef ef Fs fs Gf gf As as Bf bf))

;todo add melody logic

;without-any-color-notes ... (see-> super lame.)
#|(define MAJOR_LST (list UNISON MAJOR_SECOND MAJOR_THIRD PERFECT_FOURTH PERFECT_FIFTH MAJOR_SIXTH MAJOR_SEVENTH))
(define MINOR_LST (list UNISON MAJOR_SECOND MINOR_THIRD PERFECT_FOURTH PERFECT_FIFTH MINOR_SIXTH MINOR_SEVENTH))|#

;with color notes ...
(define MAJOR_LST (list UNISON MAJOR_SECOND MINOR_THIRD MAJOR_THIRD PERFECT_FOURTH PERFECT_FIFTH MAJOR_SIXTH MINOR_SEVENTH MAJOR_SEVENTH))
(define MINOR_LST (list UNISON MAJOR_SECOND MINOR_THIRD PERFECT_FOURTH PERFECT_FIFTH MINOR_SIXTH MAJOR_SIXTH MINOR_SEVENTH MAJOR_SEVENTH))

(define-struct piece (key-signature time-signature changes))
(define EMPTY_PIECE (make-piece ALL_KEYS '4:4 '()))

(define (get-musical-duration music)
  
    (if (not (list? music))
        (begin
          (printf "stopping ~n~a~n" music)
          (exit))
     (cond [(empty? music) 0]
        [(equal? ':+: (first music)) (get-musical-duration_sequenece (rest music))]
        [(equal? ':=: (first music)) (get-musical-duration_parallel (rest music))]
        [(equal? 'note (first music)) (note-in-lst-duration music)]
        [(equal? 'rest (first music)) (rest-in-lst-duration music)]
        [(and (list? music)
              (or (note-in-lst? (first music))
                  (rest-in-lst? (first music)))) (get-musical-duration (first music))]
        [else 0])))

(define (get-musical-duration_sequenece music)
  (cond [(empty? music) 0]
        [(note-in-lst? (first music)) (+ (note-in-lst-duration (first music)) (get-musical-duration_sequenece (rest music)))]
        [(rest-in-lst? (first music)) (+ (rest-in-lst-duration (first music)) (get-musical-duration_sequenece (rest music)))]
        [else ;its a sub-list
         (+ (get-musical-duration (first music)) (get-musical-duration_sequenece (rest music)))]))

(define (get-musical-duration_parallel music)
  (cond [(empty? music) 0]
        [(note-in-lst? (first music)) (max (note-in-lst-duration (first music)) (get-musical-duration_parallel (rest music)))]
        [(rest-in-lst? (first music)) (max (rest-in-lst-duration (first music)) (get-musical-duration_parallel (rest music)))]
        [else (max (get-musical-duration (first music)) (get-musical-duration_parallel (rest music)))]))

(define (seventh-chord? chord)
  (char-numeric? (string-ref (symbol->string chord) (- (string-length (symbol->string chord)) 1))))

(define (peel-off-seventh chord-sym)
  (string->symbol (substring (symbol->string chord-sym) 0 (- (string-length (symbol->string chord-sym)) 1))))

(define (note-in-lst-duration note)
  (third note))

(define (rest-in-lst-duration rest)
  (second rest))

(define (note-in-lst? thing)
  (if (list? thing)
      (equal? 'note (first thing))
      #f))

(define (rest-in-lst? thing)
  (if (list? thing)
      (equal? 'rest (first thing))
      #f))

;lst - '(C d e F G a b)
;key - 'C
;result - '(I ii iii IV V vi vii)
(define (chords-to-degrees chord-lst key)
  (if (empty? chord-lst)
      '()
      (cons (chord-to-degree (first chord-lst) key) (chords-to-degrees (rest chord-lst) key))))

(define (chord-to-degree chord key)
  (match chord
    ['NC 'NC]
    [_ (if (not (seventh-chord? chord))
           (let ([interval (get-tonal-distance key chord)])
             (cond [(major-key-symbol? key)#|In a major key|# (cond [(major-key-symbol? chord) (match interval
                                                                                                 [0 'I]
                                                                                                 [1 'II-b]
                                                                                                 [2 'II]
                                                                                                 [3 'III-b]
                                                                                                 [4 'III]
                                                                                                 [5 'IV]
                                                                                                 [6 'NC]
                                                                                                 [7 'V]
                                                                                                 [8 'VI-b]
                                                                                                 [9 'VI]
                                                                                                 [10 'VII-b]
                                                                                                 [11 'VII])]
                                                                    [else #|Minor chord|# (match interval
                                                                                            [0 'i]
                                                                                            [1 'ii-b]
                                                                                            [2 'ii]
                                                                                            [3 'iii-b]
                                                                                            [4 'iii]
                                                                                            [5 'iv]
                                                                                            [6 'NC]
                                                                                            [7 'v]
                                                                                            [8 'vi-b]
                                                                                            [9 'vi]
                                                                                            [10 'vii-b]
                                                                                            [11 'vii])])]
                   [else #|In a minor key|#(cond [(major-key-symbol? chord) (match interval
                                                                              [0 'I]
                                                                              [1 'II-b]
                                                                              [2 'II]
                                                                              [3 'III]
                                                                              [4 'III-s]
                                                                              [5 'IV]
                                                                              [6 'NC]
                                                                              [7 'V]
                                                                              [8 'VI]
                                                                              [9 'VI-s]
                                                                              [10 'VII]
                                                                              [11 'VII-s])]
                                                 [else #|Minor chord|# (match interval
                                                                         [0 'i]
                                                                         [1 'ii-b]
                                                                         [2 'ii]
                                                                         [3 'iii]
                                                                         [4 'iii-s]
                                                                         [5 'iv]
                                                                         [6 'NC]
                                                                         [7 'v]
                                                                         [8 'vi]
                                                                         [9 'vi-s]
                                                                         [10 'vii]
                                                                         [11 'vii-s])])]))
           (let ([interval (get-tonal-distance key (peel-off-seventh chord))])
             (cond [(major-key-symbol? key)#|In a major key|# (cond [(major-key-symbol? chord) (match interval
                                                                                                 [0 'I7]
                                                                                                 [1 'II-b7]
                                                                                                 [2 'II7]
                                                                                                 [3 'III-b7]
                                                                                                 [4 'III7]
                                                                                                 [5 'IV7]
                                                                                                 [6 'NC]
                                                                                                 [7 'V7]
                                                                                                 [8 'VI-b7]
                                                                                                 [9 'VI7]
                                                                                                 [10 'VII-b7]
                                                                                                 [11 'VII7])]
                                                                    [else #|Minor chord|# (match interval
                                                                                            [0 'i7]
                                                                                            [1 'ii-b7]
                                                                                            [2 'ii7]
                                                                                            [3 'iii-b7]
                                                                                            [4 'iii7]
                                                                                            [5 'iv7]
                                                                                            [6 'NC]
                                                                                            [7 'v7]
                                                                                            [8 'vi-b7]
                                                                                            [9 'vi7]
                                                                                            [10 'vii-b7]
                                                                                            [11 'vii7])])]
                   [else #|In a minor key|#(cond [(major-key-symbol? chord) (match interval
                                                                              [0 'I7]
                                                                              [1 'II-b7]
                                                                              [2 'II7]
                                                                              [3 'III7]
                                                                              [4 'III-s7]
                                                                              [5 'IV7]
                                                                              [6 'NC]
                                                                              [7 'V7]
                                                                              [8 'VI7]
                                                                              [9 'VI-s7]
                                                                              [10 'VII7]
                                                                              [11 'VII-s7])]
                                                 [else #|Minor chord|# (match interval
                                                                         [0 'i7]
                                                                         [1 'ii-b7]
                                                                         [2 'ii7]
                                                                         [3 'iii7]
                                                                         [4 'iii-s7]
                                                                         [5 'iv7]
                                                                         [6 'NC]
                                                                         [7 'v7]
                                                                         [8 'vi7]
                                                                         [9 'vi-s7]
                                                                         [10 'vii7]
                                                                         [11 'vii-s7])])])))]))

(define (get-tonal-distance note offset)
  (let ([distance (- (skore:pitch-class->offset offset) (skore:pitch-class->offset note))])
    (if (<= 0 distance)
        distance
        (+ 12 distance))))

(define (major-key-symbol? sym)
  (char-upper-case? (string-ref (symbol->string sym) 0)))



(define (get-music-for-duration music duration)
  (parse-music-duration music duration))
(define (get-music-after-duration music duration)
  (parse-past-music-duration music duration))

;;(:+: (note (B 7) 4.0) (:+: (rest 0.125)) (note (B 7) 4))

;((note (B 7) 4))
;this gets called somewhere and breaks
(define (parse-music-duration music duration)
  (if (empty? music)
      '()
      (match (first music)
        [':+: (let ([val (parse-music-duration-sequence (rest music) duration)])
                (cond [(empty? val) val]
                      [else (cons (first music) val)]))]
        [':=: (let ([val (parse-music-duration-parallel (rest music) duration)])
                (cond [(empty? val) val]
                      [else (cons (first music) val)]))]
        [else (begin
                (printf "~a~n" music)
                (error 'what-is-this))]
        #;[_ (parse-music-duration (first music) duration)])))

(define (parse-music-duration-sequence note-lst duration)
  (if (empty? note-lst)
      '()
      (match (first note-lst)
        [(list 'note (list a b) note-dur) (if (<= duration note-dur)
                                              (list (first note-lst)) ;; or return '()
                                              (cons (first note-lst) (parse-music-duration-sequence (rest note-lst) (- duration note-dur))))]
        [(list 'rest rest-dur) (if (<= duration rest-dur)
                                   (list (first note-lst)) ;; or return '()
                                   (cons (first note-lst) (parse-music-duration-sequence (rest note-lst) (- duration rest-dur))))]
        [':=: (list (cons ':=: (parse-music-duration-parallel (rest note-lst) duration)))]
        [':+: (list (cons ':+: (parse-music-duration-sequence (rest note-lst) duration)))]
        [_ (if (<= duration (get-musical-duration (first note-lst)))
               (list (parse-music-duration (first note-lst) duration))
               (list (append (parse-music-duration (first note-lst) duration) (list (parse-music-duration (cons ':+: (rest note-lst)) (- duration (get-musical-duration (first note-lst))))))))])))

(define (parse-music-duration-parallel note-lst duration)
  (map (lambda (x)
         (match x
           [(list 'note (list a b) note-dur) x]
           [(list 'rest rest-duration) x]
           [(list ':+: _ ...) (parse-music-duration-sequence (rest x) duration)]
           [(list ':=: _ ...) (parse-music-duration-parallel (rest x) duration)]
           [_ (parse-music-duration-parallel x duration)])) note-lst))
;(parse-music-duration-parallel '((note (C 2) 1) (note (C 2) 1) (:+: (note (C 2) 5) (note (E 2) 1))) .5)

;returns the same list you passed minus as much of the duration you passed with information loss
(define (parse-past-music-duration music duration)
  (if (or (empty? music) (<= duration 0))
      music
      (match (first music)
        [':+: (if (< 1 (length music))
                  (match (second music)
                    [(list 'note (list a b) note-duration) (if (< duration note-duration)
                                                   (if (empty? (rest (rest music)))
                                                       `(:+: (note (,a ,b) ,(- note-duration duration)))
                                                       (append `(:+: (note (,a ,b) ,(- note-duration duration))) (rest (rest music))))
                                                   (if (empty? (rest (rest music)))
                                                       '()
                                                       (parse-past-music-duration (cons ':+: (rest (rest music))) (- duration note-duration))))]
                    [(list 'rest rest-duration) (if (< duration rest-duration)
                                                    (if (empty? (rest (rest music)))
                                                       `(:+: (rest ,(- rest-duration duration)))
                                                       (append `(:+: (rest ,(- rest-duration duration))) (rest (rest music))))
                                                    (if (empty? (rest (rest music)))
                                                        '()
                                                        (parse-past-music-duration (cons ':+: (rest (rest music))) (- duration rest-duration))))]
                    [_ 
                     (if (< duration (get-musical-duration (second music)))
                         (cons ':+: (append (list (parse-past-music-duration (second music) duration)) (rest (rest music))))
                         (if (empty? (rest (rest music)))
                             '()
                             (parse-past-music-duration (cons ':+: (rest (rest music))) (- duration (get-musical-duration (second music))))))])
                  '()#|there is nothing left, you read past the entire piece|#)]
        [':=: (letrec ([func (lambda (x) (match x
                                           [(list 'note (list a b) note-duration) (if (< duration note-duration)
                                                                                      `(note (,a ,b) ,(- note-duration duration))
                                                                                      'removePlease)]
                                           [(list 'rest rest-duration) (if (< duration rest-duration)
                                                                           `(rest ,(rest-duration duration))
                                                                           'removePlease)]
                                           [_ 
                                            (if (< duration (get-musical-duration x))
                                                (parse-past-music-duration x duration)
                                                'removePlease)]))])
                (if (< 1 (length music))
                    (let ([filtered-lst (filter music? (map func (rest music)))])
                      (if (empty? filtered-lst)
                          '()
                          (cons ':=: filtered-lst)))
                    '()#|there is nothing left, you read past the entire piece|#))]
        [_ (parse-past-music-duration (first music) duration)])))

#|
;make a piece of music that is duration long. simply split if duration is too great.
(define (get-music-for-duration music dur)
    (cond [(or (empty? music) (equal? 0 dur)) '()]
        [(equal? dur (get-musical-duration music)) music]
        [(< (get-musical-duration music) dur) (append (append '(:+:) (list music)) (list `(rest ,(- dur (get-musical-duration music)))))]
        [(equal? 'note (first music)) (cond [(< (note-in-lst-duration music) dur) music]
                                            [else `(rest ,dur)])]
        [(equal? 'rest (first music)) (cond [(< (rest-in-lst-duration music) dur) music]
                                            [else `(rest ,dur)])]
        [(equal? ':+: (first music)) (cond [(and (not (empty? (rest (rest music)))) (<= (get-musical-duration (second music)) dur))
                                            (let ([rst-music (get-music-for-duration (cons ':+: (rest (rest music))) (- dur (get-musical-duration (second music))))])
                                              (if (empty? rst-music)
                                                  (cons ':+: (cons (second music) rst-music))
                                                  (cons ':+: (cons (second music) (list rst-music)))))]
                                           [else `(rest ,dur)])]
        #|TODO this is totes broken. need a separate func like the parallel thing above to handle getting the duration of the parallel music through|#
        [(equal? ':=: (first music)) (cond [(and (not (empty? (rest (rest music)))) (<= (get-musical-duration (second music)) dur))
                                            (let ([rst-music (get-music-for-duration (cons ':=: (rest (rest music))) dur)])
                                              (if (empty? rst-music)
                                                  (cons ':=: (cons (second music) rst-music))
                                                  (cons ':=: (cons (second music) (list rst-music)))))]
                                           [else `(rest ,dur)])]
        [else `(rest ,dur)]))

;make a piece of music that is the same duration minus exactly one measure. if there is an overlap, split it (if its a rest you can put another rest. if its a note you lose it)
(define (get-music-after-duration music dur)
  (cond [(or (empty? music) (equal? 0 dur) (< (get-musical-duration music) dur) (equal? dur (get-musical-duration music))) '()]
        
        [(equal? ':+: (first music)) (cond [(and (not (empty? (rest (rest music)))) (< (get-musical-duration (second music)) dur))
                                            (get-music-after-duration (cons ':+: (rest (rest music))) (- dur (get-musical-duration (second music))))]
                                           [(and (not (empty? (rest (rest music)))) (> (get-musical-duration (second music)) dur))
                                            (cons ':+: (rest (rest music)))]
                                           [(and (not (empty? (rest (rest music)))) (equal? (get-musical-duration (second music)) dur))
                                            (cons ':+: (rest (rest music)))]
                                           [else '()])]
        [(equal? ':=: (first music)) (cond [(and (not (empty? (rest (rest music)))) (< (get-musical-duration (second music)) dur))
                                            (get-music-after-duration (cons ':=: (rest (rest music))) dur)]
                                            [(and (not (empty? (rest (rest music)))) (> (get-musical-duration (second music)) dur))
                                             '()]
                                            [(and (not (empty? (rest (rest music)))) (equal? (get-musical-duration (second music)) dur))
                                            (rest (rest music))]
                                           [else '()])]
        [else '()]))
|#

(define (music? lst)
  (match lst
    [(list 'note (list a b) c) #t]
    [(list 'rest dur) #t]
    [(list ':+: _ ...) #t]
    [(list ':=: _ ...) #t]
    ['removePlease #f]))

(define (music-in-key? music key interval-lst)
  (cond 
    [(empty? music) #t]
    [(equal? 'rest (first music)) #t]
    [(equal? 'note (first music)) 
     (let ([interval (get-tonal-distance key (first (second music)))])
       (not (equal? #f (member interval interval-lst))))]
    [(or (equal? ':+: (first music))
         (equal? ':=: (first music)))
     (andmap (lambda (x) (music-in-key? x key interval-lst)) (rest music))]))

(provide get-musical-duration
         get-musical-duration_parallel
         get-musical-duration_sequenece
         note-in-lst?
         rest-in-lst?
         note-in-lst-duration
         rest-in-lst-duration
         parse-music-duration
         parse-past-music-duration
         get-music-for-duration
         get-music-after-duration
         peel-off-seventh
         seventh-chord?
         chords-to-degrees
         major-key-symbol?
         get-tonal-distance
         (struct-out piece)
         EMPTY_PIECE
         ALL_KEYS
         MAJOR_LST
         MINOR_LST
         UNISON
         MINOR_SECOND
         MAJOR_SECOND
         MINOR_THIRD
         MAJOR_THIRD
         PERFECT_FOURTH
         DIMINISHED_FIFTH
         PERFECT_FIFTH
         AUGMENTED_FIFTH
         MINOR_SIXTH
         MAJOR_SIXTH
         DIMINISHED_SEVENTH
         MINOR_SEVENTH
         MAJOR_SEVENTH
         skore:pitch-num->pitch
         skore:pitch-class->offset
         skore:offset->pitch-class
         skore:play-music
         skore:pitch->pitch-num
         skore:rest
         box
         unbox
         set-box!
         music-in-key?
         skore:set-tempo-and-whole-note-len
         (struct-out skore:midi-note-on)
         (struct-out skore:midi-note-off))

#|(define arp-test
  '(:+: 
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
   
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (C 3) 1/4)))|#