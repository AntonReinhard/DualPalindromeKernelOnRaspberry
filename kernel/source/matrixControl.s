.globl SlideNumber
//r0 is the input Number
//r1 is the duration of each tick in milliseconds
SlideNumber:
	push {lr}
	
	push {r4} //get one more register free

	duration .req r4
	mov duration,r1
	
	//r0 is number to output
	Number .req r2
	mov Number,r0
	DigitCount .req r0
	mov DigitCount,#0
	Digit .req r1

	
	//base is defined here
	base .req r3
	mov base,#10
	
	mov digit,#11			//eleventh symbol is the "empty" we want that before and after the slide
	push {digit}
	
	cumulateDigits:
		
		add DigitCount,#1

		push {DigitCount, base}

		bl IntDiv

		mov number,r0
		
		pop {DigitCount, base}

		push {Digit}

		//jump back, while Number is not zero
		cmp Number,#0
		bne cumulateDigits

		
	mov Digit,#11 	//another nothing at the end
	add DigitCount,#1	//we have one more not two because one of them is popped immediately
	push {Digit}
	.unreq DigitCount
	.unreq base
	.unreq Number
	DigitCount .req r3
	mov DigitCount,r0
	
	digitOne .req r0
	digitTwo .req r1
	
	pop {digitTwo} //first digit here
	
	displayDigits:
		
		//get the new digit and move the old to the left
		mov digitOne,digitTwo
		pop {digitTwo}
		
		mov r2,duration
		
		push {DigitCount,digitTwo}
		
		bl SlideLeft
		
		pop {DigitCount,digitTwo}
		
		sub DigitCount,#1
		cmp DigitCount,#0
		bne displayDigits		
	
	pop {r4} //get the register back
	
	pop {pc}

.globl DisplayDoubleRegister
//r0 is first register (upper half of the matrix)
//r1 is second register (lower half of the matrix)
//r2 is duration of showing in milliseconds

