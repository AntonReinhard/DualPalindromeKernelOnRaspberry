
mov r2,#5
mov r3,#7

bl IntDiv

push {r1}

bl BlinkDigit //should blink 0 times

pop {r0}

bl BlinkDigit //should blink 5 times

mov r2,#4
mov r3,#4

bl IntDiv

push {r1}

bl BlinkDigit //should blink 1 time

pop {r0}

bl BlinkDigit //should blink 0 times
