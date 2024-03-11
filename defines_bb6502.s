; configuration
CONFIG_2A := 1

CONFIG_SCRTCH_ORDER := 2

; zero page
ZP_START1 = $00
ZP_START2 = $0A
ZP_START3 = $60
ZP_START4 = $6B

; extra/override ZP variables
USR	:= GORESTART

; inputbuffer
;INPUTBUFFER     := $0200

; constants
SPACE_FOR_GOSUB := $3E
STACK_TOP		    := $FA
WIDTH			      := 80
WIDTH2			    := 80
RAMSTART2		    := $0400

; monitor functions
; defined in bios.s
