;
; Gestion de l'affichage de nombre d‚cimaux et hexad‚cimaux.
;
; affiche le nombre contenu dans EAX:
Aff_decimal     proc
		push    eax
		mov     dh,0    ; ligne
		mov     dl,0    ; colonne
		mov     ah,2
		mov     bh,0
		int     10h
		pop     eax
		; Positionnement curseur.
		mov     ebx,10
		xor     cx,cx
decompose:      xor     edx,edx
		div     ebx
		push    dx
		inc     cx
		or      eax,eax
		jnz     decompose

affichage_nombre:
		pop     dx
		add     dl,48
		mov     ah,2
		int     21h
		dec     cx
		jnz     affichage_nombre
		ret
Aff_decimal     endp
;
; Affiche un nombre hexad‚cimal contenu dans EAX:
aff_hexa        proc
		push    eax
		mov     dh,1    ; ligne
		mov     dl,0    ; colonne
		mov     ah,2
		mov     bh,0
		int     10h
		pop     ebx
		; Positionnement curseur.

		mov     cx,32/4
@affiche_nombre_hexa:
		xor     eax,eax
		shld    eax,ebx,4
		shl     ebx,4
		mov     dl,chaine_hexa[eax]
		mov     ah,2
		int     21h
		dec     cx
		jnz     @affiche_nombre_hexa
		ret
chaine_hexa     db '0123456789ABCDEF'
aff_hexa        endp
;
