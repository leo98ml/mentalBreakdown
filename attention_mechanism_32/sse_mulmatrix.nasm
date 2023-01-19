
%include "sseutils32.nasm"

section .data			; Sezione contenente dati inizializzati

section .bss			; Sezione contenente dati non inizializzati
    alignb 32
    A:        resd    1
    alignb 32
    B:        resd    1
    alignb 32
    C:        resd    1
    alignb 32
    row:      resd    1
    alignb 32
    col:	  resd 	  1
    alignb 32
    col2:	  resd	  1
    alignb 32
    col_4:	  resd 	  1
    alignb 32
    col2_4:	  resd	  1
    alignb 32

section .text			; Sezione contenente il codice macchina

extern get_block
extern free_block

%macro	getmem	2
	mov	eax, %1
	push	eax
	mov	eax, %2
	push	eax
	call	get_block
	add	esp, 8
%endmacro

%macro	fremem	1
	push	%1
	call	free_block
	add	esp, 4
%endmacro

; ------------------------------------------------------------
; Funzioni
; ------------------------------------------------------------

global mul_matrix

input		equ		8
mul_matrix:
		; ------------------------------------------------------------
		; Sequenza di ingresso nella funzione
		; ------------------------------------------------------------
		push		ebp		; salva il Base Pointer
		mov		ebp, esp	; il Base Pointer punta al Record di Attivazione corrente
		push		ebx		; salva i registri da preservare
		push		esi
		push		edi
		; ------------------------------------------------------------
		; legge i parametri dal Record di Attivazione corrente
		; ------------------------------------------------------------
        xor eax, eax
        add eax, input
        add eax,EBP
		MOV EBX, [EAX]	
		MOV [A], EBX		
		MOV EBX, [EAX+4]	
		MOV [B], EBX		
		MOV EBX, [EAX+8]	
		MOV [row], EBX		
		MOV EBX, [EAX+12]	
		MOV [col], EBX			
		MOV EBX, [EAX+16]	
		MOV [col2], EBX				
		MOV EBX, [EAX+20]	
		MOV [C], EBX
        mov eax,[col]
        shl eax,2
        mov [col_4],eax
        mov eax,[col2]
        shl eax,2
        mov [col2_4],eax; setting parameters into variables
        mov eax,0			;i=0
fori:	mov	ebx,0			;j=0
        mov edx,eax
        imul edx,[col2_4]
        add edx, [C]        ; edx points to the row_i of C at this point
forj:	mov edi, eax         
        imul edi,[col_4]    
	    xorps xmm4,xmm4    ; clean registers
	    mov ecx,0			;k=0
fork:	mov esi, ecx
        imul esi,[col2_4]   ; esi points to the row_i of B at this point
        add edi,[A]         ; edi points to the row_i of A at this point
        movaps xmm2,[edi+ecx*4] ;moves four elements of row i of A in xmm2
        shufps xmm2,xmm2,0h ; now all of xmm2 cells contains the same value, the first one;
        add esi,[B]         
        movaps xmm1,[esi+ebx*4] ;moves four elements of row k of B in xmm1
        mulps  xmm1,xmm2    ; mul those four elements with the ones in xmm1
        addps xmm4,xmm1     ; partial sum in xmm4
        movaps xmm2,[edi+ecx*4]
        shufps xmm2,xmm2,55h; the same thing as before but with seconf element;
        add esi,[col_4]
        movaps xmm1,[esi+ebx*4]
        mulps  xmm1,xmm2    ; go on the next row in B
        addps xmm4,xmm1     ; partial sum
        movaps xmm2,[edi+ecx*4] 
        shufps xmm2,xmm2,39h	
        shufps xmm2,xmm2,55h; third element
        add esi,[col_4]     
        movaps xmm1,[esi+ebx*4]; next row on B
        mulps  xmm1,xmm2
        addps xmm4,xmm1
        movaps xmm2,[edi+ecx*4]; fourth element
        sub edi,[A]
        shufps xmm2,xmm2,93h	
        shufps xmm2,xmm2,00h	
        add esi,[col_4]
        movaps xmm1,[esi+ebx*4]; next row on B
        sub esi,[col_4]
        sub esi,[col_4]
        sub esi,[col_4]
        sub esi,[B]
        mulps  xmm1,xmm2
        addps xmm4,xmm1
        add ecx,4			
        cmp ecx,[col]			
        jb fork	
        movaps [edx+ebx*4],xmm4; writing in C the result
        add ebx,4		
        cmp ebx,[col2]	
        jb forj			
        add eax,1			
        cmp eax,[row]			
        jb fori	
        mov EAX,[C];
		; ------------------------------------------------------------
		; Sequenza di uscita dalla funzione
		; ------------------------------------------------------------
		pop	edi		; ripristina i registri da preservare
		pop	esi
		pop	ebx
		mov	esp, ebp	; ripristina lo Stack Pointer
		pop	ebp		; ripristina il Base Pointer
		ret			; torna alla funzione C chiamante
