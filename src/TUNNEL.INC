;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

GO_T1                   proc    near
                        xor     eax,eax
                        mov     Time,eax
                        mov     decal,ax
                        mov     w cs:patching+2,ax
                        mov     w cs:patching1+2,ax

        @enroule:       WAIT_VBL
                        CALL    TUNNEL1
                        sub     decal,256+1
                        add     w cs:patching+2,4
                        add     w cs:patching1+2,4
                        and     w cs:patching+2,2048-1
                        and     w cs:patching1+2,2048-1
                        inc     Time
                        in      al,60h
                        cmp     al,1
                        je      fin_tunnel
                        cmp     Time,36*15
                        jbe     @enroule
        fin_tunnel:     ret
GO_T1                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GO_T2                   proc    near                        
                        xor     eax,eax
                        mov     Time,eax
                        mov     decal,ax

        @enroule1:      WAIT_VBL
                        CALL    TUNNEL2
                        sub     decal,256+1
                        inc     Time
                        in      al,60h
                        cmp     al,1
                        je      fin_tunnel1
                        cmp     Time,36*5
                        jbe     @enroule1
        fin_tunnel1:    ret
GO_T2                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Proc‚dure principale du tunnel.
ALIGN 4
TUNNEL1                 proc    near
                        mov     es,Ecran
                        mov     fs,SegAdresse1
                        mov     dx,Decal
                        push    dx
                        push    dx
                        pop     edx
                        mov     ds,SegPlasma
                        mov     cx,16000
                        push    cx
                        xor     esi,esi
                        xor     di,di
                        mov     bp,di
                        CALL    TUN1
                        xor     bp,bp
                        mov     fs,cs:SegAdresse2
                        pop     cx
                        CALL    TUN1
                        push    cs
                        pop     ds
                        ret
TUNNEL1                 endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Procedure d'affichage du tunnel.
TUN1                    proc    near
                        ALIGN   4
                @aff:   mov     ebx,fs:[bp]
                        add     ebx,edx
                        
                        movzx   si,bh
              patching: add     si,01234h
                        and     si,256-1
                        mov     si,w cs:Cos_Table[8*esi]
                        sar     si,4
                        mov     al,[bx+si]
                        
                        shr     ebx,16
                        movzx   si,bh
              patching1:add     si,01234h
                        and     si,256-1
                        mov     si,w cs:Cos_Table[8*esi]
                        sar     si,4
                        mov     ah,[bx+si]
                        
                        mov     es:[di],ax
                        add     di,2
                        add     bp,4
                        dec     cx
                        jnz     @aff
                        ret
TUN1                    endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TUNNEL2                 proc    near
                        mov     es,Ecran
                        mov     fs,SegAdresse1
                        mov     dx,Decal
                        push    dx
                        push    dx
                        pop     edx
                        mov     ds,SegPlasma
                        mov     cx,16000
                        push    cx
                        xor     esi,esi
                        xor     di,di
                        mov     bp,di
                        CALL    TUN2
                        xor     bp,bp
                        mov     fs,cs:SegAdresse2
                        pop     cx
                        CALL    TUN2
                        push    cs
                        pop     ds
                        ret
TUNNEL2                 endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Procedure d'affichage du tunnel.
TUN2                    proc    near
                        ALIGN   4
                @aff1:  mov     ebx,fs:[bp]
                        add     ebx,edx
                        mov     al,[bx]
                        shr     ebx,16
                        mov     ah,[bx]
                        mov     es:[di],ax
                        inc     di
                        inc     di
                        add     bp,4
                        dec     cx
                        jnz     @aff1
                        ret
TUN2                    endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Pr‚pare les adresses dans les segments SegAdresse1 et SegAdresse2, 
; en enroulant chaque ligne de la mappe 256*256 sur un cercle dont le rayon 
; croit.

GEN_ADRESSE             proc    near
                        mov     fs,SegAdresse1
                        mov     gs,SegAdresse2
                        mov     Popo,2
                
                @a2:    xor     bx,bx
                        mov     bp,bx
                        mov     ax,2500
                        cwd
                        mov     cx,Popo
                        shr     cx,3
                        add     cx,5
; Changement de l'effet de perspective en changeant 5
                        idiv    cx
                        mov     dh,al
                        mov     dl,bl
                        mov     w adresse+2,dx

                @a1:    and     bp,2048-1
                        mov     cx,w Cos_Table[bp]
                        sar     cx,5
                        add     cx,popo
                        mov     ax,w Cos_Table[bx]
                        imul    cx
                        shrd    ax,dx,10+1+1+1
                        cwde
                        add     eax,160
                        mov     edi,eax
                        cmp     ax,319
                        ja      @next
                        
                        lea     si,[bx-512]
                        and     si,2048-1
                        mov     ax,w Cos_Table[si]
                        imul    cx
                        shrd    ax,dx,10+1+1+1
                        cwde
                        add     eax,100
                        cmp     ax,199
                        ja      @next
                        
                        lea     eax,[eax+eax*4]
                        shl     eax,6
                        add     edi,eax
                        add     edi,edi
                        mov     ax,w adresse+2
                        
                        cmp     edi,64000
                        jb      @fs
                        add     edi,65536-64000
                        mov     gs:[di],ax
                        jmp     @next
                  
                  @fs:  mov     fs:[di],ax
               @next:   add     adresse,04000h
                        add     bp,8
                        add     bx,2
                        cmp     bx,1024*2
                        jne     @a1
                        inc     Popo
                        cmp     Popo,190*2*2*2+10
                        jnz     @a2
                        ret
GEN_ADRESSE             endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

