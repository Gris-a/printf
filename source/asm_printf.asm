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

%macro FLUSH 0
    add r8, r10

    lea rsi, buffer     ; buf
    mov rdx, r10        ; len
    mov edi, 0x01       ; stdout
    mov eax, 0x01       ; write syscall
    syscall

    xor r10d, r10d
%endmacro

%macro WRITE_BUF 0
    mov r10d, buff_sz
    FLUSH
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
            pop rax                             ; save ret addr
            MPUSH r9, r8, rcx, rdx, rsi, rdi    ; push all args
            push rax                            ; laod ret addr
; -----------------------------------------------
            MPUSH rbp, rbx                      ; push regs
; -----------------------------------------------
            xor r10d, r10d                      ; set buf pos 0
            xor r8d, r8d                        ; set chars counter 0
; -----------------------------------------------
            lea rbp, [rsp + 8 * 3]              ; first arg pos
            mov rbx, rdi                        ; save format str addr
; -----------------------------------------------
CharProcess:
            mov r9b, byte [rbx]                 ; load next character

            test r9b, r9b                       ; if '\0' then end success
            jz GoodEnding

            cmp r9b, '%'                       ; if '%' then format check
            jne PutChar
; -----------------------------------------------
            inc rbx                             ; load next char
            mov r9b, byte [rbx]

            cmp r9b, '%'                        ; if '%' then put it
            je PutChar

            cmp r9b, 'b'                        ; if < 'b' then end error
            jb BadEnding

            cmp r9b, 'u'                        ; if > 'u' then end error
            ja BadEnding
; -----------------------------------------------
            lea rbp, [rbp + 8]                  ; next arg
; -----------------------------------------------
            and r9, 0xff                        ; get switch table offset
            sub r9b, 'b'                        ;
; -----------------------------------------------
            lea rsi, FormatSwitchTable[r9 * 8]  ; load Switch Table Address
            mov r9, [rbp]                       ; load next arg to r9
            jmp [rsi]                           ; switch jump
; -----------------------------------------------
Format_b:
            sub rsp, 64
            mov rdi, r9
            mov rsi, rsp
            call bintostr
            jmp BufNum
; -----------------------------------------------
Format_o:
            sub rsp, 64
            mov rdi, r9
            mov rsi, rsp
            call octtostr
; -----------------------------------------------
Format_h:
            sub rsp, 64
            mov rdi, r9
            mov rsi, rsp
            call hextostr
            jmp BufNum
; -----------------------------------------------
Format_d:
            sub rsp, 64
            mov rdi, r9
            mov rsi, rsp
            call inttostr
            jmp BufNum
; -----------------------------------------------
Format_u:
            sub rsp, 64
            mov rdi, r9
            mov rsi, rsp
            call uinttostr
            jmp BufNum
; -----------------------------------------------
BufNum:
            lea r9, [rsi + rax - 1]
BufDigit:
            mov al, byte [r9]

            mov byte [buffer + r10], al
            inc r10b
            jne NoWriteBuf

            WRITE_BUF
NoWriteBuf:
            cmp rsp, r9
            je EndBufNum

            dec r9
            jmp BufDigit
EndBufNum:
            add rsp, 64
            jmp NextChar
; -----------------------------------------------
Format_s:
            mov al, byte [r9]
            inc r9

            test al, al
            je NextChar

            mov byte [buffer + r10], al
            inc r10b
            jne Format_s

            WRITE_BUF
            jmp Format_s
; -----------------------------------------------
PutChar:
            mov byte [buffer + r10], r9b        ; load char
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
            mov rax, -1
            jmp Ending
; -----------------------------------------------
GoodEnding:
            FLUSH                               ; flush stdout
            mov rax, r8                         ; load n chars written
; -----------------------------------------------
Ending:
            MPOP rbx, rbp                       ; load regs
            pop rsi                             ; save ret addr
            add rsp, 8 * 3                      ; restore rsp
            push rsi                            ; load ret addr
            ret
; -----------------------------------------------

section     .data
buffer:     times 256 db 0
buff_sz     equ $-buffer

section     .rodata
align 8

FormatSwitchTable:
                    dq Format_b                 ; b
                    dq PutChar                  ; c
                    dq Format_d                 ; d
times 'g' - 'e' + 1 dq BadEnding                ; e..g
                    dq Format_h                 ; h
times 'n' - 'i' + 1 dq BadEnding                ; i..n
                    dq Format_o                 ; o
times 'r' - 'p' + 1 dq BadEnding                ; p..r
                    dq Format_s                 ; s
                    dq BadEnding                ; t
                    dq Format_u                 ; u