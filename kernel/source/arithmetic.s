.globl IntDiv
@r2 and r3 input, r0 = r2/r3, r1 = r2%r3
@this only divides unsigned integers
IntDiv:

	@can't divide by zero
	cmp r3,#0
	moveq pc,lr

	push {r4,r5,r6}

	result .req r0
	remainder .req r1
	dividend .req r2
	divisor .req r3

	shift .req r4

	lzdividend .req r5
	lzdivisor .req r6

	mov result,#0 @this is important!!

	@count leading zeroes of both
	clz lzdividend,dividend
	clz lzdivisor,divisor

	mov shift,#0
	cmp lzdividend,lzdivisor
	bhi skip
		sub shift,lzdivisor,lzdividend
		lsl divisor,divisor,shift
	skip:

	.unreq lzdividend
	.unreq lzdivisor

	@part two:

	mov remainder,dividend

	subtract:

		@subtract divisor from dividend if dividend is bigger
		cmp divisor,remainder
		bhi skip2
			sub remainder,remainder,divisor
			add result,#1
		skip2:

		@ if no shift left, end
		cmp shift,#0
		beq end

		@otherwise left shift result by one, right shift divisor by one, decrease shift by one and repeat
		lsl result,#1
		lsr divisor,#1
		sub shift,#1

		b subtract

	end:

	.unreq result
	.unreq remainder
	.unreq dividend
	.unreq divisor
	.unreq shift

	pop {r4,r5,r6}

	mov pc,lr

.globl Div16Reg
@r0 is adress of first 4Bytes of the divisor (total 64 Bytes)
@r1 is the dividend (just 4Bytes)
@r2 is adress of output (total 64 Bytes)
@Output will be: the result is in the adress in r2, the remainder is in r0
Div16Reg:	@WIP
	push {lr}

	@can't divide by zero
	cmp r1,#0
	moveq pc,lr

	push {r4,r5,r6} @space

	currentInputAddress .req r0
	dividend .req r1
	currentResultAddress .req r2
	currentDivisor .req r3
	currentResult .req r4
	bitIndex .req r5 @which bit is processed right now from 0 to 31
	regIndex .req r6 @which register is processed right now from 15 to 0



	pop {r4,r5,r6} @get it back

	.unreq currentInputAddress
	.unreq dividend
	.unreq currentResultAddress
	.unreq currentDivisor
	.unreq currentResult
	.unreq bitIndex
	.unreq regIndex

	pop {pc}

.globl LSL16Reg
@r0 is address of target number
@r1 how many bits are leftshifted (maximum 32)
@r2 target address for the result
LSL16Reg:
	push {lr}

	push {r4,r5,r6,r7} @space

	currentaddress .req r0
	shift .req r1
	currenttargetaddress .req r2
	index .req r3
	currentregister .req r4
	carry .req r5
	safe .req r6
	inverseshift .req r7

	rsb inverseshift, shift, #32		@reverse subtract, inverseshift = 32 - shift

	mov index, #1
	mov carry, #0

	loop:
		ldr currentregister, [currentaddress]
		mov safe, currentregister

		lsl currentregister, currentregister, shift
		add currentregister, carry	@there can be no carry from this operation

		@calculate new carry

		str currentregister, [currenttargetaddress]

		lsr carry, safe, inverseshift

		add currenttargetaddress, #4	@4 Byte = 32 Bit = 1 Register
		add currentaddress, #4
		add index, #1
		cmp index, #16
		bne loop			@branch back, while we're not at 16 registers yet

	pop {r4,r5,r6,r7} @get the variables back

	.unreq currentaddress
	.unreq shift
	.unreq currenttargetaddress
	.unreq index
	.unreq currentregister
	.unreq carry
	.unreq safe
	.unreq inverseshift

	pop {pc}
