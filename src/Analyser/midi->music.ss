#lang scheme
(require (lib "midi/user.ss")
         "../Parser/parser.ss")

; this converts midi commands (specifically notes on and off) to music
; the notes are quantized where needed
(define (midi->music midi-stream)
  (make-music (pitch-nums->pitches (delta-time->note-durations (quantize-midi midi-stream) (parsed-midi-tempo midi-stream)))))

(define (pitch-nums->pitches lst)
  (if (not (empty? lst))
      (cons (pitch-nums->pitches-innards (first lst))
            (pitch-nums->pitches (rest lst)))
      '()))

(define (pitch-nums->pitches-innards lst)
  (map (lambda (x)
         (list (first x)
               (second x)
               (pitch-num->pitch (midi-note-on-pitch (third x))))) lst))

; given a list of note-durations, the time when the pitch is played, and pitches create structured music
(define (make-music track-lst)
  (let ([musics (map track->music track-lst)])
    ; later i'll have to put it all together here, but right now i can play one track at a time TODO
    musics))

(define (track->music lst)
  (let ([track (sort lst (lambda (x y)
                           (< (first x)
                              (first y))))])
    (track->music-recur lst)))

(define (track->music-recur track)
  (if (not (empty? track))
      (let ([music-part-pair (reverse-check (parallel-music-handler track 0))])
        (if (equal? 0 (first-check music-part-pair))
            (sequence-music-handler track)
            (cons (wrap-as-parallel-music (rest music-part-pair))
                  (sequence-music-handler (list-tail track (first music-part-pair)))))) ;; TODO bug possible here, exclusion of notes accidentally maybe.
      '()))

(define (first-check lst)
  (if (list? lst)
      (first lst)
      lst))

(define (reverse-check lst)
  (if (list? lst)
      (reverse lst)
      lst))

(define (wrap-as-parallel-music note-lst)
  `(:=: ,note-lst))

(define (parallel-music-handler track idx)
  (if (empty? track)
      idx
      (if (empty? (cdr track))
          idx
          (if (equal? (first (first track))
                      (first (second track)))
              (list (note (third (first track)) (first (first track)))
                    (note (third (second track)) (first (second track)))
                    (parallel-music-handler (list-tail track 2) (+ 2 idx)))
              idx))))

(define (sequence-music-handler track)
  (if (empty? track)
      '()
      (:+: (note (third (first track)) (first (first track)))
       (track->music-recur (rest track)))))


; given a quantized list of notes/delta-times replace the delta times with note durations
; 1 == whole note
; .25 == quarter note
; etcetera
; the 'tempo' field from the parsed-midi object is the time division in the midi header
; so if tempo is 120 then 120 as a delta time value is a quarter note
(define (delta-time->note-durations track-lst tempo)
  (if (not (empty? track-lst))
      (cons (map (lambda (x) (time->note-duration x tempo)) (add-rests (make-all-note-pairs (first track-lst) 0)))
            (delta-time->note-durations (rest track-lst) tempo))
      '()
      ))

; add rests to the list
(define (add-rests lst)
  (let ([track (sort lst (lambda (x y)
                           (< (first x)
                              (first y))))])
    (add-rests-innards track)))

(define (add-rests-innards sorted-lst)
  (if (empty? sorted-lst)
      '()
      (if (empty? (rest sorted-lst))
          (first sorted-lst)
          (if (need-to-add-rest? (first sorted-lst) (second sorted-lst))
              ;add a rest, recur
              (cons (first sorted-lst)
                    (cons (make-rest (first sorted-lst) (second sorted-lst))
                          (add-rests-innards (rest sorted-lst))))
              ;just recur
              (cons (first sorted-lst)
                    (add-rests-innards (rest sorted-lst)))
              ))))


(define (need-to-add-rest? el-a el-b)
  (if (equal? (first el-a) (first el-b))
      #f
      (let ([duration (- (first el-b) (first el-a))])
        (if (> duration (second el-b))
            #t
            #f))))

(define-struct rest-placeholder (x))

(define (make-rest el-a el-b)
  (let* ([rest-start-time (- (second el-a) (first el-a))]
         [rest-duration (- (first el-b) rest-start-time)])
    (list rest-start-time
          rest-duration
          (make-rest-placeholder #t))))



;; need to make it so that the notes-off and duplicate note-ons in the lst are removed when paired up...
(define (make-all-note-pairs lst aggregate-delta-time)
  (if (not (empty? lst))
      (if (midi-note-on? (cdr (first lst)))
          (cons (match-midi-notes (cdr (first lst)) (rest lst) 0)
                (make-all-note-pairs (rest lst)))
          (make-all-note-pairs (rest lst)))
      '()))


; (delta-time from note-on to note-off/note-on-again)
;                    /
;                  tempo
; thats how many quarter notes this note is. so then divide by four
; attach the duration of the note, but leave the 'absolute' delta time so that i know when it should come in (as a chord? (e.g. with other notes?) after a rest?))
(define (time->note-duration pair tempo)
  (list (car pair)
        (/ (/ (car pair) tempo) 4)
        (cdr pair)))

;match the channel and pitch of the 'on' note with either another on or an off
;return the pair of notes with the aggregate delta time between the two
(define (match-midi-notes midi-on lst running-time)
  (if (not (empty? lst))
      (let* ([note (cdr (first lst))]
             [delta-time (car (first lst))]
             [running-time (+ running-time delta-time)])
        (if (equal? (midi-note-on-channel midi-on)
                    (midi-channel-val note))
            (if (equal? (midi-note-on-pitch midi-on)
                        (midi-pitch-val note))
                (cons running-time midi-on)
                (match-midi-notes midi-on (rest lst) running-time))
            (match-midi-notes midi-on (rest lst) running-time)
            ))
      '()))

;could use a macro for these two... TODO
(define (midi-pitch-val note)
  (if (midi-note-on? note)
      (midi-note-on-pitch note)
      (if (midi-note-off? note)
          (midi-note-off-pitch note)
          (raise 'unexpected-midi-command))))

(define (midi-channel-val note)
  (if (midi-note-on? note)
      (midi-note-on-channel note)
      (if (midi-note-off? note)
          (midi-note-off-channel note)
          (raise 'unexpected-midi-command))))

; make delta times 'appropriate' e.g. if a quarter note's delta time value should be 250 but the listed value is 234 make it 250
(define (quantize-midi parsed-midi-data)
  (parsed-midi-track-lst parsed-midi-data))