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

.globl Div8Reg
@r0 is adress of first 4Bytes of the divisor (total 64 Bytes)
@r1 is the dividend (just 4Bytes)
@r2 is adress of output (total 64 Bytes)
@Output will be: the result is in the adress in r2, the remainder is in r0
Div8Reg:
	push {lr}

	@can't divide by zero
	cmp r1,#0
	moveq pc,lr

	push {r4,r5,r6,r7,r8,r9} @space

	currentInputAddress .req r0
	currentDivisor .req r3
	dividend .req r1
	currentResultAddress .req r2
	currentResult .req r4
	bitIndex .req r5 @which bit is processed right now from 0 to 31
	regIndex .req r6 @which register is processed right now from 15 to 0

	

	pop {r4,r5,r6,r7,r8,r9} @get it back

	pop {pc}

.globl LSL8Reg
@r0 is adress of target number
@r1 i
LSL8Reg:
