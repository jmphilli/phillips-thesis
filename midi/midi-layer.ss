#lang scheme

#|(define fst (make-midi-note-on 0 67 80))
(define snd (make-midi-note-on 0 63 80))
(define fst-off (make-midi-note-off 0 67 80))
(define snd-off (make-midi-note-off 0 63 80))
(with-midi-handle midi-handle  
    (define evts (list (cons (+ 10 (current-milliseconds)) fst) (cons (+ 10 (current-milliseconds)) snd) (cons (+ 10 (current-milliseconds)) fst-off) (cons (+ 10 (current-milliseconds)) snd-off)))
    (define time (current-milliseconds))
    (for ([evt (in-list evts)])
      ;; (printf "comparing ~s > ~s => ~s\n" time (car evt) (time . > . (car evt)))
      (when (time . < . (car evt))
        ;; (printf "sleeping ~s\n" (* 1/1000 (- (car evt) time)))
        (sleep (* 1/1000 (- (car evt) time)))
        (set! time (current-milliseconds)))
      (send-midi-command midi-handle (cdr evt)))
    ;; let the notes stop ringing:
    (sleep 0.5))
|#
(require "setup.ss")

(provide new-midi-handle
         dispose-midi-handle
         with-midi-handle
         set-bank
         send-midi-command
         (struct-out midi-note-off)
         (struct-out midi-note-on)
         (struct-out midi-aftertouch)
         (struct-out parsed-midi)
         ;jmp
         high-byte
         low-byte)

;; based on http://recording.songstuff.com/articles.php?selected=55, it looks like midi messages are structured like this:

;; A midi message is three *bytes*.  I'm guessing the interface makes them three 32-bit values for performance reasons.
;; the first "status" byte must have a 1 in the hi-value bit.  The data-1 and data-2 bytes, whose meanings are determined by the 
;; status byte, have 0s as hi-value bits.

;; the following COPIED from http://recording.songstuff.com/articles.php?selected=55:
;; Message               Status Data 1          Data 2
;; ----------
;; Note Off              8n     Note Number       Velocity
;; Note On               9n     Note Number       Velocity
;; Polyphonic Aftertouch An     Note Number       Pressure
;; Control Change	 Bn     Controller Number Data
;; Program Change	 Cn     Program Number    Unused
;; Channel Aftertouch	 Dn     Pressure          Unused
;; Pitch Wheel           En     LSB               MSB


;; a midi-command is one of 
;; (make-midi-note-off channel note velocity)
;; (make-midi-note-on channel note velocity)
(define-struct midi-note-off (channel pitch velocity))
(define-struct midi-note-on (channel pitch velocity))
(define-struct midi-aftertouch (channel pitch pressure))
(define-struct parsed-midi (tempo track-lst))
;; ... add more as necessary.



(define kMidiMessage_ControlChange        #xB0)
(define kMidiMessage_BankMSBControl       #x00) ;; yucky hardware hack
(define kMidiMessage_ProgramChange        #xC0)
(define midi-command-on               #x90)
(define midi-command-off              #x80)
(define kMidiMessage_PolyphonicAftertouch #xA0)

(define (high-byte b)
  (arithmetic-shift b -8))

(define (low-byte b)
  (bitwise-and b #xff))

(define midiChannelInUse 0)

;; in a funny back-hack, one of the "control change" messages is used to enter the high 8 bits of the "program change" message.
;; set our bank (?)

;; set the "bank"; that is, choose a synthesizer voice:
(define (set-bank midi-handle banknum)
  ;; send the high byte of the bank number:
  (midi-command! midi-handle
                 (+ kMidiMessage_ControlChange midiChannelInUse)
                 kMidiMessage_BankMSBControl
                 (high-byte banknum))
  ;; send the low byte of the bank number:
  (midi-command! midi-handle
                 (+ kMidiMessage_ProgramChange midiChannelInUse)
                 (low-byte banknum)
                 0)) ; ignored, IIUC




;; send-midi-command : midi-command -> (void)
(define (send-midi-command handle command)
  (match command
    [(struct midi-note-on (channel pitch velocity)) (midi-command! handle (+ midi-command-on channel) pitch velocity)]
    [(struct midi-note-off (channel pitch velocity)) (midi-command! handle (+ midi-command-off channel) pitch velocity)]))


