%include "sseutils32.nasm"

section .data		

	align 16
	inizio:	dd		0.0, 0.0, 0.0, 0.0
	
	align 16
	inizio1:	dd		1.0, 2.0, 3.0, 4.0	
	
	
	c equ 16
	r equ 16
	cost equ 16
	u equ 4
	
section .bss

	alignb 16
	M resd r*c
	
	alignb 16
	V resd c
	
	alignb 16
	D resd r*c
	
	
	

	
section .text

	global main
	main:
		start
		
		; carica la matrice A e il vettore V e azzera la matrice D
		;
		movaps		xmm0, [inizio]	;
		xorps		xmm2, xmm2	;
		mov		ebx, 0		;
		mov		ecx, r*c/4	;
		
ciclo:		movaps		[M+ebx], xmm0	;
		movaps		[D+ebx], xmm2	;
		add		ebx, 16	;
		dec		ecx		;
		jnz		ciclo		;
		
		movaps		xmm1, [inizio1]	;
		mov		ebx,0		;
		mov		ecx, c/4	;
ciclo1:	movaps		[V+ebx], xmm1	;
		add		ebx, 16	;
		dec		ecx		;
		jnz		ciclo1		;

		
		
	
		
		mov		eax, 0			; i = 0
fori:		mov		ebx, 0			; j = 0
forj:		imul		edi,eax,c*u ;
		imul 		esi,ebx,u;
		
			
				
		movaps		xmm0,[M+esi+edi]      ;
		movaps		xmm1,[M+esi+edi+16]   ;
		movaps		xmm2,[M+esi+edi+32]   ;
		movaps		xmm3,[M+esi+edi+48];
		
		addps		xmm0, [V+esi]		;		
		addps		xmm1, [V+esi+16]		;
		addps		xmm2, [V+esi+32]		;
		addps		xmm3, [V+esi+48]		;
		
		movaps		[D+esi+edi], xmm0	;
		movaps		[D+esi+edi+16], xmm1	;
		movaps		[D+esi+edi+32], xmm2	;
		movaps		[D+esi+edi+48], xmm3	;
				
		
		add		ebx,cost			;
		cmp 		ebx,c			;
		jl		forj			;
		add		eax,1			;
		cmp		eax,r		;
		jl		fori			;
		printps		D,r*c/4;			;
		stop
