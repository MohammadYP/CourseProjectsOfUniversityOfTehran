.text
.globl main
main:

    addi $t0, $zero, 0
    nop
    nop
    nop

outer_loop:

    slti $t9, $t0, 49
    nop
    nop
    nop
    beq  $t9, $zero, end
    nop
    nop
    nop
    nop

    addi $t2, $t0, 0
    addi $t1, $t0, 1
    nop
    nop
    nop
inner_loop:

    slti $t9, $t1, 50
    nop
    nop
    nop
    beq  $t9, $zero, end_inner
    nop
    nop
    nop
    nop
    sll  $t3, $t1, 2
    nop
    nop
    nop
    addu $t3, $zero, $t3
    nop
    nop
    nop
    lw   $t5, 0($t3)


    sll  $t4, $t2, 2
    nop
    nop
    nop
    addu $t4, $zero, $t4
    nop
    nop
    nop
    lw   $t6, 0($t4)
    nop
    nop
    nop

    slt  $t7, $t5, $t6
    nop
    nop
    nop
    beq  $t7, $zero, skip_update
    nop
    nop
    nop
    nop
    addi $t2, $t1, 0

skip_update:
    addi $t1, $t1, 1
    nop
    nop
    nop
    j    inner_loop
    nop
    nop
    nop
    nop

end_inner:

    beq  $t2, $t0, no_swap
    nop
    nop
    nop
    nop

    sll  $t3, $t0, 2
    nop
    nop
    nop
    addu $t3, $zero, $t3
    nop
    nop
    nop
    lw   $t5, 0($t3)


    sll  $t4, $t2, 2
    nop
    nop
    nop
    addu $t4, $zero, $t4
    nop
    nop
    nop
    lw   $t6, 0($t4)
    nop
    nop
    nop


    sw   $t6, 0($t3)
    nop
    nop
    nop
    sw   $t5, 0($t4)
    nop
    nop
    nop
    
no_swap:
    addi $t0, $t0, 1
    j    outer_loop
    nop
    nop
    nop
    nop

end:
    j end
    nop
    nop
    nop
    nop
