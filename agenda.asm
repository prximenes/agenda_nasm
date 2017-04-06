;bits 16
org 0x500
jmp 0x0000:loop_principal

struc   contato
	.nome:	resw	10
	.telefone:	resd	10 ;tem que checar quantos bytes precisa
	.grup:	resb	10
	.email:	resw	10
	.valid_bit:	resb	1
	.size:
endstruc


agenda.size EQU 5
nome.size EQU 21
grup.size EQU 11
telefone.size EQU 11
email.size EQU 21

array: times contato.size*5 db 0

%macro readString 2
   push bx
   mov di, %1
   mov cx, %2
   call read
   pop bx
%endmacro

%macro printString 1
   push bx
   mov si, %1
   call print
   pop bx 
%endmacro
%macro zerar 2 ; esses são macros que vão servir futuramente
   mov di, %1
   mov cx, %2
   call fill
%endmacro

%macro find 2
   mov cx, %2
   mov si, %1
   mov ax, %1
   add si, array
   mov di, aux
   call procuraString
%endmacro

__biosprint: ; funcao = printar um char (al = ASCII, bl = cor)
   mov ah, 0xe
   xor bh, bh
   mov bl, 3
   int 10h

   ret

print:
   p1:
      lodsb
      cmp al, 0
      je .sair

      call __biosprint

      jmp p1
   .sair:
      ret

%define tam    [bp-2]
%define cursor    [bp-4]
read:
   mov word tam, cx  ; armazena o tamanho total da string na variável local 'tam'

   ; pega a posição atual do cursor (dh = linha; dl = coluna)
    mov ah, 0x03
    xor bh, bh
    int 0x10

    mov word cursor, dx ; guarda a posição inicial do cursor

    mov cx, word tam
   r1:
      xor ah, ah
      int 16h

      cmp al, 0xd
      je endr

      cmp al, 0x08    ; se o backspace for pressionado, apaga o último caractere
       je apagar

       cmp cx, 0x00
       je r1

       call __biosprint

      stosb
      loop r1
      jmp r1

   apagar:
       cmp cx, word tam
       je r1
    
      mov dx, word tam  ; dx = tamanho total da string
      sub dx, cx        ; dx = quantidade de posições já andadas pelo cursor
      xor dh, dh        ; dh = zera a posição da linha pra somar certo com a posição inicial do cursor
      add dx, word cursor  ; dl = posição do cursor depois da letra errada

       ; move o cursor pra posição anterior = backspace (dec dl)
       mov ah, 0x02
       ; xor bh, bh
       dec dl           ; dl = posição da letra errada
       int 0x10

       ; imprime 'espaço' para apagar o caractere errado e não move a posição do cursor (int 10, a)
       mov al, 0x20        ; espaço
      call __biosprint

      mov ah, 0x02
      ; xor bh, bh
       int 0x10

       inc cx     ; incrementa cx para não alterar o funcionamento da instrução loop
       
       ; armazena '\0' na posição apagada
       dec di
      mov byte[es:di], 0x00

       jmp r1

   endr:
      mov byte[es:di], 0
      ret

fill:
   za:
      mov al, 0
      stosb
      loop za

   ret

procuraString:;essa funcao basicamente procura as strings que estão no array + bx(bx sendo a quantidade de contatos que temos até agora) 
   xor dx, dx ; zera dx
   xor bx, bx ; zera bx
   cld

   ps1:
      ps2:
         cmpsb ;CMPSB compares the byte at [DS:SI] or [DS:ESI](16 bits) with the byte at [ES:DI] or [ES:EDI](32 bits), and sets the flags accordingly. It then increments or decrements (depending on the direction flag: increments if the flag is clear, decrements if it is set) SI and DI (or ESI and EDI).
         je ps3
         jne ps4

         ps3:
            cmp byte[es:di], 0; compara es di(como explicado acima)
            jne ps2 ;se for igual ele vai comparando
            cmp byte[ds:si], 0 ; compara ds si
            jne ps2;se for igual ele vai comparando
            cmp ax, contato.nome ; por fim compara o tamanho (eu acho)
            je ps5;se o tamanho foi igual, sucesso!

            push ax
            lea ax, [(array + bx) + contato.nome]
            printString ax
            printString breakline
            pop ax

            loop ps2
      ps4:
         mov si, array
         mov di, aux ; string a ser procurada
         add bx, contato.size
         add si, bx
         add si, ax
         inc dx
         cmp dx, agenda.size
         jb ps1 ; se dx for menor que agenda.size, repita o processo(caso ele buscou em todas as strings)

   mov ax, 0
   jmp endps

   ps5:
      mov ax, 1

   endps:
      ret
	
