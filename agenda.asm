
;http://wiki.osdev.org/Real_mode_assembly_I
;linha nova
;oi

bits 16
org 0x7c00
	xor ax,ax
	mov ds,ax
	mov es, ax
	mov ss,ax ;set up the stack
	mov sp,0X7C00 ; pilha comeca em 0x7c00

	mov si, agenda_
	call print_string

struc   contato
	nome:	resw	10
	telefone:	resd	10 ;tem que checar quantos bytes precisa
	grup:	resb	10
	email:	resw	10
	valid_bit:	resb	1
endstruc

;https://www.csee.umbc.edu/courses/undergraduate/313/spring05/burt_katz/lectures/Lect10/structuresInAsm.html
	
loop_principal:
	mov si, prompt
	call print_string

	mov di, buffer
	call get_string

	mov si, buffer
   	cmp byte [si], 0  ; blank line?
   	je loop_principal      ; yes, ignasnore it

   	mov si, buffer
   	mov di, cadastrar  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_cadastrar

   	;xor di,di

   	mov si, buffer
   	mov di, buscar  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_buscar

   	;xor di,di

   	mov si, buffer
   	mov di, editar_contato  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_editar

   	;xor di,di

   	mov si, buffer
   	mov di, deletar_contato  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_deletar

   	;xor di,di

   	mov si, buffer
   	mov di, listar_grupos  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_listarg

   	;xor di,di

   	mov si, buffer
   	mov di, listar_contatos  ; "hi" command // aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc .cmd_listarc

   	;xor di,di

   	mov si, badcommand
   	call print_string
   	jmp loop_principal

.cmd_cadastrar:
 	;area do codigo onde iremos alocar na memoria os dados (acho que da pra usar a funcao get_string)
 	mov si, cadastrar
   	call print_string

   	mov si, pular_linha
   	call print_string

   	mov si, type_nome
   	call print_string
   	jmp get_name

   	.get_name:
   	mov di, buffer
	call get_string

	mov si, buffer
   	cmp byte [si], 0  ; blank line?
   	je get_name      ; yes, ignasnore it






 	jmp loop_principal

.cmd_buscar:
	;area do cod...
	mov si, buscar
  	call print_string
	
	jmp loop_principal

.cmd_editar:
	mov si, editar_contato
  	call print_string
	
	jmp loop_principal

.cmd_deletar:
	mov si, deletar_contato
  	call print_string
	
	jmp loop_principal

.cmd_listarg:
	mov si, listar_grupos
  	call print_string
	
	jmp loop_principal

.cmd_listarc:
	mov si, listar_contatos
  	call print_string
	
	jmp loop_principal

;db
prompt db '>', 0
type_nome db 'Digite o nome', 0X0D, 0X0A, 0
agenda_ db 'ola sejam bem vindos a agenda!', 0X0D, 0X0A, 0
pular_linha db 0X0D, 0X0A, 0
cadastrar db 'cadastrar', 0
buscar db 'buscar', 0
editar_contato db 'editar',0	
deletar_contato db 'deletar', 0
listar_grupos db 'listarg', 0
listar_contatos db 'listarc', 0
badcommand db 'Bad command entered.', 0x0D, 0x0A, 0
buffer times 64 db 0

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
		je .done      ; yes, we"re done
		
		cmp cl, 0x3F  ; 63 chars inputted?
		je .loop      ; yes, only let in backspace and enter
		
		mov ah, 0x0E
		int 0x10      ; print out character
		
		stosb  ; put character in buffer
		inc cl
		jmp .loop
		
.backspace:
	cmp cl, 0	; beginning of string?
  	je .loop	; yes, ignore the key
	
  	dec di
  	mov byte [di], 0	; delete character
  	dec cl		; decrement counter as well
	
  	mov ah, 0x0E
  	mov al, 0x08
  	int 10h		; backspace on the screen
	
  	mov al, " "
  	int 10h		; blank character out
	
  	mov al, 0x08
  	int 10h		; backspace again
	
  	jmp .loop	; go to the main loop
 
 .done:
 	mov al, 0	; null terminator
 	
 	stosb	
 	
 	mov ah, 0x0E
 	mov al, 0x0D
 	int 0x10
 	
 	mov al, 0x0A
 	int 0x10		; newline	
 	
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



   times 510-($-$$) db 0
   dw 0AA55h ; some BIOSes require this signature
