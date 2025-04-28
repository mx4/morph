;
;               ÛÜ   ÜÛ    ßßßß   ßßßßß   ßßßßß   Û    Û
;               Û ßÜß Û   Û    Û  Û    Û  Û    Û  Û    Û
;               Û     Û   Û    Û  ÛÜÜÜÜ   ÛÜÜÜÜ   ÛßßßßÛ
;               Û     Û    ÜÜÜÜ   Û    Û  Û       Û    Û


;                       THE 4Kb OF THE CENTURY !!



INCLUDE                 MACROS.INC

distance                = 11  ;(2^10=1024)

;  /ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\
;  ³°°°°°°°°°°°°°°°°°°° Segment CODE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°³
;  \ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
CODE                    SEGMENT
                        ASSUME CS:CODE,DS:CODE
.486P
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄCODEÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        ORG     100h

START:
                        mov     ah,4Ah
                        mov     bx,Offset Fincode
                        shr     bx,4
                        inc     bx
                        int     21h
                        mov     sp,OFFSET Pile+4000
                        WRITE   mess_init

; Allocation de segments de donn‚es:
                        NEWP    Virtuel,4096
                        NEWP    SegPhong,4096
                        mov     es,Virtuel
                        mov     cx,16000
                        xor     eax,eax
                        mov     di,ax
                        rep     stosd
                        push    cs
                        pop     es

; Initialisation partie tunnel:
                        NEWP    SegPlasma,4096
                        NEWP    SegAdresse1,4096
                        NEWP    SegAdresse2,4096
                        NEWP    SegFond,4096
                        CALL    Gen_Cos
                        CALL    Gen_Plasma
                        CALL    Gen_Adresse
; Initialisation partie 3D:
                        CALL    Routine
                        CALL    Gen_Phong     ; Cr‚ation mappe du Phong
; Initialisation vid‚o:
                        VGA     19
; Flashing...

                        CALL    FLASH
                        CALL    FRESH
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ TUNNEL ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        CALL    GO_T2

                        CALL    FLASH
                        CALL    FRESH

                        CALL    GO_T1
; Reflashing....
                        CALL    FLASH
                        CALL    FRESH

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ 3D PHONG & MORPHING ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Partie 1
                        push    cs
                        pop     ds
                        mov     ondule,1
                        mov     decal_ang,256*65536
                        mov     diam,80
                        mov     lng,160
                        CALL    Make1     ; G‚nŠre un tore SEGTORE
                        mov     decal_ang,0
                        CALL    Make2      ; G‚nŠre un tore SEGTORENEW
                        CALL    PAL

                        CALL    LANCE_3D
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Partie 2
                        ;mov     decal_ang,0
                        ;mov     diam,100
                        ;mov     lng,200
                        CALL    Make1     ; G‚nŠre un tore SEGTORE
                        mov     ondule,0
                        ;mov     decal_ang,0
                        ;mov     diam,100
                        ;mov     lng,200
                        CALL    Make2      ; G‚nŠre un tore SEGTORENEW

                        CALL    FLASH
                        CALL    FRESH
                        CALL    PAL

                        CALL    LANCE_3D

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Retour DOS:
               fini:    CALL    FLASH
                        VGA     3
                        WRITE   Messy
                        DOS_    0
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ PROCEDURES UTILISEES ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Pr‚pare le morphing et lance la vid‚o pour 10 secondes:
lance_3D:
                        mov     ax,SegTore
                        mov     Seg_Obj_Morph2,ax
                        mov     ax,SegToreNew
                        mov     Seg_Obj_Morph1,ax
                        mov     pas,20
                        mov     popo,1
                        CALL    PREP1
                        CALL    PREP2
                        xor     eax,eax
                        mov     compteur,ax
                        mov     Time,eax
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAINBCL:                mov     w cs:Patch+3,OFFSET FacesVisibles
                        mov     w cs:Patch1+2,OFFSET FacesVisiblesObj

                        mov     ax,popo
                        add     compteur,ax
                        mov     bx,w pas
                        cmp     compteur,bx
                        jbe     @smo
                        neg     popo
                @smo:   cmp     popo,1
                        jne     @as
                        CALL    INCREMENTE
                        jmp     @as2
                 @as:   CALL    DECREMENTE
                 @as2:  CALL    COPIE

                        mov     fs,Seg_Obj_Morph1
                        CALL    MAIN3D

                        CALL    AFFICHAGE
                        ;Raster_End
                        WAIT_VBL
                        ;RasterRouge
                        CALL    TRANSF
                        mov     fs,Seg_Obj_Morph1
                        add     alpha,7
                        add     beta,10
                        add     gamma,12
                        inc     Time
                        in      al,60h
                        cmp     al,1
                        je      fini
                        cmp     time,8*36
                        jbe     MAINBCL
                        ret
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TRANSF                  proc    near
                        push    cs
                        push    cs
                        mov     es,ecran
                        mov     ds,virtuel
                        mov     cx,16000
                        push    cx
                        xor     si,si
                        mov     di,si
                        rep     movsd
                        pop     cx
                        push    ds
                        pop     es
                        mov     ds,cs:SegFond
                        xor     si,si
                        mov     di,si
                        rep     movsd
                        pop     ds
                        pop     es
                        ret
