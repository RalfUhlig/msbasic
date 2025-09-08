.segment "CODE"
.ifdef BB6502

T1CL = $6004
T1CH = $6005
ACR  = $600B
IER  = $600E

BEEP:
  ; Get a 16 bit int parameter for the wave length.
  jsr FRMEVL    ; Call formula evaluator.
  jsr MKINT     ; Make a 16 bit int value, stores in FAC.

  ; Check if parameter is zero.
  lda FAC+4
  ora FAC+3
  ; If zero, turn off sound.
  beq @silent

  ; Store parameter in the timer counter registers.
  lda FAC+4
  sta T1CL
  sta SND1+1
  lda FAC+3
  sta SND1
  sta T1CH

  ; Enable timer to generate a sqare wave on PB7 and enable timer interrupts.
  lda #$c0
  sta ACR
  sta IER

  ; Get second parameterand store.
  jsr CHKCOM
  jsr FRMEVL
  jsr MKINT
  lda FAC+4
  sta SND2+1
  lda FAC+3
  sta SND2

@silent:
  ; Get a 8 bit parameter for the sound or silence duration.
  jsr CHKCOM    ; Check for comma.
  jsr GETBYT    ; Get 8 bit value, stored in X.

  ; If zero, sound or silence is unlinited.
  cpx #0
  beq @done

  ; Sound or silence duration delay loop.
@delay1:
  ldy #$ff
@delay2:
  dey
  bne @delay2
  dex
  bne @delay1

  ; Stop square wave to turn off sound.
  lda #0
  sta ACR
  lda #$40    ; Diabel timer interrupts.
  sta IER

@done:
  rts

.endif
