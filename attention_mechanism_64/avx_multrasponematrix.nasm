%include "sseutils64.nasm"

section .data			; Sezione contenente dati inizializzati

section .bss			; Sezione contenente dati non inizializzati
    alignb 64
    A:        resq   1
    alignb 64
    B:        resq   1
    alignb 64
    row:      resq   1
    alignb 64
    col:      resq   1
    alignb 64
    col2:     resq   1
    alignb 64
    d:        resq   1
    alignb 64
    C:        resq   1

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
global mul_matrix_transpose_and_divide_by_scalar

input		equ		16

mul_matrix_transpose_and_divide_by_scalar:
        push		rbp				; salva il Base Pointer
		mov		rbp, rsp			; il Base Pointer punta al Record di Attivazione corrente
		pushaq						; salva i registri generali

        xor rax, rax
        xor r10, r10
        add rax, input
        add rax, rbp		
		MOV [A], RDI		
		MOV [B], RSI		
		MOV [row], RDX		
		MOV [col], RCX	
		MOV [col2], R8 	
		MOVSD [d], XMM0	
		MOV [C], R9

		mov rax,0			;i=0
fori:	mov	r10,0			;j=0
        mov rdi,8
        imul rdi,[col]
        imul rdi,rax
        mov rdx,8
        imul rdx,[col2]
        imul rdx, rax
forj:	vxorpd ymm4,ymm4
        vxorpd ymm5,ymm5
        vxorpd ymm6,ymm6
        vxorpd ymm7,ymm7
        mov rsi, 8
        imul rsi,[col]
        imul rsi,r10
        mov rcx,0			;k=0
fork    add rdi,[A]
        add rsi,[B]	
        vmovapd ymm2,[rdi+rcx*8]; take 4 elem from A
        vmovapd ymm1,[rsi+rcx*8]; take 4 elem from B
        vmulpd  ymm1,ymm2
        vhaddpd ymm1,ymm1
        vpermq ymm1, ymm1, 0x39
        vhaddpd ymm1,ymm1
        vaddpd ymm4,ymm1; partial sum for C[i][j]
        mov r11, 8
        imul r11,[col]
        add r11,rsi
        vmovapd ymm1,[r11+rcx*8]; take 4 elem from next row B
        vmulpd ymm1,ymm2
        vhaddpd ymm1,ymm1
        vpermq ymm1, ymm1, 0x39
        vhaddpd ymm1,ymm1
        vaddpd ymm5,ymm1; partial sum for C[i][j+1]
        mov r11, 16
        imul r11,[col]
        add r11,rsi
        vmovapd ymm1,[r11+rcx*8]
        vmulpd  ymm1,ymm2
        vhaddpd ymm1,ymm1
        vpermq ymm1, ymm1, 0x39
        vhaddpd ymm1,ymm1
        vaddpd ymm6,ymm1; partial sum for C[i][j+2]
        mov r11, 24
        imul r11,[col]
        add r11,rsi
        vmovapd ymm1,[r11+rcx*8]
        sub rdi,[A]
        sub rsi,[B]
        vmulpd  ymm1,ymm2
        vhaddpd ymm1,ymm1
        vpermq ymm1, ymm1, 0x39
        vhaddpd ymm1,ymm1
        vaddpd ymm7,ymm1; partial sum for C[i][j+3]
        add rcx,4			;
        cmp rcx,[col]			;
        jb fork			;
        vbroadcastsd ymm3,[d]
        vmulpd ymm4,ymm3
        add rdx,[C]
        vmovsd  [rdx+r10*8],xmm4
        vmulpd ymm5,ymm3
        vmovsd  [rdx+r10*8+8],xmm5
        vmulpd ymm6,ymm3
        vmovsd  [rdx+r10*8+16],xmm6
        vmulpd ymm7,ymm3
        vmovsd [rdx+r10*8+24],xmm7
        sub rdx,[C]
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
