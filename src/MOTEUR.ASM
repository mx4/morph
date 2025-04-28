;               ATTENTION CODE CONFIDENTIEL: PHONG & PHONG MAPPE

LOCALS

Xobj    equ w fs:[24]
Yobj    equ w fs:[26]
Zobj    equ w fs:[28]
alpha   equ w fs:[18]
beta    equ w fs:[20]
gamma   equ w fs:[22]

;  /ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\
;  ³°°°°°°°°°°°°°°°°°°° Segment CODE °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°³
;  \ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄCODEÄÄÄÄÄÄÄÄ
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;Û               DEBUT DES ROUTINES DE GESTION DE LA 3D                 Û
;ÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛÛ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;/ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ\
;| PROCEDURE PRINCIPALE DE LA 3D                                            |
;|       - rotation des points et vecteurs en chaque point                  |
;|       - d‚termination de la visibilit‚,                                  |
;|       - projection des points … l'‚cran,                                 |
;|       - d‚placement des objets,                                          |
;|       - tri des faces visibles (QSORT),                                  |
;|       - affichage des faces visibles.                                    |
;\ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ/

MAIN3D                  proc    near
; Rotation des points et des vecteurs...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        CALL    PrepMatrice
; On ‚change DS et FS pour ‚viter des pr‚fixes:
                        push    fs
                        push    ds
                        pop     fs
                        pop     ds
                        mov     si,ds:[6]  ; Pts
                        mov     di,ds:[8]  ; PtsR
                        mov     bx,ds:[16] ; Matrice
                        mov     cx,ds:[2]  ; Nb_Pts
         BclRot1:       push    cx
                        mov     cx,3
                        CALL    ROTATE  ; rotation des points.
                        sub     bx,4*3*3  ; Se remet au d‚but de la matrice.
                        pop     cx
                        add     si,8
                        add     di,2
                        dec     cx
                        jnz     bclRot1
                        ; rotation PtsÄÄ>PtsR

                        mov     si,ds:[10]  ; VctNrmPts
                        mov     di,ds:[12]  ; VctNrmPtsR
                        mov     bx,ds:[16]  ; Matrice
                        mov     cx,ds:[2]   ; Nb_Pts
         BclRot2:       push    cx
                        mov     cx,2
                        CALL    ROTATE  ; rotation des vecteurs normaux.
                        sub     bx,4*3*2  ; Se remet au d‚but de la matrice.
                        pop     cx
                        add     si,8
                        add     di,4
                        dec     cx
                        jnz     bclRot2
                        ; rotation VctNrmPtsÄÄ>VctNrmPtsR

; Aplication des coordonn‚es de l'objet … ses points...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        mov     eax,ds:[24]  ; EAX=x+y*65536
                        mov     dx,ds:[28]   ; DX=z
                        mov     cx,ds:[2]    ; CX=Nb_Pts
                        mov     si,ds:[8]    ; SI=OFFSET PtsR
             @deplace:  add     [si],eax
                        add     [si+4],dx
                        add     si,8
                        dec     cx
                        jnz     @deplace

; projection des points … l'‚cran...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                        CALL    XDZ

                        push    fs
                        push    ds
                        pop     fs
                        pop     ds

; D‚tection des faces visibles...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        ; un peu de code auto-modifi‚...
                        push    cs
                        push    cs
                        pop     ds
                        pop     es

                        mov     ax,fs:[4]
                        mov     w cs:@face2+5,ax
                        add     ax,2
                        mov     w cs:@face1+5,ax
                        add     ax,2
                        mov     w cs:@face3+5,ax

                        mov     ax,fs:[14]
                        mov     w cs:@scr1+5,ax
                        mov     w cs:@scr3+5,ax
                        mov     w cs:@scr5+5,ax
                        add     ax,2
                        mov     w cs:@scr2+5,ax
                        mov     w cs:@scr4+5,ax
                        mov     w cs:@scr6+5,ax

                        mov     ax,fs:[8]
                        add     ax,4
                        mov     w cs:@ptsR1+5,ax
                        mov     w cs:@ptsR2+5,ax
                        mov     w cs:@ptsR3+5,ax
                        ; et enfin THE code:

                        xor     ebp,ebp
                        mov     esi,ebp
            mainboucle: push    bp

             @face1:    mov     si,fs:[8*ebp+2+01234h]   ; Faces
              @scr1:    mov     ax,fs:[4*esi+01234h]
              @scr2:    mov     bx,fs:[4*esi+01234h+2]   ; Ecran
                        neg     ax
                        neg     bx
                        mov     cx,ax
                        mov     di,bx
              @ptsR1:   mov     dx,fs:[8*esi+4+01234h]   ; PtsR

             @face2:    mov     si,fs:[8*ebp+01234h]
              @scr3:    add     ax,fs:[4*esi+01234h]
              @scr4:    add     bx,fs:[4*esi+01234h+2]
              @ptsR2:   add     dx,fs:[8*esi+4+01234h]

             @face3:    mov     si,fs:[8*ebp+4+01234h]
              @scr5:    add     cx,fs:[4*esi+01234h]
              @scr6:    add     di,fs:[4*esi+2+01234h]
              @ptsR3:   add     dx,fs:[8*esi+4+01234h]

                        imul    ax,di
                        imul    bx,cx

                        cmp     ax,bx
                        jle     invisible
                        pop     ax
                        push    ax
                        shl     eax,16  ; met le Nø de Masque dans les 16 bits hauts
                        mov     ax,dx
                        add     ax,profondeur
                  patch:mov     es:dwd [1111],eax
                 patch1:mov     ds:[1111],fs
                        add     w cs:patch +3,4
                        add     w cs:patch1+2,4

          invisible:    pop     bp
                        inc     bp
                        cmp     bp,fs:[0]
                        jnz     Mainboucle
                        ret
MAIN3D                  endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Affichage des faces visibles des diff‚rents objets.
AFFICHAGE               proc    near
; Tri des faces...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
                        mov     di,w cs:Patch+3
                        xor     eax,eax
                        mov     dwd [di],eax
                        mov     dwd [di+4],eax
                        sub     di,OFFSET FacesVisibles
                        CALL    QUICKSORT pascal,0,di
; Affichage des faces visibles...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

                        CALL    RINIT

                        xor     si,si
              BclAff:   movzx   ebx,FacesVisibles[si+2]    ; FacesVisibles
                        xor     edi,edi
                        mov     ax,fs
                        cmp     ax,FacesVisiblesObj[si]
                        je      @face21
                        mov     fs,FacesVisiblesObj[si]
                        CALL    RINIT
             @face21:   movzx   edi,w fs:[8*ebx+01234h]    ; Face
             @ecran1:   mov     eax,dwd fs:[4*edi+01234h]  ; Ecran
                        ror     eax,16
                        mov     dwd fy1,eax
        @VctNrmPtsR1:   mov     eax,dwd fs:[8*edi+01234h]
                        mov     dwd VctX1,eax

             @face22:   mov     di,fs:[8*ebx+2+01234h]
             @ecran2:   mov     eax,dwd fs:[4*edi+01234h]
                        ror     eax,16
                        mov     dwd fy2,eax
        @VctNrmPtsR2:   mov     eax,dwd fs:[8*edi+01234h]
                        mov     dwd VctX2,eax

             @face23:   mov     di,fs:[8*ebx+01234h+4]   ; bp=Nø du troisiŠme point
             @ecran3:   mov     eax,dwd fs:[4*edi+01234h]
                        ror     eax,16
                        mov     dwd fy3,eax
        @VctNrmPtsR3:   mov     eax,dwd fs:[8*edi+01234h]
                        mov     dwd VctX3,eax

        Gofilling:      push    si
                        call    FILL_POLY
                        pop     si

        @NextOne:       add     si,4
                        cmp     dwd FacesVisibles[si],0
                        jnz     BclAff
                        cmp     dwd FacesVisibles[si+4],0
                        jnz     BclAff
                        ret
; Finissement de l'affichage des faces visibles.
               rinit:
                        mov     ax,fs:[14]
                        mov     w cs:@ecran1+6,ax
                        mov     w cs:@ecran2+6,ax
                        mov     w cs:@ecran3+6,ax

                        mov     ax,fs:[12]
                        mov     w cs:@VctNrmPtsR1+6,ax
                        mov     w cs:@VctNrmPtsR2+6,ax
                        mov     w cs:@VctNrmPtsR3+6,ax

                        mov     ax,fs:[4]
                        mov     w cs:@face21+7,ax
                        inc     ax
                        inc     ax
                        mov     w cs:@face22+5,ax
                        inc     ax
                        inc     ax
                        mov     w cs:@face23+5,ax
                        ret
