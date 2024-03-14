section     .text
global print_format
extern putchar
extern strlen
extern inttostr
extern uinttostr
extern octtostr
extern hextostr
extern bintostr

%macro MPUSH 1-*
    %rep %0
        push %1
        %rotate 1
    %endrep
%endmacro

%macro MPOP 1-*
    %rep %0
        pop %1
        %rotate 1
    %endrep
%endmacro

%macro WRITE_BUF 0
    add r12, buff_sz

    lea rsi, buffer     ; buf
    mov rdx, buff_sz    ; len
    mov edi, 0x01       ; stdout
    mov eax, 0x01       ; write syscall
    syscall
%endmacro

%macro FLUSH 0
    add r12, r10

    lea rsi, buffer     ; buf
    mov rdx, r10        ; len
    mov edi, 0x01       ; stdout
    mov eax, 0x01       ; write syscall
    syscall

    xor r10d, r10d
%endmacro

; ===============================================
; entry:
;       rdi     format str
;       ...     parameters
; exit:
;       rax     number of chars written or -1
; destr: rcx, rdx, rsi, rdi, r8, r9, r10, r11
; ===============================================
print_format:
; -----------------------------------------------
            MPUSH r9, r8, rcx, rdx, rsi, rdi    ; push all args
            MPUSH rbp, rbx, r12, r13            ; push regs
            mov rbp, rsp                        ; save rsp pos
; -----------------------------------------------
            xor r10d, r10d                      ; set buf pos 0
            xor r12d, r12d                      ; set chars counter 0
; -----------------------------------------------
            mov r8, 4                           ; rbp + 8 * r8 = first parameter(format string addr)
            lea r9, [r8 + 1]                    ; r9 = r8 + 1
; -----------------------------------------------
            mov rbx, rdi                        ; save format str addr
; -----------------------------------------------
CharProcess:
            xor r13d, r13d                      ; set r13 to 0
            mov r13b, byte [rbx]                ; load next character

            test r13b, r13b                     ; if '\0' then end success
            jz GoodEnding

            cmp r13b, '%'                       ; if '%' then format check
            jne PutChar
; -----------------------------------------------
            inc rbx                             ; load next char
            mov r13b, byte [rbx]

            cmp r13b, '%'                       ; if '%' then put it
            je PutChar

            cmp r13b, 'b'                       ; if < 'b' then end error
            jb BadEnding

            cmp r13b, 'u'                       ; if > 'u' then end error
            ja BadEnding
; -----------------------------------------------
            inc r8                              ; next arg
            inc r9

            cmp r8, 9                           ; increace r8 if r8 > 9 because of ret address on stack
            cmovg r8, r9
; -----------------------------------------------
            sub r13b, 'b'                       ; switch(dil -= 'b')
            lea rsi, FormatSwitchTable[r13 * 8] ; load Switch Table Address
            mov r13, [rbp + 8 * r8]             ; load next arg to rdi
            jmp [rsi]                           ; case rsi:
; -----------------------------------------------
Format_bad:
            jmp BadEnding                       ; bad format
; -----------------------------------------------
Format_b:   FLUSH

            mov rdi, r13
            lea rsi, buffer
            call bintostr
            add r10, rax

            jmp NextChar
; -----------------------------------------------
Format_d:   FLUSH

            mov rdi, r13
            lea rsi, buffer
            call inttostr
            add r10, rax

            jmp NextChar
; -----------------------------------------------
Format_u:   FLUSH

            mov rdi, r13
            lea rsi, buffer
            call uinttostr
            add r10, rax

            jmp NextChar
; -----------------------------------------------
Format_h:   FLUSH

            mov rdi, r13
            lea rsi, buffer
            call hextostr
            add r10, rax

            jmp NextChar
; -----------------------------------------------
Format_o:   FLUSH

            mov rdi, r13
            lea rsi, buffer
            call octtostr
            add r10, rax

            jmp NextChar
; -----------------------------------------------
Format_s:
            mov al, byte [r13]
            inc r13

            test al, al
            je NextChar

            mov byte [buffer + r10], al
            inc r10b
            jne Format_s

            WRITE_BUF
            jmp Format_s
; -----------------------------------------------
PutChar:
            mov byte [buffer + r10], r13b       ; load char
            inc r10b
            jne NextChar                        ; write buffer if overflow

            WRITE_BUF
; -----------------------------------------------
NextChar:
            inc rbx                             ; process next char
            jmp CharProcess
; -----------------------------------------------
BadEnding:
            FLUSH
            mov rax, -1                         ; return EXIT_FAILURE(1)
            jmp Ending
; -----------------------------------------------
GoodEnding:
            FLUSH
            mov rax, r12                        ; return EXIT_SUCCESS(0)
; -----------------------------------------------
Ending:
            MPOP r13, r12, rbx, rbp             ; load regs
            add rsp, 8 * 6                      ; recovery rsp
            ret
; -----------------------------------------------

section     .data
buffer:     times 256 db 0
buff_sz     equ $-buffer

section     .rodata
align 8

FormatSwitchTable:
dq  Format_b       ; b
dq  PutChar        ; c
dq  Format_d       ; d
dq  Format_bad     ; e
dq  Format_bad     ; f
dq  Format_bad     ; g
dq  Format_h       ; h
dq  Format_bad     ; i
dq  Format_bad     ; j
dq  Format_bad     ; k
dq  Format_bad     ; l
dq  Format_bad     ; m
dq  Format_bad     ; n
dq  Format_o       ; o
dq  Format_bad     ; p
dq  Format_bad     ; q
dq  Format_bad     ; r
dq  Format_s       ; s
dq  Format_bad     ; t
dq  Format_u       ; u