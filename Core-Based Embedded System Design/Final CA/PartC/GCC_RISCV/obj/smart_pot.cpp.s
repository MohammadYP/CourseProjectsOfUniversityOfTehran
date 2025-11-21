	.file	"smart_pot.cpp"
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
	addi	sp,sp,-16
	.cfi_def_cfa_offset 16
	sw	ra,12(sp)
	sw	s0,8(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,16
	.cfi_def_cfa 8, 0
	nop
	lw	ra,12(sp)
	.cfi_restore 1
	lw	s0,8(sp)
	.cfi_restore 8
	.cfi_def_cfa 2, 16
	addi	sp,sp,16
	.cfi_def_cfa_offset 0
	mret
	.cfi_endproc
.LFE1:
	.size	_Z33m_mode_external_interrupt_handlerv, .-_Z33m_mode_external_interrupt_handlerv
	.section	.text._Z34calculate_pump_duration_ms_integerll,"ax",@progbits
	.align	2
	.globl	_Z34calculate_pump_duration_ms_integerll
	.type	_Z34calculate_pump_duration_ms_integerll, @function
_Z34calculate_pump_duration_ms_integerll:
.LFB2:
	.cfi_startproc
	addi	sp,sp,-48
	.cfi_def_cfa_offset 48
	sw	ra,44(sp)
	sw	s0,40(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,48
	.cfi_def_cfa 8, 0
	sw	a0,-36(s0)
	sw	a1,-40(s0)
	lw	a4,-36(s0)
	li	a5,59
	ble	a4,a5,.L3
	li	a5,0
	j	.L4
.L3:
	li	a4,60
	lw	a5,-36(s0)
	sub	a5,a4,a5
	slli	a5,a5,10
	li	a4,-2004316160
	addi	a4,a4,-1911
	mulh	a4,a5,a4
	add	a4,a4,a5
	srai	a4,a4,5
	srai	a5,a5,31
	sub	a5,a4,a5
	sw	a5,-24(s0)
	lw	a5,-40(s0)
	addi	a4,a5,-25
	mv	a5,a4
	slli	a5,a5,1
	add	a5,a5,a4
	slli	a4,a5,4
	add	a5,a5,a4
	addi	a5,a5,1024
	sw	a5,-20(s0)
	lw	a5,-20(s0)
	bge	a5,zero,.L5
	sw	zero,-20(s0)
.L5:
	lw	a4,-24(s0)
	mv	a5,a4
	slli	a5,a5,2
	add	a5,a5,a4
	slli	a5,a5,2
	sw	a5,-28(s0)
	lw	a4,-28(s0)
	lw	a5,-20(s0)
	mul	a5,a4,a5
	srai	a5,a5,10
	sw	a5,-28(s0)
	lw	a5,-28(s0)
	srai	a5,a5,10
	sw	a5,-28(s0)
	lw	a5,-28(s0)
.L4:
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
.LFE2:
	.size	_Z34calculate_pump_duration_ms_integerll, .-_Z34calculate_pump_duration_ms_integerll
	.section	.text.main,"ax",@progbits
	.align	2
	.globl	main
	.type	main, @function
main:
.LFB3:
	.cfi_startproc
	addi	sp,sp,-48
	.cfi_def_cfa_offset 48
	sw	ra,44(sp)
	sw	s0,40(sp)
	.cfi_offset 1, -4
	.cfi_offset 8, -8
	addi	s0,sp,48
	.cfi_def_cfa 8, 0
	li	a5,8
 #APP
# 58 "smart_pot.cpp" 1
	csrs mstatus, a5
# 0 "" 2
 #NO_APP
	li	a5,4096
	addi	a5,a5,-2048
 #APP
# 59 "smart_pot.cpp" 1
	csrs mie, a5
# 0 "" 2
 #NO_APP
	lui	a5,%hi(_Z33m_mode_external_interrupt_handlerv)
	addi	a5,a5,%lo(_Z33m_mode_external_interrupt_handlerv)
	sw	a5,-20(s0)
	lw	a5,-20(s0)
 #APP
# 62 "smart_pot.cpp" 1
	csrw mtvec, a5
# 0 "" 2
 #NO_APP
.L11:
	li	a5,-4096
	li	a4,400
	sw	a4,0(a5)
	nop
.L7:
	li	a5,-4096
	addi	a5,a5,4
	lw	a5,0(a5)
	addi	a5,a5,-1
	snez	a5,a5
	andi	a5,a5,0xff
	bne	a5,zero,.L7
	li	a5,-248
	lw	a5,0(a5)
	sw	a5,-24(s0)
	li	a5,-252
	lw	a5,0(a5)
	sw	a5,-28(s0)
	li	a5,-65536
	lw	a5,0(a5)
	sw	a5,-32(s0)
	lw	a4,-32(s0)
	li	a5,9
	bleu	a4,a5,.L11
	lw	a4,-32(s0)
	li	a5,19
	bleu	a4,a5,.L11
	lw	a5,-28(s0)
	lw	a4,-24(s0)
	mv	a1,a4
	mv	a0,a5
	call	_Z34calculate_pump_duration_ms_integerll
	sw	a0,-36(s0)
	lw	a5,-36(s0)
	beq	a5,zero,.L9
	li	a5,-4096
	lw	a4,-36(s0)
	sw	a4,0(a5)
	li	a5,-61440
	addi	a5,a5,-256
	li	a4,1
	sw	a4,0(a5)
	nop
.L10:
	li	a5,-4096
	addi	a5,a5,4
	lw	a5,0(a5)
	addi	a5,a5,-1
	snez	a5,a5
	andi	a5,a5,0xff
	bne	a5,zero,.L10
	li	a5,-61440
	addi	a5,a5,-256
	sw	zero,0(a5)
.L9:
	li	a5,-983040
	lw	a4,-36(s0)
	sw	a4,0(a5)
	li	a5,-983040
	addi	a5,a5,4
	li	a4,1
	sw	a4,0(a5)
	j	.L11
	.cfi_endproc
.LFE3:
	.size	main, .-main
	.ident	"GCC: () 14.2.0"
	.section	.note.GNU-stack,"",@progbits
