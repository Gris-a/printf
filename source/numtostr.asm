section     .text
global inttostr
global uinttostr
global octtostr
global hextostr
global bintostr

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: r11, rdx, rdi
; ===============================================
inttostr:
; -----------------------------------------------
            mov eax, edi
            mov r11, rsi
; -----------------------------------------------
            cmp eax, 0                          ; eax = |eax|
            jge PushNumber_int
            neg eax
; -----------------------------------------------
PushNumber_int:
            xor edx, edx                        ; edx = 0
            div dword [base10]                  ; edx:eax / 10

            add dl, 0x30                        ; 'i' is 0x3i in ascii
            mov byte [r11], dl                  ; save digit to buffer
            inc r11

            test eax, eax                       ; if(eax == 0) then traslated to str
            je EndPush_int

            jmp PushNumber_int
EndPush_int:
; -----------------------------------------------
            cmp edi, 0                          ; save edi sign
            jge End_int
            mov byte [r11], '-'                 ; save digit to buffer
            inc r11
; -----------------------------------------------
End_int:    sub r11, rsi                        ; n chars written
            mov rax, r11
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: r11, rdx, rdi
; ===============================================
uinttostr:
; -----------------------------------------------
            mov eax, edi
            mov r11, rsi
; -----------------------------------------------
PushNumber_u:
            xor edx, edx                        ; rdx = 0
            div dword [base10]                  ; rdx:rax / 10

            add dl, 0x30                        ; 'i' is 0x3i in ascii
            mov byte [r11], dl                  ; save digit to buffer
            inc r11

            test eax, eax                       ; if(rax == 0) then traslated to str
            je EndPush_u

            jmp PushNumber_u
EndPush_u:
; -----------------------------------------------
            sub r11, rsi                        ; count length
            mov rax, r11                        ; load length
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: r11, rdx, rdi, rcx
; ===============================================
hextostr:
; -----------------------------------------------
            mov edx, 0xf                        ; mask
            mov cl, 0x4                         ; base2 power
            jmp base2tostr
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: r11, rdx, rdi, rcx
; ===============================================
octtostr:
; -----------------------------------------------
            mov edx, 0x7                        ; mask
            mov cl, 0x3                         ; base2 power
            jmp base2tostr
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: r11, rdx, rdi, rcx
; ===============================================
bintostr:
; -----------------------------------------------
            mov edx, 0x1                        ; mask
            mov cl, 0x1                         ; base2 power
            jmp base2tostr
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
;       rdx     mask
;       cx      base2 power
; exit:
;       rax     output len
; destr: r11, rdx, rdi
; ===============================================
base2tostr:
; -----------------------------------------------
            mov r11, rsi
; -----------------------------------------------
PushNumber_b2:
            mov rax, rdi                        ; get digit
            and rax, rdx
            shr rdi, cl                         ; divide

            mov al, byte [config + rax]         ; 'i' is at i pos in config
            mov byte [r11], al                  ; save digit to stack
            inc r11

            test rdi, rdi                       ; if(rdi == 0) then traslated to str
            je EndPush_b2

            jmp PushNumber_b2
EndPush_b2:
; -----------------------------------------------
            sub r11, rsi
            mov rax, r11                        ; load length
            ret
; -----------------------------------------------


section     .data
base10      dd 10
config      db "0123456789abcdef"