DisplayDoubleRegister:
	push {lr}
	
	//need more registers ->
	push {r4,r5}
	
	DispLo .req r0	//upper half
	DispHi .req r1	//lower half
	//since these are the negative Pins, they have to be pulled low for the LED to be on, so negate everything
	ldr r3,=0xFFFFFFFF	//all ones
	eor DispLo,DispLo,r3	//essentially negating every bit
	eor DispHi,DispHi,r3
	
	Duration .req r2
	lsr Duration,#3	//divide duration by 8 since we are waiting 1 millisecond per row being displayed, so it takes 8 milliseconds per whole matrix
	
	TimedLoop:
		push {Duration} //make space while we don't need duration saved
		.unreq Duration
		//this from here should take (roughly) 8 milliseconds
		Index .req r2
		mov Index,#4
		
		LoPosPins .req r5				//the Pinnumbers of the upper half: highest byte is row 4, second highest byte is row 3, ..., lowest byte is row 1
		ldr LoPosPins,=0x100E110F		//highest byte is 16 (fourth row), after that 14 (third row), after that 17 (second row) and last is 15 (first row)
		
		RegisterZeroLoop:	
			sub Index,#1
			
			Shift .req r4
			mov r3,#255 		//make 8 1s
			lsl Shift,Index,#3	//multiply index by 8, that's what we need to shift
			lsl r3,r3,Shift		//now shift the 1s by that amount
			and r3,DispLo,r3		//"and" on the data
			lsr r3,r3,Shift		//shift back, we have one Byte in r3 now, highest Bit is GPIO 7, second highest 2, ... see the png for all of them
			.unreq Shift
			
			Data .req r4
			mov Data,r3
			
			pinNum .req r0
			pinVal .req r1
			
			push {r0,r1,r2,r3}
			
			//loops here are only possible with a lot of additional effort so I'm just doing it sequentially
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#9			//pin Numbers come from the wiring
			bl SetGpio
	
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#8			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#6			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#4			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#5			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#3			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#2			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#7			//pin Numbers come from the wiring
			bl SetGpio

			//these were the column pins, now the right row has to be turned on
			
			and pinNum,LoPosPins,#255	//last byte of LoPosPins is the current pinNumber of the Row
			push {pinNum}				//need this later and it's changed in SetGpio
			lsr LoPosPins,#8				//need the next byte next time
			mov pinVal,#1				//should be pulled highest
			bl SetGpio
				
			//while we are at it and the registers are free, let's wait one millisecond.
			ldr r0,=0x3E8
			bl WaitMicroSec
	
			//turn off the LEDs again
			pop {pinNum}
			mov pinVal,#0
			bl SetGpio
			
			.unreq pinNum
			.unreq pinVal
			.unreq Data
	
			pop {r0,r1,r2,r3}
			
			cmp Index,#0
			bne RegisterZeroLoop
		
		.unreq LoPosPins
		.unreq Index
		
		//now the same for register one
		Index .req r2
		mov Index,#4
		
		HiPosPins .req r5				//the Pinnumbers of the lower half: highest byte is row 8, second highest byte is row 7, ..., lowest byte is row 5
		ldr HiPosPins,=0x0C0B0D0A		//highest byte is 12 (fourth row), after that 11 (third row), after that 13 (second row) and last is 10 (first row)
		
		RegisterOneLoop:	
			sub Index,#1
			
			Shift .req r4
			mov r3,#255 		//make 8 1s
			lsl Shift,Index,#3	//multiply index by 8, that's what we need to shift
			lsl r3,r3,Shift		//now shift the 1s by that amount
			and r3,DispHi,r3		//"and" on the data
			lsr r3,r3,Shift		//shift back, we have one Byte in r3 now, highest Bit is GPIO 7, second highest 2, ... see the png for all of them
			.unreq Shift
			
			Data .req r4
			mov Data,r3
			
			pinNum .req r0
			pinVal .req r1
			
			push {r0,r1,r2,r3}
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#9			//pin Numbers come from the wiring
			bl SetGpio
	
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#8			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#6			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#4			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#5			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#3			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#2			//pin Numbers come from the wiring
			bl SetGpio
			
			and pinVal,Data,#1		//last bit of data in r4
			lsr Data,#1				//right shift by 1
			mov pinNum,#7			//pin Numbers come from the wiring
			bl SetGpio

			//these were the column pins, now the right row has to be turned on
			
			and pinNum,HiPosPins,#255	//last byte of HiPosPins is the current pinNumber of the Row
			push {pinNum}				//need this later and it's changed in SetGpio
			lsr HiPosPins,#8				//need the next byte next time
			mov pinVal,#1				//should be pulled high
			bl SetGpio
				
			//while we are at it and the registers are free, let's wait one millisecond.
			ldr r0,=0x3E8
			bl WaitMicroSec
	
			//turn off the LEDs again
			pop {pinNum}
			mov pinVal,#0
			bl SetGpio
			
			.unreq pinNum
			.unreq pinVal
			.unreq Data
	
			pop {r0,r1,r2,r3}
			
			cmp Index,#0
			bne RegisterOneLoop
		
		.unreq HiPosPins
		.unreq Index
		
		Duration .req r2
		pop {Duration}
		sub Duration,#1
		cmp Duration,#0
		bne TimedLoop
	
	pop {r4,r5}
	
	bl TurnOffMatrix
	
	pop {pc}

