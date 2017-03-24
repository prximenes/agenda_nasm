bits 16
org 0x7c00
jmp 0x0:start

data:
 
start:
xor ax,ax
mov ds,ax
mov es, ax
mov ss,ax
mov sp,0X7C00 ; pilha comeca em 0x7c00

jmp start

times 510-($-$$) db 0
dw 0xAA55


cadastrar db 'cadastar contato', 0X0D, 0X0A, 0
buscar db 'buscar contato' 0X0D, 0X0A, 0
editar_contato db 'editar contato ', 0X0D, 0X0A, 0
deletar_contato db 'deletar contato',0X0D, 0X0A, 0
listar_grupos db 'listar grupos',0X0D, 0X0A, 0
listar_contatos db 'listar contatos', 0X0D, 0X0A, 0


keypress:
	mov ah, 01h     ; modo da chamada para keystroke
   	int 16h
	mov ah, 00h
   	int 16h
    	cmp al, ' '
    	je reset
	jmp keypress
;teste