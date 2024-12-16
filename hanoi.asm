; Declaração de dados: 
section .data                         ; Usada para armazenar dados inicializados do programa, por exemplo uma variável global.

    ; Definindo a mensagem
    msg:
                          db        "Disco: "   
        disk:             db        " "
                          db        "   "                      
        from_tower:       db        " "  
                          db        " -> "     
        to_tower:         db        " ", 0xa  ; para quebrar linha
        
        move_msg_length            equ       $-msg

    error_msg db "Erro: Numero invalido ou fora do limite.", 0xa
    error_len equ $ - error_msg

    ask_for_disks db "Escolha um número de discos de 0 a 99: " 
    ask_len equ $ - ask_for_disks

section .bss                             ; Dados não inicializados
   num resb 3                            ; Reserva 3 bytes para armazenar os dígitos + \n

section .text                            ; Código executável
    global _start

_start:
    begin:
        mov ecx, ask_for_disks
        mov edx, ask_len
        call print

        ; Configurar leitura
        mov eax, 3                           ; Chamada de sistema 'read'
        mov ebx, 0                           ; stdin
        mov ecx, num                         ; Endereço de armazenamento
        mov edx, 3                           ; Número máximo de bytes lidos (2 dígitos + \n)
        int 80h                              ; Chama interrupção de leitura

        ; Carregar o primeiro dígito
        movzx eax, byte [num]                ; Primeiro dígito (ASCII)
        call convert_to_int            
        mov ebx, eax                         ; Armazena o primeiro dígito em ebx

        ; Carregar o segundo byte
        movzx eax, byte [num + 1]            ; Segundo byte (ASCII ou \n)
        cmp eax, 10                          ; Verifica se é o caractere de nova linha (\n)
        je single_digit                      ; Se sim, é número de 1 dígito

        call convert_to_int

        ; Combina os dois dígitos
        movzx eax, byte [num + 2]            ; Segundo byte (ASCII ou \n)
        cmp eax, 10                          ; Verifica se é o caractere de nova linha (\n)
        jnz error
        mov eax, ebx                         ; Primeiro dígito
        imul eax, 10                         ; Multiplica por 10
        add eax, ebx                         ; Soma o segundo dígito
        jmp valid                            ; Continua para o processamento

convert_to_int:
    sub eax, '0'                         ; Converte de ASCII para número
    cmp eax, 0                           ; Verifica se é um número válido
    jl error                             ; Se menor que 0, erro
    cmp eax, 9                           ; Se maior que 9, erro
    jg error  
    ret

single_digit:
    mov eax, ebx                         ; Se for apenas 1 dígito, usa diretamente o valor de ebx
    jmp valid

valid:
    ; Verifica se o número é válido
    cmp eax, 99                          ; Limite de 99 discos
    ja error                             ; Se maior que 99, erro

    ; Empilha os valores para a função hanoi
    push dword 2                         ; Torre Auxiliar
    push dword 3                         ; Torre Destino
    push dword 1                         ; Torre Origem
    push eax                             ; Número de discos
    call hanoi                           ; Chamando a função hanoi

    ; Finalização
    mov eax, 1                           ; Chamada de sistema 'exit'
    xor ebx, ebx                         ; Código de saída 0
    int 80h

error:
    mov eax, 4                           ; Chamada de sistema 'write'
    mov ebx, 1                           ; stdout
    mov ecx, error_msg                   ; Mensagem de erro
    mov edx, error_len                   ; Tamanho da mensagem
    int 80h

    jmp begin

; Labels que serão usados durante o funcionamento do codigo
    hanoi: 
        ;[ebp+8] número de discos restantes na Torre de origem
        ;[ebp+12] = Torre de origem
        ;[ebp+16] = Torre auxiliar
        ;[ebp+20] = Torre de destino

        push ebp                      ; empurra o registrador ebp na pilha (para ser a base)
        mov ebp, esp                  ; aponta o ponteiro do topo da pilha (esp) para a base

        mov eax, [ebp+8]              ; move para o registrador ax o numero de discos na Torre de origem
        
        cmp eax, 0                    ; verifica se Ainda há disco a ser movido na torre de origem
        je unstack                    ; caso nao tenha nunhum disco, pula para desempilhar
        
        ; Primeira recursividade    
        push dword [ebp+16]           ; Empurra a torre Auxiliar
        push dword [ebp+20]           ; Empurra a torre Destino
        push dword [ebp+12]           ; Empurra a torre Origem
        
        dec eax                       ; tira o disco do topo da torre de origem para ser colocado outra torre
        push dword eax                ; empurra o numero de discos restantes a serem movidos na Torre de origem
        
        call hanoi                    ; chama a label hanoi para guardar a linha de retorno (recursao)
        
        add esp, 16                   ; após retornar da chamada da label hanoi, remove o "lixo" da pilha que está ocupando espaço na memoria

        ; Printando os movimentos
        push dword [ebp+16]           ; empilha o torre de Saida
        push dword [ebp+12]           ; empilha o torre de Ida
        push dword [ebp+8]            ; empilha o disco
        
        call print_hanoi              ; chama a label para imprimir os movimentos
        
        add esp, 12                   ; após retornar da chamada da label hanoi, remove o "lixo" da pilha que está ocupando espaço na memoria
        
        ; Segunda recursividade
        push dword [ebp+12]           ; Empurra a torre Origem
        push dword [ebp+16]           ; Empurra a torre Auxiliar
        push dword [ebp+20]           ; Empurra a torre Destino
        
        mov eax, [ebp+8]              ; move para o registrador eax o número de discos restantes
        
        dec eax                       ; tira o disco do topo da torre de origem para ser colocado outra torre
        push dword eax                ; empurra o numero de discos restantes a serem movidos na Torre de origem
    
        call hanoi                    ; chama a label hanoi para guardar a linha de retorno (recursao)

    unstack: 
        mov esp, ebp                  ; aponta o ponteiro da base da pilha (ebp) para o topo
        pop ebp                       ; tira o elemento do topo da pilha e guarda o valor em ebp
        ret                           ; retira o ultimo valor do topo da pilha e da um jump para ele (a linha de retorno nesse caso)

    print_hanoi:
        push ebp                      ; empurra o registrador ebp na pilha (para ser a base)
        mov ebp, esp                  ; aponta o ponteiro do topo da pilha (esp) para a base
        
        mov eax, [ebp + 8]            ; coloca no registrador ax o disco a ser movido
        add al, 48                    ; conversao na tabela ASCII
        mov [disk], al                ; coloca o valor no [disk] para o print

        mov eax, [ebp + 12]           ; coloca no registrador ax a torre de onde o disco saiu
        add al, 64                    ; conversao na tabela ASCII
        mov [from_tower], al         ; coloca o valor no [from_tower] para o print

        mov eax, [ebp + 16]           ; coloca no registrador ax a torre de onde o disco foi
        add al, 64                    ; conversao na tabela ASCII
        mov [to_tower], al           ; coloca o valor no [to_tower] para o print

        mov edx, move_msg_length      ; tamanho da mensagem
        mov ecx, msg                  ; mensagem em si
        call print

        call unstack             
        ret                       

    print:
        mov ebx, 1
        mov eax, 4
        int 80h

        ret
