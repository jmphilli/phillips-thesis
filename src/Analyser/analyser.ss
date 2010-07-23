#lang scheme

(require (lib "midi/user.ss")
         (lib "midi/midi-layer.ss")
         "Parser/parser.ss")
;         (only-in scheme/base remove-duplicates)) why doesn't this work?!?!

;(require-for-syntax (only-in scheme/base remove-duplicates))

#|what does the parsed music look like???
what is the object that i'm passing around basically.
the music object comes from the parser
the analyser makes a new object that tells things about the music, but has no actual music in it (maybe..)
the performer makes new music objects to be transformed back into midi and then performed.

midi -> music -> piece -> music -> midi
|#

(define (analyse parsed-midi)
  (map midi->notes parsed-midi))

#;(define (analyse parsed-midi-stream))

#;(define (find-key-sig performer-streams)
  (key-sig-lst-update (eliminate-irrelevant-values performer-streams)))

#;(define (key-sig-lst-update new-values)
  )

#;(define (eliminate-irrelevant-values performer-streams)
  )



; test data (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1)))
;(play-music (:+: (:+: (:+: (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))) (trans 5 (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))))) (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))))
                   ;(:+: (:+: (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))) (trans 5 (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))))) (:=: (note '(C 5) 1) (:=: (note '(E 5) 1) (note '(G 5) 1))))))
;; i couldn't get remove-duplicates to import for some stupid reason, this ended up being faster to figure out.
(define (list-unique lst)
    (cond [(empty? lst) '()]
          [else (if (ormap (lambda (x) (eq? (first lst) x)) (rest lst))
                    (list-unique (rest lst))
                    (cons (first lst) (list-unique (rest lst))))]))

(define (make-decider-list lst)
  (list (abs (- (second lst) (first lst)))
              (abs (- (third lst) (first lst)))))

(define major-list
  '((4 7) 
    (3 8)
    (5 9)))

(define minor-list
  '((3 7) 
    (4 9)
    (5 8)))

(define (major-decider lst)
    (if (list? (member (make-decider-list (sort lst <)) major-list))
      #t
      #f))

(define (minor-decider lst)
  (if (list? (member (make-decider-list (sort lst <)) minor-list))
      #t
      #f))

#;(define (major-decider lst)
  (if (eq? (length lst) 3)
      (cond [(and (eq? (- (second lst) (first lst)) 4)
                  (eq? (- (third lst) (first lst)) 7)) #t];root
            [(and (eq? (- (second lst) (first lst)) 3)
                  (eq? (- (third lst) (first lst)) 8)) #t];1st inversion
            [(and (eq? (- (second lst) (first lst)) 5)
                  (eq? (- (third lst) (first lst)) 9)) #t];2nd inversion
            [else (list (- (second lst) (first lst))
                        (- (third lst) (first lst)))])
      #f))

#;(define (minor-decider lst)
  (if (eq? (length lst) 3)
      (cond [(and (eq? (- (second lst) (first lst)) 3)
                  (eq? (- (third lst) (first lst)) 7)) #t];root
            [(and (eq? (- (second lst) (first lst)) 4)
                  (eq? (- (third lst) (first lst)) 9)) #t];1st inversion
            [(and (eq? (- (second lst) (first lst)) 5)
                  (eq? (- (third lst) (first lst)) 8)) #t];2nd inversion
            [else (list (- (second lst) (first lst))
                        (- (third lst) (first lst)))])
      #f))

(define (major-chord? music)
  (major-decider (map (lambda (x) (modulo x 12)) (list-unique (map nnote-pitch (music->notes music))))))

(define (minor-chord? music)
  (minor-decider (map (lambda (x) (modulo x 12)) (list-unique (map nnote-pitch (music->notes music))))))

(define (tester expected actual)
  (if (eq? expected actual)
      (printf "passed test\n")
      (printf "failed\n")))

;; tests
#|
(tester #t (major-chord? (:=: (note '(C 5) 1) (:=: (note '(E 6) 1) (note '(G 4) 1)))))
(tester #t (major-chord? (:=: (note '(Af 5) 1) (:=: (note '(Ef 6) 1) (note '(C 4) 1)))))
(tester #t (major-chord? (:=: (note '(C 5) 1) (:=: (note '(F 6) 1) (note '(A 4) 1)))))

(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(Ef 4) 1) (note '(G 5) 1)))))
(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(G 4) 1) (note '(Ef 5) 1)))))
(tester #t (minor-chord? (:=: (note '(Ef 6) 1) (:=: (note '(G 4) 1) (note '(C 5) 1)))))
(tester #t (minor-chord? (:=: (note '(Ef 6) 1) (:=: (note '(C 4) 1) (note '(G 5) 1)))))
(tester #t (minor-chord? (:=: (note '(G 6) 1) (:=: (note '(C 4) 1) (note '(Ef 5) 1)))))
(tester #t (minor-chord? (:=: (note '(G 6) 1) (:=: (note '(Ef 4) 1) (note '(C 5) 1)))))
(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(A 4) 1) (note '(E 5) 1)))))
(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(E 4) 1) (note '(A 5) 1)))))
(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(F 4) 1) (note '(Af 5) 1)))))
(tester #t (minor-chord? (:=: (note '(C 6) 1) (:=: (note '(Af 4) 1) (note '(F 5) 1)))))|#