TRANSF                  endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ROUTINE                 proc    near
                        mov     es,SegFond
                        mov     ds,SegFond
                        xor     eax,eax
                        mov     di,ax
                        mov     cx,65536/4
                        rep     stosd
                        mov     cx,ax
                        mov     bx,ax
                        mov     dx,ax

                bcl:    xor     dl,bh
                        sub     dl,bl
                        rcr     dl,cl
                        mov     cl,ah
                        rcl     dl,cl
                        mov     al,[bx+319]
                        add     al,[bx+639]
                        rcr     al,1
                        mov     ah,dl
                        mov     cl,bh
                        rol     ah,cl
                        sar     ah,4
                        inc     ah
                        add     al,ah
                        mov     [bx],al
                        dec     bx
                        jnz     bcl
; Ca peut s'arreter ici, mais division par 4 et ajout de 64 pour
; l'organisation de la palette.
                   @q:  shr     b [bx],2
                        add     b [bx],64
                        dec     bx
                        jnz     @q
                        push    cs
                        pop     ds
                        push    cs
                        pop     es
                        ret
ROUTINE                 endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Cr‚ation d'une palette.
; C(c1,c2,c3)ÄÄ>D(d1,d2,d3)
MAKE_PAL                proc    near
                        movzx   ax,c
                        movzx   bx,d
                        sub     bx,ax
                        mov     dx,3C8h
                        out     dx,al
                        xor     cx,cx

                @bclPal:mov     al,d1  ; r1 := i*(d1-c1) DIV (b-a) + c1
                        sub     al,c1
                        shl     ax,8
                        imul    cx
                        idiv    bx
                        sar     ax,8
                        add     al,c1
                        mov     dx,03C9h
                        out     dx,al

                        mov     al,d2  ; g1 := i*(d2-c2) DIV (b-a) + c2
                        sub     al,c2
                        shl     ax,8
                        imul    cx
                        idiv    bx
                        sar     ax,8
                        add     al,c2
                        mov     dx,03C9h
                        out     dx,al

                        mov     al,d3  ; b1 := i*(d3-c3) DIV (b-a) + c3
                        sub     al,c3
                        shl     ax,8
                        imul    cx
                        idiv    bx
                        sar     ax,8
                        add     al,c3
                        mov     dx,03C9h
                        out     dx,al

                        inc     cx
                        cmp     cx,bx
                        jle     @bclPal
                        ret
