# RISC-V Task Manager - Main Program
# Developed by: kappasutra

.data
# Menu text and prompts
title:          .asciz "\n==== RISC-V Task Manager ====\n"
menu_options:   .asciz "1. List all processes\n2. Filter processes by name\n3. Find process by PID\n4. Terminate a process\n5. Task scheduler\n0. Exit\n"
prompt:         .asciz "Enter your choice: "
invalid_choice: .asciz "Invalid choice. Please try again.\n"
exit_msg:       .asciz "Exiting Task Manager. Goodbye!\n"
newline:        .asciz "\n"

# Process buffers and variables
proc_buffer:    .space 1024    # Buffer to store process information
pid_prompt:     .asciz "Enter PID: "
name_prompt:    .asciz "Enter process name: "
input_buffer:   .space 64      # Buffer for user input
process_header: .asciz "\nPID\tSTATE\tNAME\tCPU%\tMEM%\n------------------------------------------------\n"
no_process_msg: .asciz "No process found with this identifier.\n"

.text
.globl main
main:
    # Display welcome banner and main menu
    jal display_welcome
    
main_loop:
    # Display menu options
    jal display_menu
    
    # Get user choice
    jal read_integer
    mv s0, a0                  # Save user choice in s0
    
    # Process user choice
    beqz s0, exit_program      # If choice is 0, exit program
    li t0, 1
    beq s0, t0, list_processes # If choice is 1, list processes
    li t0, 2
    beq s0, t0, filter_by_name # If choice is 2, filter by name
    li t0, 3
    beq s0, t0, find_by_pid    # If choice is 3, find by PID
    li t0, 4
    beq s0, t0, terminate_proc # If choice is 4, terminate process
    li t0, 5
    beq s0, t0, task_scheduler # If choice is 5, task scheduler
    
    # Invalid choice
    la a0, invalid_choice
    jal print_string
    j main_loop
    
exit_program:
    # Display exit message
    la a0, exit_msg
    jal print_string
    
    # Exit program
    li a7, 10                  # System call for exit
    ecall

# ===== Menu Functions =====
display_welcome:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Clear screen (not directly available in RARS, could implement later)
    
    # Print banner
    la a0, title
    jal print_string
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret

display_menu:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Print menu options
    la a0, title
    jal print_string
    
    la a0, menu_options
    jal print_string
    
    la a0, prompt
    jal print_string
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret

# ===== Process Management Functions =====
list_processes:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Call the display_process_list function from process_manager.s
    jal display_process_list
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    j main_loop

filter_by_name:
    addi sp, sp, -12           # Allocate stack space
    sw ra, 0(sp)               # Save return address
    sw s0, 4(sp)               # Save s0
    sw s1, 8(sp)               # Save s1
    
    # Prompt for process name
    la a0, name_prompt
    jal print_string
    
    # Read process name
    la a0, input_buffer
    li a1, 64                  # Maximum length
    jal read_string
    
    # Boş giriş kontrolü
    la s0, input_buffer        # s0 = input buffer address
    lb t0, 0(s0)
    beqz t0, show_all_procs    # Boş giriş ise tüm süreçleri listele
    
    # Print header
    la a0, process_header
    jal print_string
    
    # Get process list
    jal get_process_list
    mv s0, a0                  # s0 = process data pointer
    mv s1, a1                  # s1 = number of processes
    
    # Initialize loop counter
    li t0, 0                   # t0 = current process index
    li t5, 0                   # t5 = match counter (kaç tane eşleşme bulundu)
    
