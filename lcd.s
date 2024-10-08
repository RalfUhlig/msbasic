.segment "CODE"
.ifdef BB6502

PORTB = $6000   ; 6522 Port B
DDRB  = $6002   ; 6522 Data Direction Register Port B
E     = %01000000
RW    = %00100000
RS    = %00010000

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy
  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_send:
  sta PORTB
  ora #E      ; Set E bit to send instruction
  sta PORTB
  eor #E      ; Clear E bit
  sta PORTB
  rts

lcd_print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  jsr lcd_send
  pla
  pha
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  jsr lcd_send
  pla
  rts

LCDINIT:
  lda #%11111111 ; Set all pins of port B to output
  sta DDRB

  jsr lcd_wait
  lda #%00000011 ; Set 8-bit mode three times to ensure being in 8-bit mode
  jsr lcd_send   ; and not in an incomplete 4-bit cycle
  jsr lcd_wait
  jsr lcd_send
  jsr lcd_wait
  jsr lcd_send
  jsr lcd_wait
  
  lda #%00000010 ; Set 4-bit mode
  jsr lcd_send
  and #%00001111
  sta PORTB
  
  lda #%00101000 ; Set 4-bit mode, 2-line display, 5x8 font 
  jsr lcd_instruction
  lda #%00001110 ; Set display on, cursor on, blink off 
  jsr lcd_instruction
  lda #%00000110 ; Increment and shift cursor, dont't shift display
  jsr lcd_instruction
  lda #%00000001 ; Clear display
  jsr lcd_instruction
  rts

LCDCMD:
  jsr GETBYT
  txa
lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  jsr lcd_send
  pla
  pha
  and #%00001111 ; Send low 4 bits
  jsr lcd_send
  pla
  rts

LCDPRINT:
  jsr FRMEVL            ; Evaluate formular
  bit VALTYP            ; Is it a string?
  bmi lcd_print_string  ; Yes
  jsr FOUT              ; Format floating point output
  jsr STRLIT            ; Build string descriptor
lcd_print_string:
  jsr FREFAC            ; Returns temp pointer to string
  tax                   ; Put count to counter
  ldy #0
  inx                   ; Move one ahead
lcd_print_next:
  dex
  beq lcd_print_end     ; All done
  lda (INDEX),y         ; Load char of string
  jsr lcd_print_char    ; Output to lcd
  iny
  bne lcd_print_next    ; Go on with next char
lcd_print_end:
  rts

.endif
