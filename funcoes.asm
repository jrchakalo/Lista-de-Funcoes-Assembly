org 0x7c00            
jmp 0x0000: main

func:
    ;seta a tela para o modo de video
    setVid:
        mov ah, 00h
        mov al, 01h
        int 10h
    ret

    ; lê um caractere e retorna
    getchar:
        mov ah, 0x00
        int 16h
    ret

    ; printa o caractere recebido
    putchar:
        mov ah, 0x0e
        int 10h
    ret
    
    ; deleta um caractere
    delchar:
        mov al, 0x08          ; coloca o backspace em al
        call putchar          ; printa o backspace
        mov al, ' '           ; coloca um caractere em branco em al
        call putchar          ; printa o caractere em branco
        mov al, 0x08          ; coloca o backspace em al
        call putchar          ; printa o backspace
    ret

    ; quebra uma linha
    endl:
        mov al, 0x0a          ; coloca o caractere de final de linha em al
        call putchar          ; imprime o final de linha
        mov al, 0x0d          ; coloca o cursor na próxima linha
        call putchar          ; imprime
    ret

    ; lê uma string
    getstring:
        xor cx, cx                      ; iguala o contador do tamanho da string a 0     

        loop:
            call getchar                ; lê o caractere
            cmp al, 0x08      
            je apagar                   ; se o caractere for o backspace pula pra funcão de apagar
            cmp al, 0x0d      
            je enter                    ; se o caractere for o enter pula pra conclusão
            cmp cl, 20                  ; seta o tamanho máximo da palavra
            je loop                     
                
            stosb                       ; guarda o caractere
            inc cl                      ; incrementa o contador
            call putchar                ; printa na tela o caractere que você digitou
                
            jmp loop

            ; para quando apertar o backspace
            apagar:
                cmp cl, 0       ; verifica se a palavra esta limpa
                je loop         ; se tiver volta para o loop da escrita
                dec di          ; decrementa di e o contrador
                dec cl
                mov byte[di], 0 ; coloca 0 no valor do byte de di
                call delchar    ; chama o apaga caracter
                jmp loop        ; volta para o loop da escrita
        
        ; para quando apertar o enter
        enter:
            mov al, 0           ; seta al como 0
            stosb               ; guarda na memória
            call endl           ; chama o quebra linha
            ret

    ; printa uma string
    printstring:             
        .loop:
            lodsb           ; bota character em al 
            cmp al, 0       ; ve se a string acabou
            je .endloop     ; se acabou, retorna
            call putchar    ; se não, printa
            jmp .loop       ; repete o loop
        .endloop:
            ret

    ; printa o caractere na posição do número selecionado
    printchar:
        mov cx, 9               ; iguala cx a 9

        .loop:
            lodsb               ; carrega os caracteres da string em al
            cmp al, 0           ; vê se al chegou no final da string
            je .endloop
            cmp cx, bx          ; compara para ver se o contador chegou na posição desejada
            je .achou           ; se sim vai para achou

            inc cx              ; se não, incrementa o contador
            jmp .loop           ; e continua o loop
        .achou:
            call putchar        ; printa o caractere da posição desejada
            ret
        .endloop:
            ret
        
    ;func para printar imagem
    printImg:
        ;loop da linha
        linha:
            cmp dx, 16             ; verifica se chegou na linha final
            je fimlinha            ; se chegou, vai para o final do loop da linha 
            mov cx, 0              ; se não, vai para o loop da coluna

            ;loop da coluna
            coluna:
                cmp cx, 16         ; verifica se chegou na coluna final
                je fimcoluna       ; se chegou, vai para o final do loop da coluna
                lodsb              ; carrega a cor em al
                mov ah, 0ch        ; seta o ah para escrever um pixel
                int 10h            ; printa
                inc cx             ; incrementa cx
                jmp coluna         ; volta pro loop da coluna
            fimcoluna:
                inc dx             ; incrementa dx
                jmp linha          ; volta pro loop da linha

        ;finaliza a impressao       
        fimlinha:
            ret
    
    ; inverte uma string
    reversestring:              
        mov di, si          ; coloca o endereço de si em di
        xor cx, cx          ; zera o contador

        ; carrega a palavra na pilha
        .loop1:             
            lodsb           ; carrega um caracter em al da memória
            cmp al, 0       ; vê se al vale 0
            je .endloop1    ; se for, a palavra acabou e finaliza o loop1
            inc cl          ; se não for, incrementa o contador
            push ax         ; da um push em ax na pilha
            jmp .loop1      ; repete o loop
        .endloop1:

        ; descarrega a palavra da pilha (invertida)
        .loop2:
            cmp cl, 0       ; ve se o contador vale 0
            je .endloop2    ; se valer, a palavra acabou, encerra a funcão
            dec cl          ; se não, decrementa o contador               
            pop ax          ; da um pop em ax da pilha
            stosb           ; guarda na memória
            jmp .loop2      ; repete o loop
        .endloop2:
            ret


    ; transforma uma string em inteiro
    stoi:
        xor cx, cx              ; zera o ax e o cx
        xor ax, ax

        .loop1:
            push ax             ; da um push em ax
            lodsb               ; carrega o caractere da memoria
            mov cl, al          ; salva o caractere em cl
            pop ax              ; da um pop em ax
            cmp cl, 0           ; vê se chegou no fim da string
            je .endloop1
            sub cl, 48          ; tira o '0' da palavra salva em cl
            mov bx, 2          ; coloca 2 em bx
            mul bx              ; multiplica ax por bx
            add ax, cx          ; soma o resultado com cx
            jmp .loop1
        .endloop1:
            ret

    ; transforma um inteiro em uma string
    tostring:              
        push di                 ; da um push no endereço de di

        .loop1:
            cmp ax, 0           ; vê se ax chegou no final
            je .endloop1        ; se chegou vai para o encerramento do loop
            xor dx, dx          ; zera dx
            mov bx, 2          ; coloca 2 em bx
            div bx              ; divide ax por bx
            xchg ax, dx         ; troca ax por dx
            add ax, 48          ; coloca um '0' em ax para sinalizar final de string
            stosb               ; guarda na memória
            xchg ax, dx         ; troca ax por dx
            jmp .loop1          ; volta pro loop

        ;encerramento do loop
        .endloop1:
            pop si              ; da um pop no endereço de si     
            cmp si, di          ; vê se si e di são iguais
            jne .done           ; se não são, pula pro final direto
            mov al, 48          ; se são, coloca um '0' para sinalizar final de string
            stosb               ; guarda na memória 
        .done:
            mov al, 0           ; coloca 0 em al
            stosb               ; guarda na memoria
            call reversestring  ;inverte a string
        ret

    ; limpa as coisas digitadas e mostradas anteriormente
    limpatela:
        ; coloca o cursor no topo da tela                   
        mov dx, 0 
        mov bh, 0      
        mov ah, 0x2
        int 0x10

        ; printa 2 caracteres brancos pra limpar
        mov cx, 2 
        mov bh, 0
        mov al, 0x20
        mov ah, 0x9
        int 0x10
        
        ; reseta o cursor pro topo da tela
        mov dx, 0 
        mov bh, 0      
        mov ah, 0x2
        int 0x10
        ret

    ; pausa o programa por 1 segundo
    delay:           
        mov cx, 0fh
        mov dx, 4240h
        mov ah, 86h
        int 15h
    ret

    ; copia uma string (ou sequencia) para outra
    ; coloca si na string de origem e di na string de destino
    strcpy:
    .loop1:
        lodsb                       ; carrega de si
        stosb                       ; guarda em di
        cmp al, 0                   ; ve se chegou ao final
        je .endloop1                ; se chegou encerra o loop
        jmp .loop1                  ; se nao, repete
    .endloop1:
    ret

    ; escolhe um numero aleatoriamente dentro de um intervalo usando o system time
    random: 
        mov ah, 00h                 ; interrupcao para pegar o system time        
        int 1ah                     ; cx e dx agora guardao o numero do system time     

        mov ax, dx                  ; guarda o valor de dx em ax   
        xor dx, dx                  ; zera dx
        mov cx, 5                   ; define o limete do intervalo, numeros de 0 ~ 5
        div cx                      ; divide ax por 5

        add dl, '0'                 ; coloca '0' no final de al
        mov al, dl

        ; se ouver algum resultado indesejado, roda a funcao novamente
        jmp random
    ret  

main:
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov cx, ax
    mov dx, ax


times 510 - ($ - $$) db 0
dw 0xaa55