.globl SlideLeft
//r0 is first digit, that's displayed first and then leaving the display to the left
//r1 is the second digit, that's almost in the center at the end and entering the display from the right
//r2 is the duration of each step. There are 8 steps so the total duration is 8 times that
SlideLeft:
	push {lr}
	
	//r0 and r1 have to be digits -> (10 is the smiley and 11 is empty)
	cmp r0,#11
	pophi {pc}
	cmp r1,#11
	pophi {pc}
	
	push {r4,r5,r6,r7,r8,r9,r10}	//more space
	
	//we can use r0 to r10 now = 11 registers
	
	digit1 .req r0
	digit2 .req r1
	duration .req r2
	digitOneLo .req r4
	digitOneHi .req r5
	digitTwoLo .req r6
	digitTwoHi .req r7
	maskOne .req r8
	maskTwo .req r9
	
	//mask one is what is visible from the first digit, so in the beginning its
	//11111111 -
	//11111111 -
	//11111111 -
	//11111111
	//after the first display it's
	//11111110 -
	//11111110 -
	//11111110 -
	//11111110
	//and so on. At the same time the pattern has to be left shifted one every step so the digit is going to the left
	//mask two is the opposite. For it the pattern has to be right shifted the opposite amount.
	
	//loading the data into r6-r9
	lsl digit1,#3
	lsl digit2,#3
	ldr r3,=matrixzero0
	add digit1,r3
	add digit2,r3
	ldr digitOneLo,[digit1]
	ldr digitTwoLo,[digit2]
	add digit1,#4
	add digit2,#4
	ldr digitOneHi,[digit1]
	ldr digitTwoHi,[digit2]
	
	.unreq digit1
	.unreq digit2
	inputLo .req r0
	inputHi .req r1
	
	//init the masks:
	ldr maskOne,=0xFFFFFFFF
	mov maskTwo,#0
	
	index .req r3
	mov index,#0
	looping:
		
		//the second digit first since it has to be shifted everytime
		mov inputLo,digitTwoLo
		
		mov r10,#8			//have 8
		sub r10,r10,index	//subtract index from it -> the amount digit two needs to be shifted right
		lsr inputLo,r10		//shift input that much right
		and inputLo,maskTwo	//now the mask on to it -> second digit is done
		//now first digit to it
		and digitOneLo,maskOne	//mask the thing
		add inputLo,digitOneLo	//add it to the second digit that's already there
		
		//now the same for the Hi part
		
		mov inputHi,digitTwoHi
		
		//r10 is still right
		lsr inputHi,r10		//shift input that much right
		and inputHi,maskTwo	//now the mask on to it -> second digit is done
		//now first digit to it
		and digitOneHi,maskOne	//mask the thing
		add inputHi,digitOneHi	//add it to the second digit that's already there
		
		push {r2,r3} //save r2 and r3

		bl DisplayDoubleRegister
		
		pop {r2,r3}
		
		//now update masks and shift the digits
		
		lsl maskTwo,#1
		ldr r10,=0x01010101
		add maskTwo,r10
		ldr r10,=0xFFFFFFFF
		eor maskOne,maskTwo,r10
		
		//push {r0,r1,r2,r3}
		
		//mov r0,maskOne
		//mov r1,maskTwo
		//bl DisplayDoubleRegister
		
		//pop {r0,r1,r2,r3}
		
		//digit two is always shifted, digit one has to be done here
		lsl digitOneLo,#1
		lsl digitOneHi,#1
		
		add index,#1
		cmp index,#8
		bne looping
		
		
	.unreq index
	.unreq maskOne
	.unreq maskTwo
	.unreq digitOneHi
	.unreq digitOneLo
	.unreq digitTwoHi
	.unreq digitTwoLo
	.unreq inputHi
	.unreq inputLo
	
	pop {r4,r5,r6,r7,r8,r9,r10}		//get the registers back from before the function
	
	pop {pc}
	
.globl MatrixDigit
//r0 is digit
MatrixDigit:
	push {lr}

	//sort out, if r0 is really a digit (10 is the smiley :) )
	cmp r0,#10
	pophi {pc}	//just return if not

	digit .req r2
	mov digit,r0
	
	//load the pattern
	ptrn0 .req r0
	ptrn1 .req r1
	
	//calculate address:
	lsl digit,#3	//times 8
	ldr r3,=matrixzero0
	add digit,r3	//matrixzero0 is the base address
	ldr ptrn0,[digit]
	add digit,#4
	ldr ptrn1,[digit]
	
	.unreq digit
	duration .req r2
	mov duration,#1000
	
	bl DisplayDoubleRegister

	.unreq ptrn0
	.unreq ptrn1
	.unreq duration
	
	pop {pc}	
	
.globl InitMatrix
//no input/no output, just initializing
InitMatrix:
	push {lr}

	pinNum .req r0
	pinFunc .req r1
	index .req r2
		
	mov index,#2
		
	//set Functions of GPIOs 2 to 17
	forloop:
		mov pinNum,index
		mov pinFunc,#1
		push {index}
		bl SetGpioFunction
		pop {index}
		
		add index,#1
		cmp index,#18
		bne forloop
		
	.unreq pinNum
	.unreq pinFunc
	
	bl TurnOffMatrix
	
	pop {pc}
	
.globl TurnOffMatrix
TurnOffMatrix:
	push {lr}

	//negative (all high so they are off)
	pinNum .req r0
	pinVal .req r1
	mov pinNum,#2
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#3
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#4
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#5
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#6
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#7
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#8
	mov pinVal,#1
	bl SetGpio
	mov pinNum,#9
	mov pinVal,#1
	bl SetGpio

	//positive (all low so they are off)
	mov pinNum,#10
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#11
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#12
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#13
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#14
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#15
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#16
	mov pinVal,#0
	bl SetGpio
	mov pinNum,#17
	mov pinVal,#0
	bl SetGpio

	.unreq pinNum
	.unreq pinVal

	pop {pc}
	