# RISC-V Task Manager - Process Manager Module
# This module contains functions for process management

.data
# Process display headers
process_header:  .asciz "\nPID\tSTATE\tNAME\tCPU%\tMEM%\n------------------------------------------------\n"
no_process_msg:  .asciz "No process found with this identifier.\n"
kill_success:    .asciz "Process terminated successfully.\n"
kill_failed:     .asciz "Failed to terminate process.\n"

# Simulated process data for demonstration
# Format: PID, State, Name, CPU%, MEM%
process_count:   .word 5       # Number of simulated processes

# Her süreç için sabit boyut
process_entry_size: .word 32   # Size of each process entry (4 bytes PID + 16 bytes state + 4 bytes pointer to name + 4 bytes CPU% + 4 bytes MEM%)

process_data:
    # Süreç 1
    .word 1001     # PID
    .byte 'R'      # State (R = Running)
    .byte 0, 0, 0  # Padding for alignment
    .asciz "System"  # Name (null-terminated string)
    .space 8       # Name için ek padding (toplam 16 byte alan)
    .word 10       # CPU%
    .word 20       # MEM%
    
    # Süreç 2
    .word 1002     # PID
    .byte 'S'      # State (S = Sleeping)
    .byte 0, 0, 0  # Padding for alignment
    .asciz "Init"    # Name
    .space 11      # Name için ek padding (toplam 16 byte alan)
    .word 5        # CPU%
    .word 10       # MEM%
    
    # Süreç 3
    .word 1003     # PID
    .byte 'R'      # State
    .byte 0, 0, 0  # Padding for alignment
    .asciz "Terminal" # Name
    .space 7       # Name için ek padding (toplam 16 byte alan)
    .word 15       # CPU%
    .word 25       # MEM%
    
    # Süreç 4
    .word 1004     # PID
    .byte 'Z'      # State (Z = Zombie)
    .byte 0, 0, 0  # Padding for alignment
    .asciz "Defunct"  # Name
    .space 8       # Name için ek padding (toplam 16 byte alan)
    .word 0        # CPU%
    .word 0        # MEM%
    
    # Süreç 5
    .word 1005     # PID
    .byte 'S'      # State
    .byte 0, 0, 0  # Padding for alignment
    .asciz "Server"   # Name
    .space 9       # Name için ek padding (toplam 16 byte alan)
    .word 20       # CPU%
    .word 30       # MEM%

# Buffer for process display
buffer:         .space 128

.text
.globl get_process_list
.globl display_process_list
.globl find_process
.globl kill_process
.globl process_entry_size

# Function: get_process_list
# Description: Load process list (simulated in this implementation)
# Parameters: None
# Returns: a0 - Pointer to process data
#          a1 - Number of processes
get_process_list:
    la a0, process_data        # Load address of process data
    lw a1, process_count       # Load number of processes
    ret

# Function: display_process_list
# Description: Display list of all processes
# Parameters: None
# Returns: None
display_process_list:
    addi sp, sp, -8            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    sw s0, 4(sp)               # Save s0
    
    # Print header
    la a0, process_header
    li a7, 4                   # System call for print_string
    ecall
    
    # Get process list
    jal get_process_list
    mv s0, a0                  # s0 = process data pointer
    
    # Initialize loop counter
    li t0, 0                   # t0 = current process index
    lw t1, process_count       # t1 = total number of processes
    lw t2, process_entry_size  # t2 = size of each process entry
    
display_loop:
    # Check if we've processed all entries
    beq t0, t1, display_done
    
    # Calculate address of current process
    mul t3, t0, t2             # t3 = index * entry_size
    add t3, s0, t3             # t3 = base + offset = current entry address
    
    # Print PID
    lw a0, 0(t3)               # Load PID
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11                  # System call for print_character
    ecall
    
    # Print State
    lb a0, 4(t3)               # Load State (byte at offset 4)
    li a7, 11                  # System call for print_character
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print Name (address at offset 8)
    addi a0, t3, 8             # Calculate address of name string (8 bytes offset)
    li a7, 4                   # System call for print_string
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print CPU%
    lw a0, 24(t3)              # Load CPU% (offset 24)
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print MEM%
    lw a0, 28(t3)              # Load MEM% (offset 28)
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print newline
    li a0, '\n'
    li a7, 11
    ecall
    
    # Increment counter and continue loop
    addi t0, t0, 1
    j display_loop
    
display_done:
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore s0
    addi sp, sp, 8             # Deallocate stack space
    ret

# Function: find_process
# Description: Find a process by PID
# Parameters: a0 - PID to find
# Returns: a0 - 1 if found, 0 if not found
#          a1 - Address of process data if found
find_process:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Save the target PID
    mv t0, a0                  # t0 = PID to find
    
    # Get process list
    jal get_process_list
    mv t1, a0                  # t1 = process data pointer
    mv t2, a1                  # t2 = number of processes
    
    # Initialize loop counter
    li t3, 0                   # t3 = current process index
    lw t4, process_entry_size  # t4 = size of each process entry
    
find_loop:
    # Check if we've processed all entries
    beq t3, t2, find_not_found
    
    # Calculate address of current process
    mul t5, t3, t4             # t5 = index * entry_size
    add t5, t1, t5             # t5 = base + offset = current entry address
    
    # Compare PID
    lw t6, 0(t5)               # Load current PID
    beq t6, t0, find_found     # If match, process found
    
    # Increment counter and continue loop
    addi t3, t3, 1
    j find_loop
    
find_found:
    # Process found
    li a0, 1                   # Return 1 (found)
    mv a1, t5                  # Return address of process data
    j find_exit
    
find_not_found:
    # Process not found
    li a0, 0                   # Return 0 (not found)
    li a1, 0                   # Return null address
    
find_exit:
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret

# Function: kill_process
# Description: Kill a process by PID (simulated)
# Parameters: a0 - PID to kill
# Returns: a0 - 1 if successful, 0 if failed
kill_process:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
    # Find the process
    jal find_process
    
    # Check if process was found
    beqz a0, kill_failed_handler
    
    # In a real implementation, we would use system calls to terminate the process
    # For this simulation, we'll just return success
    li a0, 1                   # Return 1 (success)
    
    # Print success message
    addi sp, sp, -4            # Save a0
    sw a0, 0(sp)
    
    la a0, kill_success
    li a7, 4                   # System call for print_string
    ecall
    
    lw a0, 0(sp)               # Restore a0
    addi sp, sp, 4
    
    j kill_exit
    
kill_failed_handler:
    # Process not found or couldn't be killed
    li a0, 0                   # Return 0 (failed)
    
    # Print failure message
    addi sp, sp, -4            # Save a0
    sw a0, 0(sp)
    
    la a0, kill_failed
    li a7, 4                   # System call for print_string
    ecall
    
    lw a0, 0(sp)               # Restore a0
    addi sp, sp, 4
    
kill_exit:
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret 