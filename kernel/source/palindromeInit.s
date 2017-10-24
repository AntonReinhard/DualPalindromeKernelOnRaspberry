.globl initPowersOfThree
initPowersOfThree:
	push {lr}

	@this procedure writes the consecutive powers of three up to 3^255 into the memory
	@r0 is the starting address for the powers of three.
	@each number is stored in 512 Bit long words in little endian, so the least significant 4 bytes come first.
	@everything is unsigned

	currentAdress .req r0
	carry .req r1
	currentNumber .req r2
	index .req r3

	@put 3^0 in the first adress
	mov currentNumber,#1
	stm currentAdress,{currentNumber}
	add currentAdress,currentAdress,#4
	mov index,#15
	putZeroes:
		mov currentNumber,#0
		stm currentAdress,{currentNumber}
		add currentAdress,currentAdress,#4
		sub index,index,#1
		cmp index,#0
		bne putZeroes

	mov index,#255	@3^0 is ready, 255 to go

	bigloop:		@bigloop means the 255 multiplications of 512 bit integers by three in total

		sub index,index,#1
		push {index}

		mov index,#16		@this is the index for the smallloop, I had no better solution ;)
		mov carry,#0			@incoming carry is always zero

		smallloop:	@smallloop means the 16 register carried multiplication by three
			sub index,index,#1
			push {index}							@we need more spaaaaace! 4 registers really isn't much

			@r3 is the new carry, since we need to add the carry after we multiplied the number by 3
			mov r3,#0

			sub currentAdress,currentAdress,#64	@go 64 bytes back to get last number
			ldr currentNumber,[currentAdress]
			push {currentAdress}	@I need the register, we get it back in a moment

			@calculate currentNumber * 3 and save the carry
			mov r0,currentNumber			@save currentNumber since it's overwritten in the next step
			adds currentNumber,currentNumber,currentNumber	@double the number
			adc r3,r3,#0				@add 1 to carry if carry flag is set
			adds currentNumber,r0,currentNumber			@add the saved currentNumber again
			adc r3,r3,#0				@add 1 to carry again if carry flag is set
			adds currentNumber,carry,currentNumber
			adc r3,r3,#0
			mov carry,r3 				@now get the new carry back into the carry for the next



			pop {currentAdress}		@get adress back
			add currentAdress,currentAdress,#64	@add the 64 back on
			stm currentAdress,{currentNumber}		@store at this adress
			add currentAdress,currentAdress,#4		@add 4 so we get to the next part of this number

			pop {index}
			cmp index,#0
			bne smallloop

		pop {index}

		cmp index,#0
		bne bigloop

	pop {pc}
