section .data
    ; Define texto usado ao longo do programa
    ask_disks db "Com quantos discos você quer jogar?(0 a 99) ", 0
    invalid db "Entrada inválida, tente novamente(0 a 99) "
    move_disk db "Mova o disco", 0
    from_column db " da coluna ", 0
    to_column db " para a coluna ", 0
    done db "Concluído!", 0
    origin_tower db "A", 0
    aux_tower db "B", 0
    goal_tower db "C", 0

    endline db 10

section .text
    global _start

_start:

    inicio:
    mov ecx, done
    call print_string
    
    mov eax, 1
    xor ebx, ebx
    int 0x80

    print_char:
        mov eax, 4
        mov ebx, 1
        mov edx, 1
        int 0x80
        ret

    print_string:
        print_all_chars:
            mov al, ecx[0]
            cmp al, 0
            je end_print
            call print_char
            inc ecx
            jmp print_all_chars

        end_print:
            ret
