.globl BlinkDigit
//r0 is digit to blink
BlinkDigit:
	push {lr}

	//sort out, if r0 is really a digit
	cmp r0,#9
	pophi {pc}

	digit .req r0

	//load the pattern
	ptrn .req r2
	ldr ptrn,=blinkzero
	//add 4 times the digit to the address of the first pattern so that the address is the correct one for the pattern we want
	add ptrn,digit,lsl #2
	ldr ptrn,[ptrn]
	//don't need the digit anymore
	.unreq digit
	seq .req r3
	mov seq,#31


	loop:

		//get the pin state for the next blink or not blink into r1
		mov r1,#1
		lsl r1,seq
		and r1,ptrn

		//save pattern and sequence ->
		push {ptrn,seq}

		//set pin
		mov r0,#47
		bl SetGpio

		//wait 0.25 sec

		ldr r0,=250000
		bl WaitMicroSec

		//get pattern and sequence back
		pop {ptrn,seq}

		//subtract 1 to seq, if it's 0 break out

		cmp seq,#0
		beq end
		sub seq,#1

	//as long as seq is not zero keep going
	b loop

	end:

	.unreq ptrn
	.unreq seq

	pop {pc}

.globl BlinkSingleRegister
BlinkSingleRegister:
	//uses register 0-6
	//displays numbers digit by digit in base 10

	push {lr}

	//r0 is number to blink
	Number .req r2
	mov Number,r0
	DigitCount .req r0
	mov DigitCount,#0
	Digit .req r1
	
	//base is defined here
	base .req r3
	mov base,#10
	
	cumulateDigits:
		
		add DigitCount,#1

		//this is for octal number system
		//Digit = number % 8
		//and Digit,Number,#7
		//push {Digit}
		//number = number / 8
		//lsr Number,Number,#3
		
		//number in r2 is dividend
		//base is in r3 as divisor

		//Digit (r1) is gonna be remainder, r0 result

		push {DigitCount, base}

		bl IntDiv

		mov number,r0
		
		pop {DigitCount, base}

		push {Digit}

		//jump back, while Number is not zero
		cmp Number,#0
		bne cumulateDigits

	//DigitCount can't be in r0, need that for BlinkDigit
	.unreq DigitCount
	mov r2,r0
	DigitCount .req r2

	blinkDigits:
		pop {r0}

		push {DigitCount}

		bl BlinkDigit

		pop {DigitCount}

		sub DigitCount,#1
		cmp DigitCount,#0
		bne blinkDigits

	.unreq Number
	.unreq DigitCount
	.unreq Digit
	.unreq base

	pop {pc}
