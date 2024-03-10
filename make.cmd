@echo off
if not exist tmp (
    mkdir tmp
)

for %%i in (cbmbasic1 cbmbasic2 kbdbasic osi kb9 applesoft microtan aim65 sym1) do (
    echo %%i
    C:\CC65\bin\ca65 -D %%i msbasic.s -o tmp\%%i.o
    C:\CC65\bin\ld65 -C %%i.cfg tmp\%%i.o -o tmp\%%i.bin -Ln tmp\%%i.lbl
)
