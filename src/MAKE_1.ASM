;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;                     Cr‚ation d'objet par r‚volution.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; This is a very useful routine to make 3D objects in a very little 4Kb.

Nb_Pts   equ w gs:[0]
Nb_Etape equ gs:[2]

MakeObj         proc    near
                ; ATTENTION 'GS' doit pointer sur le segment du plan.
                mov     eax,1024*65536
                cdq
                idiv    dwd Nb_etape
                mov     Incr,eax         ; Increment de rotation
                
                ; mise des parametres dans le seg de donn‚es.
                movzx   eax,Nb_Pts
                cdq
                imul    w Nb_etape
                mov     totpts,ax       ; Nb de pts
                lea     dx,[eax*2]     
                mov     totface,dx      ; Nb de face
                imul    ax,36
                lea     dx,[edx*8+eax+10]
                shr     dx,4
                add     dx,10
                
                NEWP    SegLofter,dx
                
                mov     fs,SegLofter
                mov     ax,totpts
                mov     w fs:[2],ax      ; Nb_Pts
                mov     ax,totface
                mov     w fs:[0],ax      ; Nb_Faces                

                mov     di,30
                mov     fs:[6],di        ; OFFSET Pts

; Cr‚ation de tous les points de mon objet par rotation autour de Oy.
                mov     angle,0
                mov     cx,w Nb_Etape
    @MakePts:   push    cx
                
                movzx   ebx,w angle+2
                and     bx,1024-1
                movsx   eax,w cos_table[2*ebx]
                mov     cos,eax
                ; cos(à)
                dec     bh
                and     bx,1024-1
                movsx   eax,w cos_table[2*ebx]
                mov     sin,eax
                ; sin(à)

                mov     si,2+4
                mov     cx,Nb_Pts
  @MakePts1:    movsx   ebx,w gs:[si]
                mov     eax,ebx
                imul    eax,cos
                sar     eax,10
                mov     fs:[di],ax
                mov     ax,w gs:[si+2]
                mov     fs:[di+2],ax
                mov     eax,ebx
                imul    eax,sin
                sar     eax,10
                mov     fs:[di+4],ax
                mov     w fs:[di+6],0
                add     di,8
                add     si,4
                dec     cx
                jnz     @makePts1

                mov     eax,Incr
                add     angle,eax
                pop     cx
                dec     cx
                jnz     @makePts

; Cr‚ation des faces de l'objet.
                mov     fs:[4],di               ; OFFSET Face
                
                mov     bp,w Nb_Etape
                dec     bp
                imul    bp,Nb_Pts
                add     bp,Nb_Pts
                
                xor     eax,eax
                mov     ebx,eax
                mov     esi,eax
                
                mov     cx,Nb_Etape
     @mface3:   push    cx
                xor     edx,edx
                mov     cx,w Nb_Pts
     @mface4:   push    cx
                mov     fs:[di],bx
                mov     ax,bx
                add     ax,Nb_Pts
                cmp     ax,bp
                jb      @ok_make_faces
                mov     ax,dx
@ok_make_faces: mov     fs:[di+2],ax
                inc     ax
                inc     dx
                cmp     dx,Nb_Pts
                jne     @ok_make_faces3
                sub     ax,Nb_Pts
@ok_make_faces3:dec     dx
                mov     fs:[di+4],ax
                mov     w fs:[di+6],0
                add     di,8
                
                mov     fs:[di],bx
                mov     fs:[di+2],ax
                lea     ax,[ebx+1]
                inc     dx     
                cmp     dx,Nb_Pts
                jne     @ok_make_faces2
                sub     ax,Nb_Pts
@ok_make_faces2:dec     dx
                mov     fs:[di+4],ax
                mov     w fs:[di+6],0
                add     di,8
                
                inc     dx
                inc     bx
                pop     cx
                dec     cx
                jnz     @mface4
                
                add     si,Nb_Pts
                pop     cx
                dec     cx
                jnz     @mface3

; Initialisation des offsets dans le segment:
                mov     ax,di
                add     ax,10
                mov     w fs:[8],di             ;PtsR
                mov     bx,TotPts
                shl     bx,3
                add     bx,10
                add     ax,bx
                mov     w fs:[10],ax            ;VctNrmPts
                add     ax,bx
                mov     w fs:[12],ax            ;VctNrmPtsR
                add     ax,bx
                mov     w fs:[14],ax            ;Ecran
                mov     bx,totpts
                shl     bx,2
                add     bx,10
                add     ax,bx
                mov     w fs:[16],ax            ;Matrice
                ret
MakeObj         endp

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

