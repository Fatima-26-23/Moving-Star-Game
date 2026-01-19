[org 0x0100]
jmp start
clear: 
mov di,0
clearing: mov word [es:di], 0x7020
add di,2
cmp di,4000
jne clearing
ret
place_obstacles:
mov di,650
mov si,570
mov bp,1030
vertical:
mov word[es:di], 0x2220
mov word[es:si], 0x2220
mov word[es:bp], 0x2220
add di,160
add si,160
add bp,160
cmp di,1610
jne vertical
mov di,910
mov si,824
mov bp,2108
horizontal:
mov word[es:si], 0x2220
mov word[es:di], 0x2220
mov word[es:bp], 0x2220
add di,2
add si,2
add bp,2
cmp si,852
jne horizontal
mov di,158
end_green: mov word[es:di],0x2220
add di,160
cmp di,3998 
jne end_green
mov di,0
mov word [es:di],0x4420
ret
place_player:
mov di, 3920
mov word [es:di], 0x712A
ret
timer:
     push ax
    push bx
    push cx
    push dx
    push si
    push di
    inc word [tickcount]
    cmp word [tickcount], 2
    jb continueTimer
    mov word [tickcount], 2
continueTimer:
    mov al, 20h
    out 20h, al
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    iret
keys:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ah, 0
    int 16h          
    cmp al, 0         
    jne normalKey
    int 16h            
    mov al, ah         
normalKey:
    cmp al, 4Dh        
    je r
    cmp al, 4Bh        
    je l
    cmp al, 48h        
    je U
    cmp al, 50h        
    je D
    jmp keys
r: mov byte [direction], 1
   jmp keysdone
l: mov byte [direction], 2
   jmp keysdone
U: mov byte [direction], 3
   jmp keysdone
D: mov byte [direction], 4
   jmp keysdone
moveplayer:
    mov di,[playerPos]     
    mov word [es:di],0x7020 

    cmp byte [direction],1
    je moveRight
    cmp byte [direction],2
    je moveLeft
    cmp byte [direction],3
    je moveUp
    cmp byte [direction],4
    je moveDown
    ret
moveRight: add di,2
           jmp collision
moveLeft:  sub di,2
           jmp collision
moveUp:    sub di,160
           jmp collision
moveDown:  add di,160
           jmp collision
collision:
    cmp di,0
    je done
    mov si,650
    mov bp,570
    mov dx,1030
checkV:
    cmp di,si
    je lost
    cmp di,bp
    je lost
    cmp di,dx
    je lost
    add si,160
    add bp,160
    add dx,160
    cmp si,1610
    jne checkV

    mov si,910
    mov bp,824
    mov dx,2108
checkH:
    cmp di,si
    je lost
    cmp di,bp
    je lost
    cmp di,dx
    je lost
    add si,2
    add bp,2
    add dx,2
    cmp bp,852
    jne checkH

    mov si,158
ending:
    cmp di,si
    je lost
    add si,160
    cmp si,3998
    jne ending

    mov word [es:di],0x712A
    mov [playerPos],di
    ret
keysdone:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
done:
mov dx,win
mov ah,9h
int 0x21
jmp end
lost:
mov dx,loser
mov ah,9h
int 0x21
jmp end

start:
mov ax, 0xb800
mov es, ax 
call clear
call place_obstacles
call place_player
jmp main
main:
   cli
    mov ax, 0xb800
    mov es, ax
    mov ax, cs
    mov ds, ax
    push es
    xor ax,ax
    mov es,ax
    cli
    mov word [es:8*4], timer
    mov [es:8*4+2], cs
    pop es
    sti
mainloop:
    call keys    
    cmp byte [tickcount],2
    jb loop1
    mov word [tickcount],0
    call moveplayer
loop1:
    jmp mainloop

end:
mov ax,0x4c00
int 0x21
win: db "GAME WIN$",0
playerPos: dw 3920 
tickcount dw 0
loser: db "GAME LOST$",0
direction: db 1;1 for right