AFFICHAGE               endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Pr‚pare une matrice {4,3} de rotation sur 3 axes.

PrepMatrice             proc    near
                        mov     si,fs:[16]  ; Matrice
                        mov     bx,fs:[18]
                        shl     bx,1
                        and     bx,2048-1
                        movsx   ecx,w cos_table[bx]
                        ; cos(à)

                        sub     bh,2
                        and     bx,2048-1
                        movsx   ebp,w cos_table[bx]
                        ; sin(à)

                        mov     bx,fs:[20]
                        shl     bx,1
                        and     bx,2048-1
                        movsx   eax,w cos_table[bx]
                        mov     cosy,eax
                        ; cos(á)

                        sub     bh,2
                        and     bx,2048-1
                        movsx   eax,w cos_table[bx]
                        mov     siny,eax
                        ; sin(á)

                        mov     bx,fs:[22]
                        shl     bx,1
                        and     bx,2048-1
                        movsx   eax,w cos_table[bx]
                        mov     cosz,eax
                        ; cos(â)

                        sub     bh,2
                        and     bx,2048-1
                        movsx   eax,w cos_table[bx]
                        mov     sinz,eax
                        ; sin(â)

; Fin de la pr‚paration des sinus et cosinus.

                        mov     eax,cosz
                        imul    cosy
                        shrd    eax,edx,10
                        mov     fs:[si+0],eax
                        mov     eax,sinz
                        imul    cosy
                        shrd    eax,edx,10
                        neg     eax
                        mov     fs:[si+4],eax
                        mov     eax,siny
                        mov     fs:[si+8],eax
; premiŠre ligne finie.
                        mov     eax,sinz
                        imul    ecx
                        shrd    eax,edx,10
                        mov     ebx,eax
                        mov     eax,ebp
                        imul    cosz
                        shrd    eax,edx,10
                        imul    siny
                        shrd    eax,edx,10
                        add     eax,ebx
                        mov     fs:[si+12],eax

                        mov     eax,cosz
                        imul    ecx
                        shrd    eax,edx,10
                        mov     ebx,eax
                        mov     eax,ebp
                        imul    sinz
                        shrd    eax,edx,10
                        imul    siny
                        shrd    eax,edx,10
                        sub     ebx,eax
                        mov     fs:[si+16],ebx
                        mov     eax,cosy
                        imul    ebp
                        shrd    eax,edx,10
                        neg     eax
                        mov     fs:[si+20],eax
; seconde ligne finie.
                        mov     eax,sinz
                        imul    ebp
                        shrd    eax,edx,10
                        mov     ebx,eax
                        mov     eax,ecx
                        imul    cosz
                        shrd    eax,edx,10
                        imul    siny
                        shrd    eax,edx,10
                        sub     ebx,eax
                        mov     fs:[si+24],ebx
                        mov     eax,cosz
                        imul    ebp
                        shrd    eax,edx,10
                        mov     ebx,eax
                        mov     eax,ecx
                        imul    sinz
                        shrd    eax,edx,10
                        imul    siny
                        shrd    eax,edx,10
                        add     eax,ebx
                        mov     fs:[si+28],eax
                        mov     eax,ecx
                        imul    cosy
                        shrd    eax,edx,10
                        mov     fs:[si+32],eax
; troisiŠme ligne finie.
                        ret
PrepMatrice             endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Fait rotater les coordonn‚es d'un objet … partir d'une matrice de rotation.
; bx=OFFSET Matrice
; si=OFFSET PointSource
; di=OFFSET PointDestination

ROTATE                  proc    near
                  @rot: movsx   eax,w [si]
                        imul    dwd [bx]
                        mov     ebp,eax
                        movsx   eax,w [si+2]
                        imul    dwd [bx+4]
                        add     ebp,eax
                        movsx   eax,w [si+4]
                        imul    dwd [bx+8]
                        add     eax,ebp
                        shr     eax,10
                        mov     [di],ax
                        add     di,2
                        add     bx,4*3
                        dec     cx
                        jnz     @rot
                        ret
