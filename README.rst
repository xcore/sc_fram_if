XCORE.com xkcam software and related schematics and documentation
.................................

:Stable release:   unreleased

:Status:  Feature complete

:Maintainer:  Corin (github: xmos-corin)


Key Features
============

   * Example project that shows how to interface to a RAMTRON FM25V10 (1Mbit) or FM25H20 (2Mbit) SPI F-RAM Memory. These have the advantages of:
   
      * Low power than FLASH.
      * Faster write performance (there are no write delays).
      * Much larger umber of write cycles (at least 100 trillion).
      
   * Uses a light weight SPI interface.
   * Provides a low level interface, so the client manages the data directly on the F-RAM.

Firmware Overview
=================

You can read and write to it using xflash/flashlib and a suitalbe SPI-spec file, but this is a lightweight interface for fast access to it.
The XCore can boot from it as if it was a normal FLASH.

The example project shows how to (by commenting in/out the appropriate options in main()):

   * test the memory by writing data (0x00, 0x55, 0xFF) and verifying the contents of the F-RAM.
   * read the contents of the F-RAM and printing it to the terminal.
   * write a binary file to the F-RAM (e.g. the XK-1 FLASH firmware in example/xk-1.bin).

Known Issues
============

None, although the interface to the F-RAM could be sped up, by using clock blocks and buffered ports.

Required Modules
=================

None.

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the manitainer for this line.
