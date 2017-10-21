.globl IntDiv
IntDiv:
	//uses registers 0-6

	push {r4,r5,r6}
	
	//r2 and r3 input, r0 = r2/r3, r1 = r2%r3
	//this only divides unsigned integers

	//can't divide by zero
	cmp r3,#0
	moveq pc,lr

	result .req r0
	remainder .req r1
	dividend .req r2
	divisor .req r3

	shift .req r4

	lzdividend .req r5
	lzdivisor .req r6

	mov result,#0 //this is important!!

	//count leading zeroes of both
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

	//part two:

	mov remainder,dividend

	subtract:

		//subtract divisor from dividend if dividend is bigger
		cmp divisor,remainder
		bhi skip2
			sub remainder,remainder,divisor
			add result,#1
		skip2:

		// if no shift left, end
		cmp shift,#0
		beq end

		//otherwise left shift result by one, right shift divisor by one, decrease shift by one and repeat
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
