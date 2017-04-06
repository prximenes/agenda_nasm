org 0x500
jmp 0x0000:start

agenda.size EQU 5
nome.size EQU 21
grupo.size EQU 11
telefone.size EQU 11
email.size EQU 21
minOption EQU '0'
maxOption EQU '6'
allChars EQU 0
numeros EQU 1
YesNo EQU 2

dados:
	STRUC contato
		.nome: resb 21
		.grupo: resb 11
		.telefone: resb 11
		.email: resb 21
		.size:
	ENDSTRUC

	STRUC grupos
		.nome: resb 11
		.quantidade: resw 1
		.size:
	ENDSTRUC

	array: times contato.size*agenda.size db 0
	array_gp: times grupos.size*agenda.size db 0
	nome: db 'Nome: ', 0
	grupo: db 'Grupo: ', 0
	telefone: db 'Telefone: ', 0
	email: db 'E-mail: ', 0
	nogrupos: db 'Nao ha grupos para mostrar.', 0
	editnome: db 'Deseja Editar Nome? [s/n]: ', 0
	editgrupo: db 'Deseja Editar Grupo? [s/n]: ', 0
	editfone: db 'Deseja Editar Telefone? [s/n]: ', 0
	editemail: db 'Deseja Editar E-mail? [s/n]: ', 0
	opcao: db 'Opcao: ', 0
	contGrupos: db 'Contatos do Grupo:', 0
	okcontato: db 'Contato Adicionado', 13, 10, 0
	okdelete: db 'Contato Deletado', 13, 10, 0
	erroroption: db 13, 'Opcao Inexistente', 0
	ok: db 'Ok!', 13, 10, 0
	erroCheio: db 'Agenda Cheia!', 13, 10, 0
	erroContato: db 'Contato Inexistente!', 13, 10, 0
	infoContato: db 'Info do Contato:', 13, 10, 0
	erroGrupo: db 'Grupo Nao Encontrado', 13, 10, 0
	breakline: db 13, 10, 0
	aux: times 21 db 0
	end_aux: dw 0
	flag: db 0
	option: db 0

%macro readString 3
	push bx
	mov di, %1
	mov cx, %2
	mov bx, %3
	call read
	pop bx
%endmacro

%macro printString 1
	push bx
	mov si, %1
	call print
	pop bx
%endmacro

%macro zerar 2
	mov di, %1
	mov cx, %2
	call fill
%endmacro

%macro find 1
	mov si, %1
	mov ax, %1
	add si, array
	mov di, aux
	call procuraString
%endmacro

%macro strcpy 2	;macro para copia de string de memoria para memoria:	%1-DEST	%2-SOUR
	mov di, %1
	mov si, %2
	call copiaString
%endmacro

%macro strcmp 3	;macro para comparar strings:	%1-STR1 %2-STR2 %3-TAMANHO
	; push cx
	mov di, %1
	mov si, %2
	mov cx, %3
	call strCompare
	; pop cx
%endmacro

copiaString:
	.p1:
		mov al, byte[si]
		mov byte[di], al
		cmp al, 0
		je .exit

		inc si
		inc di
		jmp .p1
	.exit:
ret

__biosprint:
	mov ah, 0xe
	xor bh, bh
	mov bl, 3
	int 10h

	ret

eraseChar:
    ; move o cursor pra posição anterior = backspace (dec dl)
    mov ah, 0x02
   	xor bh, bh
    dec dl				; dl = posição da letra errada
    int 0x10

    ; imprime 'espaço' para apagar o caractere errado e não move a posição do cursor (int 10, a)
    mov al, 0x20        ; espaço
	call __biosprint

	mov ah, 0x02
	; xor bh, bh
    int 0x10

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

%define tam 	[bp-2]
%define cursor 	[bp-4]
%define mode	[bp-6]
read:
	mov word mode, bx
	mov word tam, cx	; armazena o tamanho total da string na variável local 'tam'

	; pega a posição atual do cursor (dh = linha; dl = coluna)
    mov ah, 0x03
    xor bh, bh
    int 0x10

    mov word cursor, dx	; guarda a posição inicial do cursor

    mov cx, word tam
	r1:
		xor ah, ah
		int 16h

		; Mode = allChars
		cmp al, 0xd
		je endr

		cmp al, 0x08    ; se o backspace for pressionado, apaga o último caractere
	    je apagar

	    cmp cx, 0x00
	    je r1

	    cmp word mode, numeros
		je filtrarNumeros

		cmp word mode, YesNo
		je filtrarYesNo

	    jmp exibirChars

	filtrarNumeros:
		cmp al, '0'
		jl r1

		cmp al, '9'
		jg r1

		jmp exibirChars

	filtrarYesNo:
		cmp al, 's'
		je exibirChars

		cmp al, 'n'
		je exibirChars

		jmp r1

	exibirChars:
	    call __biosprint

		stosb
		loop r1
		jmp r1

	apagar:
	    cmp cx, word tam
	    je r1
    
    	mov dx, word tam	; dx = tamanho total da string
    	sub dx, cx			; dx = quantidade de posições já andadas pelo cursor
    	xor dh, dh			; dh = zera a posição da linha pra somar certo com a posição inicial do cursor
    	add dx, word cursor	; dl = posição do cursor depois da letra errada

    	call eraseChar

	    inc cx		; incrementa cx para não alterar o funcionamento da instrução loop
	    
	    ; armazena '\0' na posição apagada
	    dec di
		mov byte[es:di], 0

	    jmp r1

		mov byte[es:di], 0
	endr:
		cmp cx, word tam
		je r1

	printString breakline
