org 0x500
jmp 0x0000:start

agenda.size EQU 5
nome.size EQU 21
grupo.size EQU 11
telefone.size EQU 11
email.size EQU 21

dados:
   STRUC contato
      .nome: resb nome.size
      .grupo: resb grupo.size
      .telefone: resb telefone.size
      .email: resb email.size
      .size:
   ENDSTRUC

   array: times contato.size*agenda.size db 0
   nome: db 'Nome: ', 0
   grupo: db 'Grupo: ', 0
   telefone: db 'Telefone: ', 0
   email: db 'E-mail: ', 0
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

%macro zerar 2
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

procuraString:
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

cadastrar:
   mov cx, agenda.size ;cx recebe o tamanho agenda.size = 5, ou seja podemos ter 5 pessoas
   xor bx, bx ; zera bx

   c1:
      cmp byte[(array + bx) + contato.nome], 0 ; ve se tem algum campo vazio pra colocar na struct
      je c2
      add bx, contato.size ; vai adicionar mais um contato (o tamanho da struct e quanto o array vai pular pra colocar os dados)
      loop c1

   printString erroCheio ; se ele já pulou 5 vezes e mesmo assim nao tinha espaço (o contador do loop c1 acabou e nao viu nenhum espaço vazio)
   jmp endc

   c2:
      printString nome
      lea ax, [(array + bx) + contato.nome] ; coloca em ax cada campo da struct (ele coloca o endereço livre em que foi reservado cada campo da struct pra ax apontar)
      readString ax, nome.size-1

      printString breakline

      printString grupo
      lea ax, [(array + bx) + contato.grupo] ;mesma coisa pros outros
      readString ax, grupo.size-1

      printString breakline

      printString telefone
      lea ax, [(array + bx) + contato.telefone]
      readString ax, telefone.size-1

      printString breakline

      printString email
      lea ax, [(array + bx) + contato.email]
      readString ax, email.size-1

      printString breakline
      printString okcontato

   endc:
      jmp readoption

buscar:
   printString nome
   readString aux, 20
   printString breakline

   find contato.nome, 20 ; chama o macro(funcao) pra buscar o nome de tamanho 20

   cmp al, 1 ; se o flag acionado por 1 (achou a string)
   je b1

   printString erroContato
   jmp endb

   b1:; caso achou vai printar tudo
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
      zerar aux, 20
      jmp readoption

editar:
   printString nome
   readString aux, 20

   find contato.nome, 20

   cmp al, 1 ;mesma coisa, caso ele achou a string
   je e1

   printString breakline
   printString erroContato;se nao achou imprime
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
      printString ok
   
   e2:
      printString breakline
      printString editgrupo
      readString aux, 1
      
      cmp byte[aux], 73h
      jne e3

      lea ax, [(array + bx) + contato.grupo]

      zerar ax, 10
      printString breakline
      printString grupo

      lea ax, [(array + bx) + contato.grupo]

      readString ax, 10
      printString breakline
      printString ok

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
      printString ok

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
      printString ok

   ende:
      printString breakline
      zerar aux, 20
      jmp readoption

deletar:
   printString nome
   readString aux, 20
   printString breakline

   find contato.nome, 20

   cmp al, 1
   je d1

   printString erroContato
   jmp endd

   d1:
      lea ax, [array + bx]

      zerar ax, contato.size
      printString okdelete

   endd:
      zerar aux, 20
      jmp readoption


listgrupcont:
   printString grupo
   readString aux, 20
   printString breakline
   
   printString contGrupos
   printString breakline
   printString breakline

   find contato.grupo, 10

   zerar aux, 20
   jmp readoption

terminateProg:
   ;MOV AH, 0x4C
   INT 0x23

start:
   xor ax, ax ;zera os registradores
   mov ds, ax

   readoption:
      printString breakline ;chama os macros pra printar 
      printString opcao

      rd1:
         xor ah, ah ;zera ah e chama pra ler do teclado
         int 16h

         call __biosprint

         push ax
         cmp al, 0xd ; se nao for igual a 0xd, ele pula (ainda tem coisa pra ler)
         jne rd1

      printString breakline

      pop ax
      pop ax

      cmp al, 30h ; aqui fica o menu pra acessar cada campo correspondente
      je cadastrar

      cmp al, 31h
      je buscar

      cmp al, 32h
      je editar

      cmp al, 33h
      je deletar

      cmp al, 35h
      je listgrupcont

      cmp al, 36h ; sair
      je terminateProg

      printString erroroption
      printString breakline

   jmp readoption