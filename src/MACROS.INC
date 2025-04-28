;  /\
; /ю°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°ю\
; |°°°°°°°°°°°°°°°°°°°°°ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД°°°°°°°°°°°°°°°°°°°°°|
; |°°°°°°°°°°°°°°°°°°°°°         COM stories...        °°°°°°°°°°° (c) 94 °°|
; |°°°°°°°°°°°°°°°°°°°°°ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД°°°°°°°°°°° BART­! °°|
; \ю°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°ю/
;  \/
;
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

b       equ byte ptr
w       equ word ptr
dwd     equ dword ptr


DOS_                    MACRO code
			mov    AX,4ch*256+code
			int    21h
			ENDM

;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
WRITE                   MACRO  chaine
			mov    AH,09h
			mov    DX,offset chaine
			int    21h
			ENDM
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
VGA                     MACRO     lekel
			mov       ax,lekel
			int       10h
			ENDM

;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

WAIT_VBL                MACRO
			LOCAL     @@l1,@@l2
			mov       dx,3DAh
@@l1:
			in        al,dx
			and       al,08h
			jz        @@l1
@@l2:
			in        al,dx
			and       al,08h
			jnz       @@l2
			ENDM

;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
NEWP                    MACRO  Segment,Taille   ; Alloue un bloc de
			local  @@OkMemory       ; m‚moire de taille = …
			mov    AH,48h           ; 16*Taille
			mov    BX,Taille
			int    21h              ; Taille : Word
			jnc    @@OkMemory       ; Retour : Segment=AX
			DOS_   255
@@OkMemory:             mov    Segment,AX
			ENDM
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
DISPOS                  MACRO  Segment          ; Desalloue un bloc
			mov    AH,49h           ; Segment est le segment
			mov    ES,Segment       ; du bloc
			int    21h
			ENDM
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
INIT_                   MACRO  Fincode,Pile
			mov    AH,4Ah
			mov    BX,Offset Fincode
			shr    BX,4
			inc    BX
			int    21h
			mov    SP,Offset Pile+100
			ENDM
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
;-----------------------------------------------------------------------------
;    /\
;   /                                                                    \
;   |         Gestionnaire de fichier...  ( by Barti & Max )             |
;   \                                                                    /
;    \/
;
;-----------------------------------------------------------------------------
;   ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Assign        MACRO     File,Attr,Handle      ; Attr = _ 0 : Lecture
	      Local     @@OKAY                ;        _ 1 : Ecriture
	      mov       AH,3Dh                ;        _ 2 : Les deux
	      mov       AL,Attr               ;
	      mov       DX,offset File        ;
	      int       21h                   ; File = db 'Nom du fichier',0
	      jnc       @@OKAY                ;
	      dos_      255                   ; Retour : Handle
@@OKAY:       mov       Handle,AX             ;
	      ENDM                            ; Si erreur on quitte !

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; Charge vers DS:DX
BlockRead     MACRO     Handle,Bytes          ; <=> … :
	      push      DS                    ;
	      push      AX                    ;  BLOCKREAD(
	      mov       AH,3Fh                ;  Handle,MEM[AX:DX],Bytes
	      mov       BX,Handle             ;  );
	      mov       CX,Bytes              ;
	      pop       DS                    ;  PS: Pas de test d'erreur!
	      int       21h
	      pop       DS
	      endm

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Close         MACRO      Handle
	      mov        ah,3Eh
	      mov        bx,handle
	      int        21h
	      endm

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Seek          MACRO      code,distanceH,distanceL,handle
	      mov        ah,42h
	      mov        al,code
	      mov        bx,handle
	      mov        cx,distanceH     ; mot fort   du d‚placement
	      mov        dx,distanceL     ;  "  faible  "   "  "   "
	      int        21h
	      endm

; Code : 0 :debut
;        1 :relatif
;        2 :fin

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

; attend la frappe d'une touche
Key?          MACRO
	      mov ah,1
	      int 21h
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

pset          MACRO   X,Y,coul
	      push 0A000h
	      pop es
	      mov ax,Y
	      mov bx,X
	      mov cl,coul
	      xchg ah,al
	      add bx,ax
	      shr ax,2
	      add bx,ax
	      mov es:[bx],cl
	      endm
;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

RasterBleu    MACRO              ; Macro ki "allume" le raster
	      mov       dx,3c8h
	      xor       al,al
	      out       dx,al
	      inc       dx
	      out       dx,al
	      out       dx,al
	      mov       al,32
	      out       dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

RasterRouge   MACRO           ; Macro ki "allume" le raster
	      mov       dx,3c8h
	      xor       al,al
	      out       dx,al
	      inc       dx
	      mov       al,32
	      out       dx,al
	      xor       al,al
	      out       dx,al
	      out       dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
RasterVert    MACRO     coul                   ; Macro ki "allume" le raster
	      mov       dx,3c8h
	      xor       al,al
	      out       dx,al
	      inc       dx
	      out       dx,al
	      mov       al,32
	      out       dx,al
	      xor       al,al
	      out       dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
Raster_Start  MACRO     coul                   ; Macro ki "allume" le raster
	      mov       dx,3c8h
	      xor       al,al
	      out       dx,al
	      inc       dx
	      xor       al,al
	      out       dx,al
	      out       dx,al
	      mov       al,coul
	      out       dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Raster_end    MACRO                          ; Macro ki "eteint" le raster
	      mov     dx,3c8h
	      xor     al,al
	      out     dx,al

	      inc     dx
	      out     dx,al
	      out     dx,al
	      out     dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Tempo           MACRO   delai
		LOCAL   time
		mov     ecx,delai
       time:    nop
		dec     ecx
		jnz     time
		ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Hard          MACRO     wd                 ; Scrolling !
	      push      dx
	      mov       dx,3d4h
	      mov       bx,wd
	      mov       ah,bh
	      mov       al,12
	      out       dx,ax
	      mov       ah,bl
	      mov       al,13
	      out       dx,ax
	      pop       dx
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

Palette16     MACRO                           ; palette
	      mov     dx,3c8h                ; ds:si pointe vers le taleau
	      xor     al,al                  ; de couleurs DAC db 768 dup(0)
	      out     dx,al
	      inc     dx
	      mov     cx,32*3
	      rep     outsb
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

PaletteS      MACRO                           ; palette
	      mov     dx,3c8h                ; ds:si pointe vers le tableau
	      xor     al,al                  ; de couleurs DAC db 768 dup(0)
	      out     dx,al
	      inc     dx
	      mov     cx,768
	      rep     outsb
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

SETCOLOR      MACRO   Number, R,G,B
	      mov       dx,3c8h
	      mov       ax,number
	      out       dx,al
	      inc       dl
	      mov       al,R
	      out       dx,al
	      mov       al,G
	      out       dx,al
	      mov       al,B
	      out       dx,al
	      ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД
; passage en mode X
InitX           MACRO
		mov       dx,3c4h          ; Mode X 320x200 (TWEAKED)
		mov       ax,0604h         ; Pas de Palette … zero
		out       dx,ax            ; M‚moire vid‚o … zero aussi
		mov       dl,0d4h
		mov       ax,0014h
		out       dx,ax
		mov       ax,0e317h
		out       dx,ax
		mov       ax,0a000h
		mov       es,ax
		xor       si,si
		mov       cx,32768
		mov       ax,0
		rep       stosw
		ENDM

;ДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДДД

