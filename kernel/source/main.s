.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000

@set Function of ACT LED (pin 47, function 1 (out))

pinNum .req r0
pinFunc .req r1
mov pinNum,#47
mov pinFunc,#1
bl SetGpioFunction
.unreq pinFunc
.unreq pinNum

@initialize the pins for operation of the LED Matrix
bl InitMatrix

/*ldr r0,=0x80000
bl initPowersOfThree

@first 6 hexdigits of 3^255 are given out in decimal blinks.
ldr r0,=0x83FF0	@should be 1175984
ldr r0,[r0]
mov r1,#75
bl SlideNumber
*/

ldr r4,=0x100000
ldr r5,=0x100004
mov r1,#5
str	r1,[r4]
mov r1,#0
str r1,[r5]

Infiniteloop:
	mov r1,#50 @duration
	ldr r0,[r4] @load number
	bl SlideNumber

	mov r1, #50 @duration
	ldr r0,[r5] @load next 32 bit of number
	bl SlideNumber

@leftshift by one
	mov r0,r4 @target number address
	mov r1,#3 @leftshift amount
	mov r2,r4 @output address
	bl LSL16Reg

b Infiniteloop

@turn off LED at the end

pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal

@infinite Loop
infloop:

	ldr r0,=0x539	@number
	mov r1,#50		@duration
	bl SlideNumber

	ldr r0,=0x2A	@number
	mov r1,#50		@duration
	bl SlideNumber

b infloop

.section .data
.align 2
pattern:
.int 0b11111111101010100010001000101010

.globl blinkzero
blinkzero:
.int 0b11110000001111111111111111111111
blinkone:
.int 0b11110000001111011111111111111111
blinktwo:
.int 0b11110000001111010111111111111111
blinkthree:
.int 0b11110000001111010101111111111111
blinkfour:
.int 0b11110000001111010101011111111111
blinkfive:
.int 0b11110000001111010101010111111111
blinksix:
.int 0b11110000001111010101010101111111
blinkseven:
.int 0b11110000001111010101010101011111
blinkeight:
.int 0b11110000001111010101010101010111
blinknine:
.int 0b11110000001111010101010101010101
.globl matrixzero0
matrixzero0:
.int 0b00000000011111001100011011001110
matrixzero1:
.int 0b11011110111101101110011001111100
matrixone0:
.int 0b00000000000110000011100000011000
matrixone1:
.int 0b00011000000110000001100001111110
matrixtwo0:
.int 0b00000000001111000110011000000110
matrixtwo1:
.int 0b00011100001100000110011001111110
matrixthree0:
.int 0b00000000001111000110011000000110
matrixthree1:
.int 0b00011100000001100110011000111100
matrixfour0:
.int 0b00000000000111000011110001101100
matrixfour1:
.int 0b11001100111111100000110000011110
matrixfive0:
.int 0b00000000011111100110000001111100
matrixfive1:
.int 0b00000110000001100110011000111100
matrixsix0:
.int 0b00000000000111000011000001100000
matrixsix1:
.int 0b01111100011001100110011000111100
matrixseven0:
.int 0b00000000011111100110011000000110
matrixseven1:
.int 0b00001100000110000001100000011000
matrixeight0:
.int 0b00000000001111000110011001100110
matrixeight1:
.int 0b00111100011001100110011000111100
matrixnine0:
.int 0b00000000001111000110011001100110
matrixnine1:
.int 0b00111110000001100000110000111000
matrixsmile0:
.int 0b01111110100000011010010110000001
matrixsmile1:
.int 0b10111101100110011000000101111110
.globl nothing
nothing:
.int 0b00000000000000000000000000000000
.int 0b00000000000000000000000000000000
