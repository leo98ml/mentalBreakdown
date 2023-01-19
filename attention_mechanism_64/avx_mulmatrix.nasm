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
    C:        resq   1

section .text			; Sezione contenente il codice macchina

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

        mov rax,0			;i=0
fori:	mov r10,0			;j=0
        mov rsi, 8
        imul rsi,[col2]
        imul rsi,rax
        add rsi, [C]
forj:	mov rdi,8
        imul rdi,[col]
        imul rdi,rax		
        vxorpd ymm4,ymm4
        mov rcx,0			;k=0
fork:	mov rdx,8
        imul rdx,[col2]
        imul rdx, rcx
        add rdi, [A]
        add rdx, [B]
        vbroadcastsd ymm2,[rdi+rcx*8]
        vmovapd ymm1,[rdx+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm4,ymm1
        mov r11, 8
        imul r11,[col2]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+8]
        vmovapd ymm1,[r11+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm4,ymm1
        mov r11, 16
        imul r11,[col2]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+16]
        vmovapd ymm1,[r11+r10*8]
        vmulpd  ymm1,ymm2
        vaddpd ymm4,ymm1
        mov r11, 24
        imul r11,[col2]
        add r11,rdx
        vbroadcastsd ymm2,[rdi+rcx*8+24]
        vmovapd ymm1,[r11+r10*8]
        sub rdi, [A]
        sub rdx, [B]
        vmulpd  ymm1,ymm2
        vaddpd ymm4,ymm1
        add rcx,4		
        cmp rcx,[col]		
        jb fork			
        vmovapd [rsi+r10*8],ymm4
        add r10,4		
        cmp r10,[col2]		
        jb forj			
        add rax,1		
        cmp rax,[row]	        
        jb fori			
        mov rax,[C]
       
        popaq				; ripristina i registri generali
        mov		rsp, rbp	; ripristina lo Stack Pointer
        pop		rbp		; ripristina il Base Pointer
        ret				; torna alla funzione C chiamante
