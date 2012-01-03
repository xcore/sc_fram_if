XCORE.com xkcam software, schematics and documentation
.................................

:Description: XMOS + Kodak image sensor decription with sensor driver, sensor control and basic image processing.

:Status: Initial prototype.

:Version: Unreleased.

:Maintainer: https://github.com/davidgibson


Key Features
============

* Schematics and port map for XMOS + Kodak KAC-401 dev board
* Kodak KAC-401 driver interface via I2C
* Two examples of sensor control and image capture:
  - GrabFrame128x128HVSub
  - Grab64x40BlocksSUB
* 8.24 signed fixed point:

  - basic functions: mul, div, sqrt
* Basic piece-wise image processing

Firmware Overview
=================

* A driver interface for the KAC-401 image sensor
* Access to most of the sensor registers (with a debug capability)
* Sensor pin to XMOS port mappings

Known Issues
============

None

Required Repositories
=====================

None

Support
=======

Issues may be submitted via the Issues tab in this github repo. Response to any issues submitted as at the discretion of the maintainer for this line.
