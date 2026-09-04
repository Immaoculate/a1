# hailstone_trace.s
#
# Commit 2:
# Pack hailstone decisions into bits and add the stop marker.
#
# Register usage:
#   s0 = current hailstone value n
#   s1 = packed trace value
#   s2 = number of steps taken
#
# Temporary registers:
#   t0 = parity test
#   t1 = bit mask
#   t2 = temporary arithmetic value
#   t4 = constant 1

.text
.globl main

main:
    # Read starting value n.
    read_int s0

    # s1 stores the packed decision bits.
    addi s1, x0, 0

    # s2 counts hailstone steps.
    addi s2, x0, 0

    # Constant 1.
    addi t4, x0, 1

pack_loop:
    # Stop once n reaches 1.
    beq s0, t4, pack_done

    # The lowest bit tells us whether n is odd or even.
    andi t0, s0, 1
    beq t0, x0, pack_even

    # Odd step:
    # Record a 1 in bit position 'steps'.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    # Apply odd hailstone rule:
    # n = 3n + 1
    slli t2, s0, 1
    add s0, t2, s0
    addi s0, s0, 1

    jal x0, pack_step_done

pack_even:
    # Even steps are represented by a 0 bit.
    # Since the packed value starts at 0, no bit needs to be set.

    # Apply even hailstone rule:
    # n = n / 2
    srli s0, s0, 1

pack_step_done:
    # Move to the next trace bit.
    addi s2, s2, 1
    jal x0, pack_loop

pack_done:
    # Add the stop marker.
    # The marker is stored at bit position 'steps'.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    # Print Part A result.
    print_int s2
    println

    print_int s1
    println

    exit
