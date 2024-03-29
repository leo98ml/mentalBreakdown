
%include "sseutils32.nasm"

section .data			; Sezione contenente dati inizializzati
	u equ 4
	cost equ 4

section .bss			; Sezione contenente dati non inizializzati
    alignb 32
    M:        resd    1
    alignb 32
    V:        resd    1
    alignb 32
    c:        resd    1
    alignb 32
    r:      resd     1
    alignb 32
    D:      resd     1

section .text			; Sezione contenente il codice macchina

global sum_matrix_vector

input		equ		8

sum_matrix_vector:
		
		push		ebp		; salva il Base Pointer
		mov		ebp, esp	; il Base Pointer punta al Record di Attivazione corrente
		push		ebx		; salva i registri da preservare
		push		esi
		push		edi
		
		xor eax, eax
        add eax, input
        add eax,EBP
		MOV EBX, [EAX]	
		MOV [M], EBX		
		MOV EBX, [EAX+4]	
		MOV [V], EBX		
		MOV EBX, [EAX+8]	
		MOV [r], EBX		
		MOV EBX, [EAX+12]	
		MOV [c], EBX			
		MOV EBX, [EAX+16]	
		MOV [D], EBX			

        mov		eax, 0			; i = 0
fori:	mov		ebx, 0			; j = 0
forj:   mov         edi, [c];
        imul        edi, u     
        imul		edi, eax
		mov         esi, u;
        imul 		esi, ebx
        add         esi, [M]
		movaps		xmm0,[esi+edi]      ;
		mov			edx, [c]
		imul        edx, 4
		add			esi,edx
		movaps		xmm1,[esi+edi]   ;
		sub			esi,edx
		mov			edx, [c]
		imul        edx, 8
		add			esi,edx
		movaps		xmm2,[esi+edi]   ;
		sub			esi,edx
		mov			edx, [c]
		imul        edx, 12
		add			esi,edx
		movaps		xmm3,[esi+edi]   ;
		sub			esi,edx
        sub         esi, [M]
        add         esi, [V]
		movaps		xmm5,[esi]
		addps		xmm0,xmm5		    ;
		addps		xmm1,xmm5		;
		addps		xmm2,xmm5		;
		addps		xmm3,xmm5		;
        sub         esi, [V]
        add         esi, [D]
		movaps		[esi+edi], xmm0	;
		mov			edx, [c]
		imul        edx, 4
		add			esi,edx		
		movaps		[esi+edi], xmm1	;
		sub			esi,edx
		mov			edx, [c]
		imul        edx, 8
		add			esi,edx
		movaps		[esi+edi], xmm2	;
		sub			esi,edx
		mov			edx, [c]
		imul        edx, 12
		add			esi,edx
		movaps		[esi+edi], xmm3	;
		sub			esi,edx
        sub         esi, [D]
		add		    ebx, cost			;
		cmp 		ebx, [c]			;
		jb		    forj			;
		add	    	eax, 4		;
		cmp		    eax, [r]		;
		jb		    fori			;
		
		pop	edi		; ripristina i registri da preservare
		pop	esi
		pop	ebx
		mov	esp, ebp; ripristina lo Stack Pointer
		pop	ebp		; ripristina il Base Pointer
		ret			; torna alla funzione C chiamante


