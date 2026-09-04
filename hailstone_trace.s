# hailstone_trace.s
#
# Hailstone Bit Trace
#
# Part A:
#   Reads a positive integer n and generates its hailstone sequence.
#   Each step is packed into one bit:
#       0 = even rule (n / 2)
#       1 = odd rule  (3n + 1)
#   Step 0 is stored in the least significant bit.
#   When the sequence reaches 1, an additional stop-marker bit is set
#   at position 'steps'.
#
# Part B:
#   Reads a separate packed trace p.
#   The highest set bit is the stop marker and gives the number of
#   recorded steps. Starting from value 1, the recorded steps are
#   processed backwards to reconstruct the original starting value.
#
# Register usage:
#   s0 = current hailstone value n in Part A
#        temporary shifted copy of p while locating marker in Part B
#   s1 = packed trace constructed in Part A
#   s2 = number of hailstone steps in Part A
#   s3 = packed trace input for Part B
#   s4 = number of recorded steps m in Part B
#   s5 = reconstructed hailstone value during decoding
#
# Temporary registers:
#   t0 = parity test
#   t1 = current bit position or generated bit mask
#   t2 = mask / arithmetic temporary
#   t3 = isolated decision bit
#   t4 = small integer constants

.text
.globl main

main:
    ####################################################################
    # Part A - Pack the hailstone trace
    ####################################################################

    # Read starting positive integer n.
    read_int s0

    # Packed trace initially contains no set bits.
    addi s1, x0, 0

    # No hailstone steps have been performed yet.
    addi s2, x0, 0

    # Constant used for comparison with the final hailstone value 1.
    addi t4, x0, 1

pack_loop:
    # The sequence is complete when n becomes 1.
    beq s0, t4, pack_done

    # AND with 1 checks the least significant bit.
    # Result 0 means even; result 1 means odd.
    andi t0, s0, 1
    beq t0, x0, pack_even

    ####################################################################
    # Odd hailstone step
    ####################################################################

    # Odd decisions are represented by a 1.
    #
    # Generate the mask:
    #     1 << steps
    #
    # and OR it into the packed trace.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    # Compute n = 3n + 1.
    #
    # Instead of multiplying directly:
    #     3n = 2n + n
    #
    # The shift produces 2n.
    slli t2, s0, 1
    add s0, t2, s0
    addi s0, s0, 1

    jal x0, pack_step_done

pack_even:
    ####################################################################
    # Even hailstone step
    ####################################################################

    # Even decisions are represented by 0.
    # The packed register starts at 0, so no bit needs to be changed.

    # Positive even n divided by two is equivalent to shifting right
    # one bit.
    srli s0, s0, 1

pack_step_done:
    # Advance to the next bit position.
    addi s2, s2, 1
    jal x0, pack_loop

pack_done:
    ####################################################################
    # Add stop marker
    ####################################################################

    # All decision bits occupy positions 0 through steps - 1.
    # Therefore setting bit 'steps' makes it the highest set bit and
    # allows the packed value to describe its own length.
    addi t1, x0, 1
    sll t1, t1, s2
    or s1, s1, t1

    # Required Part A output.
    print_int s2
    println

    print_int s1
    println

    ####################################################################
    # Part B - Decode a separate packed hailstone trace
    ####################################################################

    # This packed value is independent of the trace created in Part A.
    read_int s3

    ####################################################################
    # Locate the stop marker
    ####################################################################

    # Copy p because s3 must remain unchanged for later bit testing.
    add s0, s3, x0

    # s4 counts how many times p is shifted.
    # This becomes the position of its highest set bit.
    addi s4, x0, 0

    addi t4, x0, 1

find_marker:
    # When the shifted copy becomes exactly 1, the original highest
    # set bit has been shifted down to bit 0.
    #
    # The number of shifts performed is therefore m, the number of
    # decision bits below the stop marker.
    beq s0, t4, marker_found

    srli s0, s0, 1
    addi s4, s4, 1
    jal x0, find_marker

marker_found:
    ####################################################################
    # Reverse the hailstone sequence
    ####################################################################

    # All hailstone sequences represented by the trace finish at 1,
    # so decoding starts there.
    addi s5, x0, 1

    # A packed value containing only the stop marker has m = 0.
    beq s4, x0, decode_done

    # The last decision is at bit position m - 1.
    addi t1, s4, -1

    # Create a mask for bit m - 1.
    addi t2, x0, 1
    sll t2, t2, t1

decode_loop:
    # After bit 0 is processed, t1 becomes -1.
    blt t1, x0, decode_done

    # AND the packed trace with the mask.
    # Zero means the recorded decision was even.
    # Non-zero means it was odd.
    and t3, s3, t2
    beq t3, x0, decode_even

    ####################################################################
    # Reverse odd rule
    ####################################################################

    # Forward rule:
    #     current = 3 * previous + 1
    #
    # Therefore:
    #     previous = (current - 1) / 3
    addi s5, s5, -1
    addi t4, x0, 3
    div s5, s5, t4

    jal x0, decode_step_done

decode_even:
    ####################################################################
    # Reverse even rule
    ####################################################################

    # Forward rule:
    #     current = previous / 2
    #
    # Therefore:
    #     previous = current * 2
    slli s5, s5, 1

decode_step_done:
    # Shift the mask one position right to inspect the next earlier
    # decision bit.
    srli t2, t2, 1

    # Move from step i to step i - 1.
    addi t1, t1, -1

    jal x0, decode_loop

decode_done:
    # Required Part B output.
    print_int s5
    println

    exit
