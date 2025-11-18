printf:
p_loop:
    lodsb
    cmp al, 0
    je p_done
    mov ah, 0x0E
    mov bh, 0x00
    mov bl, 0x07
    int 0x10
    jmp p_loop
p_done:
    ret

endl:
    mov ah, 0x0E
    mov al, 13
    int 0x10
    mov al, 10
    int 0x10
    ret

cmdinp:
    mov ah, 0x00
    int 0x16
    cmp al, '$'
    je isdollar
    cmp al, 13
    je enterpressed

    ;verificare prim element
    mov ah,0x03 	
    mov bh, 0x00
    int 0x10
    cmp dl, 0
    je setpos1

    mov [i_buffer], al
    mov [i_buffer+1],0
    mov si, i_buffer
    call printf
    ret
isdollar:
    ret
setpos1:
    mov ah,0x02
    mov bh,0x00
    inc dl
    int 0x10
    ret
enterpressed:
    mov si,
    call endl
    mov al,'$'
    mov ah,0x0E
    int 0x10
    ret

verif:
    

;=====DATA=====
i_buffer db 2 dup(0)