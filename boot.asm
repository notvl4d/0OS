BITS 16
ORG 0x7C00
start:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    mov si, mesaj1
    call printf
    call endl
    mov si, mesaj2
    call printf
    call endl
    call user_input
    jmp next

user_input:
    cmp al,0
    je .after
    mov ah,0x00
    int 0x16
.after:
    ret

next: 				;incarca stage 2
    mov ah, 0x02
    mov cl, 0x02
    mov al, 1
    mov ch, 0x00
    mov dh, 0x00
    xor bx,bx
    mov es, bx
    mov bx, 0x8000
    int 0x13
    jmp 0x0000:0x8000


;=====DATA=====    

mesaj1 db "Salut!",0
mesaj2 db "Apasa orice tasta pentru a continua",0

%include "functions.asm"

times 510-($-$$) db 0
dw 0xAA55
