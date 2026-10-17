; ------------------------------------------------------------
; Proyecto Modulo 2 - Keygen Basico (Laboratorio 8: Fases 1 y 2)
; Materia: Lenguajes de Interfaz (SCC-1014)
; Alumno:  Julio Alejandro Magana Nunez
;
; Comandos para ensamblar y enlazar:
;   uasm64 -win64 keygen_magana_alejandro.asm
;   GoLink.exe keygen_magana_alejandro.obj kernel32.dll /fo keygen_magana_alejandro.exe /console /entry main
; ------------------------------------------------------------

extrn GetStdHandle: proc
extrn WriteConsoleA: proc
extrn ReadConsoleA: proc
extrn ExitProcess: proc

.data
    prompt          db 'Ingresa tu nombre de usuario: ', 0
    prompt_len      dq $ - prompt - 1
    buffer          db 64 DUP (0)
    buffer_len      dq 64
    leidos          dq 0
    escritos        dq 0

    mensaje_llave   db 'Tu llave es: ', 0
    mensaje_len     dq $ - mensaje_llave - 1
    newline         db 13, 10, 0
    newline_len     dq $ - newline - 1

    error_vacio     db 'Error: nombre no valido.', 13, 10, 0
    error_len       dq $ - error_vacio - 1

    suma            dq 0
    hex_buffer      db 17 DUP (0)       ; 16 digitos + null
    hex_chars       db '0123456789ABCDEF'

.code
main proc
    sub rsp, 28h

    ; ------------------------------------------------------------
    ; 1. Obtener handles de consola
    ; ------------------------------------------------------------
    mov rcx, -11
    call GetStdHandle
    mov rbx, rax            ; stdout

    mov rcx, -10
    call GetStdHandle
    mov rsi, rax            ; stdin

    ; ------------------------------------------------------------
    ; 2. Mostrar prompt
    ; ------------------------------------------------------------
    mov rcx, rbx
    lea rdx, prompt
    mov r8, [prompt_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; ------------------------------------------------------------
    ; 3. Leer nombre del usuario
    ; ------------------------------------------------------------
    mov rcx, rsi
    lea rdx, buffer
    mov r8, [buffer_len]
    lea r9, leidos
    mov qword ptr [rsp + 20h], 0
    call ReadConsoleA

    ; ------------------------------------------------------------
    ; 4. Verificar si el nombre esta vacio (solo Enter)
    ; ------------------------------------------------------------
    mov rax, [leidos]
    cmp rax, 2
    jle error_nombre_vacio

    ; ------------------------------------------------------------
    ; 5. Calcular la suma de los valores ASCII (Fase 1)
    ; ------------------------------------------------------------
    lea rsi, buffer
    mov rcx, [leidos]
    sub rcx, 2              ; Descontar los 2 bytes de Enter (CR + LF: 13, 10)
    xor rax, rax

suma_loop:
    movzx rdx, byte ptr [rsi]
    add rax, rdx
    inc rsi
    loop suma_loop

    ; Nota (Bonus opcional RF-2 del PDF 1):
    ; Si se desea aplicar la transformacion extra XOR, descomentar:
    ; xor rax, 0ABCDh

    mov [suma], rax

    ; ------------------------------------------------------------
    ; 6. Convertir la suma a hexadecimal (Fase 2)
    ; ------------------------------------------------------------
    push rbx                ; Preservar el handle stdout guardado en RBX

    mov rax, [suma]
    lea rdi, hex_buffer
    add rdi, 15             ; Empezar desde el final (digito menos significativo)
    mov rcx, 16             ; 16 digitos hexadecimales (64 bits)
    lea rbx, hex_chars

hex_loop:
    mov rdx, rax
    and rdx, 0Fh
    mov dl, [rbx + rdx]
    mov [rdi], dl
    dec rdi
    shr rax, 4
    loop hex_loop

    mov byte ptr [hex_buffer + 16], 0

    pop rbx                 ; Restaurar el handle stdout en RBX

    ; ------------------------------------------------------------
    ; 7. Mostrar la llave en pantalla (Fase 2)
    ; ------------------------------------------------------------
    ; 7.1 Imprimir "Tu llave es: "
    mov rcx, rbx
    lea rdx, mensaje_llave
    mov r8, [mensaje_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; 7.2 Imprimir hex_buffer (16 digitos en hexadecimal)
    mov rcx, rbx
    lea rdx, hex_buffer
    mov r8, 16
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; 7.3 Imprimir nueva linea
    mov rcx, rbx
    lea rdx, newline
    mov r8, [newline_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    jmp fin

    ; ------------------------------------------------------------
    ; 8. Manejo de error: nombre vacio
    ; ------------------------------------------------------------
error_nombre_vacio:
    mov rcx, rbx
    lea rdx, error_vacio
    mov r8, [error_len]
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; ------------------------------------------------------------
    ; 9. Terminar
    ; ------------------------------------------------------------
fin:
    xor ecx, ecx
    call ExitProcess

main endp
end