MAKE_PAL                endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FRESH                   proc    near
                        mov     dwd c,0
                        ;mov     c1,0
                        ;mov     c2,0
                        ;mov     c3,0
                        mov     d,32
                        mov     d1,0
                        mov     d2,32
                        mov     d3,63
                        CALL    MAKE_PAL
                        mov     c,32
                        mov     c1,0
                        mov     c2,32
                        mov     c3,63
                        mov     d,64
                        mov     d1,0
                        mov     w d2,63*256+63
                        ;mov     d3,63
                        CALL    MAKE_PAL
                        ret
FRESH                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
FLASH                   proc    near
                        mov     es,Ecran
                        mov     cx,16000
                        xor     eax,eax
                        mov     di,ax
                        rep     stosd
                        push    cs
                        pop     es

                        mov     dx,03C8h
                        xor     al,al
                        out     dx,al
                        inc     dl

                        mov     cx,64
              @flash1:  mov     ax,64
              @flash2:  out     dx,al
                        out     dx,al
                        out     dx,al
                        dec     ax
                        jns     @flash2
                        push    dx
                        WAIT_VBL
                        pop     dx
                        dec     cx
                        jnz     @flash1

                        mov     cx,64
              @flash3:  xor     ax,ax
              @flash4:  out     dx,al
                        out     dx,al
                        out     dx,al
                        inc     ax
                        cmp     al,64
                        jbe     @flash4
                        push    dx
                        WAIT_VBL
                        pop     dx
                        dec     cx
                        jnz     @flash3
                        ret
FLASH                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Cr‚ation d'un torre dans le segment SEGTORE
Make_Tore               proc    near
                        ; Cr‚ation du profil
                        mov     ax,OFFSET DATAprofil
                        shr     ax,4
                        mov     bx,cs
                        add     ax,bx
                        mov     es,ax

                        xor     di,di
                        mov     eax,32          ; 32 points sur le profil
                        stosw
                        mov     al,8          ; 8 ‚tapes de rotation
                        stosd
                        mov     incr,1024*65536/32

                        mov     eax,decal_ang
                        mov     angle,eax

                        xor     esi,esi
                        mov     cx,32
              @maz:     push    cx
                        movzx   ebx,w angle+2
                        and     bx,1023
                        and     si,1023
                        mov     edx,diam
                        cmp     ondule,0
                        je      @suite

                        movsx   edx,w Cos_Table[2*esi]
                        sar     edx,6
                        add     edx,diam

             @suite:    movsx   eax,w Cos_Table[2*ebx]
                        imul    eax,edx
                        sar     eax,10
                        sub     ax,lng
                        stosw

                        dec     bh
                        and     bx,1023
                        movsx   eax,w Cos_Table[2*ebx]
                        imul    eax,edx
                        sar     eax,10
                        stosw
                        mov     eax,incr
                        add     angle,eax
                        add     si,1024*6/32
                        pop     cx
                        dec     cx
                        jnz     @maz
                        push    cs
                        pop     es

                        ; Cr‚ation du tore
                        mov     ax,OFFSET DATAprofil
                        shr     ax,4
                        mov     bx,cs
                        add     ax,bx
                        mov     gs,ax
                        CALL    MakeObj         ; G‚nŠre l'objet.
                        mov     ax,SegLofter
                        mov     fs,ax
                        CALL    Calc_Norm    ; G‚nŠre les normales de l'objet.
                        xor     ax,ax
                        mov     Xobj,ax
                        mov     Yobj,ax
                        mov     Zobj,ax
                        mov     alpha,ax
                        mov     beta,ax
                        mov     gamma,ax
                        push    cs
                        pop     es
                        ret
Make_Tore               endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAKE1                   proc    near
                        call    Make_tore
                        mov     ax,SegLofter
                        mov     SegTore,ax
                        ret
MAKE1                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
MAKE2                   proc    near
                        call    Make_tore
                        mov     ax,SegLofter
                        mov     SegToreNew,ax
                        ret
