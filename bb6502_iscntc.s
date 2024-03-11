ISCNTC:
              JSR MONRDKEY
              BCC @NOT_CNTC
              CMP #3
              BEQ @IS_CNTC
@NOT_CNTC:
              RTS

@IS_CNTC:
              ; Fall through.