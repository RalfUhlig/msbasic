.setcpu "65c02"
.segment "BIOS"
.debuginfo

ACIA_DATA = $5000 ; 6551 Data Register.
ACIA_STATUS = $5001 ; 6551 Status Register.
ACIA_CMD = $5002 ; 6551 Command Register.
ACIA_CTRL = $5003 ; 6551 Control Register.

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
                LDA ACIA_STATUS
                AND #$08
                BEQ @NO_KEY_PRESSED
                LDA ACIA_DATA
                JSR CHROUT            ; Echo
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

.include "wozmon.s"

.segment "RESETVEC"
                .word   $0F00          ; NMI vector
                .word   RESET          ; RESET vector
                .word   $0000          ; IRQ vector