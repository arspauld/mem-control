# MEM-CONTROL

This repository contains a memory controller for the ISSI 512Mb SDRAM chip contained on the DE10-Lite FPGA Evaluation board. The memory controller is capable of completing single word read and single word write at arbitrary locations in memory. The controller is connected to an SDRAM model in simulation to verify that communications between the memory chip and the memory controller follow the specification provided in the device data sheet.

The repository also contains an interface that can be instantiated on the DE10-Lite FPGA which allows users to submit both read and write commands to the memory controller. The IO Controller receives inputs from the onboard buttons and switches, and provides feedback to the user through the LED's and 7-segment display. The device presents a variety of states to the user, allowing the user to provide a full 16 bit word of data and select from any of the 23 bit address locations using only 9 switches on the board.

This memory controller can be connected to a computer system to allow for random access reads and writes at any time. The device is not currently capable of performing continuous reads and writes, and an individual command must be submitted for each read and write.
