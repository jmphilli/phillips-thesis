#lang scheme
(require "midi-layer.ss")

;pitch is just modeled as a number, not a pitch class and an octave

(define-struct nnote (pitch     ;; (number or #f for rest)
                     duration 
                     velocity 
                     channel
                     time)) ;; in ms

;; an event is (cons/c abstime command), where abstime is the wall-clock 
;; milliseconds at which the event should occur, and command is a midi-command

#;(define-struct: nnote ([pitch    : Integer] 
                      [duration : Number] 
                      [velocity : Integer] 
                      [channel  : Integer]))

#;(define-struct: rest ([duration : Number]))

#|
;jmp
(define (play-music music)
  (play-notes (music->notes music)))

;; play a bunch of notes, using a new midi handle.
(define (play-notes notes)
  (with-midi-handle midi-handle  
    (define evts (notes->events notes #;(flatten notes)
                                (+ 10 (current-milliseconds))))
    (define time (current-milliseconds))
    (for ([evt (in-list evts)])
      ;; (printf "comparing ~s > ~s => ~s\n" time (car evt) (time . > . (car evt)))
      (when (time . < . (car evt))
        ;; (printf "sleeping ~s\n" (* 1/1000 (- (car evt) time)))
        (sleep (* 1/1000 (- (car evt) time)))
        (set! time (current-milliseconds)))
      (send-midi-command midi-handle (cdr evt)))
    ;; let the notes stop ringing:
    (sleep 0.5)))
|#



;; this stuff turns it into midi -- give it a new module?
(define ((note->midi-on/off maker) note)
  (and (nnote-pitch note)
       (maker
        (nnote-channel note)
        (nnote-pitch note)
        (nnote-velocity note))))


;; note->on-event : number? -> note? -> (list/c number? number? number?)
(define ((note->on-event time0) note)
  (cons (+ time0 (nnote-time note))
        ((note->midi-on/off make-midi-note-on) note)))

;; note->on-event : number? -> note? -> (list/c number? number? number?)
(define ((note->off-event time0) note)
  (cons (+ time0 (nnote-time note) (nnote-duration note))
        ((note->midi-on/off make-midi-note-off) note)))

;; each note becomes two events, a note-on and a note-off
;; (listof note?) number? -> (list event?)
(define (notes->events notes time0)
  (sort (filter cdr (append (map (note->on-event  time0) notes)
                            (map (note->off-event time0) notes)))
        (lambda (n1 n2)
          (let ([d (- (car n1) (car n2))])
            (cond [(positive? d) #f]
                  [(negative? d) #t]
                  ;; off events precede on events
                  [else n1])))))

(define ((delay-note t) n)
  (match n
    [(struct nnote (pitch duration velocity channel time))
     (make-nnote pitch duration velocity channel (+ time t))]))

(define (delay-notes t ns)
  (map (delay-note t) ns))



;; okay, this comes from haskore:

#|
data Music = Note Pitch Dur [NoteAttribute]  -- a note \ atomic 
  | Rest Dur                                 -- a rest / objects
  | Music :+: Music                          -- sequential composition
  | Music :=: Music                          -- parallel composition
  | Tempo (Ratio Int) Music   -- scale the tempo
  | Trans Int Music     -- transposition
  | Instr IName Music   -- instrument label
  | Player PName Music  -- player label
  | Phrase [PhraseAttribute] Music -- phrase attributes

type Dur = Ratio Int  -- in whole notes
|#

;; let's code this up just using sexps for now.

;; a notename is one of 'Cf 'C 'Cs 'Df 'D 'Ds ... 'Bf 'B 'Bs
;; a pitch is `(,notename ,octave)

;; a music is one of 
;; `(note ,pitch ,dur)
;; `(rest ,dur)
;; `(:+: ,music ...)
;; `(:=: ,music ...)
;; ...


#|Decided to leave out player/instrument/phrase.|#
(define (note p d) `(note ,p ,d))
(define (rest d) `(rest ,d))
(define (:+: . args) (cons ':+: args))
(define (:=: . args) (cons ':=: args))
(define (tempo n m) `(tempo ,n ,m))
;; jmp
(define (trans half-steps m) `(trans ,half-steps ,m))
(define line :+:)
(define chord :=:)

(define (pitch-class->offset pitch-class)
  (match pitch-class
    ['Cf -1]
    ['C  00]
    ['Cs 01]
    ['Df 01]
    ['D  02]
    ['Ds 03]
    ['Ef 03]
    ['E  04]
    ['Es 05]
    ['Ff 04]
    ['F  05]
    ['Fs 06]
    ['Gf 06]
    ['G  07]
    ['Gs 08]
    ['Af 08]
    ['A  09]
    ['As 10]
    ['Bf 10]
    ['B  11]
    ['Bs 12]))

(define (offset->pitch-class offset)
  (list-ref '(C Cs D Ds E F Fs G Gs A As B) offset))

(define (key-offset->pitch-class key-offset)
  (list-ref '(C D E F G A B) key-offset))

;; map a pitch to its MIDI note number
#;(define (pitch->pitch-num pitch)
  (match pitch
    [(list pitch-class octave) (+ (pitch-class->offset pitch-class) (* 12 octave) 12)]))

;; justin bug fix MIDI
(define (pitch->pitch-num pitch)
  (match pitch
    [(list pitch-class octave) (+ (pitch-class->offset pitch-class) (* 12 octave))]))

(define (pitch-num->pitch num)
  (list (offset->pitch-class (modulo num 12)) (floor (/ num 12))))

(define (key-pitch-num->pitch num)
  (list (key-offset->pitch-class (modulo num 7)) (floor (/ num 7))))

#;(define base-tempo 120)
#;(define whole-note-len (* 1000 (/ 240 base-tempo))) ;; in milliseconds

(define (music-duration music)
  (match music
    [`(note ,p ,d) d]
    [`(rest ,d) d]
    [`(:+: ,ms ...) (apply + (map music-duration ms))]
    [`(:=: ,ms ...) (apply max (map music-duration ms))]
    [`(tempo ,n ,m) (/ (music-duration m) n)]
    ;jmp
    [`(trans ,half-steps ,m) (music-duration m)]))

(define (music->notes music whole-note-len)
  (match music
    [`(note ,p ,d) (list (make-nnote (pitch->pitch-num p) (* d whole-note-len) 80 0 0))]
    [`(rest ,d) (list)]
    [`(:+: ,ms ...) (music-append-loop ms)]
    [`(:=: ,ms ...) (apply append (map music->notes ms))]
    [`(tempo ,n ,m) (music->notes (scale-music (/ 1 n) m))]
    ;jmp this seems really lame as i create a whole new struct for every existing one, but i couldn't find a setter..
    [`(trans ,half-steps ,m) (map (lambda (x) (make-nnote (+ (nnote-pitch x) half-steps)
                                                            (nnote-duration x)
                                                            (nnote-velocity x)
                                                            (nnote-channel x)
                                                            (nnote-time x))) (music->notes m))]
    [else (if (not (empty? music))
              (if (nnote? (first music))
                  (music->notes (rest music))
                  (raise 'bad-input))
              '())]))

;changes the duration of the music
(define (scale-music scale-by music)
  (let recur ([music music])
    (match music
      [`(note ,p ,d) `(note ,p ,(* d scale-by))]
      [`(rest ,d) `(rest ,(* d scale-by))]
      [`(:+: ,ms ...) `(:+: ,@(map recur ms))]
      [`(:=: ,ms ...) `(:=: ,@(map recur ms))]
      [`(tempo ,n ,m) `(tempo ,n ,(recur m))]
      [`(trans ,half-steps ,m) `(trans ,half-steps ,(recur m))])))
 
(define (music-append-loop musics whole-note-len)
  (apply
   append
   (let loop ([musics musics] [delay 0])
     (match musics
       [`() null]
       [(cons f r) (cons (map (delay-note (* delay whole-note-len)) (music->notes f))
                         (loop r (+ delay (music-duration f))))]))))


(define (key-pitch-num->music n) (note (key-pitch-num->pitch n) 1/4))
(define (key-pitch-nums->music ns) (apply :+: (map key-pitch-num->music ns)))

#|jmp|#
(define (absPitch p-class oct)
  (+ (pitch-class->offset p-class) (* 12 oct)))
;pitch is not necessary since pitch is modeled as a number, not a pitch-class and octave
;nor is trans that works solely on pitch, just add.

#|(define (line m)
  (foldr cons ':+: m))

(define cMaj '((note '(C 5) 1) (note '(E 5) 1) (note '(G 5) 1)))|#

#| delay handled by delay-notes and music->notes func
(define m (:=: (note '(C 5) 1) (note '(E 5) 1) (note '(G 5) 1)))
(play-music (:=: m (delay 1 m)))

(play-music (:=: m (delay-notes 500 (music->notes (trans 7 m)))));; doesn't work as i'd hoped
|#

;; tested, works
(define (nnote->note n whole-note-len)
  (let* ([pitch (pitch-num->pitch (nnote-pitch n))]
         [duration (/ (nnote-duration n) whole-note-len)])
    `(note ',pitch ,duration)))

#;(define (retro m)
  (replace-notes-in-music m (map nnote->note (reverse (music->notes m)))))

;should only be used on single note melodic lines for correct functionality
; works
(define (retro-strict m)
  (map nnote->note (reverse (music->notes m))))

(define (invert-intervals old-ns new-ns)
  (if (empty? (cdr old-ns))
      new-ns
      (let ([new-note (make-nnote (+ (nnote-pitch (last new-ns)) (- 0 (- (nnote-pitch (second old-ns)) (nnote-pitch (first old-ns)))))
                                  (nnote-duration (second old-ns)) 80 0 0)])
        (invert-intervals (cdr old-ns) (append new-ns (list new-note))))))
;inversion, if music goes a a# then inversion goes a ab
(define (invert-strict m)
  (let ([m-lst (music->notes m)])
    (map nnote->note (invert-intervals m-lst (list (first m-lst))))))

;; todo, retro and invert take only notes as for simple melodic lines, not chords and such... 

;;justin added
(provide make-nnote
         nnote-pitch
         music->notes
         :=:
         :+:
         note
         rest
         pitch-num->pitch
         (struct-out midi-note-off)
         (struct-out midi-note-on)
         (struct-out midi-aftertouch))

; TODO :
; lineToList, retro...
; upgrade tempo for triplets???
