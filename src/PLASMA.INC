; G‚n‚ration d'un segment de plasma … la Mars.
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; PLASMA.INC
SegPlasma               dw  ?
RandomSeed              dw  56        ; Chiffre al‚atoire 0<X<255 (56)
W_Divider               dw  0DB97h
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

GEN_PLASMA      proc    near                
                xor     di, di
                mov     es,SegPlasma
                stc
                sbb     eax,eax
                mov     cx, 16384
                rep     stosd
                mov     si,RandomSeed
                call    M_MakeMUL
                mov     RandomSeed,dx
                xor     bx,bx
                mov     cx,0100h
                mov     b es:[0080h],  -2
                mov     b es:[8000h],  -2
                mov     b es:[0000h],   cl
                mov     b es:[8080h],   cl
                call    CalcFrac
                xor     di,di
        @shr:   mov     ax,es:[di]
                shr     ah,2
                shr     al,2
                stosw
                or      di,di
                jne     @shr
                push    cs
                pop     es                
                ret
GEN_PLASMA      endp
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Routine pour l'affichage des nuages de MARS.

CalcFrac        PROC    NEAR       
                shr     cx, 1
                jz      End_Frac
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                add     bl, cl
                mov     di, bx
                add     bl, cl
                CALL    M_CalcSquare
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                add     bh, cl
                mov     di, bx
                add     bh, cl
                CALL    M_CalcSquare
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                sub     bl, cl
                mov     di, bx
                sub     bl, cl
                CALL    M_CalcSquare
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                sub     bh, cl
                mov     di, bx
                sub     bh, cl
                CALL    M_CalcSquare
                xor     ax, ax
                add     al, es:[bx]
                adc     ah, ch
                add     bl, cl
                add     bl, cl
                add     al, es:[bx]
                adc     ah, ch
                add     bh, cl
                add     bh, cl
                add     al, es:[bx]
                adc     ah, ch
                sub     bl, cl
                sub     bl, cl
                add     al, es:[bx]
                adc     ah, ch
                shr     ax, 2
                CALL    M_Calc2Square
                add     bl, cl
                sub     bh, cl
                mov     es:[bx], al
                push    bx
                push    cx
                call    CalcFrac
                pop     cx
                pop     bx
                sub     bl, cl
                push    bx
                push    cx
                call    CalcFrac
                pop     cx
                pop     bx
                sub     bh, cl
                push    bx
                push    cx
                call    CalcFrac
                pop     cx
                pop     bx
                add     bl, cl
                call    CalcFrac
end_Frac:       ret
CalcFrac        ENDP

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

M_Calc2Square           proc    near
                        mov     ch, al
                        CALL    M_MakeMUL
                        sub     dx, 67E8h
                        xor     ax, ax
                        mov     al, cl
                        shl     ax, 3
                        imul    dx
                        xor     ax, ax
                        add     dl, ch
                        mov     ch, al
                        adc     dh, ch
                        js      @CS2
                        jz      @CS1
                        mov     dl, 0FEh
  @CS1:                 mov     al, dl
  @CS2:                 ret
M_Calc2Square           Endp

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
M_CalcSquare            proc    near
                        cmp     byte ptr es:[di], 0FFh
                        jne     @CS3
                        add     al, es:[bx]
                        adc     ah, ch
                        shr     ax, 1
                        CALL    M_Calc2Square
                        stosb
  @CS3:                 ret
M_CalcSquare            Endp
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
M_MakeMUL               PROC    NEAR
                        mov     ax, 0AFh
                        mul     si
                        add     ax, 2BC0h
                        adc     dx, 0
                        div     W_Divider
                        mov     si, dx
                        ret
M_MakeMUL               EndP
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
