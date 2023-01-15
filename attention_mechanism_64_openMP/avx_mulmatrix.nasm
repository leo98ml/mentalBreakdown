%include "sseutils64.nasm"

section .data			; Sezione contenente dati inizializzati

section .bss			; Sezione contenente dati non inizializzati
    alignb 32
    A:        resq    1
    alignb 32
    B:        resq    1
    alignb 32
    row:        resq    1
    alignb 32
    col:      resq     1
    alignb 32
    col2:      resq     1
    alignb 32
    C:      resq     1

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
global mul_matrix


mul_matrix:
        push		rbp				; salva il Base Pointer
		mov		rbp, rsp			; il Base Pointer punta al Record di Attivazione corrente
		pushaq						; salva i registri generali

        	
		MOV [A], RDI		
		MOV [B], RSI		
		MOV [row], RDX		
		MOV [col], RCX	
		MOV [col2], R8 
		MOV [C], R9

		
        mov 	rax,0			;i=0
fori:	mov	r10,0			;j=0
forj:	
        mov rdi,8
        imul rdi,[col]
        imul rdi,rax		;
        vxorpd ymm3,ymm3
        mov rcx,0			;k=0
fork:	mov rsi, 8
        imul rsi,[col2]
        imul rsi,rax
 	    mov rdx,8
        imul rdx,[col2]
        imul rdx, rcx
        add rdi, [A]
        add rdx, [B]
        vbroadcastsd ymm2,[rdi+rcx*8]
        vmovapd ymm1,[rdx+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm4,ymm1
        mov r11, 8
        imul r11,[col]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+8]
        vmovapd ymm1,[r11+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm5,ymm1
        mov r11, 16
        imul r11,[col]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+16]
        vmovapd ymm1,[r11+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm6,ymm1
        mov r11, 24
        imul r11,[col]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+24]
        vmovapd ymm1,[r11+r10*8]
        sub rdi, [A]
        sub rdx, [B]
        vmulpd  ymm1,ymm2
        vaddpd ymm7,ymm1
        add rcx,4			;
        cmp rcx,[col]			;
        jb fork			;
        vaddpd ymm3,ymm4
        vaddpd ymm3,ymm5
        vaddpd ymm3,ymm6
        vaddpd ymm3,ymm7
        vxorpd ymm4,ymm4
        vxorpd ymm5,ymm5
        vxorpd ymm6,ymm6
        vxorpd ymm7,ymm7
        add rsi, [C]
        vmovapd [rsi+r10*8],ymm3
        sub rsi, [C]
        add r10,4			;
        cmp r10,[col2]			;
        jb forj			;
        add rax,1			;
        cmp rax,[row]			;
        jb fori			;
        mov rax,[C];
        
    ; ------------------------------------------------------------
    ; Sequenza di uscita dalla funzione
    ; ------------------------------------------------------------
    
    popaq				; ripristina i registri generali
    mov		rsp, rbp	; ripristina lo Stack Pointer
    pop		rbp		; ripristina il Base Pointer
    ret				; torna alla funzione C chiamante