filter_loop:
    # Check if we've processed all entries
    beq t0, s1, filter_complete
    
    # Calculate address of current process
    lw t1, process_entry_size  # t1 = size of each process entry
    mul t2, t0, t1             # t2 = index * entry_size
    add t3, s0, t2             # t3 = base + offset = current entry address
    
    # Load process name
    addi t4, t3, 8             # t4 = name address (PID 4 bytes + STATE 4 bytes)
    
    # Basit karşılaştırma: İlk harfe bak
    la t1, input_buffer
    lb t1, 0(t1)               # t1 = kullanıcı girişinin ilk harfi
    lb t2, 0(t4)               # t2 = süreç adının ilk harfi
    
    bne t1, t2, next_proc      # İlk harfler eşleşmezse, sonraki süreç
    
    # İlk harfler eşleşti, süreci göster
    addi t5, t5, 1             # Eşleşme sayacını artır
    
    # Print PID
    lw a0, 0(t3)               # Load PID
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11                  # System call for print_character
    ecall
    
    # Print State
    lb a0, 4(t3)               # Load State
    li a7, 11                  # System call for print_character
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print Name
    mv a0, t4                  # Address of name
    li a7, 4                   # System call for print_string
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print CPU%
    lw a0, 24(t3)              # Load CPU%
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print MEM%
    lw a0, 28(t3)              # Load MEM%
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print newline
    li a0, '\n'
    li a7, 11
    ecall
    
next_proc:
    addi t0, t0, 1             # Increment counter
    j filter_loop              # Continue loop
    
show_all_procs:
    # Boş giriş durumunda tüm süreçleri listele
    jal display_process_list
    j filter_exit
    
filter_complete:
    # Eğer hiç eşleşme bulunamadıysa bilgi ver
    beqz t5, no_matches
    j filter_exit
    
no_matches:
    # Eşleşme bulunamadı mesajı
    la a0, no_process_msg
    jal print_string
    
filter_exit:
    # Return to main menu
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore s0
    lw s1, 8(sp)               # Restore s1
    addi sp, sp, 12            # Deallocate stack space
    j main_loop                # Explicit jump to main menu

find_by_pid:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Prompt for PID
    la a0, pid_prompt
    jal print_string
    
    # Read PID
    jal read_integer
    mv s0, a0                  # Save PID in s0
    
    # Call find_process from process_manager.s
    jal find_process
    
    # Check if process was found
    beqz a0, process_not_found
    
    # Process found, display it
    mv s1, a1                  # s1 = address of process data
    
    # Print header
    la a0, process_header
    jal print_string
    
    # Print PID
    lw a0, 0(s1)               # Load PID
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11                  # System call for print_character
    ecall
    
    # Print State
    lb a0, 4(s1)               # Load State
    li a7, 11                  # System call for print_character
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print Name
    addi a0, s1, 8             # Address of name
    li a7, 4                   # System call for print_string
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print CPU%
    lw a0, 24(s1)              # Load CPU%
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print MEM%
    lw a0, 28(s1)              # Load MEM%
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print newline
    li a0, '\n'
    li a7, 11
    ecall
    
    j find_done
    
process_not_found:
    # Print no process found message
    la a0, no_process_msg
    jal print_string
    
find_done:
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    j main_loop

terminate_proc:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Prompt for PID
    la a0, pid_prompt
    jal print_string
    
    # Read PID
    jal read_integer
    
    # Call kill_process from process_manager.s
    jal kill_process
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    j main_loop

task_scheduler:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Call scheduler_menu_handler from scheduler.s
    jal scheduler_menu_handler
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    j main_loop

# ===== Utility Functions =====
print_string:
    li a7, 4                   # System call for print_string
    ecall
    ret

read_string:
    li a7, 8                   # System call for read_string
    ecall
    ret

read_integer:
    li a7, 5                   # System call for read_integer
    ecall
    ret

# Tam metin karşılaştırma fonksiyonu (strcmp) ile değiştiriyorum
# Sadece tam eşleşme yapacak
# Parameters: a0 - String 1 address
#             a1 - String 2 address
# Returns: a0 - 1 if equal, 0 if not equal
strcmp:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
strcmp_loop:
    lb t0, 0(a0)               # Load byte from string 1
    lb t1, 0(a1)               # Load byte from string 2
    
    bne t0, t1, strcmp_not_equal  # If bytes are not equal, strings are not equal
    
    beqz t0, strcmp_equal     # If end of string (null byte), strings are equal
    
    addi a0, a0, 1             # Increment string 1 pointer
    addi a1, a1, 1             # Increment string 2 pointer
    j strcmp_loop
    
strcmp_equal:
    li a0, 1                   # Return 1 (equal)
    j strcmp_exit
    
strcmp_not_equal:
    li a0, 0                   # Return 0 (not equal)
    
strcmp_exit:
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret 