#lang Racket

(require 
 "../Lib/utility.rkt")

(define midi-note-on-flag #x90)
(define midi-note-off-flag #x80)

(define midi-lst (box '()))
(define music-lst (box '()))
(define starting-time (box 0))
(define absolute-start (box (expt 10 6)))

(define (reset)
  (begin
    (set-box! midi-lst '())
    (set-box! music-lst '())
    (set-box! starting-time 0)
    (set-box! absolute-start (expt 10 6))))

;HardwareLink/Connect.ss provides a function read-midi-packet which returns the 'delta-time' (although i feel its been bastardized...) and the midi data
; ((delta-time-value midi-data-length (midi-command-and-channel note-value velocity)) ...) although i've never seen a list longer than length 1
;parse - returns a 'piece' of music if it can. a list of midi data is turned into haskore // skore and an 'unmatched' list. 

;eventually provide other interfaces other than just midi... but for now ...
(define (parse stream tempo)
  (cond [(not (empty? stream)) (let ([val (parse-stream (remove-voids (list (parse-stream_midi stream))) tempo)])
                                 (begin
                                   (printf "~a~n" val)
                                   val))]
        [else '()]))

;concatenates the new music stuff (notes chords, whatever its been handed) to the old music.
; the old music is assumed to start at abs-time == 0
; the new music is assumed to be concatenated to itself appropriately/correctly

;find the place that the new music belongs [via abs-time included in music (abs-start-time (music))
;put it there, set box, return unbox
(define (music-concat music tempo)
  (if (empty? (unbox music-lst))
      (begin
        (set-box! music-lst `(:+: ,(first (rest music))))
        (unbox music-lst))
      #;(cond [(or (equal? (first music) (unbox absolute-start)) (deviation (first music) (unbox absolute-start) EPSILON))
             (begin
               (set-box! music-lst `(:+: ,(first (rest music))))
               (unbox music-lst))]
            [(< (unbox absolute-start) (first music)) 
             (begin
               (set-box! music-lst (append `(:+: ,(make-rest (unbox absolute-start) (first music) tempo)) (rest music)))
               (unbox music-lst))]
            [else (raise 'restCreationError)])
      (let ([new-piece (concatenate-musics (unbox music-lst) (unbox absolute-start) (rest music) (convert-to-bps (first music) tempo) tempo)])
        (begin
          (set-box! music-lst new-piece)
          (unbox music-lst)))))

(define (remove-voids lst)
  (if (empty? lst)
      '()
      (if (void? (first lst))
          (remove-voids (rest lst))
          (cons (first lst) (remove-voids (rest lst))))))

;stream is a list
(define (parse-stream stream tempo)
  (if (<= 1 (length (unbox midi-lst)))
      (let* ([pairs-and-unmatched (let ([vals (unbox midi-lst)])
                                    (pair-notes (append vals stream) tempo))]
             [pairs (all-but-last pairs-and-unmatched)]
             [unmatched (set-box! midi-lst (remove-voids (last pairs-and-unmatched)))])
          (cond 
            [(not (empty? pairs)) (music-concat (paired-notes->music pairs tempo) tempo)]
            [else (unbox music-lst)]))
      (begin
        (set-box! midi-lst (append (unbox midi-lst) (remove-voids stream)))
        (unbox music-lst))))

;paired-lst looks like ((start-time-of-this-note (duration midinote))...)
(define (paired-notes->music paired-lst tempo)
  (let ([start-time (first (first paired-lst))])
    (cons start-time (list (data->music (map (lambda (x) (list (first x) (first (second x)) (skore:pitch-num->pitch (skore:midi-note-on-pitch (second (second x)))))) paired-lst) tempo)))))

;list of (abs-time duration note)
(define (data->music lst tempo)
  (if (>= 1 (length lst))
      (datum->music (first lst) tempo)
      (let ([x (first lst)])
        (if (< (first (second lst)) (+ (first x) (second x)))
            ;there is some simultaneous playback (the notes sound at the same time for some amount of time.)
            (let ([chord (chord? x (second lst))])
              (if chord
                  (list ':=: (datum->music x tempo) (data->music (rest lst) tempo))
                  ;(begin
                   ; (printf "apple~n")
                    (list ':=: (datum->music x tempo) (list ':+: (
                                                                  x (second lst) tempo) (data->music (rest lst) tempo)))))
            ;sequence
            (let ([musical-rest (rest? x (second lst) tempo)])
              (if musical-rest
                    (list ':+: (datum->music x tempo) musical-rest (data->music (rest lst) tempo))
                    (list ':+: (datum->music x tempo) (data->music (rest lst) tempo))))))))

(define (rest? x y tempo)
  (if (not (deviation (+ (first x) (second x)) (first y) EPSILON))#;(< (+ (first x) (second x)) (first y))
      ;#t, make the rest
      (begin
        (printf "second~N")
        (make-rest (convert-to-bps (first x) tempo) (convert-to-bps (first y) tempo) tempo))
      #f))

;abs-start duration note
(define (chord? x y)
  ;for right now, i'll be strict, but later i might want to use a threshold...
  (equal? (first x) (first y)))

;abs-start duration note
(define (make-rest x y tempo)
  (if (and (list? x) (list? y))
      (if (< (first x) (first y))
          (skore:rest (quantize (convert-to-bps (- (first y) (first x)) tempo)))
          (begin
            (printf "~a~n" (- (first y) (first x)))
            (raise 'improperRestTime)))
      (if (and (number? x) (number? y))
          (cond [(< x y) (skore:rest (quantize (- y x)))]
                [else (begin
                        (printf "~a~n" (- y x))
                        (raise 'improperRestTime))])
          (raise 'unsupported))))
  
(define (datum->music datum tempo)
  (let ([pitch (third datum)]
        [duration (/ (second datum) tempo)])
  `(note ,pitch ,duration)))

(define (pair-notes midi-stream tempo)
    (find-time-values midi-stream '() tempo))

;turns the list of (delta-time (midi-command)) into (abs-start-time (duration (midi-command)))
(define (find-time-values midi-lst unmatched-lst tempo)
  (if (empty? midi-lst)
      (list unmatched-lst)
      (if (midi-on? (last (first midi-lst)))
          (let ([time-value? (find-time-value (first midi-lst) (rest midi-lst) tempo)])
            (if (not (equal? #f time-value?))
                (cons (list (first (first midi-lst)) time-value?) (find-time-values (rest midi-lst) unmatched-lst tempo))
                (find-time-values (rest midi-lst) (append unmatched-lst (list (first midi-lst))) tempo)))
          (if (midi-off? (first (first midi-lst)))
              (find-time-values (rest midi-lst) unmatched-lst tempo)
              ;i can't interprent // i don't care about this input
              (find-time-values (rest midi-lst) (append unmatched-lst (list (first midi-lst))) tempo)))))

(define (find-time-value el lst tempo)
  (if (empty? lst)
      (if (skore:midi-note-on? (last el))
          #f
          '())
      (if (midi-pair? (last el) (last (first lst)))
          (cond [(< (first el) (first (first lst))) (list (quantize (convert-to-bps (- (first (first lst)) (first el)) tempo)) (last el))]
                [else (find-time-value el (rest lst) tempo)])
          (find-time-value el (rest lst) tempo))))

(define (deviation actual expected epsilon)
  (cond [(or (<= (abs (- actual expected)) epsilon)) #t]
        [else #f]))

(define EPSILON .1)

(define (convert-to-bps duration tempo)
  (* (/ duration 10000) (/ tempo 60)));; convert bpm to bpseconds then multiply by number of seconds to get # beats

(define (quantize beats)
  ;(let ([beats (* (/ duration 10000) (/ tempo 60))] 
   ;    )
  (cond 
    [(deviation beats 1 EPSILON) 1] ;quarter note
    [(deviation beats .875 EPSILON) .875]
    [(deviation beats .75 EPSILON) .75]
    [(deviation beats .625 EPSILON) .625]
    [(deviation beats .5 EPSILON) .5] ;eigth
    [(deviation beats .375 EPSILON) .375]
    [(deviation beats .25 EPSILON) .25] ;sixteenth
    [(deviation beats .125 EPSILON) .125] ;thirty-second
    [else (if (> beats .125)
              (* 2 (quantize (/ beats 2)))
              .0625)]
    ;[else (* 2 (quantize (/ duration 2) tempo))]
    ))

(define (midi-off? struct)
  (if (skore:midi-note-on? struct)
      ;velocity equal 0?
      (equal? 0 (skore:midi-note-on-velocity struct))
      ;midi note off?
      (skore:midi-note-off? struct)))

(define (midi-on? struct)
  (if (midi-off? struct)
      #f
      (and (skore:midi-note-on? struct) (< 0 (skore:midi-note-on-velocity struct)))))

(define (midi-pair? el1 el2)
  (if (skore:midi-note-on? el1)
      (and (midi-off? el2)
           (equal? (skore:midi-note-on-channel el1)
                   (get-midi-channel el2))
           (equal? (skore:midi-note-on-pitch el1)
                   (get-midi-note el2)))
      #f))


;TODO prime candidate for syntax macro
(define (get-midi-channel el)
  (if (skore:midi-note-on? el)
      (skore:midi-note-on-channel el)
      (skore:midi-note-off-channel el)))

(define (get-midi-note el)
  (if (skore:midi-note-on? el)
      (skore:midi-note-on-pitch el)
      (skore:midi-note-off-pitch el)))

(define (join-music m1 m2 joiner)
  (list joiner m1 m2))

#;(define (put-music-together m1 m2))

(define (parse-stream_midi data)
  (let ([midi-data (third data)])
    (cond [(midi-command-equal? midi-data midi-note-on-flag)
           (begin
             (cond [(< (+ (unbox starting-time) (get-delta-time data)) (unbox absolute-start)) (set-box! absolute-start (+ (unbox starting-time) (get-delta-time data)))])
             (set-box! starting-time (+ (unbox starting-time) (get-delta-time data)))
             (list (unbox starting-time) (get-delta-time data) (skore:make-midi-note-on (get-channel midi-data) (get-pitch midi-data) (get-velocity midi-data))))]
          [(midi-command-equal? midi-data midi-note-off-flag)
           (begin
             (set-box! starting-time (+ (unbox starting-time) (get-delta-time data)))
             (list (unbox starting-time) (get-delta-time data) (skore:make-midi-note-off (get-channel midi-data) (get-pitch midi-data) (get-velocity midi-data))))])))

(define (get-delta-time data)
  (first data))

(define (midi-command-equal? midi-data flag)
      (equal? (bitwise-and #xF0 (first midi-data)) flag))

(define (get-channel midi-data)
  (bitwise-and #x0F (first midi-data)))

(define (get-pitch midi-data)
  (second midi-data))

(define (get-velocity midi-data)
  (third midi-data))

(define (all-but-last lst)
      (reverse (rest (reverse lst))))

(define (list-unique lst)
    (cond [(empty? lst) '()]
          [else (if (ormap (lambda (x) (eq? (first lst) x)) (rest lst))
                    (list-unique (rest lst))
                    (cons (first lst) (list-unique (rest lst))))]))

;takes a piece (just a bunch of music) and a new note with a defined starting-time
(define (concatenate-musics piece aggregate-time new-chunk new-chunk-start-time tempo)
  (let ([piece-duration (* tempo (get-musical-duration piece))])
    (cond [(equal? ':+: (first piece)) (let ([val (sequential-music-handler (rest piece) aggregate-time new-chunk new-chunk-start-time tempo)])
                                         (if (equal? #f (last val))
                                             (cond [(equal? (+ aggregate-time piece-duration) new-chunk-start-time) (append piece (list new-chunk))]
                                                   [(< (+ aggregate-time piece-duration) new-chunk-start-time)
                                                    (maybe-add-rest new-chunk-start-time (+ aggregate-time piece-duration) tempo piece new-chunk)]
                                                   [else (raise 'itShouldnaHaveGottenHere)])
                                             (cons (first piece) val)))]
          [(equal? ':=: (first piece)) (let ([val (parallel-music-handler (rest piece) aggregate-time new-chunk new-chunk-start-time tempo)])
                                         (if (equal? #f (last val))
                                             (cond [(equal? (+ aggregate-time piece-duration) new-chunk-start-time) (append `(:+: ,piece) new-chunk)]
                                                   [(< (+ aggregate-time piece-duration) new-chunk-start-time)
                                                    (maybe-add-rest new-chunk-start-time (+ aggregate-time piece-duration) tempo piece new-chunk)]
                                                   [else (raise 'itShouldnaHaveGottenHere)])
                                           (cons (first piece) val)))]
          [(equal? 'note (first piece)) (cond [(equal? aggregate-time (* tempo new-chunk-start-time)) (begin(printf "here~n")(append `(:=: ,piece) new-chunk))]
                                              [(< (+ aggregate-time (get-musical-duration piece)) (* tempo new-chunk-start-time))
                                               (maybe-add-rest new-chunk-start-time (+ aggregate-time piece-duration) tempo piece new-chunk)]
                                              [else (append `(:=: ,piece) (list (append `(:+: ,(make-rest aggregate-time new-chunk-start-time tempo)) new-chunk)))])]
        [else (raise 'improperlyFormattedMusicError)])))

(define (maybe-add-rest new-start-time duration tempo piece new-chunk)
  ;(begin
   ; (printf "maybe~n")
    (cond [(equal? .125 (quantize (- new-start-time duration))) 
         (append piece new-chunk)]
        [else ;(begin
               ; (printf "fifth~n")
                (append piece (append `((:+: ,(make-rest duration new-start-time tempo))) new-chunk))]))

(define (_sequential-innards note-lst new-chunk aggregate-time new-chunk-start-time tempo)
  (if (<= (+ aggregate-time (* tempo (get-musical-duration (first note-lst)))) new-chunk-start-time)
      (cons (first note-lst) (sequential-music-handler (rest note-lst) (+ aggregate-time (* tempo (get-musical-duration (first note-lst)))) new-chunk new-chunk-start-time tempo))
      (if (deviation aggregate-time new-chunk-start-time EPSILON)
          ;(begin
           ; (printf "aaaaaa~n")
            (add-music-here note-lst new-chunk)
          ;(begin
           ; (printf "ssssssssss~n")
            (add-music-here note-lst (list (append `(:+: ,(make-rest aggregate-time new-chunk-start-time tempo)) new-chunk))))))
      
      ;(list (append (append (list ':+:) note-lst) new-chunk))))

(define (sequential-music-handler note-lst aggregate-time new-chunk new-chunk-start-time tempo)
  (cond [(empty? note-lst) (list #f)]
        [else (_sequential-innards note-lst new-chunk aggregate-time new-chunk-start-time tempo)]))

(define (parallel-music-handler note-lst aggregate-time new-chunk new-chunk-start-time tempo)
  (cond [(or (empty? note-lst)
             (<= (+ aggregate-time (* tempo (get-musical-duration note-lst))) new-chunk-start-time)) (list #f)]
        [else ;i need to add it
         (cond [(equal? aggregate-time new-chunk-start-time) (append note-lst new-chunk)]
               [else ;(begin
                      ; (printf "screen~n")
                       (append note-lst `((:+: ,(make-rest aggregate-time new-chunk-start-time tempo) ,(list new-chunk))))])]))

(define (add-music-here note-lst new-chunk)
  (if (equal? ':=: (first (first note-lst)))
      (list (cons ':=: (append (rest (first note-lst)) new-chunk)))
      (list (append (cons ':=:  note-lst) new-chunk))))


#|
(define test-music-seq-a '(:+: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1)))
(define test-music-par-a '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1)))

(define test-music-a '(:+: (note (C 3) 1) (:=: (note (E 4) 1) (:+: (note (Bb 4) 2) (note (G 4) 2)) (note (C 4) 3)) (note (G 4) 1)))
(define test-music-b '(:+: (note (C 3) 1) (:=: (note (E 4) 1) (note (G 4) 2) (note (C 4) 3)) (note (G 4) 1)))
(define test-music-c '(:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3)) 
                         (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2))))


;simple tests. (add at start, end and middle (on beat)
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 1) 0 120) '(:+: (:=: (:+: (note (C 3) 1) (note (C 4) 3)) (note (E 3) 1)) (note (G 4) 1)))
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 1) 120 120) '(:+: (note (C 3) 1) (:=: (:+: (note (C 4) 3)) (note (E 3) 1)) (note (G 4) 1)))
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 1) 600 120) '(:+: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (note (E 3) 1)))
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 1) 0 120) '(:+: (:=: (:+: (note (C 3) 1) (note (C 4) 3)) (note (E 3) 1)) (note (G 4) 1)))

(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 0 120) '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (note (E 3) 1)))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 360 120) '(:+: (:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1)) (note (E 3) 1)))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 120 120) '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (:+: (rest 1) (note (E 3) 1))))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 240 120) '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (:+: (rest 2) (note (E 3) 1))))

;simple tests (off beat {rests}) 
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 1) 150 120) '(:+: (note (C 3) 1) (:=: (:+: (note (C 4) 3)) (:+: (rest 1/4)(note (E 3) 1))) (note (G 4) 1)))
(equal? (concatenate-musics test-music-seq-a 0 '(note (E 3) 4) 150 120) '(:+: (note (C 3) 1) (:=: (:+: (note (C 4) 3) (note (G 4) 1)) (:+: (rest 1/4)(note (E 3) 4)))))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 120 120) '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (:+: (rest 1) (note (E 3) 1))))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 240 120) '(:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1) (:+: (rest 2) (note (E 3) 1))))
(equal? (concatenate-musics test-music-par-a 0 '(note (E 3) 1) 480 120) '(:+: (:=: (note (C 3) 1) (note (C 4) 3) (note (G 4) 1)) (rest 1) (note (E 3) 1)))

;tests 
(equal? (concatenate-musics test-music-a 0 '(:+: (note (f 4) 1) (note (f 3) 4)) 10 10) '(:+: (note (C 3) 1) (:=: (:+: (:=: (note (E 4) 1) (:+: (note (Bb 4) 2) (note (G 4) 2)) (note (C 4) 3)) (note (G 4) 1)) (:+: (note (f 4) 1) (note (f 3) 4)))))
(equal? (concatenate-musics test-music-a 0 '(:+: (note (f 4) 1) (note (f 3) 4)) 30 10) '(:+: (note (C 3) 1) (:=: (:+: (:=: (note (E 4) 1) (:+: (note (Bb 4) 2) (note (G 4) 2)) (note (C 4) 3)) (note (G 4) 1)) (:+: (rest 2) (:+: (note (f 4) 1) (note (f 3) 4))))))
(equal? (concatenate-musics test-music-c 0 test-music-c 3 1) '(:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3))
                                                                   (:=:
                                                                    (:+: (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))
                                                                    (:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3)) (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2))))))
(equal? (concatenate-musics test-music-c 0 test-music-c 4 1) '(:+:
                                                               (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3))
                                                               (:=:
                                                                (:+: (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))
                                                                (:+: (rest 1) (:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3)) (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))))))
(equal? (concatenate-musics test-music-c 0 test-music-c 6 1) '(:+:
                                                               (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3))
                                                               (:=:
                                                                (:+: (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))
                                                                (:+: (rest 3) (:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3)) (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))))))
(equal? (concatenate-musics test-music-c 0 test-music-c 8 1) '(:+:
                                                               (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3))
                                                               (:=:
                                                                (:+: (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))
                                                                (:+: (rest 5) (:+: (:=: (note (C 3) 3) (note (C 3) 3) (note (C 3) 3)) (:=: (:+: (note (C 4) 2) (note (C 5) 1)) (:+: (note (C 3) 3) (note (C 3) 3)) (note (C 5) 2)))))))

(equal? (concatenate-musics test-music-c 0 test-music-c 0 1) `(:+: (:=: ,test-music-c ,test-music-c)))
(equal? (concatenate-musics test-music-c 0 test-music-c (get-musical-duration test-music-c) 1) (append test-music-c (list test-music-c)))


;more test stuff
(define c-on-chord '(0 3 (144 60 23)))
(define e-on-chord '(0 3 (144 64 23)))
(define g-on-chord '(0 3 (144 67 23)))
(define c-off-chord '(1 3 (144 60 0)))
(define e-off-chord '(0 3 (144 64 0)))
(define g-off-chord '(0 3 (144 67 0)))

;check!

(define (test-chord)
  (begin
    (parse c-on-chord 1)
    (parse e-on-chord 1)
    (parse g-on-chord 1)
    (parse c-off-chord 1)
    (parse e-off-chord 1)
    (parse g-off-chord 1)
    ))
|#
#|
(define c-on-arp '(1 3 (144 60 23)))
(define e-on-arp '(0 3 (144 64 23)))
(define g-on-arp '(0 3 (144 67 23)))
(define c-off-arp '(1 3 (144 60 0)))
(define e-off-arp '(1 3 (144 64 0)))
(define g-off-arp '(1 3 (144 67 0)))

;check!
(define (test-arp)
  (begin
    (parse c-on-arp 1)
    (parse c-off-arp 1)
    (parse e-on-arp 1)
    (parse e-off-arp 1)
    (parse g-on-arp 1)
    (parse g-off-arp 1)
    ))

(define note-on-long '(0 3 (144 60 23)))
(define note-on-in-between '(1 3 (144 66 23)))
(define note-off-in-between '(1 3 (144 66 0)))
(define note-off-long '(1 3 (144 60 0)))

(define (test-sus)
  (begin
    (parse note-on-long 1)
    (parse note-on-in-between 1)
    (parse note-off-in-between 1)
    (parse note-off-long 1)))

(define note-on-long-sus '(0 3 (144 59 23)))
(define note-off-long-sus '(1 3 (144 59 0)))
(define note-on-long-sus-2 '(0 3 (144 58 23)))
(define note-off-long-sus-2 '(1 3 (144 58 0)))

(define (test-long-sus)
  (begin 
    (parse note-on-long-sus 1)
    (test-arp)
    (parse note-off-long-sus 1))
  )

(define (test-long-sus2)
  (begin 
    (parse note-on-long-sus 1)
    (parse c-on-arp 1)
    (parse c-off-arp 1)
    (parse e-on-arp 1)
    (parse note-on-long-sus-2 1)
    (parse e-off-arp 1)
    (parse g-on-arp 1)
    (parse note-off-long-sus-2 1)
    (parse g-off-arp 1)
    (parse note-off-long-sus 1))
  )
|#
(provide parse)