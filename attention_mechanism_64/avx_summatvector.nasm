%include "sseutils64.nasm"

section .data			; Sezione contenente dati inizializzati
	u equ 8
section .bss			; Sezione contenente dati non inizializzati
    alignb 64
    M:        resq    1
    alignb 64
    V:        resq    1
    alignb 64
    r:        resq    1
    alignb 64
    c:      resq     1
    alignb 64
    D:      resq     1

section .text			; Sezione contenente il codice macchina

extern get_block
extern free_block

%macro	getmem	2
	mov	rdi, %1
	mov	rsi, %2
	call	get_block
%endmacro

%macro	fremem	1
	mov	rdi, %1
	call	free_block
%endmacro

; ------------------------------------------------------------
; Funzione 
; ------------------------------------------------------------
global sum_matrix_vector

input		equ		16

sum_matrix_vector:
        push		rbp				; salva il Base Pointer
		mov		rbp, rsp			; il Base Pointer punta al Record di Attivazione corrente
		pushaq						; salva i registri generali
        		
		MOV [M], RDI		
		MOV [V], RSI		
		MOV [r], RDX		
		MOV [c], RCX	
		MOV [D], R8 	
        
		mov		rax, 0			; i = 0
fori:	mov		r10, 0			; j = 0
forj:	mov         rdi,[c]
        imul        rdi,u
        imul		rdi,rax;
		imul 		rsi,r10,u;
        add         rsi,[M]
		vmovapd		ymm0,[rsi+rdi] 
        mov         r11,[c]
        imul        r11,8
        add         r11,rsi     ;
		vmovapd		ymm1,[r11+rdi] 
        mov         r11,[c]
        imul        r11,16
        add         r11,rsi  ;
		vmovapd		ymm2,[r11+rdi]  
        mov         r11,[c]
        imul        r11,24
        add         r11,rsi ;
		vmovapd		ymm3,[r11+rdi];
        sub         rsi,[M]
        add         rsi,[V]
        vmovapd     ymm5, [rsi]	
		vaddpd		ymm0, ymm5		;		
		vaddpd		ymm1, ymm5		;
		vaddpd		ymm2, ymm5		;
		vaddpd		ymm3, ymm5		;
        sub         rsi,[V]
        add         rsi,[D]
		vmovapd		[rsi+rdi], ymm0	;
        mov         r11,[c]
        imul        r11,8
        add         r11,rsi
		vmovapd		[r11+rdi], ymm1	;
        mov         r11,[c]
        imul        r11,16
        add         r11,rsi
		vmovapd		[r11+rdi], ymm2	;
        mov         r11,[c]
        imul        r11,24
        add         r11,rsi
		vmovapd		[r11+rdi], ymm3	;
        sub         rsi,[D]
		add		    r10,4			;
		cmp 		r10,[c]			;
		jb		forj			;
		add		rax,4			;
		cmp		rax,[r]		;
		jb		fori		
        ; ------------------------------------------------------------
        ; Sequenza di uscita dalla funzione
        ; ------------------------------------------------------------
        
        popaq				; ripristina i registri generali
        mov		rsp, rbp	; ripristina lo Stack Pointer
        pop		rbp		; ripristina il Base Pointer
        ret				; torna alla funzione C chiamante
