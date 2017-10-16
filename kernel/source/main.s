.section .init
.globl _start
_start:

b main

.section .text
main:
mov sp,#0x8000

//set Function of ACT LED (pin 47, function 1 (out))

pinNum .req r0
pinFunc .req r1
mov pinNum,#47
mov pinFunc,#1
bl SetGpioFunction
.unreq pinFunc
.unreq pinNum

//do stuff

ldr r0,=0x80000
bl initPowersOfThree

//first 6 hexdigits of 3^255 are given out in decimal blinks.
ldr r0,=0x83FF0	//should be 1175984
ldr r0,[r0]
bl BlinkSingleRegister



//turn off LED at the end

pinNum .req r0
pinVal .req r1
mov pinNum,#47
mov pinVal,#1
bl SetGpio
.unreq pinNum
.unreq pinVal

//infinite Loop
infloop:
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
