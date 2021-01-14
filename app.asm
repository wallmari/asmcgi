global _start

;
; CONSTANTS
;
SYS_WRITE   equ 1
SYS_EXIT    equ 60
STDOUT      equ 1

;
; Initialised data goes here
;
SECTION .data
hello               db  "Hello "
hello_len           equ $-hello
world               db  "World!"
world_len           equ $-world
content_type        db  "Content-Type: text/html", 10, 13
content_type_len    equ $-content_type
nl                  db  10, 13
nl_len              equ $-nl
query_string        db  "QUERY_STRING=name=", 0
query_string_len    equ $-query_string
name_length         db 0

;
; Uninitialised data
;
SECTION .bss
name            resb    64; Up to 64 bytes of name

;
; Code goes here
;
SECTION .text

_start:
    pop     rax ;get argument counter, we don't care
    pop     rax ;get our name (argv[0]), we don't care

.arg:
    pop     rax ;pop all arguments, we don't care
    test    rax,rax
    jnz     .arg

.env:           ;pop all environment vars
    pop     rax
    test    rax,rax ;end-of-list null?
    jz      .output

    mov     rbx,query_string ;Name of the env variable we're looking for
.match1:
    mov     dl,[rax]
    cmp     [rbx],dl   ; Same character?
    jne     .env        ; Nope, this is not the droid we're looking for
    inc     rax
    inc     rbx
    mov     dl,[rbx]
    test    [rbx],dl    ; end of string null?
    jnz     .match1     ; Nope, check next character
.matched:
    mov     rbx, 63     ; Max char count
    mov     cl, 0      ; Length of the specified name
    mov     rdi,name    ; Place to copy to
.copy1:
    mov     dl,[rax]
    mov     [rdi],dl    ; Copy the character
    inc     cl
    test    dl,dl       ; Is this the ending null?
    jz      .copydone   ; Copy complete
    inc     rdi
    inc     rax
    dec     rbx         ; Decrement out limit count
    jnz     .copy1      ; Loop if we're not at the end
.copydone:
    mov     rax, name_length
    mov     [rax], cl

.output:
    ; syscall(SYS_WRITE, STDOUT, content_type, content_type_len);
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, content_type
    mov     rdx, content_type_len
    syscall

    ; syscall(SYS_WRITE, STDOUT, nl, nl_len);
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, nl
    mov     rdx, nl_len
    syscall

    ; syscall(SYS_WRITE, STDOUT, hello, hello_len);
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, hello
    mov     rdx, hello_len
    syscall

    mov     rsi, name
    mov     rdx, 0
    mov     rax, name_length
    mov     dl, [rax]
    test    rdx, rdx
    jnz     .write_name     ; If the length>0, jump
    mov     rsi, world
    mov     rdx, world_len

.write_name:
    ; syscall(SYS_WRITE, STDOUT, world, world_len);
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    syscall

    ; syscall(SYS_WRITE, STDOUT, nl, nl_len);
    mov     rax, SYS_WRITE
    mov     rdi, STDOUT
    mov     rsi, nl
    mov     rdx, nl_len
    syscall

    ; syscall(SYS_EXIT, 0);
    mov     rax, SYS_EXIT
    mov     rdi,0
    syscall