MAKE2                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
GEN_COS                proc    near
; Calcul de la table de Cosinus :
                        lea     di,Cos_Table+8
                        mov     cx,1022
                        mov     ebx,Cos_Table[4]
                        mov     eax,ebx
    calc:               imul    ebx
                        shrd    eax,edx,23
                        sub     eax,[di-8]
                        stosd
                        loop    calc
; Tout les cosinus sont * par 2^10.
                        push    cs
                        pop     es
                        mov     si,OFFSET Cos_Table
                        mov     di,si
                        mov     cx,1024
              @div:     lodsd
                        sar     eax,14
                        stosw
                        dec     cx
                        jnz     @div
                        ret
GEN_COS                 endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Pr‚paration des incr‚ments pour le morphing.
PREP1                   proc    near
                        mov     fs,Seg_Obj_Morph1
                        mov     gs,Seg_Obj_Morph2
                        push    cs
                        pop     es

                        mov     si,30
                        mov     di,OFFSET TabPtsInc
                        call    @d
                        mov     si,fs:[10]
                        mov     di,OFFSET TabVctInc
                @d:     mov     cx,fs:[2]
                        shl     cx,2

               @rer:    mov     ax,gs:[si]
                        sub     ax,fs:[si]
                        shl     eax,16
                        cdq
                        idiv    PAS
                        stosd
                        add     si,2
                        dec     cx
                        jnz     @rer
                        ret
PREP1                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PREP2                   proc    near
                        mov     si,30
                        mov     di,OFFSET TabPts
                        call    @d1
                        mov     si,fs:[10]
                        mov     di,OFFSET TabVct
               @d1:     mov     cx,fs:[2]
                        shl     cx,2

                        mov     cx,fs:[2]
                        shl     cx,2
                @tra:   mov     ax,w fs:[si]
                        shl     eax,16
                        stosd
                        add     si,2
                        dec     cx
                        jnz     @tra
                        ret
PREP2                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCREMENTE              proc    near
                        mov     fs,Seg_Obj_Morph1
                        mov     di,OFFSET TabPts
                        mov     si,OFFSET TabPtsInc
                        call    @c2
                        mov     di,OFFSET TabVct
                        mov     si,OFFSET TabVctInc
                @c2:    mov     cx,fs:[2]
                        shl     cx,2

            @@@@inx:    mov     eax,dwd [si]
                        add     dwd [di],eax
                        add     si,4
                        add     di,4
                        dec     cx
                        jnz     @@@@inx
                        ret
INCREMENTE              endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
DECREMENTE              proc    near
                        mov     fs,Seg_Obj_Morph1
                        mov     di,OFFSET TabPts
                        mov     si,OFFSET TabPtsInc
                        call    @c1
                        mov     di,OFFSET TabVct
                        mov     si,OFFSET TabVctInc
                @c1:    mov     cx,fs:[2]
                        shl     cx,2

            @@@@inx2:   mov     eax,dwd [si]
                        sub     dwd [di],eax
                        add     si,4
                        add     di,4
                        dec     cx
                        jnz     @@@@inx2
                        ret
DECREMENTE              endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
COPIE                   proc    near
                        push    cs
                        pop     ds
                        mov     si,OFFSET TabPts+2
                        mov     fs,Seg_Obj_Morph1
                        mov     di,30
                        call    @c
                        mov     si,OFFSET TabVct+2
                        mov     di,fs:[10]
                  @c:   mov     cx,fs:[2]
                        shl     cx,2

                @cop:   mov     ax,w [si]
                        mov     w fs:[di],ax
                        add     si,4
                        add     di,2
                        dec     cx
                        jnz     @cop
                        ret
COPIE                   endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; fait la palette du fond d'ecran:
PAL                     proc    near
COMMENT                 %
                        mov     c,64
                        mov     c1,0
                        mov     c2,0
                        mov     c3,64
                        mov     d,127
                        mov     d1,55
                        mov     d2,55
                        mov     d3,64
                        CALL    MAKE_PAL  ; jaune ÄÄ> noir
                        %
                        mov     c,64
                        mov     c1,0
                        mov     c2,0
                        mov     c3,0
                        mov     d,127
                        mov     d1,0
                        mov     d2,0
                        mov     d3,64
                        CALL    MAKE_PAL
                        ret
