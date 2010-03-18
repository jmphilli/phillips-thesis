#lang scheme
(require (prefix-in skore: (lib "midi/user.ss"))
         "../Parser/parser.ss")

; this converts midi commands (specifically notes on and off) to music
; the notes are quantized where needed
(define (midi->music midi-stream)
  (make-music (map make-notes (pitch-nums->pitches (delta-time->note-durations (quantize-midi midi-stream) (parsed-midi-tempo midi-stream))))))

(define (make-notes lst)
  (if (empty? lst)
      '()
      (if (rest-placeholder? (third (first lst)))
          (cons (list (first (first lst))
                  (skore:rest (second (first lst))))
                (make-notes (rest lst)))
          (let ([note `(',(third (first lst)))])
            (cons (list (first (first lst))
                         (skore:note (third (first lst)) (second (first lst))))
                   (make-notes (rest lst)))))))

(define (pitch-nums->pitches lst)
  (if (not (empty? lst))
      (cons (pitch-nums->pitches-innards (first lst))
            (pitch-nums->pitches (rest lst)))
      '()))

(define (pitch-nums->pitches-innards lst)
  (map (lambda (x)
         
         (if (skore:midi-note-on? (third x))
             (list (first x)
                   (second x)
                   (skore:pitch-num->pitch (skore:midi-note-on-pitch (third x))))
             ;its a rest, let it go through
             x))
       lst))

; given a list of note-durations, the time when the pitch is played, and pitches create structured music
(define (make-music track-lst)
  (let ([musics (map track->music track-lst)])
    ; later i'll have to put it all together here, but right now i can play one track at a time TODO
    musics))

(define (track->music lst)
  ;(let ([track (sort lst (lambda (x y)
  ;                         (< (first x)
  ;                            (first y))))])
    (track->music-recur lst))
;)

(define (track->music-recur track)
  (if (not (empty? track))
      (let ([music-part-pair (reverse-check (parallel-music-handler track (first (first track)) 0))])
        (if (equal? 0 (first-check music-part-pair))
            (append  (list ':+:) 
                     (sequence-music-handler track))
            (cons (wrap-as-parallel-music (rest music-part-pair))
                  (list (track->music-recur (list-tail track (first music-part-pair))))))) ;; TODO bug possible here, exclusion of notes accidentally maybe.
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
  (append (list ':=:) note-lst))

(define (parallel-music-handler track start-time idx)
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

(define (sequence-music-handler track)
  (if (empty? track)
      '()
      (if (< 2 (length track))
          (if (equal? 0 (first-check (reverse-check (parallel-music-handler (rest track) (first (first (rest track))) 0)))) ;TODO fix the first-first-rest call here, not safe
              (cons (second (first track))
                    (sequence-music-handler (rest track)))
              (cons (second (first track))
                    (track->music-recur (rest track))))
          (cons (second (first track))
                (list (second (second track)))))
      #;(skore::+: (second (first track))
                 (track->music-recur (rest track)))))


; given a quantized list of notes/delta-times replace the delta times with note durations
; 1 == whole note
; .25 == quarter note
; etcetera
; the 'tempo' field from the parsed-midi object is the time division in the midi header
; so if tempo is 120 then 120 as a delta time value is a quarter note
(define (delta-time->note-durations track-lst tempo)
  (if (not (empty? track-lst))
      (cons (safety-wrapper_temp (add-rests (make-all-note-pairs (first track-lst) 0)) tempo);(map (lambda (x) (time->note-duration x tempo)) (add-rests (make-all-note-pairs (first track-lst) 0))) ;(make-all-note-pairs (first track-lst) 0))
            (delta-time->note-durations (rest track-lst) tempo))
      '()
      ))

;TODO get rid of this?
(define (safety-wrapper_temp lst tempo)
  (if (empty? lst)
      '()
      (cons (time->note-duration (first lst) tempo)
            (safety-wrapper_temp (rest lst) tempo))))

; add rests to the list
(define (add-rests lst)
  (if (empty? lst)
      lst
      (let ([track (sort lst (lambda (x y)
                           (< (first x)
                              (first y))))])
    ;sorted by absolute-start-time
    (add-rests-innards track))))

(define (add-rests-innards sorted-lst)
  (if (empty? sorted-lst)
      '()
      (if (empty? (rest sorted-lst))
          sorted-lst
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
        (if (> (+ duration (first el-b)) (second el-b))
            #t
            #f))))

(define-struct rest-placeholder (x))

(define (make-rest el-a el-b)
  (let* ([rest-start-time (+ (second el-a) (first el-a))]
         [rest-duration (- (first el-b) rest-start-time)])
    (list rest-start-time
          rest-duration
          (make-rest-placeholder #t))))



;; need to make it so that the notes-off and duplicate note-ons in the lst are removed when paired up...
(define (make-all-note-pairs lst aggregate-delta-time)
  (if (not (empty? lst))
      (if (skore:midi-note-on? (cdr (first lst)))
          (cons (match-midi-notes (first lst) (rest lst) aggregate-delta-time 0)
                (make-all-note-pairs (rest lst) (+ aggregate-delta-time (car (first lst)))))
          (make-all-note-pairs (rest lst) (+ aggregate-delta-time (car (first lst)))))
      '()))


; (delta-time from note-on to note-off/note-on-again)
;                    /
;                  tempo
; thats how many quarter notes this note is. so then divide by four
; attach the duration of the note, but leave the 'absolute' delta time so that i know when it should come in (as a chord? (e.g. with other notes?) after a rest?))
; dealing with (absolute-start-time duration note/rest)
(define (time->note-duration lst tempo)
  (list (first lst)
        (/ (/ (second lst) tempo) 4)
        (third lst)))

;match the channel and pitch of the 'on' note with either another on or an off
;return the pair of notes with the aggregate delta time between the two
(define (match-midi-notes midi-on lst absolute-start-time running-time)
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
            (match-midi-notes midi-on (rest lst) absolute-start-time running-time)
            ))
      '()))

;could use a macro for these two... TODO
(define (midi-pitch-val note)
  (if (skore:midi-note-on? note)
      (skore:midi-note-on-pitch note)
      (if (skore:midi-note-off? note)
          (skore:midi-note-off-pitch note)
          (raise 'unexpected-midi-command))))

(define (midi-channel-val note)
  (if (skore:midi-note-on? note)
      (skore:midi-note-on-channel note)
      (if (skore:midi-note-off? note)
          (skore:midi-note-off-channel note)
          (raise 'unexpected-midi-command))))

; make delta times 'appropriate' e.g. if a quarter note's delta time value should be 250 but the listed value is 234 make it 250
(define (quantize-midi parsed-midi-data)
  (parsed-midi-track-lst parsed-midi-data))

(define (play-music m)
  (skore:play-notes (skore:music->notes m)))