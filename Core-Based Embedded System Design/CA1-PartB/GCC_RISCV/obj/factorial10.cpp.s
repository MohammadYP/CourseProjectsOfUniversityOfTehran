	.file	"factorial10.cpp"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text.main,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	addi	sp,sp,-48
	.cfi_def_cfa_offset 48
	sw	ra,44(sp)
	sw	s0,40(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,48
	.cfi_def_cfa 8, 0
	li	a1,10
	sw	a1,-36(s0)
	li	a0,1
	li	a1,0
	sw	a0,-32(s0)
	sw	a1,-28(s0)
	li	a1,1
	sw	a1,-20(s0)
	j	.L2
.L3:
	lw	a1,-20(s0)
	mv	a4,a1
	srai	a1,a1,31
	mv	a5,a1
	lw	a1,-28(s0)
	mul	a0,a1,a4
	lw	a1,-32(s0)
	mul	a1,a1,a5
	add	a0,a0,a1
	lw	a1,-32(s0)
	mul	a6,a1,a4
	mulhu	a3,a1,a4
	mv	a2,a6
	add	a1,a0,a3
	mv	a3,a1
	sw	a2,-32(s0)
	sw	a3,-28(s0)
	sw	a2,-32(s0)
	sw	a3,-28(s0)
	lw	a1,-20(s0)
	addi	a1,a1,1
	sw	a1,-20(s0)
.L2:
	lw	a0,-20(s0)
	lw	a1,-36(s0)
	ble	a0,a1,.L3
	li	a5,0
	mv	a0,a5
	lw	ra,44(sp)
	.cfi_restore 1
	lw	s0,40(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 48
	addi	sp,sp,48
	.cfi_def_cfa_offset 0
	jr	ra
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.ident	"GCC: () 14.2.0"
	.section	.note.GNU-stack,"",@progbits
