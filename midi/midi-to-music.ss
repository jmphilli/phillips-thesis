#lang Racket
(require (prefix-in skore: "user.ss")
         "midi-layer.ss")

; this converts midi commands (specifically notes on and off) to music
; the notes are quantized where needed

;abs-start-time duration note
(define (paired-notes->music paired-lst tempo)
  (data->music (map (lambda (x) (list (first x) (second x) (pitch-num->pitch (third x)))) paired-lst) tempo))

;add a blank rest in between chords that are right next to each other. blank meaning no duration
(define (data->music lst tempo)
  (if (>= 1 (length lst))
      (datum->music (first lst) tempo)
      (let ([x (first lst)])
        (if (< (first (second lst)) (+ (first x) (second x)))
            ;there is some simultaneous playback (the notes sound at the same time for some amount of time.)
            (let ([chord (chord? x (second lst))])
              (if chord
                  (list ':=: (datum->music x tempo) (data->music (rest lst) tempo))
                  (list ':=: (datum->music x tempo) (list ':+: (make-rest x (second lst) tempo) (data->music (rest lst) tempo)))))
            ;sequence
            (let ([musical-rest (rest? x (second lst) tempo)])
              (if musical-rest
                  (list ':+: (datum->music x tempo) musical-rest (data->music (rest lst) tempo))
                  (list ':+: (datum->music x tempo) (data->music (rest lst) tempo))))))))

;abs-start duration note
(define (rest? x y tempo)
  (if (< (+ (first x) (second x)) (first y))
      ;#t, make the rest
      (make-rest x y tempo)
      #f))

;abs-start duration note
(define (chord? x y)
  ;for right now, i'll be strict, but later i might want to use a threshold...
  (equal? (first x) (first y)))

;abs-start duration note
(define (make-rest x y tempo)
  (skore:rest (/ (- (first y) (first x)) tempo)))
  
(define (datum->music datum tempo)
  (let ([pitch (third datum)]
        [duration (/ (second datum) tempo)])
  `(note ,pitch ,duration)))

(define (pitch-num->pitch note)
  (skore:pitch-num->pitch (skore:midi-note-on-pitch note)))

;pairs up notes (on and offs) removes the off signals and sets up the duration of the notes
;returns two lists. first list is paired notes. second list is unpaired notes

;;TODO change this so that it gives more context. it gives the duration of the note, the note itself, and how it should be joined. e.g.
#|
notes each have their own duration.
even in :=:
so notes can start at the same time (what :=: means)
but be released at different times
clustered :+: will cause another strike of note
clustered :=: shouldn't

note-on c delta-time
note-on e delta-time == 0
note-on g delta-time == 0
note-off c delta-timex
note-off e delta-time ==0
note-off g delta-time == 0

should be marked as joined with a :=:

note-on c delta-time
note-on e delta-timeb
should be marked as joined with a :+:

note-on c delta-time
note-on e delta-time == 0
note-on g delta-timeb
note-off c delta-timec
note-off e delta-time == 0
note-off g delta-time == 0
should be marked as joined as such (:+: (:=: c e) g) which cannot be simplified

notes that start at the same time and end at different times 
(:=: c e g) can be written like this because they each have their own duration. 

how would you play a c then later e (but together) end together.
(:=: c (:+: rest e))

how would you play a c then later an e that are together, but then end at different times (2 cases)
(:=: c (:+: rest e))

|#
(define (pair-notes midi-stream absolute-starting-time)
  (find-time-values midi-stream '() absolute-starting-time))

;turns the list of (delta-time (midi-command)) into (length-of-this-note chord? (midi-command))
(define (find-time-values midi-lst unmatched-lst absolute-starting-time)
  (if (empty? midi-lst)
      (list unmatched-lst)
      (if (midi-on? (cdr (first midi-lst)))
          (let ([time-value? (find-time-value (first midi-lst) (rest midi-lst) 0)])
            (if time-value?
                (cons (cons (+ (car (first midi-lst)) absolute-starting-time) time-value?) (find-time-values (rest midi-lst) unmatched-lst (+ absolute-starting-time (car (first midi-lst)))))
                (find-time-values (rest midi-lst) (append unmatched-lst (list (cons absolute-starting-time (first midi-lst)))) (+ absolute-starting-time (car (first midi-lst))))))
          (if (midi-off? (cdr (first midi-lst)))
              (find-time-values (rest midi-lst) unmatched-lst (+ absolute-starting-time (car (first midi-lst))))
              ;i can't interprent // i don't care about this input
              (find-time-values (rest midi-lst) (append unmatched-lst (list (cons absolute-starting-time (first midi-lst)))) (+ absolute-starting-time (car (first midi-lst))))))))

(define (find-time-value el lst passed-time)
  (if (empty? lst)
      (if (skore:midi-note-on? (cdr el))
          #f
          '())
      (if (midi-pair? (cdr el) (cdr (first lst)))
          (list (+ (car (first lst)) passed-time) (cdr el))
          (find-time-value el (rest lst) (+ passed-time (car (first lst)))))))

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

(define CHORD_THRESHOLD 10)

(define (midi-pair? el1 el2)
  (if (skore:midi-note-on? el1)
      (if (or (skore:midi-note-off? el2)
              (skore:midi-note-on? el2))
          (and (equal? (skore:midi-note-on-channel el1)
                       (get-midi-channel el2))
               (equal? (skore:midi-note-on-pitch el1)
                       (get-midi-note el2))
               (midi-off? el2))
          #f)
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

#;(define (midi-off-signal? el)
  (or (skore:midi-note-off? el)
      (equal? 0 (skore:midi-note-on-velocity el))));the velocity is zero for a note on meaning that its a note off
  

#;(define (make-notes lst)
  (if (empty? lst)
      '()
      (let ([note `(',(third (first lst)))])
        (cons (list (first (first lst))
                    (skore:note (third (first lst)) (second (first lst))))
              (make-notes (rest lst))))))

; given a list of note-durations, the time when the pitch is played, and pitches create structured music
#;(define (make-music track-lst)
  (let ([musics (map track->music track-lst)])
    ; later i'll have to put it all together here, but right now i can play one track at a time TODO
    musics))

#;(define (track->music lst)
  ;(let ([track (sort lst (lambda (x y)
  ;                         (< (first x)
  ;                            (first y))))])
    (track->music-recur lst))
;)

#;(define (track->music-recur track)
  (if (not (empty? track))
      (let ([music-part-pair (reverse-check (parallel-music-handler track (first (first track)) 0))])
        (if (equal? 0 (first-check music-part-pair))
            (append  (list ':+:) 
                     (sequence-music-handler track))
            (cons (wrap-as-parallel-music (rest music-part-pair))
                  (list (track->music-recur (list-tail track (first music-part-pair))))))) ;; TODO bug possible here, exclusion of notes accidentally maybe.
      '()))

#;(define (first-check lst)
  (if (list? lst)
      (first lst)
      lst))

#;(define (reverse-check lst)
  (if (list? lst)
      (reverse lst)
      lst))

#;(define (wrap-as-parallel-music note-lst)
  (append (list ':=:) note-lst))

#;(define (parallel-music-handler track start-time idx)
  (if (empty? track)
      idx
      (if (empty? (cdr track))
          idx
          (if (and (equal? (first (first track))
                           (first (second track)))
                   (equal? (first (first track))
                           start-time))
              (list (second (first track)) ; make a note with the pitch and duration (abs-time duration pitch)
                    (second (second track))
                    (parallel-music-handler (list-tail track 2) start-time (+ 2 idx)))
              idx))))

#;(define (sequence-music-handler track)
  (if (empty? track)
      '()
      (if (< 2 (length track))
          (if (equal? 0 (first-check (reverse-check (parallel-music-handler (rest track) (first (first (rest track))) 0)))) ;TODO fix the first-first-rest call here, not safe
              (cons (second (first track))
                    (sequence-music-handler (rest track)))
              (cons (second (first track))
                    (track->music-recur (rest track))))
          (second (first track)))
      #;(skore::+: (second (first track))
                 (track->music-recur (rest track)))))


; given a quantized list of notes/delta-times replace the delta times with note durations
; 1 == whole note
; .25 == quarter note
; etcetera
; the 'tempo' field from the parsed-midi object is the time division in the midi header
; so if tempo is 120 then 120 as a delta time value is a quarter note
;(define (delta-time->note-duration midi-note tempo)
;      (cons (time-values->note-durations (find-time-values (first track-lst)) tempo)
;            (delta-time->note-durations (rest track-lst) tempo))

#;(define (time-values->note-durations track tempo)
  (map (lambda (x) (list (/ (first x) tempo) (second x) (third x))) track))


; (delta-time from note-on to note-off/note-on-again)
;                    /
;                  tempo
; thats how many quarter notes this note is. so then divide by four
; attach the duration of the note, but leave the 'absolute' delta time so that i know when it should come in (as a chord? (e.g. with other notes?) after a rest?))
; dealing with (absolute-start-time duration note/rest)
#;(define (time->note-duration lst tempo)
  (list (first lst)
        (/ (/ (second lst) tempo) 4)
        (third lst)))

;match the channel and pitch of the 'on' note with either another on or an off
;return the pair of notes with the aggregate delta time between the two
#;(define (match-midi-notes midi-on lst absolute-start-time running-time)
  (if (not (empty? lst))
      (let* ([note (cdr (first lst))]
             [delta-time (car (first lst))]
             [running-time (+ running-time delta-time)])
        (if (equal? (skore:midi-note-on-channel (cdr midi-on))
                    (midi-channel-val note))
            (if (equal? (skore:midi-note-on-pitch (cdr midi-on))
                        (midi-pitch-val note))
                (list absolute-start-time running-time (cdr midi-on))
                (match-midi-notes midi-on (rest lst) absolute-start-time running-time))
            (match-midi-notes midi-on (rest lst) absolute-start-time running-time)))
      (list absolute-start-time 10 (cdr midi-on)))) ; TODO that 10 ??? make any sense tomorrow?

;could use a macro for these two... TODO
#;(define (midi-pitch-val note)
  (if (skore:midi-note-on? note)
      (skore:midi-note-on-pitch note)
      (if (skore:midi-note-off? note)
          (skore:midi-note-off-pitch note)
          (raise 'unexpected-midi-command))))

#;(define (midi-channel-val note)
  (if (skore:midi-note-on? note)
      (skore:midi-note-on-channel note)
      (if (skore:midi-note-off? note)
          (skore:midi-note-off-channel note)
          (raise 'unexpected-midi-command))))

; make delta times 'appropriate' e.g. if a quarter note's delta time value should be 250 but the listed value is 234 make it 250
(define (quantize-midi parsed-midi-data tempo)
  parsed-midi-data)

;(define a (make-midi-note-on 0 60 30))

;(define c-on (make-midi-note-on 0 60 32))
;(define c-off (make-midi-note-off 0 60 0))
;(define e-on (make-midi-note-on 0 64 32))
;(define e-off (make-midi-note-off 0 64 0))
;(define a (cons 0 c-on))
;(define b (cons 0 e-on))
;(define c (cons 30 c-off))
;-(define d (cons 30 e-off))

;(define a (list 120 #t (make-midi-note-on 0 60 30)))
;(define b (list 120 #t (make-midi-note-on 0 64 30)))
;(define b (make-midi-note-off 0 60 0))
;(find-time-values (list (cons 120 a) (cons 240 b)) '())

(provide paired-notes->music
         pair-notes)
;(paired-notes->music (reverse (rest (reverse (pair-notes (list a b a b a b) 0)))) 120)