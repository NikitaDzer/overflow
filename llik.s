SYS_READ     equ 0
SYS_WRITE    equ 1
SYS_EXIT     equ 60

STDIN        equ 0
STDOUT       equ 1

EXIT_SUCCESS equ 0
; ------- defines ------<


global _start


section .data
times 0x1000 - 6   db 0

password:          dq 0xc40ab6c668b71237    ; " unc. Lo", 0xA 

str_fullaccess:    db  "Full access", 0xA
str_fullaccess_len equ $ - str_fullaccess

str_halfaccess:    db  "Half access", 0xA
str_halfaccess_len equ $ - str_halfaccess

times 0x50         db 0

str_noaccess:      db  "No access", 0xA
str_noaccess_len   equ $ - str_noaccess

times 0x40 + 69    db 0
                   db 1

user_input:        times 8 db 0
user_input_len     equ $ - user_input

str_age:           db  "♀♀♀ Full access for boys 18. First line - your age, second line - your password.", 0xA
str_age_len        equ $ - str_age

section .text
_start:
    xor rax, rax
    xor rdi, rdi

    mov  al, SYS_WRITE
    mov dil, STDOUT
    mov rsi, str_age
    mov rdx, str_age_len
    syscall

    mov  al, SYS_READ
    mov dil, STDIN
    mov rsi, user_input
    mov rdx, user_input_len
    syscall

    mov rcx, user_input_len
    call Atoi
    
    mov r12, rax
    
    mov rax, SYS_READ
    mov rdi, STDIN
    mov rdx, user_input_len
    syscall
    
    call Qhash
    
    mov r11, rax
    mov r10, QWORD [password]

    mov rax, SYS_WRITE
    mov dil, STDOUT
 
    cmp r12, 18
    jne .BadAge

    cmp r10, r11
    jne .NoAccess

    mov rsi, str_fullaccess
    mov rdx, str_fullaccess_len
    syscall

    jmp .ExitProgram

.BadAge:
    cmp r10, r11
    jne .NoAccess

    mov  al, SYS_WRITE
    mov dil, STDOUT
    mov rsi, str_halfaccess
    mov rdx, str_halfaccess_len
    syscall

    jmp .ExitProgram

.NoAccess:
    mov rsi, str_noaccess
    mov rdx, str_noaccess_len
    syscall
    
.ExitProgram: 
    mov rax, SYS_EXIT
    xor rdi, rdi                ; mov rdi, EXIT_SUCCESS
    syscall


Atoi:
    xor rax, rax
    mov r10, 10

    .LOOP_ScanChar:
        movzx rbx, BYTE [rsi]
        cmp rbx, 0xA
        je .Ret

        mul r10
        sub rbx, '0'
        add rax, rbx

        inc sil
        loop .LOOP_ScanChar
    
.Ret:
    lea rsi, [rsi + rcx - user_input_len]
    ret
; ======= AtoiSimple ======<



Qhash:
    lea rcx, [rsi + 8]
    mov rax, 0xDED007

    .LOOP_HashByte:
        mov rdx, rax
        add rsi, 1
        
        shr rax, 8
        sal rdx, 22
        add rdx, rax
        movsx rax, BYTE [rsi - 1]
        xor rax, rdx
        
        cmp rsi, rcx
        jne .LOOP_HashByte

    mov [rsi - 8], rax

    ret

