#lang FrTime
(require "./Performer-Interface.rkt")

#|
This is the function that saves rhythm values and weights more heavily the most commonly seen rhythm values.
|#

#|A list of pairs. # of occurenes and rhythm value|#
(define rhythms (box '()))

#|Look at our graph of seen rhythms. which one has more notes and rhythm values like the ones we've seen? return it|#
(define (find-better-rhythm music-a music-b)
  (let ([lst-a (map (lambda (x) (make-new-list '() (get-rhythm x))) (make-note-and-rest-lst music-a))]
        [lst-b (map (lambda (x) (make-new-list '() (get-rhythm x))) (make-note-and-rest-lst music-b))])
    (cond [(and (has-notes? lst-a) (has-notes? lst-b)) (let ([val (compare-lists (unbox rhythms) lst-a lst-b)])
                                                         (if (equal? val lst-a)
                                                             music-a
                                                             music-b))]
          [(has-notes? lst-a) music-a]
          [else music-b])))

(define (has-notes? lst)
  (let ([note-lst (make-note-and-rest-lst lst)])
    (has-notes?_ note-lst)))

(define (has-notes?_ note-lst)
  (if (empty? note-lst)
      #f
      (or (equal? 'note (first note-lst)) (has-notes?_ (rest note-lst)))))

(define (compare-lists comp-lst lst-a lst-b)
  (let ([val-a (compare-list comp-lst lst-a)]
        [val-b (compare-list comp-lst lst-b)])
    (if (< val-a val-b)
        lst-b
        lst-a)))

(define (compare-list comp-lst lst)
  (if (empty? comp-lst)
      0
      (let ([val (has-rhythmic-value (car (first comp-lst)) lst)])
        (cond [(equal? #f val) (compare-list (rest comp-lst) lst)]
              [(+ (compare-list (rest comp-lst) lst) (car (first comp-lst)) val)]))))

(define (has-rhythmic-value r-val lst)
  (if (empty? lst)
      #f
      (cond [(equal? r-val (cdr (first lst))) (car (first lst))]
            [else (has-rhythmic-value r-val (rest lst))])))

#|Just grab each rhythm value and update our structure|#
(define (update-rhythms music)
  (map (lambda (x) (set-box! rhythms (make-new-list (unbox rhythms) (get-rhythm x)))) (make-note-and-rest-lst music)))

(define (make-note-and-rest-lst music)
  (if (empty? music)
      '()
      (cond [((equal? ':=: (first music))
              (equal? ':+: (first music))) (make-note-and-rest-lst (rest music))]
            [(list? (first music))
             (cond [(or (equal? 'rest (first (first music)))
                        (equal? 'note (first (first music)))) (cons (first music) (make-note-and-rest-lst (rest music)))]
                   [else (append (make-note-and-rest-lst (first music)) (make-note-and-rest-lst (rest music)))])]
            [else 'unsupported])))

(define (make-new-list lst rhythm-value)
  (if (empty? lst)
      (cons 1 rhythm-value)
      (cond [(equal? rhythm-value (cdr (first lst))) (cons (cons (+ 1 (car (first lst))) (cdr (first lst))) (rest lst))]
            [else (cons (first lst) (make-new-list (rest lst) rhythm-value))])))

(define (get-rhythm music)
  (cond [(equal? 'note (first music)) (third music)]
        [(equal? 'rest (first music)) (second music)]
        [else 'unsupported]))


#|**********************|#
(define (new-func_ . lst)
  (if (null? lst)
      '(rest 1)
      (find-better-rhythm (car lst) (apply new-func_ (cdr lst)))))

(define (music-value-function . lst)
  (let ([new-musical-fragment-to-play (new-func_ lst)])
    (begin
      (update-rhythms new-musical-fragment-to-play)
      new-musical-fragment-to-play)))
#|**********************|#

(provide perform
         update-music-signal
         init-performer
         music-value-function)