.section .data
bin_ls:  .string "/bin/ls\0"
argv:
   # Pointer to filename
   .quad bin_ls
   # Null-terminated argument list
   .quad 0            
   # Null-terminated environment    # pointer for execve
    envp:   .quad 0
child_msg:   .string "child\n"
parent_msg:   .string "parent\n"
.section .bss
pid: .skip 4
.section .text
.globl main
main:
    # fork() system call
    xorq %rax, %rax         # Clear rax for syscall number
    movq $57, %rax          # syscall number
    syscall
    # Check fork result
    testq %rax, %rax        # Check if rax is zero (child process)
    js fork_error           # Jump to error handler if rax < 0
    jz child_process        # Jump if rax == 0 (child process)  
parent_process:
    # wait() system call
    movq %rax, %rdi         # Save child's PID in rdi
    xorq %rax, %rax         # Zero out rax for syscall number
    movq $61, %rax          # syscall number
    xorq %rsi, %rsi         # rsi = 0 (wait for any child process)
    xorq %rdx, %rdx         # rdx = 0 (no options)
    xorq %r10, %r10         # r10 = 0 (no usage of rusage)
    syscal
    # Print a message using write() syscall
    movq $1, %rdi           # file descriptor 1 (stdout)
    leaq parent_msg(%rip), %rsi # pointer to parent message
    movq $7, %rdx          # size of the parent message
    movq $1, %rax           # syscall number for write()
    syscall
exit: # Exit parent process
    movq $60, %rax          # syscall number for exit()
    xorq %rdi, %rdi         # rdi = 0 (exit code)
    syscall
child_process:
    # Print a message using write() syscall
    movq $1, %rdi           # file descriptor 1 (stdout)
    leaq child_msg(%rip), %rsi # pointer to child message
    movq $6, %rdx          # size of the child message
    movq $1, %rax           # syscall number for write()
    syscall
    # execve("/bin/ls", argv, envp) system call
    leaq bin_ls(%rip), %rdi # rdi = pointer to filename
    leaq argv(%rip), %rsi   # rsi = pointer to argv array
    leaq envp(%rip), %rdx   # rdx = pointer to envp array
    movq $59, %rax          # syscall number
    syscall
    # If execve returns, it failed
execve_error:
    movq $60, %rax          # syscall number for exit()
    movq $1, %rdi           # rdi = 1 (exit code)
    syscall
fork_error:
    movq $60, %rax          # syscall number for exit()
    movq $2, %rdi           # rdi = 2 (exit code)
    syscall
