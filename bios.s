.setcpu "65c02"
.debuginfo

.zeropage
                .org ZP_START0
READ_PTR:       .res 1
WRITE_PTR:      .res 1

.segment "INPUT_BUFFER"
INPUT_BUFFER:   .res 256

.segment "BIOS"

ACIA_DATA = $5000 ; 6551 Data Register.
ACIA_STATUS = $5001 ; 6551 Status Register.
ACIA_CMD = $5002 ; 6551 Command Register.
ACIA_CTRL = $5003 ; 6551 Control Register.

T1LL = $6006 ; 6522 Timer 1 Latch Low
T1LH = $6007 ; 6522 Timer 1 Latch High
IFR = $600D ; 6522 Interrupt Flag Register

; Dummy function for LOAD.
LOAD:
                RTS

; Dummy function for SAVE.
SAVE:
                RTS
                
; Input a character from the seriel interface.
; On return, carry flag indicates whether a key was pressed.
; If a key was pressed, the key value will be in the A register.
; Modifies: flags, A
MONRDKEY:
CHRIN:
                JSR BUFFER_SIZE
                BEQ @NO_KEY_PRESSED
                JSR READ_BUFFER
                JSR CHROUT            ; Echo
                PHA
                JSR BUFFER_SIZE       ; Check if buffer is still mostly full.
                CMP #$B0
                BCS @MOSTLY_FULL
                LDA ACIA_CMD          ; Set ~DTR to low by setting bit 0 to 1.
                ORA #$01
                STA ACIA_CMD
@MOSTLY_FULL:
                PLA
                SEC                   ; Indicate key was pressed.
                RTS
@NO_KEY_PRESSED:
                CLC                   ; Indicate no key was pressed.
                RTS

; Output a character from the A register to the serial interface.
; Modifies: flags
MONCOUT:
CHROUT:
                PHA
                STA ACIA_DATA
@TX_WAIT:
                LDA ACIA_STATUS
                AND #$10
                BEQ @TX_WAIT
                PLA
                RTS

; Initialize circular input buffer.
; Modifies: flag, A
INIT_BUFFER:
                LDA READ_PTR    ; Set write pointer equal to read pointer.
                STA WRITE_PTR
                RTS

; Write a character from the A register to the input buffer.
; Modifies: flags
WRITE_BUFFER:
                PHX
                LDX WRITE_PTR
                STA INPUT_BUFFER, X
                INC WRITE_PTR
                PLX
                RTS

; Read a character from the input buffer to the A register.
; Modifies: flags, A
READ_BUFFER:
                PHX
                LDX READ_PTR
                LDA INPUT_BUFFER, X
                INC READ_PTR
                PLX
                RTS

; Get number of unread bytes in the A register.
; Modifies: flags, A
BUFFER_SIZE:
                LDA WRITE_PTR
                SEC
                SBC READ_PTR
                RTS

; Interrupt request handler.
IRQ_HANDLER:
                PHA
                PHX
                LDA ACIA_STATUS   ; Reset interrupt flag of ACIA.
                BPL @NOT_FULL     ; Skip if not ACIA interrupr.
                LDA ACIA_DATA     ; Read character from seriel interface.
                JSR WRITE_BUFFER  ; Store character in the buffer.
                JSR BUFFER_SIZE   ; Check if the buffer is mostly full.
                CMP #$F0
                BCC @NOT_FULL
                LDA ACIA_CMD      ; Set ~DTR to high by setting bit 0 to 0.
                AND #$FE
                STA ACIA_CMD
@NOT_FULL:
                LDA IFR
                BPL @IRQ_EXIT     ; No interrupt from 6522
                LDA PORTB         ; PB7 will be th current sound phase.
                BMI @SND2         ; if PB7 is set, set time to SND2.
                LDA SND1+1        ; otherwise set timer to SND1.
                STA T1LL
                LDA SND1
                STA T1LH
                JMP @IRQ_EXIT
@SND2:
                LDA SND2+1
                STA T1LL
                LDA SND2
                STA T1LH
@IRQ_EXIT:
                PLX
                PLA
                RTI

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   IRQ_HANDLER    ; IRQ vector