ROTATE                  endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Trie le tableau moyen avec l'algorithme QuickSort.

QUICKSORT       proc    pascal bas,haut:word
                mov     bx,bas
                mov     si,bx
                mov     cx,bx
                mov     di,haut
                add     bx,di
                shr     bx,1
                and     bx,not 3
                mov     dx,FacesVisibles[bx]
gauche_pluspres:
                cmp     FacesVisibles[si],dx
                jbe     a_gauche
                add     si,4
                jmp     gauche_pluspres
        a_gauche:
                cmp     FacesVisibles[di],dx
                jae     a_droite
                sub     di,4
                jmp     a_gauche
        a_droite:
                cmp     si,di
                jg      finbou

                mov     eax,dwd FacesVisibles[si]
                xchg    eax,dwd FacesVisibles[di]
                mov     dwd FacesVisibles[si],eax
                mov     ax,w FacesVisiblesObj[si]
                xchg    ax,w FacesVisiblesObj[di]
                mov     w FacesVisiblesObj[si],ax

                add     si,4
                sub     di,4
        finbou:
                cmp     si,di
                jle     gauche_pluspres
                mov     cx,si

                cmp     bas,di
                jge     droite_fini
                call    quicksort pascal,bas,di
        droite_fini:
                mov     si,cx
                cmp     haut,si
                jle     gauche_fini
                call    quicksort pascal,si,haut
        gauche_fini:
                ret
QUICKSORT       endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Transforme les coordonn‚es 3D en coordonn‚es … l'‚cran.

XDZ                     proc    near
                        mov     si,ds:[8]       ; MasquePtsR
                        mov     di,ds:[14]      ; MasqueEcran
                        mov     cx,ds:[2]       ; Nb_Pts
                        mov     bp,fs:profondeur
                bclXDZ: mov     bx,[si+4] ; Z
                        add     bx,bp
                        jnz     bon1
                        inc     bx
                bon1:   mov     eax,[si]   ; X+Y*65536
                        cwd
                        shld    dx,ax,distance
                        shl     ax,distance
                        idiv    bx
                        add     ax,160
                        mov     [di],ax
                        shr     eax,16     ; Y
                        cwd
                        shld    dx,ax,distance
                        shl     ax,distance
                        idiv    bx
                        add     ax,100
                        mov     [di+2],ax
                        add     si,8
                        add     di,4
                        dec     cx
                        jnz     bclXDZ
                        ret
XDZ                     endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; PHONG 2 inst/pxl
FILL_POLY               proc    near
; Tri des points:
                        mov     eax,dwd fY1
                        mov     ebx,dwd fY2
                        mov     ecx,dwd fY3

                        mov     esi,dwd VctX1
                        mov     edi,dwd VctX2
                        mov     ebp,dwd VctX3

                        cmp     ax,bx
                        jle     @1
                        xchg    eax,ebx
                        xchg    esi,edi
                   @1:  cmp     bx,cx
                        jle     @2
                        xchg    ebx,ecx
                        xchg    edi,ebp
                   @2:  cmp     ax,bx
                        jle     @3
                        xchg    eax,ebx
                        xchg    esi,edi
                   @3:
; Elimination des faces totalement invisibles:
                        cmp     ax,199
                        jg      @end_poly
                        or      ch,ch
                        js      @end_poly

                        mov     edx,319*65536
                        cmp     eax,edx
                        jle     @ok
                        cmp     ebx,edx
                        jle     @ok
                        cmp     ecx,edx
                        jle     @ok
                        jmp     @end_poly
                   @ok:
                        mov     dwd fY1,eax
                        mov     dwd fY2,ebx
                        mov     dwd fY3,ecx

                        mov     dwd VctX1,esi
                        mov     dwd VctX2,edi
                        mov     dwd VctX3,ebp

                        mov     Ycourant,ax
                        sub     cx,ax
                        mov     count,cx

                        mov     dx,320
                        mul     dx
                        mov     off_ligne,ax

                        xor     ax,ax
                        mov     Xg,eax
                        mov     Xp,eax
                        mov     ax,si
                        shl     eax,16
                        mov     Xm,eax
                        xor     si,si
                        mov     Ym,esi

