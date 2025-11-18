BITS 16
ORG 0x8000
start:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov si, msg1
    call printf
    call endl
    mov si, msg2
    call printf
    
loop:
    call cmdinp
    jmp loop

;=====DATA=====
msg1 db "Stage 2 a fost incarcat.",0
msg2 db "$",0

%include "functions.asm"