ret

fill:
	za:
		mov al, 0
		stosb
		loop za

	ret

strCompare:	;salva em AL 0, para strings diferentes e 1 para strings iguais
	cld
	.p1:
		cmpsb
		jne .dif
		loop .p1

	mov al, 1	;strings iguais
	jmp .exit

	.dif:
		mov al, 0	;strings diferentes
	.exit:
ret

%define bkp 	[BP-2]
addParaGrupo:
	push bx
	mov byte[flag], 0
	mov cx, agenda.size
	mov bx, array_gp ;bx é o indice do vetor de grupos
	
	.start:
		push cx
		strcmp bx, word[end_aux], grupo.size-1
		pop cx
		cmp al, 0
		je .p1

		;se achou o grupo, incrementa o contador desse grupo e move 1 para a flag, indicando que achou um grupo
		mov byte[flag], 1
		.inc_qtd:
		inc word[bx+grupos.quantidade]
		jmp .sair

		.p1:
			add bx, grupos.size	;incrementa o indice no vetor da struct de grupos
			loop .start

		;adicona novo grupo no primeiro espaço vazio
		mov bx, array_gp
		cmp byte[bx], 0
		je .p3 

		.p2:
			add bx, grupos.size
			cmp byte[bx], 0
			jne .p2

		.p3:
			strcpy bx, word[end_aux]
			jmp .inc_qtd

	.sair:
	pop bx
ret       

removerDoGrupo:
	push ax
	push bx
	mov cx, agenda.size
	mov bx, array_gp;bx é o indice do vetor de grupos

	.start:
		push cx
		strcmp bx, word[end_aux], grupo.size-1
		pop cx
		cmp al, 0
		je .p1
		
		dec word[bx+grupos.quantidade]
		cmp word[bx+grupos.quantidade], 0	;se a quantidade de contatos por grupo é zero, retira o grupo do vetor
		jne .sair

		zerar bx, grupo.size-1
		jmp .sair

		.p1:
		add bx, grupos.size
		loop .start

	.sair:
	pop bx
	pop ax
ret 

%define bkp 	[BP-2]
procuraString:
	xor dx, dx
	xor bx, bx

	ps1:
		ps2:
			cmpsb
			jne ps4

			ps3:
				cmp byte[di], 0
				jne ps2
				cmp byte[si], 0
				jne ps2
				cmp ax, contato.nome
				je ps5

				mov word bkp, ax
				lea ax, [(array + bx) + contato.nome]
				printString ax
				printString breakline
				mov ax, word bkp

				; loop ps2

		ps4:
			mov si, array
			mov di, aux
			add bx, contato.size
			add si, bx
			add si, ax
			inc dx
			cmp dx, agenda.size

			jb ps1

	mov ax, 0
	jmp endps

	ps5:
		mov ax, 1

	endps:
		ret

cadastrar:
	mov cx, agenda.size 
	xor bx, bx

	c1:
		cmp byte[(array + bx) + contato.nome], 0
		je c2
		add bx, contato.size
		loop c1

	printString erroCheio
	jmp endc

	c2:
		printString nome
		lea ax, [(array + bx) + contato.nome]
		readString ax, nome.size-1, allChars

		printString grupo
		lea ax, [(array + bx) + contato.grupo]
		mov word[end_aux], ax
		readString ax, grupo.size-1, allChars
		call addParaGrupo

		printString telefone
		lea ax, [(array + bx) + contato.telefone]
		readString ax, telefone.size-1, numeros

		printString email
		lea ax, [(array + bx) + contato.email]
		readString ax, email.size-1, allChars

		printString okcontato

	endc:
		jmp readOption

