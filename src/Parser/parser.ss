#lang scheme

(require (lib "midi/midi-layer.ss")
         "./variable-length-handler.ss"
         "../module/connect.ss")

(define-struct parsed-midi (tempo track-lst))

;; open a file and play it back
;clean - bass1*2
(define (parse-file midi-file)
  (let ([in (open-input-file midi-file #:mode 'binary)])
    (read-midi-file in)))

(define (parse-stream midi-bstr)
  (make-parsed-midi 120 (list (read-track-bstr midi-bstr #"")))) 
;; the extra list is for posterity. j/k its cause its a track coming from an instrument. parse-file lists tracks so this has to as well for the analysing step to work

(define (connect-to-midi)
  (connect))

;this just makes every element in the list a time-event pair. it could be done with a simple in-line map, but this way it is clear what i am doing...
(define (make-time-event-pairs lst)
  (map (lambda (x) (cons (+ 10 (current-milliseconds)) x)) lst))

(define-struct midi-header (format track-num tempo))

; header_chunk = "MThd" (4 bytes) + <header_length> (4 bytes, always has the value 6) + <format> (2 bytes)+ <n> (2 bytes) + <division> (2 bytes aka tempo...)
(define total-header-length 14)
(define header-length 6) ; as defined by midi standards
(define (read-header in-stream)
  (let ([header (read-bytes in-stream total-header-length)])
    (if (and (eq? (bytes-length header) total-header-length)
             (equal? (bytes->string/utf-8 (subbytes header 0 4)) "MThd"))
        ;it is a midi file, and the whole header was read in
        (if (eq? header-length (integer-bytes->integer header #t #t 4 8))
            (make-midi-header (integer-bytes->integer header  #t #t 8 10)
                              (integer-bytes->integer header  #t #t 10 12)
                              (integer-bytes->integer header  #t #t 12 14))
            (raise 'Corrupt-Midi-File))
        (raise 'Not-A-Midi-File))))


; this reads past the header, and reads every midi track/command, returning the list of commands for further processing
(define (read-midi-file in-stream)
  (let ([header (read-header in-stream)])
    (match (midi-header-format header)
      [0 'single-track-format]
      [1 (make-parsed-midi (midi-header-tempo header)
                            (read-tracks in-stream (midi-header-track-num header)))]
      [2 'multiple-song-format])))


(define (read-tracks in-stream num-tracks)
  (if (> num-tracks 0)
      (cons (read-track in-stream) (read-tracks in-stream (- num-tracks 1)))
      '()))


(define meta-event-flag (bytes #xFF)) ; 0xFF
(define sysex-event-flag (bytes #xF0))  ; 0xF0
(define sysex-event-flag-end (bytes #xF7))  ; 0xF7
(define end-of-track-flag (bytes #x2F))

(define-struct meta-event (type data))
;midi-note-on channel pitch velocity
;midi-note-off channel pitch velocity
;track_chunk = "MTrk" (4 bytes)+ <length> (4 bytes)+ <track_event> [+ <track_event> ...]
; track_event = <v_time> + <midi_event> | <meta_event> | <sysex_event>
(define (read-track in-stream)
  (if (equal? (bytes->string/utf-8 (read-bytes in-stream 4)) "MTrk")
      (let ([track-bstr (read-bytes in-stream (integer-bytes->integer (read-bytes in-stream 4) #t #t))])
       (read-track-bstr track-bstr #""))
      (error 'read-track-failed)))


(define (read-track-bstr track-bstr previous-midi-command)
  (if (> (bytes-length track-bstr) 0)
      
      (let ([delta-time (read-variable-length-part track-bstr 0)])
        (cond 
          ; meta_event = 0xFF + <meta_type> + <v_length> + <event_data_bytes>
          [(command-equal? meta-event-flag (subbytes track-bstr (car delta-time) (+ 1 (car delta-time))))
           ;one byte is the meta-type
           (let* ([meta-type (subbytes track-bstr (+ 1 (car delta-time)) ; plus one for the length of the meta-flag
                                       (+ 2 (car delta-time))) #| meta-type is one byte long|#]
                  [v-length (read-variable-length-part track-bstr (+ 2 (car delta-time)))])
             (if (command-equal? meta-type end-of-track-flag)
                 ;(printf "end of track\n")
                 (read-track-bstr (subbytes track-bstr
                                            (+ (variable-length-total-length v-length)
                                               (+ 2 (car delta-time)))
                                            (bytes-length track-bstr)) meta-event-flag)
                 (read-track-bstr (subbytes track-bstr
                                            (+ (variable-length-total-length v-length)
                                               (+ 2 (car delta-time)))
                                            (bytes-length track-bstr)) meta-event-flag)))]
          ; sysex_event = 0xF0 + <v_length> + <data_bytes> 0xF7 
          ;             | 0xF7 + <data_bytes> 0xF7
          [(command-equal? sysex-event-flag (subbytes track-bstr (car delta-time) (+ 1 (car delta-time)))) 
           ;sysex-event
           ; start reading the variable length field after the command flag area which is 2 bytes after the delta-time which was variable.
           (let ([v-length (read-variable-length-part track-bstr (+ 1 (car delta-time)))])
             ; don't do anything, just recur
             (read-track-bstr (subbytes track-bstr (+ (+ 1 (variable-length-total-length delta-time)) (variable-length-total-length v-length)) (bytes-length track-bstr)) sysex-event-flag))]
          [(command-equal? sysex-event-flag-end (subbytes track-bstr (car delta-time) (+ 1 (car delta-time)))) (printf "sysex-event-other\n")]
          ; v_time + midi_event = 
          [else (midi-handler (subbytes track-bstr (car delta-time) (bytes-length track-bstr)) delta-time previous-midi-command)]
          ))
      '()))

(define midi-note-on-flag (bytes #x9))
(define midi-note-off-flag (bytes #x8))
(define midi-note-aftertouch-flag (bytes #xA))
(define midi-controller-flag (bytes #xB))
(define midi-program-change-flag (bytes #xC))
(define midi-channel-aftertouch-flag (bytes #xD))
(define midi-pitch-bend-flag (bytes #xE))


(define (command-equal? command bstr)
  (equal? (car (bytes->list command)) (car (bytes->list bstr))))

(define (midi-command-equal? command bstr)
  (equal? (car (bytes->list command)) (arithmetic-shift (car (bytes->list bstr)) -4)))

#|
event type value - 4 bits
midi channel - 4 bits
param1 - 1 byte
param2 - 1 byte
|#

(define (midi-handler bstr delta-time previous-midi-command)
  (let ([midi-command (subbytes bstr 0 1)])
      ;([midi-command (bytes (bitwise-and #xF0 (integer-bytes->integer (bytes-append #"\0" (subbytes bstr 0 1)) #t #t 0 2)))])
      ;([midi-command (bytes (integer-bytes->integer (bytes-append (subbytes bstr 0 1) #"\0") #t #t 0 2))])
    (cond
      [(midi-command-equal? midi-note-off-flag midi-command)
       ;param1 note number
       ;param2 velocity
       ;**exercised
       (cons
        (cons (variable-length-data-length delta-time) (make-midi-note-off (get-midi-channel (subbytes bstr 0 1)) (car (bytes->list (subbytes bstr 1 2))) (subbytes bstr 2 3)))
        (read-track-bstr (subbytes bstr 3 (bytes-length bstr)) midi-command))]
      [(midi-command-equal? midi-note-on-flag midi-command)
       ;param1 note number
       ;param2 velocity
       ;**exercised
       (cons
        (cons (variable-length-data-length delta-time) (make-midi-note-on (get-midi-channel (subbytes bstr 0 1)) (car (bytes->list (subbytes bstr 1 2))) (subbytes bstr 2 3)))
        (read-track-bstr (subbytes bstr 3 (bytes-length bstr)) midi-command))]
      [(midi-command-equal? midi-note-aftertouch-flag midi-command)
       ;normal recursive call
       ;**not
       (read-track-bstr (subbytes bstr 3 (bytes-length bstr)) midi-command)]
      [(midi-command-equal? midi-controller-flag midi-command)
       ;normal recursive call
       ;**exercised
       (read-track-bstr (subbytes bstr 3 (bytes-length bstr)) midi-command)]
      [(midi-command-equal? midi-program-change-flag midi-command)
       ;different recursive call
       ;**exercised
       (read-track-bstr (subbytes bstr 2 (bytes-length bstr)) midi-command)]
      [(midi-command-equal? midi-channel-aftertouch-flag midi-command)
       ;different recursive call
       ;**not
       (read-track-bstr (subbytes bstr 2 (bytes-length bstr)) midi-command)]
      [(midi-command-equal? midi-pitch-bend-flag midi-command)
       ;normal recursive call
       ;**not
       (read-track-bstr (subbytes bstr 3 (bytes-length bstr)) midi-command)]
      ;if the command is the same as the previous command, then it isn't stored in the file. http://everything2.com/user/arfarf/writeups/MIDI+running+status
      ;just append it to the bstr and try again.
      [else (midi-handler (bytes-append previous-midi-command bstr) delta-time #"")])))
      
#|
       #;(printf "command ~a\nchannel ~a\n" 
                    (car (bytes->list midi-command))
                    #;(bitwise-and #xF0 (integer-bytes->integer (bytes-append #"\0" (subbytes bstr 0 1)) #t #t 0 2))
                    (get-midi-channel (subbytes bstr 0 1)))])))
  #;(cons (midi-event-handler (subbytes track-bstr (variable-length-total-length delta-time) (+ 3 (variable-length-total-length delta-time))))
                      (read-track-bstr (subbytes track-bstr (+ 3 (variable-length-total-length delta-time)) (bytes-length track-bstr))))
|#

(define (get-midi-channel bstr)
  (bitwise-and #x0F (car (bytes->list bstr))))

(define (variable-length-data-length p)
  (cond
    [(or (equal? 1 (car p))
         (equal? 3 (car p))
         (equal? 7 (car p)))
     ;add a zero byte to bring it up to 2 or 4 and then convert and return
     (integer-bytes->integer (bytes-append #"\0" (cdr p)) #t #t 0 (+ 1 (car p)))]
    [(equal? 5 (car p))
     (integer-bytes->integer (bytes-append #"\0\0\0" (cdr p)) #t #t 0 (+ 3 (car p)))]
    [(equal? 6 (car p))
     (integer-bytes->integer (bytes-append #"\0\0" (cdr p)) #t #t 0 (+ 2 (car p)))]
    [(or (equal? 2 (car p))
         (equal? 4 (car p))
         (equal? 8 (car p)))
     (integer-bytes->integer (cdr p) #t #t 0 (car p))]
    [else (printf "problem in variable-length-data-length\n")]))

(define (variable-length-total-length p)
  (+ (car p) (variable-length-data-length p)))

#;(define (midi-event-handler track-bstr)
  (let* ([delta-time (read-variable-length-part track-bstr 0)] ; time since last event...
         [data-length (car delta-time)]) 
     (midi-inner-handler (subbytes track-bstr
                                   data-length
                                   (bytes-length track-bstr)))))

; from http://253.ccarh.org/handout/smf/
#|
Several different values in SMF events are expressed as variable length quantities (e.g. delta time values). A variable length value uses a minimum number of bytes to hold the value, and in most circumstances this leads to some degree of data compresssion.
A variable length value uses the low order 7 bits of a byte to represent the value or part of the value. The high order bit is an "escape" or "continuation" bit. All but the last byte of a variable length value have the high order bit set. The last byte has the high order bit cleared. The bytes always appear most significant byte first.

Here are some examples:

   Variable length              Real value
   0x7F                         127 (0x7F)
   0x81 0x7F                    255 (0xFF)
   0x82 0x80 0x00               32768 (0x8000)
|#






(define (read-bytes in-stream length)
  (list->bytes (read-bytes-innards in-stream length)))

(define (read-bytes-innards in-stream length)
  (if (> length 0)
      (let ([b (read-byte in-stream)])
        (if (eof-object? b)
            '()
            (cons b (read-bytes-innards in-stream (- length 1)))))
      '()))

(define (play-back-notes evts)
  (with-midi-handle midi-handle  
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

(provide parse-file
         parse-stream
         connect-to-midi
         read-midi
         (struct-out parsed-midi))