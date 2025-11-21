	.file	"factorial_gpio.cpp"
	.option nopic
	.attribute arch, "rv32i2p1_m2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 16
	.text
	.section	.text._Z33m_mode_external_interrupt_handlerv,"ax",@progbits
	.align	2
	.globl	_Z33m_mode_external_interrupt_handlerv
	.type	_Z33m_mode_external_interrupt_handlerv, @function
_Z33m_mode_external_interrupt_handlerv:
.LFB1:
	.cfi_startproc
	addi	sp,sp,-48
	.cfi_def_cfa_offset 48
	sw	ra,44(sp)
	sw	s0,40(sp)
	sw	a4,36(sp)
	sw	a5,32(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	.cfi_offset 14, -12
	.cfi_offset 15, -16
	addi	s0,sp,48
	.cfi_def_cfa 8, 0
	li	a5,16777216
	addi	a5,a5,8
	sw	zero,0(a5)
	li	a5,16777216
	lw	a5,0(a5)
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	sw	a5,-32(s0)
	li	a5,1048576
	sw	a5,-36(s0)
	li	a5,1
	sw	a5,-20(s0)
	li	a5,1
	sw	a5,-24(s0)
	j	.L2
.L3:
	lw	a4,-20(s0)
	lw	a5,-24(s0)
	mul	a5,a4,a5
	sw	a5,-20(s0)
	lw	a5,-24(s0)
	addi	a5,a5,1
	sw	a5,-24(s0)
.L2:
	lw	a4,-24(s0)
	lw	a5,-32(s0)
	bleu	a4,a5,.L3
	lw	a5,-36(s0)
	lw	a4,-20(s0)
	sw	a4,0(a5)
	li	a5,16777216
	addi	a5,a5,4
	lw	a4,-20(s0)
	sw	a4,0(a5)
	li	a5,16777216
	addi	a5,a5,8
	li	a4,1
	sw	a4,0(a5)
	nop
	lw	ra,44(sp)
	.cfi_restore 1
	lw	s0,40(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 48
	lw	a4,36(sp)
	.cfi_restore 14
	lw	a5,32(sp)
	.cfi_restore 15
	addi	sp,sp,48
	.cfi_def_cfa_offset 0
	mret
	.cfi_endproc
.LFE1:
	.size	_Z33m_mode_external_interrupt_handlerv, .-_Z33m_mode_external_interrupt_handlerv
	.section	.text.main,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	addi	sp,sp,-32
	.cfi_def_cfa_offset 32
	sw	ra,28(sp)
	sw	s0,24(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,32
	.cfi_def_cfa 8, 0
	li	a5,8
 #APP
# 32 "factorial_gpio.cpp" 1
	csrs mstatus, a5
# 0 "" 2
 #NO_APP
	li	a5,4096
	addi	a5,a5,-2048
 #APP
# 33 "factorial_gpio.cpp" 1
	csrs mie, a5
# 0 "" 2
 #NO_APP
	lui	a5,%hi(_Z33m_mode_external_interrupt_handlerv)
	addi	a5,a5,%lo(_Z33m_mode_external_interrupt_handlerv)
	sw	a5,-20(s0)
	lw	a5,-20(s0)
 #APP
# 37 "factorial_gpio.cpp" 1
	csrw mtvec, a5
# 0 "" 2
 #NO_APP
	li	a5,16777216
	addi	a5,a5,8
	li	a4,1
	sw	a4,0(a5)
.L5:
	nop
	j	.L5
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: () 14.2.0"
	.section	.note.GNU-stack,"",@progbits