; Calcul des incr‚ments des X sur les cot‚s du triangle:
; D'abord sur le grand c“t‚:
                        mov     cx,fy3
                        sub     cx,fy1
                        jnz     @ok1
                        inc     cx
                 @ok1:  movsx   ecx,cx
                        mov     ax,fx3
                        sub     ax,fx1
                        shl     eax,16
                        cdq
                        idiv    ecx
                        mov     dwd cs:inc_Xg +5,eax

; puis sur le petit cot‚ 1:
                        mov     bx,fy2
                        sub     bx,fy1
                        jnz     @ok2
                        inc     bx
                 @ok2:  movsx   ebx,bx
                        mov     ax,fx2
                        sub     ax,fx1
                        shl     eax,16
                        cdq
                        idiv    ebx
                        mov     dwd cs:inc_Xp+5,eax

; pr‚paration du petit cot‚ 2:
                        mov     bx,fy3
                        sub     bx,fy2
                        jnz     @ok3
                        inc     bx
                @ok3:   movsx   ebx,bx
                        mov     ax,fx3
                        sub     ax,fx2
                        shl     eax,16
                        cdq
                        idiv    ebx
                        mov     dwd cs:incA +6,eax

; Calcul des incr‚ments des vecteurs:
                        mov     bx,fy3
                        sub     bx,fy1
                        jnz     @ok4
                        inc     bx
                 @ok4:  movsx   ebx,bx
                        mov     ax,VctX3
                        sub     ax,VctX1
                        shl     eax,16
                        cdq
                        idiv    ebx
                        mov     esi,eax
                        mov     dwd cs:inc_Xm+5,eax

                        mov     ax,VctY3
                        sub     ax,VctY1
                        shl     eax,16
                        cdq
                        idiv    ebx
                        mov     edi,eax
                        mov     dwd cs:inc_Ym+5,eax

                        mov     bp,fy2
                        sub     bp,fy1
                        movsx   ebp,bp
                        ; EBP=(fy2-fy1)

                        mov     sens,0
                        mov     ebx,dwd cs:inc_Xg+5
                        imul    ebx,ebp
                        sar     ebx,16
                        add     bx,fx1
                        mov     cx,fx2
                        sub     cx,bx
                        jns     @5
                        inc     sens
                        neg     cx
                   @5:  jnz     @ok5
                        inc     cx
                 @ok5:  movsx   ecx,cx
                        ; ECX=d(X)

                        mov     largeur,cx
                        add     largeur,2

                        imul    esi,ebp
                        sar     esi,16
                        add     si,VctX1
                        mov     ax,VctX2
                        sub     ax,si
                   @f1: shl     eax,16
                        cdq
                        idiv    ecx
                        mov     ebx,eax
                        ; IncX fini

                        imul    edi,ebp
                        shr     edi,16
                        add     di,VctY1
                        mov     ax,VctY2
                        sub     ax,di
                 @f2:   shl     eax,16
                        cdq
                        idiv    ecx
                        shr     eax,8
                        shl     ebx,8
                        mov     bx,ax
                        mov     increment,ebx
                        ; IncY fini

                        Call    GenCode
                        mov     es,Virtuel
                        xor     edx,edx
                        mov     ebp,edx

; Remplissage du polygone:
                        mov     ax,fy1
                        cmp     ax,fy2
                        jne     @next_line
                        mov     ax,fx2
                        shl     eax,16
                        mov     Xp,eax
                        mov     ax,Ycourant
                        jmp     incA

; Boucle du remplissage...ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
        @next_line:     mov     ax,Ycourant
                        cmp     ax,fy2
                        jne     @fsuite
                  incA: mov     dwd cs:inc_Xp+5,012345678h

                @fsuite:or      ax,ax
                        jl      inc_Xg
                        cmp     ax,199
                        jg      @end_poly

                        cmp     sens,0
                        je      @r
                        Call    Gauche
                        jmp     @over
                  @r:   Call    Droite
              @over:    mov     b cs:fill[8*ebp],0C3h   ; (0C3h=ret)
                        mov     dx,ds
                        mov     ds,SegPhong

                        CALL    FILL

                        mov     ds,dx
                        mov     b cs:fill[8*ebp],08Ah

                inc_Xg: add     Xg,012345678h      ; X grand cot‚
                inc_Xp: add     Xp,012345678h      ; X petit cot‚
                inc_Xm: add     Xm,012345678h      ; VctX grand cot‚
                inc_Ym: add     Ym,012345678h      ; VctY grand cot‚
                        add     off_ligne,320
                        inc     Ycourant
                        cld
                        dec     count
                        jns     @next_line
        @end_poly:      ret

        @end_poly1:     add     sp,2
                        ret

