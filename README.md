# DualPalindromeKernelOnRaspberry
This is a repository where I keep my kernels for the RaspberryPi Zero W. Eventually I want it to be able to run 24/7 and calculate more numbers of the series http://oeis.org/A060792

See http://chesswanks.com/txt/BigDualPalindromes.txt for how I want to do this roughly.

To try one of these kernels on your own RPi Zero (W) take a Micro SD card, copy the bootcode.bin and start.elf files in the firmware folder on it and the kernel you want to try. The kernel must be named kernel.img on the SD card for it to work. 
If you have an OS installed on your SD card and want to keep it then only copy the kernel.img in the root directory of the SD card. Make sure to rename the kernel.img from the OS to something so it's not replaced. When you're done just rename your previous kernel back to kernel.img to get your OS back.
If you have another RPi version (1, 2 or 3 instead of Zero (W)) then the LED blinking will most likely not work. You would have to compile the assembler files yourself and change the LED control. For example for the RPi 2 the ACT LED is on the same GPIO but you have to write a 1 for it to go on, instead of a 0 like for the RPi Zero. The other versions even have different GPIOs for the LED. Just google a while, it's not so easy to find out.

I got the GPIO functions and the makefile from:
http://www.cl.cam.ac.uk/projects/raspberrypi/tutorials/os/ok03.html

and the firmware from:
https://github.com/raspberrypi/firmware/tree/master/boot
