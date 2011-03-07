This is an example project that shows how to interface to a RAMTRON FM25V10 1Mbit Serial 3V F-RAM Memory.

The XCore can boot from it as if it was a normal FLASH.

This is not magnetic core (as used to land on the moon), but Ferroelectric RAM. It uses a ferroelectric instead of a dielectric layer and a construction similar to DRAM to be non-volatile.

This gives it the advantages of:

- Low power than FLASH

- Faster write performance (there are no write delays).

- Much larger umber of write cycles (at least 100 trillion).

You can read and write to it using xflash/flashlib and a suitalbe SPI-spec file, but this is a lightweight interface for fast access to it.

It is designed to be run on a XK-1 with the standard FLASH replaced with the F-RAM.

The example project shows how to (by commenting in/out the appropriate options in main()):

- test the memory by writing data (0x00, 0x55, 0xFF) and verifying the contents of the F-RAM.

- read the contents of the F-RAM and printing it to the terminal.

- write a binary file to the F-RAM (e.g. the XK-1 FLASH firmware in example/xk-1.bin).


