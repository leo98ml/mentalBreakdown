
%include "sseutils32.nasm"

section .data			; Sezione contenente dati inizializzati

section .bss			; Sezione contenente dati non inizializzati
    alignb 16
    A:        resd    1
    alignb 16
    B:        resd    1
    alignb 16
    C:        resd    1
    alignb 16
    row:      resd     1
    alignb 16
    col:	    resd 	  1
    alignb 16
    col2:	 resd	  1
    alignb 16
    col_4:	    resd 	  1
    alignb 16
    col2_4:	 resd	  1
    alignb 16

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
        mov [col2_4],eax
        mov eax,0			;i=0
fori:	mov	ebx,0			;j=0
forj:	mov edi, eax
        imul edi,[col_4]
	    xorps xmm3,xmm3
	    mov ecx,0			;k
fork:	mov esi, ecx
        imul esi,[col2_4]
        add edi,[A]
        movaps xmm2,[edi+ecx*4]
        sub edi,[A]
        shufps xmm2,xmm2,0h
        add esi,[B]
        movaps xmm1,[esi+ebx*4]
        sub esi,[B]
        mulps  xmm1,xmm2
        addps xmm4,xmm1
        add edi,[A]
        movaps xmm2,[edi+ecx*4]
        sub edi,[A]
        shufps xmm2,xmm2,55h
        add esi,[B]
        add esi,[col_4]
        movaps xmm1,[esi+ebx*4]
        sub esi,[col_4]
        sub esi,[B]
        mulps  xmm1,xmm2
        addps xmm5,xmm1
        add edi, [A]
        movaps xmm2,[edi+ecx*4]
        sub edi, [A]
        shufps xmm2,xmm2,39h	
        shufps xmm2,xmm2,55h	
        add esi,[B]
        add esi,[col_4]
        add esi,[col_4]
        movaps xmm1,[esi+ebx*4]
        sub esi,[col_4]
        sub esi,[col_4]
        sub esi,[B]
        mulps  xmm1,xmm2
        addps xmm6,xmm1
        add edi,[A]
        movaps xmm2,[edi+ecx*4]
        sub edi,[A]
        shufps xmm2,xmm2,93h	
        shufps xmm2,xmm2,00h	
        add esi,[B]
        add esi,[col_4]
        add esi,[col_4]
        add esi,[col_4]
        movaps xmm1,[esi+ebx*4]
        sub esi,[col_4]
        sub esi,[col_4]
        sub esi,[col_4]
        sub esi,[B]
        mulps  xmm1,xmm2
        addps xmm7,xmm1
        add ecx,4			
        cmp ecx,[col]			
        jb fork			
        addps xmm3,xmm4
        addps xmm3,xmm5
        addps xmm3,xmm6
        addps xmm3,xmm7
        xorps xmm4,xmm4
        xorps xmm5,xmm5
        xorps xmm6,xmm6
        xorps xmm7,xmm7
        mov edx,eax
        imul edx,[col2_4]
        add edx, [C]
        movaps [edx+ebx*4],xmm3
        sub edx, [C]
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
