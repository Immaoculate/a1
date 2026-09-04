# hailstone_trace.s
#
# Commit 3:
# Complete Part A and add packed trace decoding for Part B.
#
# Register usage:
#   s0 = current hailstone value in Part A / temporary shifted p in Part B
#   s1 = packed trace built in Part A
#   s2 = number of Part A steps
#   s3 = packed trace input for Part B
#   s4 = number of recorded steps in Part B
#   s5 = reconstructed value while decoding
#
# Temporary registers:
#   t0 = parity test
#   t1 = bit position
#   t2 = bit mask / temporary arithmetic value
#   t3 = selected decision bit
#   t4 = constants

.text
.globl main

main:
    ####################################################################
    # Part A - Pack
    ####################################################################

    read_int s0

    addi s1, x0, 0
    addi s2, x0, 0
    addi t4, x0, 1

pack_loop:
    beq s0, t4, pack_done

    # Check whether n is odd.
    andi t0, s0, 1
    beq t0, x0, pack_even

    # Odd step: set bit 'steps' to 1.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    # n = 3n + 1
    slli t2, s0, 1
    add s0, t2, s0
    addi s0, s0, 1

    jal x0, pack_step_done

pack_even:
    # Even decision bit stays 0.
    # n = n / 2
    srli s0, s0, 1

pack_step_done:
    addi s2, s2, 1
    jal x0, pack_loop

pack_done:
    # Add stop marker at bit position steps.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    print_int s2
    println

    print_int s1
    println

    ####################################################################
    # Part B - Decode
    ####################################################################

    # Read an unrelated packed trace.
    read_int s3

    # Find the highest set bit.
    # Its position is the number of recorded steps.
    add s0, s3, x0
    addi s4, x0, 0
    addi t4, x0, 1

find_marker:
    # Once the shifted value becomes 1,
    # the highest set bit has reached bit position 0.
    beq s0, t4, marker_found

    srli s0, s0, 1
    addi s4, s4, 1
    jal x0, find_marker

marker_found:
    # Every hailstone sequence ends at 1.
    addi s5, x0, 1

    # If there are no recorded steps, decoding is already complete.
    beq s4, x0, decode_done

    # Start from bit m - 1.
    addi t1, s4, -1

    # Create mask 1 << (m - 1).
    addi t2, x0, 1
    sll t2, t2, t1

decode_loop:
    # Once the bit position becomes negative, all decisions are done.
    blt t1, x0, decode_done

    # Isolate the current decision bit.
    and t3, s3, t2
    beq t3, x0, decode_even

    # Reverse an odd hailstone step:
    # previous = (current - 1) / 3
    addi s5, s5, -1
    addi t4, x0, 3
    div s5, s5, t4

    jal x0, decode_step_done

decode_even:
    # Reverse an even hailstone step:
    # previous = current * 2
    slli s5, s5, 1

decode_step_done:
    # Move to the next lower bit.
    srli t2, t2, 1
    addi t1, t1, -1
    jal x0, decode_loop

decode_done:
    print_int s5
    println

    exit
