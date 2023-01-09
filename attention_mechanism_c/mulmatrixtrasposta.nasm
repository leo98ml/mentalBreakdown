%include "sseutils32.nasm"

 

section .data            ; Sezione contenente dati inizializzati

 

row      equ          4
col	 equ 	      4
col2	 equ	     4
d 	 dd		0.5
; 
; Le matrici si assumono memorizzate per colonne
;

 

align 16
inizio:        dd        1.0, 1.0, 1.0, 1.0

align 16
inizio1:        dd        1.0, 2.0, 3.0, 4.0

 

section .bss            ; Sezione contenente dati non inizializzati

 

alignb 16
A:        resd    row*col
alignb 16
B:        resd    col*row
alignb 16
C:        resd    row*col2


 

section .text            ; Sezione contenente il codice macchina

 

global    main

 

main:    start

 

        ; ----------------------------------------
        ; carica le matrici A e B e azzera la matrice C
        ;
        movaps        xmm0, [inizio]
        xorps        xmm2,xmm2 
        mov        ebx, 0
        mov        ecx, row*col/4
ciclo1: movaps        [A+ebx], xmm0
        add        ebx, 16
        dec        ecx
        jnz        ciclo1
        
      	movaps      xmm3,[inizio1]
        mov        ebx, 0
        mov        ecx, col*row/4
ciclo2: movaps        [B+ebx], xmm3
        add        ebx, 16
        dec        ecx
        jnz        ciclo2
        
         
        mov        ebx, 0
        mov        ecx, row*col2/4
ciclo3:  movaps        [C+ebx], xmm2
        add        ebx, 16
        dec        ecx
        jnz        ciclo3
  
        
        mov 	eax,0			;i=0
fori:	mov	ebx,0			;j=0
forj:	imul edi, eax, col*4		;
	xorps xmm3,xmm3
	
	mov ecx,0			;k=0
fork:	imul esi,eax,col2*4		;
 	
	movaps xmm2,[A+edi+ecx*4]
	movaps xmm1,[B+esi+ebx*4]
	mulps  xmm1,xmm2
	haddps xmm1,xmm1
	haddps xmm1,xmm1
	addps xmm4,xmm1
	
	
	movaps xmm2,[A+edi+ecx*4+32]
	movaps xmm1,[B+esi+ebx*4+32]
	mulps  xmm1,xmm2
	haddps xmm1,xmm1
	haddps xmm1,xmm1
	addps xmm5,xmm1
	
	
	
	movaps xmm2,[A+edi+ecx*4+64]
	movaps xmm1,[B+esi+ebx*4+64]
	mulps  xmm1,xmm2
	haddps xmm1,xmm1
	haddps xmm1,xmm1
	addps xmm6,xmm1
	
	movaps xmm2,[A+edi+ecx*4+96]
	movaps xmm1,[B+esi+ebx*4+96]
	mulps  xmm1,xmm2
	haddps xmm1,xmm1
	haddps xmm1,xmm1
	addps xmm7,xmm1
	
        add ecx,4			;
        cmp ecx,col			;
        jb fork			;
        
         movss xmm3,[d]
         shufps xmm3,xmm3,0h
         mulps xmm4,xmm3
         movaps [C+esi+ebx*4],xmm4
         mulps xmm5,xmm3
         movaps [C+esi+ebx*4+32],xmm5
         mulps xmm6,xmm3
         movaps [C+esi+ebx*4+64],xmm6
         mulps xmm7,xmm3
         movaps [C+esi+ebx*4+96],xmm7
         
         xorps xmm4,xmm4
         xorps xmm5,xmm5
         xorps xmm6,xmm6
         xorps xmm7,xmm7
        
        add ebx,4			;
        cmp ebx,col2			;
        jb forj			;
        
         
        
        add eax,1			;
        cmp eax,row			;
        jb fori			;
        
        
        
       
       printps C,row*col2/4	;
        
        stop
       
    
