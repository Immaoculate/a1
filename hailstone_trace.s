# hailstone_trace.s
#
# Initial implementation of hailstone sequence.
# s0 = current hailstone value
# s2 = number of steps

.text
.globl main

main:
    read_int s0

    addi s2, x0, 0
    addi t4, x0, 1

pack_loop:
    beq s0, t4, pack_done

    andi t0, s0, 1
    beq t0, x0, pack_even

    # Odd: n = 3n + 1
    slli t1, s0, 1
    add s0, t1, s0
    addi s0, s0, 1
    jal x0, pack_step_done

pack_even:
    # Even: n = n / 2
    srli s0, s0, 1

pack_step_done:
    addi s2, s2, 1
    jal x0, pack_loop

pack_done:
    print_int s2
    println

    exit# Your code here
