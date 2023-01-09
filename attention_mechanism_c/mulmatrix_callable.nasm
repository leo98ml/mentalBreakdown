
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
    row      resd     1
    alignb 16
    col	    resd 	  1
    alignb 16
    col2	 resd	  1
    alignb 16
    col_4	 resd	  1
    alignb 16
    col2_4	 resd	  1

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

input		equ		16
msg	db	'BANANA',32,0
nl	db	10,0
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
        
		prints msg            
		prints nl
		mov EAX, [EBP+input]	
		MOV EBX, [EAX]	
		MOV [C], EBX		
		MOV EBX, [EAX+4]	
		MOV [col2], EBX		
		MOV EBX, [EAX+8]	
		MOV [col], EBX		
		MOV EBX, [EAX+12]	
		MOV [row], EBX			
		MOV EBX, [EAX+16]	
		MOV [B], EBX				
		MOV EBX, [EAX+20]	
		MOV [A], EBX


		MOV EBX, col*4
        MOV [col_4],EBX
		MOV EBX, col2*4
        MOV [col2_4],EBX
        
        mov eax,0			;i=0
fori:	mov	ebx,0			;j=0
forj:	imul edi, eax, col_4;
	    xorps xmm3,xmm3
	    mov ecx,0			;k=0
fork:	imul esi,eax,col2_4		;
        movaps xmm2,[A+edi+ecx*4]
        shufps xmm2,xmm2,0h
        movaps xmm1,[B+esi+ebx*4]
        mulps  xmm1,xmm2
        addps xmm4,xmm1
        
        movaps xmm2,[A+edi+ecx*4]
        shufps xmm2,xmm2,55h
        movaps xmm1,[B+esi+ebx*4]
        mulps  xmm1,xmm2
        addps xmm5,xmm1
        
        movaps xmm2,[A+edi+ecx*4]
        shufps xmm2,xmm2,39h	;
        shufps xmm2,xmm2,55h	;
        movaps xmm1,[B+esi+ebx*4]
        mulps  xmm1,xmm2
        addps xmm6,xmm1
        
        movaps xmm2,[A+edi+ecx*4]
        shufps xmm2,xmm2,93h	;
        shufps xmm2,xmm2,00h	;
        movaps xmm1,[B+esi+ebx*4]
        mulps  xmm1,xmm2
        addps xmm7,xmm1

        add ecx,4			;
        cmp ecx,col			;
        jb fork			;

        addps xmm3,xmm4
        addps xmm3,xmm5
        addps xmm3,xmm6
        addps xmm3,xmm7

        xorps xmm4,xmm4
        xorps xmm5,xmm5
        xorps xmm6,xmm6
        xorps xmm7,xmm7
        movaps [C+esi+ebx*4],xmm3

        add ebx,4			;
        cmp ebx,col2			;
        jb forj			;

        add eax,1			;
        cmp eax,row			;
        jb fori			;
        mov eax,row
        shr eax,2
        imul edi,eax,col2;
        ;printps C,edi
        mov EAX,C;
		; ------------------------------------------------------------
		; Sequenza di uscita dalla funzione
		; ------------------------------------------------------------

		pop	edi		; ripristina i registri da preservare
		pop	esi
		pop	ebx
		mov	esp, ebp	; ripristina lo Stack Pointer
		pop	ebp		; ripristina il Base Pointer
		ret			; torna alla funzione C chiamante
