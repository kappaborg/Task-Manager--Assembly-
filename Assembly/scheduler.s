# RISC-V Task Manager - Task Scheduler Module
# This module contains functions for task scheduling

.data
# Task scheduler headers and messages
scheduler_header:    .asciz "\n===== Task Scheduler =====\n"
scheduler_menu:      .asciz "1. Add new task\n2. List scheduled tasks\n3. Remove task\n4. Back to main menu\nEnter choice: "
task_prompt:         .asciz "Enter task command: "
time_prompt:         .asciz "Enter execution time (seconds from now): "
type_prompt:         .asciz "Task type (1-Once, 2-Interval, 3-Daily): "
interval_prompt:     .asciz "Enter interval (seconds): "
task_added:          .asciz "Task added successfully.\n"
task_removed:        .asciz "Task removed successfully.\n"
invalid_index:       .asciz "Invalid task index.\n"
task_list_empty:     .asciz "No scheduled tasks.\n"
task_list_header:    .asciz "\nID\tTYPE\tCOMMAND\t\tTIME\n-------------------------------------------\n"
type_once:           .asciz "Once"
type_interval:       .asciz "Interval"
type_daily:          .asciz "Daily"
back_msg:            .asciz "Returning to main menu...\n"
prompt:              .asciz "Enter task index: "

# Task data structure
# Structure:
# - command (64 bytes)
# - type (4 bytes) - 1: Once, 2: Interval, 3: Daily
# - execution_time (4 bytes)
# - interval (4 bytes)
# - is_active (4 bytes)
# - priority (4 bytes)  # New field for task priority
# Total: 84 bytes per task

task_entry_size:     .word 84        # Updated size of each task entry
max_tasks:           .word 10        # Maximum number of tasks
current_task_count:  .word 0         # Current number of tasks
tasks_data:          .space 840      # Space for 10 tasks (10 * 84 = 840 bytes)

# Dizeyi .asciz ile tanımla ve adresini yükle
priority_prompt: .asciz "Enter task priority (1-High, 2-Medium, 3-Low): "

.text
.globl scheduler_menu_handler
.globl add_task
.globl list_tasks
.globl remove_task

# Function: scheduler_menu_handler
# Description: Handle the scheduler menu
# Parameters: None
# Returns: None
scheduler_menu_handler:
    addi sp, sp, -4            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    
scheduler_loop:
    # Display scheduler menu
    la a0, scheduler_header
    li a7, 4                   # System call for print_string
    ecall
    
    la a0, scheduler_menu
    li a7, 4                   # System call for print_string
    ecall
    
    # Get user choice
    li a7, 5                   # System call for read_integer
    ecall
    mv t0, a0                  # t0 = user choice
    
    # Process user choice
    li t1, 1
    beq t0, t1, call_add_task
    
    li t1, 2
    beq t0, t1, call_list_tasks
    
    li t1, 3
    beq t0, t1, call_remove_task
    
    li t1, 4
    beq t0, t1, scheduler_exit
    
    # Invalid choice, loop back
    j scheduler_loop
    
call_add_task:
    jal add_task
    j scheduler_loop
    
call_list_tasks:
    jal list_tasks
    j scheduler_loop
    
call_remove_task:
    jal remove_task
    j scheduler_loop
    
scheduler_exit:
    # Print exit message
    la a0, back_msg
    li a7, 4                   # System call for print_string
    ecall
    
    lw ra, 0(sp)               # Restore return address
    addi sp, sp, 4             # Deallocate stack space
    ret

# Function: add_task
# Description: Add a new scheduled task
# Parameters: None
# Returns: None
add_task:
    addi sp, sp, -8            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    sw s0, 4(sp)               # Save s0
    
    # Check if we've reached the maximum number of tasks
    lw t0, current_task_count
    lw t1, max_tasks
    bge t0, t1, add_task_exit  # If current_task_count >= max_tasks, exit
    
    # Get the address of the new task
    la s0, tasks_data          # s0 = base address of tasks data
    lw t2, task_entry_size     # t2 = size of each task entry
    mul t3, t0, t2             # t3 = current_task_count * task_entry_size
    add s0, s0, t3             # s0 = address of the new task
    
    # Prompt for task command
    la a0, task_prompt
    li a7, 4                   # System call for print_string
    ecall
    
    # Read command (into the task structure directly)
    mv a0, s0                  # First field of task is command
    li a1, 64                  # Maximum length
    li a7, 8                   # System call for read_string
    ecall
    
    # Prompt for task type
    la a0, type_prompt
    li a7, 4                   # System call for print_string
    ecall
    
    # Read task type
    li a7, 5                   # System call for read_integer
    ecall
    sw a0, 64(s0)              # Store task type at offset 64
    
    # Prompt for execution time
    la a0, time_prompt
    li a7, 4                   # System call for print_string
    ecall
    
    # Read execution time and calculate absolute time
    li a7, 5                   # System call for read_integer
    ecall
    
    li a7, 30                  # System call for system time (seconds)
    ecall
    add a0, a0, a1             # a0 = current_time + offset
    sw a0, 68(s0)              # Store execution time at offset 68
    
    # If task type is interval, prompt for interval
    lw t0, 64(s0)              # Load task type
    li t1, 2                   # 2 = Interval
    bne t0, t1, skip_interval  # If task type != Interval, skip interval prompt
    
    la a0, interval_prompt
    li a7, 4                   # System call for print_string
    ecall
    
    li a7, 5                   # System call for read_integer
    ecall
    j store_interval
    
skip_interval:
    li a0, 0                   # Default interval = 0
    
store_interval:
    sw a0, 72(s0)              # Store interval at offset 72
    
    # Prompt for task priority
    la a0, priority_prompt
    li a7, 4                   # System call for print_string
    ecall
    
    # Read task priority
    li a7, 5                   # System call for read_integer
    ecall
    sw a0, 80(s0)              # Store priority at offset 80
    
    # Set task as active
    li a0, 1                   # 1 = active
    sw a0, 76(s0)              # Store is_active at offset 76
    
    # Increment task count
    lw t0, current_task_count
    addi t0, t0, 1
    la t1, current_task_count      # Adres yükleniyor
    sw t0, 0(t1)                  # Store is_active at offset 0
    
    # Print success message
    la a0, task_added
    li a7, 4                   # System call for print_string
    ecall
    
add_task_exit:
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore s0
    addi sp, sp, 8             # Deallocate stack space
    ret

# Function: list_tasks
# Description: List all scheduled tasks
# Parameters: None
# Returns: None
list_tasks:
    addi sp, sp, -8            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    sw s0, 4(sp)               # Save s0
    
    # Check if there are any tasks
    lw t0, current_task_count
    beqz t0, list_tasks_empty
    
    # Print header
    la a0, task_list_header
    li a7, 4                   # System call for print_string
    ecall
    
    # Initialize loop counter and address
    li t0, 0                   # t0 = current task index
    la s0, tasks_data          # s0 = base address of tasks data
    lw t1, task_entry_size     # t1 = size of each task entry
    lw t2, current_task_count  # t2 = total number of tasks
    
list_tasks_loop:
    # Check if we've processed all tasks
    beq t0, t2, list_tasks_exit
    
    # Calculate address of current task
    mul t3, t0, t1             # t3 = index * task_entry_size
    add t3, s0, t3             # t3 = base + offset = current task address
    
    # Print task ID (index + 1)
    addi a0, t0, 1
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11                  # System call for print_character
    ecall
    
    # Print task type
    lw t4, 64(t3)              # Load task type
    
    li t5, 1
    beq t4, t5, print_type_once
    
    li t5, 2
    beq t4, t5, print_type_interval
    
    li t5, 3
    beq t4, t5, print_type_daily
    
    # Default case
    j print_type_done
    
print_type_once:
    la a0, type_once
    j print_type
    
print_type_interval:
    la a0, type_interval
    j print_type
    
print_type_daily:
    la a0, type_daily
    
print_type:
    li a7, 4                   # System call for print_string
    ecall
    
print_type_done:
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print command
    mv a0, t3                  # Address of command (first field)
    li a7, 4                   # System call for print_string
    ecall
    
    # Print tab
    li a0, '\t'
    li a7, 11
    ecall
    
    # Print execution time
    lw a0, 68(t3)              # Load execution time
    li a7, 1                   # System call for print_integer
    ecall
    
    # Print newline
    li a0, '\n'
    li a7, 11
    ecall
    
    # Increment counter and continue loop
    addi t0, t0, 1
    j list_tasks_loop
    
list_tasks_empty:
    # No tasks found
    la a0, task_list_empty
    li a7, 4                   # System call for print_string
    ecall
    
list_tasks_exit:
    lw ra, 0(sp)               # Restore return address
    lw s0, 4(sp)               # Restore s0
    addi sp, sp, 8             # Deallocate stack space
    ret

# Function: remove_task
# Description: Remove a scheduled task by index
# Parameters: None
# Returns: None
remove_task:
    addi sp, sp, -8            # Allocate stack space
    sw ra, 0(sp)               # Save return address
    sw s0, 4(sp)               # Save s0
    
    # List tasks first
    jal list_tasks
    
    # Check if there are any tasks
    lw t0, current_task_count
    beqz t0, remove_task_exit
    
    # Prompt for task index
    la a0, prompt
    li a7, 4                   # System call for print_string
    ecall
    
    # Read task index
    li a7, 5                   # System call for read_integer
    ecall
    mv t0, a0                  # t0 = task index (1-based)
    
    # Validate index
    li t1, 1
    blt t0, t1, remove_invalid_index    # If index < 1, invalid
    lw t1, current_task_count
    bgt t0, t1, remove_invalid_index    # If index > current_task_count, invalid
    
    # Convert to 0-based index
    addi t0, t0, -1
    
    # Calculate address of task to remove
    la s0, tasks_data                   # s0 = base address of tasks data
    lw t1, task_entry_size              # t1 = size of each task entry
    mul t2, t0, t1                      # t2 = index * task_entry_size
    add s0, s0, t2                      # s0 = address of task to remove
    
    # Get address of last task
    lw t3, current_task_count
    addi t3, t3, -1                     # t3 = last task index
    mul t4, t3, t1                      # t4 = last_index * task_entry_size
    la t5, tasks_data
    add t5, t5, t4                      # t5 = address of last task
    
    # If this is not the last task, move the last task to this position
    beq s0, t5, skip_move               # If removing the last task, skip move
    
    # Copy last task to the position of the removed task
    mv a0, s0                           # Destination
    mv a1, t5                           # Source
    mv a2, t1                           # Size (task_entry_size)
    jal memcpy
    
skip_move:
    # Decrement task count
    lw t0, current_task_count
    addi t0, t0, -1
    la t1, current_task_count      # Adres yükleniyor
    sw t0, 0(t1)                  # Store is_active at offset 0
    
    # Print success message
    la a0, task_removed
    li a7, 4                            # System call for print_string
    ecall
    
    j remove_task_exit
    
remove_invalid_index:
    # Print invalid index message
    la a0, invalid_index
    li a7, 4                            # System call for print_string
    ecall
    
remove_task_exit:
    lw ra, 0(sp)                        # Restore return address
    lw s0, 4(sp)                        # Restore s0
    addi sp, sp, 8                      # Deallocate stack space
    ret

# Function: memcpy
# Description: Copy memory from source to destination
# Parameters: a0 - Destination address
#             a1 - Source address
#             a2 - Number of bytes to copy
# Returns: None
memcpy:
    beqz a2, memcpy_done               # If size is 0, done
    
    lb t0, 0(a1)                       # Load byte from source
    sb t0, 0(a0)                       # Store byte to destination
    
    addi a0, a0, 1                     # Increment destination
    addi a1, a1, 1                     # Increment source
    addi a2, a2, -1                    # Decrement size
    
    j memcpy                           # Loop
    
memcpy_done:
    ret 