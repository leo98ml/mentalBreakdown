%include "sseutils32.nasm"

section .data
    Question  byte  "Please enter your name."
section .bss 
section .text 
global print_string
print_string:
    start
    mov eax, [ebp+4] ; get first argument (pointer to string)

    printps Question,6

.done:
    stop