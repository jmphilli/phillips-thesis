#lang scheme

(provide read-variable-length-part)

(define (read-variable-length-part bstr start)
  (let ([p (read-variable-length-part-innards bstr start)])
    (cons (bytes-length p) (remove-escape-bits p))))

(define continue-bit #b10000000)

(define (read-variable-length-part-innards bstr start)
  (let* ([byte (subbytes bstr start (+ 1 start))]
         [byte-i (integer-bytes->integer (bytes-append #"\0" byte) #t #t)]) ; todo possible error
    (if (equal? continue-bit (bitwise-and continue-bit byte-i));continue/escape bit is set, read the next 2 bytes
        (bytes-append byte (read-variable-length-part-innards bstr (+ 1 start)))
        byte)
    ))

(define (four-byte-handler bstr)
  (let* ([blst (bytes->list bstr)]
         [right-byte (bitwise-and #b01111111 (fourth blst))])
    (if (equal? #b00000001 (bitwise-and #b00000001 (third blst)))
        ;need to set highbit in right-byte to be on
        (let* ([right-byte (bitwise-ior #b10000000 right-byte)]
               [mid-right-byte (arithmetic-shift (bitwise-and #b01111110 (third blst)) -1)])
          (cond 
            [(equal? #b00000011 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b11000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [(equal? #b00000010 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b10000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [(equal? #b00000001 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b01000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [else 
             (let ([mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]))
        ;do nothing
        (let ([mid-right-byte (arithmetic-shift (bitwise-and #b01111110 (third blst)) -1)])
          (cond 
            [(equal? #b00000011 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b11000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [(equal? #b00000010 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b10000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [(equal? #b00000001 (bitwise-and #b00000011 (second blst)))
             (let* ([mid-right-byte (bitwise-ior #b01000000 mid-right-byte)]
                    [mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))]
            [else 
             (let ([mid-left-byte (arithmetic-shift (bitwise-and #b01111100 (second blst)) -2)])
               (cond 
                 [(equal? #b00000111 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000110 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b11000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000101 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b10100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000100 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b1000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000011 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000010 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b01000000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [(equal? #b00000001 (bitwise-and #b00000111 (first blst)))
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         (bitwise-ior #b00100000 mid-left-byte)
                         mid-right-byte
                         right-byte)]
                 [else
                  (bytes (arithmetic-shift (bitwise-and #b01111000 (first blst)) -3)
                         mid-left-byte
                         mid-right-byte
                         right-byte)]))])))))


#| ************************************ |#
;don't read this. it is super gross
(define (remove-escape-bits bstr)
    (cond
      [(> (bytes-length bstr) 4) ;TODO this is broken. 100% broken. i either need a 4 vs 8 case or to finally write this functionally
       (let* ([four-byte-string (subbytes bstr (- (bytes-length bstr) 4) (bytes-length bstr))]
              #;[rest (arithmetic-shift (integer-bytes->integer bstr #t #t 0 (- (bytes-length bstr) 4)))]
              [rest (subbytes bstr 0 (- (bytes-length bstr) 4))])
       (bytes-append (remove-escape-bits rest) (four-byte-handler four-byte-string)))]
      
      [(eq? (bytes-length bstr) 4)
       (four-byte-handler bstr)]
      
      [(eq? (bytes-length bstr) 3) 
       (let* ([blst (bytes->list bstr)]
              [right-byte (bitwise-and #b01111111 (third blst))])
         (if (equal? #b00000001 (bitwise-and #b00000001 (second blst)))
             ;need to set highbit in right-byte to be on
             (let* ([right-byte (bitwise-ior #b10000000 right-byte)]
                    ;i want 6 bits for the middle byte from the middle byte. then i take the two bits from the leftmost byte for the middle byte. 
                    [middle-byte (arithmetic-shift (bitwise-and #b01111110 (second blst)) -1)])
               (cond 
                 [(equal? #b00000011 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b11000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [(equal? #b00000010 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b10000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [(equal? #b00000001 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b01000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [else (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte)])
               )
             ;continue, eg right-byte is fine as it is.
             (let ([middle-byte (arithmetic-shift (bitwise-and #b01111110 (second blst)) -1)])
               (cond 
                 [(equal? #b00000011 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b11000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [(equal? #b00000010 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b10000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [(equal? #b00000001 (bitwise-and #b00000011 (first blst)))
                  (let ([middle-byte (bitwise-ior #b01000000 middle-byte)])
                    (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte))]
                 [else (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -2) middle-byte right-byte)]))
             ))]
      
      [(eq? (bytes-length bstr) 2) ;save the rightmost bits as they are. but for the high bit in the penultimate half byte use the first bit from the antipenultimate half byte
       (let* ([blst (bytes->list bstr)]
              [right-byte (bitwise-and #b01111111 (second blst))])
         (if (equal? #b00000001 (bitwise-and #b00000001 (first blst)))
             ;set the highbit in right-byte to be on
             (let ([right-byte (bitwise-ior #b10000000 right-byte)])
               (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -1)
                      right-byte)) ;this bitwise-and turns off the high bit because the high bit should be on as it needs to continue
             ;do nothing, continue
             (bytes (arithmetic-shift (bitwise-and #b01111111 (first blst)) -1)
                      right-byte)))]
      
      [(eq? (bytes-length bstr) 1) ;return second half byte as it is, return first half byte as it is, but a zero in the high bit guaranteed
       (bytes (bitwise-and #b01111111 (first (bytes->list bstr))))]))



#| Test Cases |#
#|
;1 byte
(equal? #"\177" (cdr (read-variable-length-part (bytes #x7F) 0)))
(equal? #"3" (cdr (read-variable-length-part (bytes #x33) 0)))
(equal? #"B" (cdr (read-variable-length-part (bytes #x42) 0)))
(equal? #"\1" (cdr (read-variable-length-part (bytes #x01) 0)))
(equal? #"\0" (cdr (read-variable-length-part (bytes #x00) 0)))

;2 bytes
(equal? #"?\377" (cdr (read-variable-length-part (bytes #xFF #x7F) 0)))
(equal? #"\t\342" (cdr (read-variable-length-part (bytes #x93 #x62) 0)))
(equal? #"\0\343" (cdr (read-variable-length-part (bytes #x81 #x63) 0)))

;3 bytes
(equal? (bytes 31 199 194) (cdr (read-variable-length-part (bytes #xFF #x8F #x42) 0)))
(equal? (bytes 28 0 66) (cdr (read-variable-length-part (bytes #xF0 #x80 #x42) 0)))
(equal? (bytes 0 137 51) (cdr (read-variable-length-part (bytes #x82 #x92 #x33) 0)))
(equal? (bytes 28 0 66) (cdr (read-variable-length-part (bytes #xF0 #x80 #x42) 0)))
(equal? (bytes 28 0 66) (cdr (read-variable-length-part (bytes #xF0 #x80 #x42) 0)))

;4 bytes
(equal? (bytes 14 0 17 194) (cdr (read-variable-length-part (bytes #xF0 #x80 #xA3 #x42) 0)))
(equal? (bytes 2 0 0 0) (cdr (read-variable-length-part (bytes #x90 #x80 #x80 #x00) 0)))
(equal? (bytes 4 21 4 196) (cdr (read-variable-length-part (bytes #xA0 #xD4 #x89 #x44) 0)))
(equal? (bytes 8 31 225 41) (cdr (read-variable-length-part (bytes #xC0 #xFF #xC2 #x29) 0)))

;5 bytes
(equal? (bytes 1 14 0 17 194) (cdr (read-variable-length-part (bytes #x90 #xF0 #x80 #xA3 #x42) 0)))
|#
;(equal? #b0011111111111111 (integer-bytes->integer (cdr (read-variable-length-part (bytes #xFF #x7F) 0)) #t #t 0 2))

;(equal? (remove-escape-bits (bytes #b01111111)) (remove-escape-bits (bytes #b11111111))) ; should be true
;(equal? (remove-escape-bits (bytes #b01111111 #b01111111)) (remove-escape-bits (bytes #b11111111 #b01111111)))
;(equal? (remove-escape-bits (bytes #b01111110 #b01111111)) (remove-escape-bits (bytes #b11111110 #b01111111)))
;(equal? (remove-escape-bits (bytes #b01111111 #b11111111 #b11111111)) (remove-escape-bits (bytes #b11111111 #b11111111 #b11111111)))
;(remove-escape-bits (bytes #x7F #xFF #xFF #xFF))

;(equal? (cdr (read-variable-length-part #"\271\a\177" 0)))
