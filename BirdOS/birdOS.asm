org 0x7C00   ; add 0x7C00 to label addresses
 bits 16      ; tell the assembler we want 16 bit code

section .data


segment .bss
num resb 5
num1 resb 2
num2 resb 2
res resb 1

 global _start  ;must be declared for using gcc
section .text
   mov ax, 0  ; set up segments
   mov ds, ax
   mov es, ax
   mov ss, ax     ; setup stack
   mov sp, 0x7C00 ; stack grows downwards from 0x7C00
 
   mov si, welcome
   call print_string
 
 mainloop:
   mov si, prompt
   call print_string
 
   mov di, buffer
   call get_string
 
   mov si, buffer
   cmp byte [si], 0  ; es una linea en blanco
   je mainloop       ; si lo es ignore y regrese a menu
 
   mov si, buffer
   mov di, cmd_hi  ; comando hola
   call strcmp
   jc .hola_mundo
 
   mov si, buffer
   mov di, cmd_apagar  ; comando apagado
   call strcmp
   jc .apagado

   mov si, buffer
   mov di, cmd_sonido  ; comando sonido
   call strcmp
   jc .ircalc

   mov si, buffer
   mov di, cmd_help  ; "help" command
   call strcmp
   jc .ayuda
 
   mov si,badcommand
   call print_string 
   jmp mainloop  
 
 ;//////////////////////////comando hola mundo
 .hola_mundo:
   mov si, msg_helloworld
   call print_string
   jmp mainloop

;//////////////////////////comando apagado
.apagado:
    mov ax, 0x1000
    mov ax, ss
    mov sp, 0xf000
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15

 ;///////////////////////comando help
 .ayuda:
   mov si, msg_help
   call print_string
   jmp mainloop

;///////////////////////comando sonido

.ircalc:
   mov ah, 0x02                    ; carga el proceso de calculadora
    mov al, 1                       ; numero de sectores a leer en memoria
    mov dl, 0x80                    ; sector leido de fixed/usb disk
    mov ch, 0                       ; numero ciclico
    mov dh, 0                       ; numero de cabeza 
    mov cl, 2                       ; numero de sector sector number
    mov bx, calculadora             ; carga en es en el segmento bx
    int 0x13                        ; interrupcion de E/S
    jmp calculadora                 ; salta a el proceso calculadora


 welcome db 'Bienvenido a birdOS!', 0x0D, 0x0A, 0
 msg_helloworld db 'Hola, bienvenido a birdOS!', 0x0D, 0x0A, 0
 badcommand db 'El comando no existe.', 0x0D, 0x0A, 0
 prompt db '-->', 0
 cmd_hi db 'hola', 0
 cmd_apagar db 'apagar', 0
 cmd_sonido db 'calc', 0
 cmd_help db 'ayuda', 0
 msg_help db 'comandos birdOS: hola, apagar, calc, ayuda', 0x0D, 0x0A, 0

 
 msg3 db 'la suma es: ', 0x0D, 0x0A, 0
msg4 db 'la resta es:', 0x0D, 0x0A, 0
buffer times 64 db 0
 
 ; ================
 ; comienza las llamadas en este bloque
 ; ================
 
 print_string:
   lodsb        ; grab a byte from SI
 
   or al, al  ; logical or AL by itself
   jz .done   ; if the result is zero, get out
 
   mov ah, 0x0E
   int 0x10      ; otherwise, print out the character!
 
   jmp print_string
 
 .done:
   ret
 
 get_string:
   xor cl, cl
 
 .loop:
   mov ah, 0
   int 0x16   ; wait for keypress
 
   cmp al, 0x08    ; backspace pressed?
   je .backspace   ; yes, handle it
 
   cmp al, 0x0D  ; enter pressed?
   je .done      ; yes, we're done
 
   cmp cl, 0x3F  ; 63 chars inputted?
   je .loop      ; yes, only let in backspace and enter
 
   mov ah, 0x0E
   int 0x10      ; print out character
 
   stosb  ; put character in buffer
   inc cl
   jmp .loop
 
 .backspace:
   cmp cl, 0    ; beginning of string?
   je .loop ; yes, ignore the key
 
   dec di
   mov byte [di], 0 ; delete character
   dec cl       ; decrement counter as well
 
   mov ah, 0x0E
   mov al, 0x08
   int 10h      ; backspace on the screen
 
   mov al, ' '
   int 10h      ; blank character out
 
   mov al, 0x08
   int 10h      ; backspace again
 
   jmp .loop    ; go to the main loop
 
 .done:
   mov al, 0    ; null terminator
   stosb
 
   mov ah, 0x0E
   mov al, 0x0D
   int 0x10
   mov al, 0x0A
   int 0x10     ; newline
 
   ret
 


 strcmp:
 .loop:
   mov al, [si]   ; grab a byte from SI
   mov bl, [di]   ; grab a byte from DI
   cmp al, bl     ; are they equal?
   jne .notequal  ; nope, we're done.
 
   cmp al, 0  ; are both bytes (they were equal before) null?
   je .done   ; yes, we're done.

   inc di     ; increment DI
   inc si     ; increment SI
   jmp .loop  ; loop!
 
 .notequal:
   clc  ; not equal, clear the carry flag
   ret
 
 .done:     
   stc  ; equal, set the carry flag
   ret
 





 ;////////////////////////////////////booteo
   times 510-($-$$) db 0

   dw 0AA55h ; some BIOSes require this signature



calculadora:


    mov ax,0x00             ; get keyboard input
    int 0x16                ; hold for input
    mov dl,al

    mov ax,0x00             ; get keyboard input
    int 0x16                ; hold for input
    mov cl,al

je .suma

.suma:

   ;/////////////////////////////////suma
    mov bh, dl
    sub bh, '0'    
    mov ch,  cl
    sub ch, '0'
   
    add bh, ch

    add bh, '0'
    mov [res], bh

    mov si,msg3
    call print_string

    mov si, res
    call print_string
    int 0x10     ; newline
    int 0x10     ; newline

    ;////////////////////////////////Resta
    mov bh, dl
    sub bh, '0'    
    mov ch,  cl
    sub ch, '0'

    sub bh, ch

    add bh, '0'
    mov [res], bh

    mov si,msg4
    call print_string

    mov si, res
    call print_string
    int 0x10     ; newline
    int 0x10     ; newline

   
    int 0x10     ; newline

    

   

;////////////////////////////////////////////////////////////////////////////
   ;msg3 db 'la suma es: ', 0x0D, 0x0A, 0
   ;msg4 db 'la resta es:', 0x0D, 0x0A, 0
   ;msg5 db 'la multiplicacion es:', 0x0D, 0x0A, 0
   ;msg6 db 'la division de numero1/2 es: ', 0x0D, 0x0A, 0
   ;msg7 db 'la division no se puede realizar ecx es cero ', 0x0D, 0x0A, 0
   ;msg8 db '----------------<>---------------------------', 0x0D, 0x0A, 0

jmp mainloop
   






     ; add how much memory we need
    times (2048 - ($-$$)) db 0x00
                                   
   