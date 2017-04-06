org 0x7c00                                                                                  
jmp 0x0000:__start

dados:
	comandos: db '--- Comandos disponiveis ---', 13,10,0
    cadastro: db '0: Cadastrar', 13, 10, 0
    busca: db '1: Buscar', 13, 10, 0
    editar: db '2: Editar', 13, 10, 0
    deletar: db '3: Deletar', 13, 10, 0
    listgrup: db '4: Listar Grupos', 13, 10, 0
    listgrupcont: db '5: Listar Contatos do Grupo', 13, 10, 0
    agenda: db '____ Ola! Seja Bem vindo a agenda! ____', 13,10,0
    exit: db '6: Sair', 13, 10, 0
    espaco: db '', 13, 10, 0

__print:
    mov cl, 0
    _p:
        lodsb 
        cmp al, cl
        je .sair

        mov ah, 0xe
        xor bh, bh
        mov bl, 7
        int 10h

        jmp _p

    .sair:
    ret
    
__start:                                                                         
    xor ax, ax                                                                                
    mov ds, ax  

    mov ah, 0
    mov al, 0xe
    xor bh, bh
    int 10h

    mov ah, 0xb
    mov bh, 0
    mov bl, 0
    int 10h

    mov si, comandos
    call __print

    mov si, cadastro
    call __print

    mov si, busca
    call __print

    mov si, editar
    call __print

    mov si, deletar
    call __print

    mov si, listgrup
    call __print

    mov si, listgrupcont
    call __print

    mov si, exit
    call __print  

    mov si, espaco
    call __print

    mov si, agenda
    call __print

    xor bx, bx                                                                                

zerarDisco:
    mov ah,00h
    mov dl, 0                                                                                 
    int 13h                                                                                     
    jc zerarDisco                                                                           

disco:                   
    mov ah, 02h
    mov al, 50                                                                                 
    mov ch, 0                                                                                
    mov cl, 2                                                                                 
    mov dh, 0                                                                                
    mov dl, 0                                                                                 
    mov bx, 0x0000                                                                       
    mov es, bx                                                                               
    mov bx, 0x0500                                                                       
    int 13h                                                                                     

    jmp 0x0000:0x0500 
                                                                    
times 510 -($-$$) db 0                                                                 
dw 0xaa55                                                                                   
