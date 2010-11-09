
#lang FrTime
(require "./Performer-Interface.rkt")

#|
This is the function that saves rhythm values and weights more heavily the most commonly seen rhythm values.
|#

#|A list of pairs. # of occurenes and rhythm value|#
(define rhythms (box '()))

#|Look at our graph of seen rhythms. which one has more notes and rhythm values like the ones we've seen? return it|#
(define (find-better-rhythm music-a music-b)
  (let ([lst-a (first (map (lambda (x) (make-new-list '() (get-rhythm x))) (make-note-and-rest-lst music-a)))]
        [lst-b (first (map (lambda (x) (make-new-list '() (get-rhythm x))) (make-note-and-rest-lst music-b)))])
    (cond [(and (has-notes? music-a) (has-notes? music-b)) (let ([val (compare-lists (unbox rhythms) lst-a lst-b)])
                                                             (if (equal? val lst-a)
                                                                 music-a
                                                                 music-b))]
          [(has-notes? music-a) music-a]
          [else music-b])))

(define (has-notes? lst)
  ;(let ([note-lst (make-note-and-rest-lst lst)])
    (has-notes?_ lst))

(define (has-notes?_ note-lst)
  (if (empty? note-lst)
      #f
      (or (equal? 'note (first note-lst)) (if (list? (first note-lst))
                                                     (or (has-notes?_ (rest note-lst)) (has-notes?_ (first note-lst)))
                                                     (has-notes?_ (rest note-lst))))))

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
  (let* ([lst (first (map (lambda (x) (make-new-list '() (get-rhythm x))) (make-note-and-rest-lst music)))]
         [result (add-two-lists (unbox rhythms) lst)])
    ;(printf "result ~a~n" result)
    ;(if (list? result)
    (set-box! rhythms result)))
;   (set-box! rhythms (list result)))))

(define (add-two-lists l lst)
  (if (empty? lst)
      ;(if (pair? (first l))
      l
          ;(list l))
      (if (equal? 1 (car (first lst)))
          (add-two-lists (make-new-list l (cdr (first lst))) (rest lst))
          (add-two-lists (make-new-list l (cdr (first lst))) (cons (cons (- (car (first lst)) 1) (cdr (first lst))) (rest lst))))))

(define (make-note-and-rest-lst music)
  (if (empty? music)
      '()
      (cond [(or (equal? ':=: (first music))
                 (equal? ':+: (first music))) (make-note-and-rest-lst (rest music))]
            [(or (equal? 'rest (first music))
                 (equal? 'note (first music)))
             (list music)]
            [(list? (first music))
             (cond [(or (equal? 'rest (first (first music)))
                        (equal? 'note (first (first music)))) (cons (first music) (make-note-and-rest-lst (rest music)))]
                   [else (append (make-note-and-rest-lst (first music)) (make-note-and-rest-lst (rest music)))])]
            [else (begin
                    (printf "~a~n" music)
                    (raise 'unsupported))])))

(define (make-new-list lst rhythm-value)
  (if (empty? lst)
      (list (cons 1 rhythm-value))
      (cond [(equal? rhythm-value (cdr (first lst))) (cons (cons (+ 1 (car (first lst))) rhythm-value) (rest lst))]
            [else (cons (first lst) (make-new-list (rest lst) rhythm-value))])))

(define (get-rhythm music)
  (cond [(equal? 'note (first music)) (third music)]
        [(equal? 'rest (first music)) (second music)]
        [else 'unsupported]))


#|**********************|#
(define (new-func_ . lst)
  (if (or (null? lst) (empty? lst))
      '(rest 1)
      (find-better-rhythm (first lst) (apply new-func_ (rest lst)))))

(define (music-value-function . lst)
  (let ([new-musical-fragment-to-play (new-func_ (first (first lst)))])
    (begin
      (printf "playing ~a~n" new-musical-fragment-to-play)
      (update-rhythms new-musical-fragment-to-play)
      (thread (lambda () (skore:play-music new-musical-fragment-to-play))))))
#|**********************|#

(provide perform
         update-music-signal
         init-performer
         music-value-function)