PAL                     endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
INCLUDE                 MOTEUR.ASM
INCLUDE                 MAKE_1.ASM
INCLUDE                 PLASMA.INC
INCLUDE                 TUNNEL.INC
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;   ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDATASÄÄÄÄÄÄÄ
mess_init               db 'Initializing....','$'
messy                   db '*MORPH*','$'
Ecran                   dw 0A000h
profondeur              dw 4000

Time                    dd ?

octet                   db ?
ondule                  db ?

ALIGN   16
DATAProfil              dd 80 dup (?)
diam                    dd ?
lng                     dw ?
decal_ang               dd ?

; Table de cosinus:
Cos_Table               dd     16777216     ; 2^24
                        dd     16776900     ; 2 ^24*cos(2ã/1024)
                        dd     1022 dup (?)

; Segments de donn‚es:
Seg_Obj_Morph1          dw ?
Seg_Obj_Morph2          dw ?
SegPhong                dw ?
SegMappe                dw ?
SegTore                 dw ?
SegToreNew              dw ?
SegFond                 dw ?
Virtuel                 dw ?
; Donn‚es du g‚n‚rateur de palette.
c                       db ?
c1                      db ?
c2                      db ?
c3                      db ?
d                       db ?
d1                      db ?
d2                      db ?
d3                      db ?

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MAKE_1.ASM
Angle            dd ?
Incr             dd ?
sin              dd ?
cos              dd ?
SegLofter        dw ?
totpts           dw ?
totface          dw ?
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; T.INC
SegAdresse1             dw ?
SegAdresse2             dw ?
decal                   dw ?
adresse                 dd ?
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; MOTEUR.ASM
; Variables diverses:
X                       dd ?
Y                       dd ?
Z                       dd ?
X1                      dd ?
Y1                      dd ?
Z1                      dd ?
X2                      dd ?
Y2                      dd ?
Z2                      dd ?
cosy                    dd ?
siny                    dd ?
cosz                    dd ?
sinz                    dd ?
popo                    dw ?

; Donn‚es pour le remplissage de Polys:
; Position … l'‚cran des extr‚mit‚s du triangle.
fy1                     dw  ?
fx1                     dw  ?
fy2                     dw  ?
fx2                     dw  ?
fy3                     dw  ?
fx3                     dw  ?

; Coordonn‚es du vecteur normal en chaque extr‚mit‚ du triangle.
VctX1                   dw  ?
VctY1                   dw  ?
VctX2                   dw  ?
VctY2                   dw  ?
VctX3                   dw  ?
VctY3                   dw  ?

ALIGN   4
Xg                      dd  ?
Xp                      dd  ?
Xm                      dd  ?
Ym                      dd  ?
Xm1                     dd  ?
Ym1                     dd  ?
increment               dd  ?
increment1              dd  ?
largeur                 dw  ?
Off_Ligne               dw  ?
Count                   dw  ?
Ycourant                dw  ?
inc1                    dw  1
inc2                    dw  1
depasse                 db  ?
sens                    db  ?

; ParamŠtres pour g‚rer plusieurs objets:
FacesVisibles           dw 1200*2 dup (?)
FacesVisiblesObj        dw 1200*2 dup (?)

; Tableau temporaire pour le morphing:
compteur                dw ?
Pas                     dd ?
ALIGN   4
TabPts                  dd 500 dup (?,?,?,?)
TabPtsInc               dd 500 dup (?,?,?,?)
TabVct                  dd 500 dup (?,?,?,?)
TabVctInc               dd 500 dup (?,?,?,?)
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

PILE            dw 2000 dup (?)
                FINCODE:
CODE                    ENDS
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        END    START