gauche:                 mov     di,w Xg+2
                        mov     bp,w Xp+2
                        sub     bp,di
                        neg     bp
                        js      @end_poly1
                        inc     bp
                        add     di,off_ligne
                        mov     bh,b Ym+2
                        mov     bl,b Xm+2
                        std
                        ret

droite:                 mov     bp,w Xp+2
                        mov     di,w Xg+2
                        sub     bp,di
                        js      @end_poly1
                        inc     bp
                        add     di,off_ligne
                        mov     bh,b Ym+2
                        mov     bl,b Xm+2
                        ret


; Ici est le code autog‚n‚r‚ !
fill:                   REPT    200
                        mov     al,[bx+01234h]
                        mov     es:[di],al
                        inc     di              ; 2 inst/pxl
                        ENDM

; Pr‚paration du code autog‚n‚r‚ pour tout le triangle
gencode:                xor     ecx,ecx
                        mov     ax,cx
                        mov     dl,47h          ; inc di
                        cmp     sens,1
                        jne     @sa
                        mov     dl,04Fh         ; dec di
                   @sa: mov     ebp,increment
                        mov     di,OFFSET fill+2
                        mov     bx,largeur

                @mod:   mov     cs:[di],ax
                        mov     cs:[di+5],dl
                        add     ecx,ebp
                        mov     al,ch
                        shld    eax,ecx,8
                        add     di,8
                        dec     bx
                        jnz     @mod
                        ret
FILL_POLY               endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Pr‚calcule les vecteurs normaux en chaque points et les norme.

CALC_NORM               proc    near
                        push    fs
                        pop     es
                        mov     cx,fs:[2]   ; Nb_Pts
                        shl     cx,1
                        mov     di,fs:[10]  ; VctNrmPts
                        xor     eax,eax
                        rep     stosd
                        push    cs
                        pop     es

                        mov     di,fs:[4]      ; Faces
                        xor     bx,bx
        main1boucle:    push    bx
                        shl     bx,3

                        movzx   ebp,w fs:[6]      ; Pts
                        movzx   esi,w fs:[di+bx]   ; Faces
                        movsx   ecx,w fs:[ebp+8*esi]    ; Pts
                        neg     ecx
                        mov     X1,ecx
                        mov     X2,ecx
                        movsx   ecx,w fs:[ebp+8*esi+2]  ; Pts
                        neg     ecx
                        mov     Y1,ecx
                        mov     Y2,ecx
                        movsx   ecx,w fs:[ebp+8*esi+4]  ; Pts
                        neg     ecx
                        mov     Z1,ecx
                        mov     Z2,ecx

                        mov     si,fs:[di+bx+2]  ; Faces
                        movsx   ecx,w fs:[ebp+8*esi]
                        add     X1,ecx
                        movsx   ecx,w fs:[ebp+8*esi+2]
                        add     Y1,ecx
                        movsx   ecx,w fs:[ebp+8*esi+4]
                        add     Z1,ecx          ; Premier vecteur fini.

                        mov     si,fs:[di+bx+4]   ; Faces
                        movsx   ecx,w fs:[ebp+8*esi]
                        add     X2,ecx
                        movsx   ecx,w fs:[ebp+8*esi+2]
                        add     Y2,ecx
                        movsx   ecx,w fs:[ebp+8*esi+4]
                        add     Z2,ecx          ; Second vecteur fini.

                        ; Les vecteurs de surface sont finis.

                        mov     eax,Y1
                        imul    eax,Z2
                        mov     ecx,Z1
                        imul    ecx,Y2
                        sub     eax,ecx
                        sar     eax,4
                        mov     X,eax     ; Xn fini

                        mov     eax,Z1
                        imul    eax,X2
                        mov     ecx,X1
                        imul    ecx,Z2
                        sub     eax,ecx
                        sar     eax,4
                        mov     Y,eax    ; Yn fini

                        mov     eax,X1
                        imul    eax,Y2
                        mov     ecx,Y1
                        imul    ecx,X2
                        sub     eax,ecx
                        sar     eax,4
                        mov     Z,eax    ; Zn fini

                        mov     eax,X
                        mov     edx,Y
                        mov     ecx,Z

                        movzx   ebp,w fs:[10]
                        mov     popo,3
            @MakeVct:   movzx   esi,w fs:[di+bx]   ; Faces
                        add     fs:[ebp+8*esi],ax     ; VctNrmPts
                        add     fs:[ebp+8*esi+2],dx
                        add     fs:[ebp+8*esi+4],cx
                        add     bx,2
                        dec     popo
                        jnz     @MakeVct

                        pop     bx
                        inc     bx
                        cmp     bx,fs:[0]    ; Nb_Faces
                        jnz     Main1boucle