loop_principal:
	xor ax,ax
	mov ds,ax
	mov es, ax
	mov ss,ax ;set up the stack
	mov sp,0X7C00 ; pilha comeca em 0x7c00

	mov si,breakline
	call print_string

	mov si, agenda_
	call print_string

	mov si, prompt
	call print_string

	mov di, buffer
	call get_string

	mov si, buffer
   	cmp byte [si], 0  ; blank line?
   	je loop_principal      ; yes, ignasnore it

   	pop ax

   	mov si, buffer
   	mov di, cadastrar  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_cadastrar

   	;xor di,di

   	mov si, buffer
   	mov di, buscar  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_buscar

   	;xor di,di

   	mov si, buffer
   	mov di, editar_contato  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_editar

   	;xor di,di

   	mov si, buffer
   	mov di, deletar_contato  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_deletar

   	;xor di,di

   	mov si, buffer
   	mov di, listar_grupos  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_listarg

   	;xor di,di

   	mov si, buffer
   	mov di, listar_contatos  ; aqui que ele vai pra área do código em respeito ao comando
   	call strcmp
   	jc cmd_listarc

   	;xor di,di

   	mov si, badcommand
   	call print_string
   	jmp loop_principal

cmd_cadastrar:
 	;area do codigo onde iremos alocar na memoria os dados (acho que da pra usar a funcao get_string)
 	;mov si, cadastrar
   	;call print_string

   	mov si, pular_linha
   	call print_string

    mov cx, agenda.size ;cx recebe o tamanho agenda.size = 5, ou seja podemos ter 5 pessoas
   	xor bx, bx ; zera bx

   	c1:
     	cmp byte[(array + bx) + contato.nome], 0 ; ve se tem algum campo vazio pra colocar na struct
        je c2
        add bx, contato.size ; vai adicionar mais um contato (o tamanho da struct e quanto o array vai pular pra colocar os dados)
        loop c1

   mov si, agendacheia
   call print_string ; se ele já pulou 5 vezes e mesmo assim nao tinha espaço (o contador do loop c1 acabou e nao viu nenhum espaço vazio)
   jmp endc

   c2:
      printString nome
      lea ax, [(array + bx) + contato.nome] ; coloca em ax cada campo da struct (ele coloca o endereço livre em que foi reservado cada campo da struct pra ax apontar)
      readString ax, nome.size-1

      printString breakline

      printString grupo
      lea ax, [(array + bx) + contato.grup] ;mesma coisa pros outros
      readString ax, grup.size-1

      printString breakline

      printString telefone
      lea ax, [(array + bx) + contato.telefone]
      readString ax, telefone.size-1

      printString breakline

      printString email
      lea ax, [(array + bx) + contato.email]
      readString ax, email.size-1

      printString breakline
      printString sucesso

    endc:
 	jmp loop_principal

cmd_buscar:
;area do cod...2
  mov si, nome
  call print_string

  readString aux, 20
  printString breakline
  find contato.nome, 20

  cmp al, 1
  je contato_encontrado

  printString not_found
  jmp endb

  contato_encontrado:
    printString encontrado
   
    lea ax, [(array + bx) + contato.nome]
    printString ax

    endb:
    zerar aux, nome.size-1
    jmp loop_principal
	
	jmp loop_principal

