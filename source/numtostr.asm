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
; destr: rcx, rdx, rdi
; ===============================================
inttostr:
; -----------------------------------------------
            push 0
            mov eax, edi                        ; eax = edi
; -----------------------------------------------
            cmp eax, 0                          ; eax = |eax|
            jge PushNumber_int
            neg eax
; -----------------------------------------------
PushNumber_int:
            xor edx, edx                        ; edx = 0
            div dword [base10]                  ; edx:eax / 10

            add dl, 0x30                        ; 'i' is 0x3i in ascii
            push rdx                            ; save digit to stack

            test eax, eax                       ; if(eax == 0) then traslated to str
            je EndPush_int

            jmp PushNumber_int
EndPush_int:
; -----------------------------------------------
            mov rax, rsi                        ; save buffer addr
; -----------------------------------------------
            cmp edi, 0                          ; push edi sign
            jge PopNumber_int
            push '-'
; -----------------------------------------------
PopNumber_int:
            pop rdi                             ; get digit

            test dil, dil                       ; end if 0
            je End_int

            mov byte [rax], dil                 ; load digit to buffer
            inc rax                             ; next buffer pos
            jmp PopNumber_int
; -----------------------------------------------
End_int:    sub rax, rsi                        ; load lngth
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: rcx, rdx, rdi
; ===============================================
uinttostr:
; -----------------------------------------------
            push 0
            mov eax, edi
; -----------------------------------------------
PushNumber_u:
            xor edx, edx                        ; rdx = 0
            div dword [base10]                  ; rdx:rax / 10

            add dl, 0x30                        ; 'i' is 0x3i in ascii
            push rdx                            ; save digit to stack

            test eax, eax                       ; if(rax == 0) then traslated to str
            je EndPush_u

            jmp PushNumber_u
EndPush_u:
; -----------------------------------------------
            mov rax, rsi                        ; save buffer addr
; -----------------------------------------------
PopNumber_u:
            pop rdi                             ; get digit

            test dil, dil                       ; end if 0
            je End_u

            mov byte [rax], dil                 ; load digit to buffer
            inc rax                             ; next buffer pos
            jmp PopNumber_u
; -----------------------------------------------
End_u:      sub rax, rsi                        ; load length
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: rcx, rdx, rdi
; ===============================================
hextostr:
; -----------------------------------------------
            mov edx, 0xf                        ; mask
            mov cl, 0x4                         ; base2 power
            call base2tostr
; -----------------------------------------------
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: rcx, rdx, rdi
; ===============================================
octtostr:
; -----------------------------------------------
            mov edx, 0x7                        ; mask
            mov cl, 0x3                         ; base2 power
            call base2tostr
; -----------------------------------------------
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
; exit:
;       rax     output len
; destr: rcx, rdx, rdi
; ===============================================
bintostr:
; -----------------------------------------------
            mov edx, 0x1                        ; mask
            mov cl, 0x1                         ; base2 power
            call base2tostr
; -----------------------------------------------
            ret
; -----------------------------------------------

; ===============================================
; entry:
;       edi     integer
;       rsi     buffer addr
;       rdx     mask
;       cx      base2 power
; exit:
;       rax     output len
; destr: rcx, rdx, rdi
; ===============================================
base2tostr:
; -----------------------------------------------
            push 0
; -----------------------------------------------
PushNumber_b2:
            mov rax, rdi                        ; get digit
            and rax, rdx
            shr rdi, cl                         ; divide

            mov al, byte [config + rax]          ; 'i' is at i pos in config
            push rax                            ; save digit to stack

            test rdi, rdi                       ; if(rdi == 0) then traslated to str
            je EndPush_b2

            jmp PushNumber_b2
EndPush_b2:
; -----------------------------------------------
            mov rax, rsi                        ; save buffer addr
; -----------------------------------------------
PopNumber_b2:
            pop rdi                             ; get digit

            test dil, dil                       ; end if 0
            je End_b2

            mov byte [rax], dil                 ; load digit to buffer
            inc rax                             ; next buffer pos
            jmp PopNumber_b2
; -----------------------------------------------
End_b2:     sub rax, rsi                        ; load length
            ret
; -----------------------------------------------


section     .data
base10      dd 10
config      db "0123456789abcdef"