; Calcule la norme du vecteur normal … chaque point et norme le vecteur.
; La norme de chaque vecteur est de 128.

                        mov     bx,fs:[10]         ; VctNrmPts
                        xor     si,si
            main2bcl:   shl     si,3
                        movsx   ebp,w fs:[bx+si]     ; VctNrmPts
                        movsx   eax,w fs:[bx+si+2]
                        movsx   ecx,w fs:[bx+si+4]
                        imul    ebp,ebp
                        imul    eax,eax
                        imul    ecx,ecx
                        add     ebp,eax
                        add     ebp,ecx
                        push    bx
                        CALL    RACINE
                        pop     bx
                        mov     ebp,eax
                        or      ebp,ebp
                        jnz     po10
                        inc     ebp
                 po10:
                        movsx   eax,w fs:[bx+si]     ; VctNrmPts
                        movsx   edi,w fs:[bx+si+2]
                        movsx   ecx,w fs:[bx+si+4]
                        shl     eax,7
                        cdq
                        idiv    ebp
                        mov     fs:[bx+si],ax
                        mov     eax,edi
                        shl     eax,7
                        cdq
                        idiv    ebp
                        mov     fs:[bx+si+2],ax
                        mov     eax,ecx
                        shl     eax,7
                        cdq
                        idiv    ebp
                        mov     fs:[bx+si+4],ax
                        shr     si,3
                        inc     si
                        cmp     si,fs:[2]       ;Nb_Pts
                        jnz     main2bcl
                        ret
CALC_NORM               endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;Cr‚ation de la mappe du Phong.

Gen_Phong               proc    near
                        mov     es,SegPhong
                        mov     si,-128       ; y
               bclj:    mov     di,-128      ; x
               bcli:    mov     ax,si
                        imul    ax,ax
                        mov     bp,di
                        imul    bp,bp
                        add     bp,ax
                        movzx   ebp,bp
                        CALL    RACINE
                        imul    ebp,eax,19*19
                        CALL    RACINE
                        sub     al,255
                        neg     al
;coul:=255-(û(û((xı+yı)*19ı))
                        cmp     al,220
                        jbe     @col1
                        mov     al,255
                        jmp     @col2
                  @col1:cmp     al,190
                        jbe     @col2
                        mov     al,220
                  @col2:mov     cx,si
                        mov     bh,cl
                        mov     cx,di
                        mov     bl,cl
                        shr     al,2
                        mov     es:[bx],al
                        inc     di
                        cmp     di,127
                        jng     bcli
                        inc     si
                        cmp     si,127
                        jng     bclj
                        push    cs
                        pop     es
                        ret
Gen_Phong               endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; Calcul de la racine carr‚e.
; entr‚e:EBP=carr‚
; sortie:EAX=racine
RACINE                  proc    near
                        mov     cx,7
                        mov     ebx,0FFh
                        EVEN
             @racbcl:   mov     eax,ebp
                        cdq
                        div     ebx
                        add     eax,ebx
                        shr     eax,1
                        mov     ebx,eax
                        dec     cx
                        jnz     @racbcl
                        ret
RACINE                  endp
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