cmd_editar:
   printString nome
   readString aux, 20

   find contato.nome, 20

   cmp al, 1 ;mesma coisa, caso ele achou a string
   je e1

   printString breakline
   printString not_found;se nao achou imprime
   jmp ende

   e1:   
      printString breakline
      printString breakline
      printString editnome
      readString aux, 1
      
      cmp byte[aux], 73h
      jne e2

      lea ax, [(array + bx) + contato.nome]
      
      zerar ax, 20
      printString breakline
      printString nome

      lea ax, [(array + bx) + contato.nome]

      readString ax, 20
      printString breakline
      printString sucesso
   
   e2:
      printString breakline
      printString editgrupo
      readString aux, 1
      
      cmp byte[aux], 73h
      jne e3

      lea ax, [(array + bx) + contato.grup]

      zerar ax, 10
      printString breakline
      printString grupo

      lea ax, [(array + bx) + contato.grup]

      readString ax, 10
      printString breakline
      printString sucesso

   e3:
      printString breakline
      printString editfone
      readString aux, 1

      cmp byte[aux], 73h
      jne e4

      lea ax, [(array + bx) + contato.telefone]

      zerar ax, 10
      printString breakline
      printString telefone

      lea ax, [(array + bx) + contato.telefone]

      readString ax, 10
      printString breakline
      printString sucesso

   e4:
      printString breakline
      printString editemail
      readString aux, 1
      
      cmp byte[aux], 73h
      jne ende

      lea ax, [(array + bx) + contato.email]

      zerar ax, 20
      printString breakline
      printString email

      lea ax, [(array + bx) + contato.email]

      readString ax, 20
      printString breakline
      printString sucesso

   ende:
      printString breakline
      zerar aux, 20
      jmp loop_principal

cmd_deletar:
  mov si, nome
  call print_string
  readString aux, 20
  printString breakline
  find contato.nome, 20

  cmp al, 1
  je .delete

  printString not_found
  jmp endd

  .delete:
    lea ax, [array + bx]

    mov cx, contato.grup
    add cx, ax

    mov word[end_aux], cx
    ;call removerDoGrupo ; implementar essa

    zerar ax, contato.size
    printString deletado

  endd:
    zerar aux, nome.size-1
    jmp loop_principal

cmd_listarg:
	mov si, listar_grupos
  call print_string

  
	
	jmp loop_principal

cmd_listarc:

	mov si, listar_contatos_ui
  call print_string
  readString aux, 20

  printString breakline

  find contato.grup, 10

  zerar aux, 20
  jmp loop_principal

;db
prompt db '>', 0
agenda_ db 'ola sejam bem vindos a agenda!', 0X0D, 0X0A, 'digite o comando respectivo',0X0D,0X0A, 0
pular_linha db 0X0D, 0X0A, 0
cadastrar db 'cadastrar', 0
buscar db 'buscar', 0
editar_contato db 'editar',0	
deletar_contato db 'deletar', 0
listar_grupos db 'listarg', 0
listar_contatos db 'Listar Contatos do Grupo', 0
listar_contatos_ui db 'Qual grupo voce deseja buscar ? ', 0
badcommand db 'Bad command entered.', 0x0D, 0x0A, 0
agendacheia db 'Agenda Cheia!', 13, 10, 0
breakline db 13, 10, 0
nome db 'Digite o nome: ', 0
grupo db 'Digite o grupo: ', 0
telefone db 'Digite o telefone: ', 0
email db 'Digite o email: ', 0
sucesso db 'Sucess!', 0
end_aux: dw 0
aux times 21 db 0
not_found db 'contato nao encontrado', 0
encontrado db 'contato encontrado: ', 0
editnome db 'editar nome? ', 0
deletado db 'Contato deletado! ', 0
editfone db 'editar fone? ', 0
editgrupo db 'editar grupo? ', 0
editemail db 'editar email?', 0
erroContato db 'contato nao encontrado'

buffer times 64 db 0


print_string:
	lodsb        ; grab a byte from SI
 
	or al, al  ; logical or AL by itself
	jz .done   ; if the result is zero, get out
 
	mov ah, 0x0E
	mov bl, 5
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



   ;times 1390-($-$$) db 0
   dw 0AA55h ; assinatura de boot
