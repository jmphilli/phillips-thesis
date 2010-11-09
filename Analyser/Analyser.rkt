#lang Racket

(require "../Lib/utility.rkt")

#|
This works ok. Its too strict. I could have a color note rule or something. Modulation isn't handled either. 
It would be nice to know that in fact the song is in C then modulates to G but uses the same numerical (degree based) progression in G, repeating the same melodic motif // material in G

Fugues would be great test cases. 
Jazz for the color notes. 
|#

;TODO add melody analyzing content.

(define (analyse music piece)
  (analyse-piece music (piece-time-signature piece) piece))

(define (analyse-piece music-lst time-signature piece)
  (let* ([key (find-key-signature music-lst (piece-key-signature piece) time-signature)]
         [chords (find-chord-progression music-lst key time-signature)])
    (make-piece key time-signature chords)))

(define (find-chord-progression music key time-signature)
  (let ([chords (find-chords music time-signature)])
    (if (equal? 1 (length key))
        (chords-to-degrees chords (first key))
        chords)))

(define (find-chords music time-signature)
  (if (empty? music)
      '()
      (let ([chord (read-chord (read-beat music time-signature) time-signature)])
        (cons chord (find-chords (read-past-beat music time-signature) time-signature)))))

;given a measure of music. is it a chord? 
(define (read-chord note-lst time-signature)
  (match note-lst
    [(list ':=: _ ...) (make-chord-symbol (list-notes note-lst time-signature))]
    [(list (list 'note (list a b) c) ...) (make-chord-symbol (list-notes note-lst time-signature))]
    [(list ':+: _ ...) (make-chord-symbol (list-notes note-lst time-signature))]
    [_ 'NC]))

;really simple. really gross. 
(define (make-chord-symbol note-lst)
  (let* ([lst (remove-duplicates (flatten note-lst))]
         [tonic (find-tonic lst)]
         [major-third (major-third? tonic lst)]
         [dominant-seventh (dominant-seventh? tonic lst)])
    (if tonic
        (cond [(and major-third dominant-seventh) (match tonic
                                                    ['C 'C7]
                                                    ['Cs 'Cs7]
                                                    ['Df 'Df7]
                                                    ['D 'D7]
                                                    ['Ds 'Ds7]
                                                    ['Ef 'Ef7]
                                                    ['E 'E7]
                                                    ['F 'F7]
                                                    ['Fs 'Fs7]
                                                    ['Gf 'Gf7]
                                                    ['G 'G7]
                                                    ['Gs 'Gs7]
                                                    ['Af 'Af7]
                                                    ['A 'A7]
                                                    ['As 'As7]
                                                    ['Bf 'Bf7]
                                                    ['B 'B7])]
              [major-third tonic]
              [dominant-seventh (match tonic
                                  ['C 'c7]
                                  ['Cs 'cs7]
                                  ['Df 'df7]
                                  ['D 'd7]
                                  ['Ds 'ds7]
                                  ['Ef 'ef7]
                                  ['E 'e7]
                                  ['F 'f7]
                                  ['Fs 'fs7]
                                  ['Gf 'gf7]
                                  ['G 'g7]
                                  ['Gs 'gs7]
                                  ['Af 'af7]
                                  ['A 'a7]
                                  ['As 'as7]
                                  ['Bf 'bf7]
                                  ['B 'b7])]
              [else (match tonic
                      ['C 'c]
                      ['Cs 'cs]
                      ['Df 'df]
                      ['D 'd]
                      ['Ds 'ds]
                      ['Ef 'ef]
                      ['E 'e]
                      ['F 'f]
                      ['Fs 'fs]
                      ['Gf 'gf]
                      ['G 'g]
                      ['Gs 'gs]
                      ['Af 'af]
                      ['A 'a]
                      ['As 'as]
                      ['Bf 'bf]
                      ['B 'b])])
        'NC)))

(define (major-third? tonic note-lst)
  (degree-in-lst? MAJOR_THIRD tonic note-lst))

(define (dominant-seventh? tonic note-lst)
  (degree-in-lst? MINOR_SEVENTH tonic note-lst))

(define (degree-in-lst? degree tonic lst)
  (if tonic
      (ormap (lambda (x) (or (equal? degree (- (skore:pitch-class->offset x) (skore:pitch-class->offset tonic)))
                         (equal? degree (- (+ 12 (skore:pitch-class->offset x)) (skore:pitch-class->offset tonic))))) lst)
      #f))

(define (find-tonic note-lst)
  (if (empty? note-lst)
      #f
      (perfect-fifth? note-lst note-lst)))

(define (perfect-fifth? lst-a lst-b)
  (if (empty? lst-a)
      #f
      (let ([tonic (perfect-fifth?_ (first lst-a) lst-b)])
        (if (equal? #f tonic)
            (perfect-fifth? (rest lst-a) lst-b)
            tonic))))

(define (perfect-fifth?_ note lst)
  (if (empty? lst)
      #f
      (if (or (equal? PERFECT_FIFTH (- (skore:pitch-class->offset (first lst)) (skore:pitch-class->offset note)))
              (equal? PERFECT_FIFTH (- (+ 12 (skore:pitch-class->offset (first lst))) (skore:pitch-class->offset note))))
          note
          (perfect-fifth?_ note (rest lst)))))

(define (list-notes chord time-signature)
  (if (empty? chord)
      '()
      (cond [(list? (first chord)) (cond [(equal? 'note (first (first chord))) (cons (first (second (first chord))) (list-notes (rest chord) time-signature))]
                                         [(equal? ':=: (first (first chord))) (append (map (lambda (x) (list-notes x time-signature)) (rest (first chord))) (list-notes (rest chord) time-signature))]
                                         [(equal? ':+: (first (first chord))) 
                                          (let ([down-beat (read-beat (first chord) time-signature)])
                                            (if (equal? 'note (first down-beat))
                                                (cons (first (second down-beat)) (list-notes (rest chord) time-signature))
                                                (list-notes (rest chord) time-signature)))]
                                         [else (list-notes (rest chord) time-signature)])]
            [(equal? 'note (first chord)) (first (second chord))]
            [else (list-notes (rest chord) time-signature)])))

(define (find-key-signature music possible-keys time-signature)
  (if (empty? music)
      possible-keys
      (find-key-signature (read-past-beat music time-signature) (fit-in-key-signature? (read-beat music time-signature) possible-keys) time-signature)))

(define (fit-in-key-signature? music possible-keys)
  (if (empty? possible-keys)
      '()
      (cond [(match-key-to-music music (first possible-keys)) (cons (first possible-keys) (fit-in-key-signature? music (rest possible-keys)))]
            [else (fit-in-key-signature? music (rest possible-keys))])))

(define (match-key-to-music music key)
  (if (major-key-symbol? key)
      (music-in-key? music key MAJOR_LST)
      (music-in-key? music key MINOR_LST)))

#;(define (music-in-key? music key interval-lst)
  (cond 
    [(empty? music) #t]
    [(equal? 'rest (first music)) #t]
    [(equal? 'note (first music)) 
     (let ([interval (get-tonal-distance key (first (second music)))])
       (not (equal? #f (member interval interval-lst))))]
    [(or (equal? ':+: (first music))
         (equal? ':=: (first music)))
     (andmap (lambda (x) (music-in-key? x key interval-lst)) (rest music))]))

         
;         (let ([on-beat-notes (on-beat-note music)])
;                                            (if (equal? #f on-beat-notes)
;                                                #t
;                                                (if (not (equal? 'note (first on-beat-notes)))
;                                                    (andmap (lambda (x) (cond [(equal? #f x) #t]
;                                                                              [else (music-in-key? x key interval-lst)])) on-beat-notes)
;                                                    (music-in-key? on-beat-notes key interval-lst))))]))

(define (on-beat-note music)
    (cond [(equal? (first music) 'note) music]
        [(equal? (first music) 'rest) #f]
        [else #|list|#
         (if (equal? ':=: (first music))
             (map on-beat-note (rest music))
             (on-beat-note (second music)))]))

;time sig should be of the form '3:4 or something like that ... '3-4
(define (read-beat music time-signature)
  #;(let ([beats-per-measure (string->number (substring (symbol->string time-signature) 0 1))])
    (parse-music-duration music beats-per-music))
  (parse-music-duration music 1))

    ;(cond [(or (equal? 'note (first music))
    ;           (equal? ':=: (first music))) music]
    ;      [(equal? 'rest (first music)) '()]
    ;      [(equal? ':+: (first music)) (second music)])))

(define (read-past-beat music time-signature)
  #;(let ([beats-per-measure (string->number (substring (symbol->string time-signature) 0 1))])
    (parse-past-music-duration music beats-per-measure))
  (parse-past-music-duration music 1))
;  (cond [(or (equal? 'note (first music))
;             (equal? 'rest (first music))
;             (equal? ':=: (first music))) '()]
;        [(equal? ':+: (first music)) 
;         (if (< 2 (length music))
;             (cons ':+: (rest (rest music)))
;             '())#|The rest rest bit has to change for beat duration|#]
;        [else (rest music)]));this one is super questionable..


#|(define chord-test
  '(:+:
    (:=: (note (C 5) 2) (note (E 5) 2) (note (G 5) 2))
    (:=: (note (F 5) 2) (note (A 5) 2) (note (D 5) 2))
    (:=: (note (C 5) 2) (note (E 5) 2) (note (G 5) 2))
    (:=: (note (G 5) 2) (note (B 5) 2) (note (D 5) 2))))

(define chord-test-2
  '(:+:
    (:=: (note (Df 5) 1) (note (Af 5) 1) (note (F 5) 1))
    (rest 1)
    (:=: (note (Df 5) 1) (note (Af 5) 1) (note (F 5) 1))
    (rest 1)
    (:=: (:+: (note (Af 5) 2)) (note (F 5) 2) (note (C 5) 2))
    (:=: (:+: (note (Ef 5) 2)) (note (Gf 5) 2) (note (Bf 5) 2))
    (:=: (:+: (note (C 5) 1)) (note (Af 5) 1) (note (Ef 5) 1))
    (:=: (:+: (note (Af 5) 1)) (note (F 5) 1) (note (Df 5) 1))))

(define chord-test-3
  '(:+:
    (:=: (note (C 5) 5) (note (E 5) 5) (note (G 5) 5))
    (rest 1)
    (:=: (:+: (note (C 5) 5)) (note (E 5) 5) (note (G 5) 5) (note (Bf 5) 5))
    (:+: (rest 1))
    (:=: (:+: (note (C 5) 5)) (note (E 5) 5) (note (G 5) 5) (note (Bf 5) 5))
    (:+: (rest 1))
    (:=: (:+: (note (C 5) 5)) (note (E 5) 5) (note (G 5) 5) (note (Bf 5) 5))))

(define arp-test
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
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (C 3) 1/4)))
;CFGF CFGG CFGF CFGC

(define arp-test-2
  '(:+: 
    (note (E 3) 1/4) (note (Gs 3) 1/4) (note (B 3) 1/4) (note (E 3) 1/4)
    (note (E 3) 1/4) (note (Gs 3) 1/4) (note (B 3) 1/4) (note (E 3) 1/4)
    (note (A 3) 1/4) (note (C 3) 1/4) (note (E 3) 1/4) (note (C 3) 1/4)
    (note (D 3) 1/4) (note (A 3) 1/4) (note (F 3) 1/4) (note (A 3) 1/4)
    
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
    (note (G 3) 1/4) (note (B 3) 1/4) (note (D 3) 1/4) (note (B 3) 1/4)
   
    (note (E 3) 1/4) (note (Gs 3) 1/4) (note (B 3) 1/4) (note (E 3) 1/4)
    (note (E 3) 1/4) (note (Gs 3) 1/4) (note (B 3) 1/4) (note (E 3) 1/4)
    (note (A 3) 1/4) (note (C 3) 1/4) (note (E 3) 1/4) (note (C 3) 1/4)
    (note (D 3) 1/4) (note (A 3) 1/4) (note (F 3) 1/4) (note (A 3) 1/4)
    
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (E 3) 1/4) (note (D 3) 1/4) (note (Gs 3) 1/4)
    (note (A 3) 1/4) (note (C 3) 1/4) (note (E 3) 1/4) (note (A 3) 1/4)))

(define arp-test-3
  '(:+: 
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (Bf 3) 1/4) (note (D 3) 1/4) (note (F 3) 1/4) (note (D 3) 1/4)
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (Bf 3) 1/4) (note (D 3) 1/4) (note (F 3) 1/4)
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (Bf 3) 1/4)
    (note (Bf 3) 1/4) (note (D 3) 1/4) (note (F 3) 1/4) (note (Af 3) 1/4)
   
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (Bf 3) 1/4) (note (D 3) 1/4) (note (F 3) 1/4) (note (D 3) 1/4)
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (E 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)
    (note (G 3) 1/4) (note (Bf 3) 1/4) (note (D 3) 1/4) (note (F 3) 1/4)
    (note (C 3) 1/4) (note (E 3) 1/4) (note (G 3) 1/4) (note (Bf 3) 1/4)
    (note (F 3) 1/4) (note (A 3) 1/4) (note (C 3) 1/4) (note (A 3) 1/4)))|#

(provide analyse
         EMPTY_PIECE)
;define language. write parsing tool that will get you any element described via reg ex or something would hndle a lot of these problems with the parsing stuff