buscar:
	printString nome
	readString aux, nome.size-1, allChars

	find contato.nome

	cmp al, 1
	je b1

	printString erroContato
	jmp endb

	b1:
		printString breakline
		printString infoContato

		printString breakline

		printString nome
		lea ax, [(array + bx) + contato.nome]
		printString ax

		printString breakline

		printString grupo
		lea ax, [(array + bx) + contato.grupo]
		printString ax

		printString breakline

		printString telefone
		lea ax, [(array + bx) + contato.telefone]
		printString ax

		printString breakline

		printString email
		lea ax, [(array + bx) + contato.email]
		printString ax

		printString breakline

	endb:
		zerar aux, nome.size-1
		jmp readOption

editar:
	printString nome
	readString aux, nome.size-1, allChars

	find contato.nome

	cmp al, 1
	je e1

	printString erroContato
	jmp ende

	e1:	
		printString breakline
		printString editnome
		readString aux, 1, YesNo

		cmp byte[aux], 's'
		jne e2

		lea ax, [(array + bx) + contato.nome]
		
		zerar ax, nome.size-1
		printString nome

		lea ax, [(array + bx) + contato.nome]

		readString ax, nome.size-1, allChars
		printString ok
	
	e2:
		printString breakline
		printString editgrupo
		readString aux, 1, YesNo

		cmp byte[aux], 's'
		jne e3

		lea ax, [(array + bx) + contato.grupo]
		mov word[end_aux], ax
		call removerDoGrupo
		mov ax, word[end_aux]

		zerar ax, grupo.size-1
		printString grupo

		lea ax, [(array + bx) + contato.grupo]
		mov word[end_aux], ax

		readString ax, grupo.size-1, allChars
		call addParaGrupo

		printString ok

	e3:
		printString breakline
		printString editfone
		readString aux, 1, YesNo

		cmp byte[aux], 's'
		jne e4

		lea ax, [(array + bx) + contato.telefone]

		zerar ax, telefone.size-1
		printString telefone

		lea ax, [(array + bx) + contato.telefone]

		readString ax, telefone.size-1, allChars
		printString ok

	e4:
		printString breakline
		printString editemail
		readString aux, 1, YesNo
		
		cmp byte[aux], 's'
		jne ende

		lea ax, [(array + bx) + contato.email]

		zerar ax, email.size-1
		printString email

		lea ax, [(array + bx) + contato.email]

		readString ax, email.size-1, allChars
		printString ok

	ende:
		printString breakline
		zerar aux, email.size-1
		jmp readOption

deletar:
	printString nome
	readString aux, nome.size-1, allChars

	find contato.nome

	cmp al, 1
	je d1

	printString erroContato
	jmp endd

	d1:
		lea ax, [array + bx]

		mov cx, contato.grupo
		add cx, ax

		mov word[end_aux], cx
		call removerDoGrupo

		zerar ax, contato.size
		printString okdelete

	endd:
		zerar aux, nome.size-1
		jmp readOption


listGroup:
	mov byte[flag], 0
	mov cx, agenda.size
	mov bx, array_gp

	.p1:
	cmp byte[bx], 0
	je .incrementa
	printString bx

	printString breakline
	mov byte[flag], 1

	.incrementa:
	add bx, grupos.size
	loop .p1

	cmp byte[flag], 1
	je .exit
	printString nogrupos
	printString breakline
	.exit:
	jmp readOption


listGroupCont:
 	printString grupo
 	readString aux, grupo.size-1, allChars

 	find contato.grupo

 	zerar aux, grupo.size-1
 	jmp readOption

shutdown:
    xor ah, ah
    mov al, 0x0E
    xor bh, bh
    int 10h

    mov ah, 0x0B
	xor bx, bx
    int 10h
nada:    	
	jmp nada
	
start:
	xor ax, ax
	mov ds, ax

	readOption:
		printString breakline
		printString opcao

		; pega a posição atual do cursor (dh = linha; dl = coluna)
    	mov ah, 0x03
    	xor bh, bh
    	int 0x10

    	xor ch, ch 		; contador de caracteres da opção

	rd1:
		xor ah, ah
		int 16h

		cmp ch, 0
		jg enterErase

		cmp al, minOption
		jl rd1

		cmp al, maxOption
		jg rd1

		inc ch	; incrementa o contador de caracteres da opção
		inc dl	; incremeta a posição do cursor
		mov byte[option], al

		call __biosprint

	enterErase:
		cmp al, 0x08
		je eraseOption

		cmp al, 0x0D
		jne rd1
		jmp indetifyOption

	eraseOption:
		call eraseChar
		dec ch
		jmp rd1

	indetifyOption:
		printString breakline

		mov al, byte[option]

		cmp al, '0'
		je cadastrar

		cmp al, '1'
		je buscar

		cmp al, '2'
		je editar

		cmp al, '3'
		je deletar

		cmp al, '4'
		je listGroup

		cmp al, '5'
		je listGroupCont

		cmp al, '6'
		je shutdown

		printString erroroption
		printString breakline

	jmp readOption
