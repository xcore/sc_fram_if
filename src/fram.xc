// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

// Functions to interface to the F-RAM
#include <xs1.h>
#include <platform.h>
#include "fram.h"


// Divider for the clock block to drive SCLK = 25MHz.
#define CLK_DIV 2


// Define the SPI commands from the Ramtron datasheet
#define WREN 	0x06	// Set Write Enable Latch  0000 0110b
#define WRDI 	0x04	// Write Disable  0000 0100b
#define RDSR 	0x05	// Read Status Register  0000 0101b
#define WRSR 	0x01	// Write Status Register  0000 0001b
#define READ 	0x03	// Read Memory Data  0000 0011b
#define FSTRD 	0x0B	// Fast Read Memory Data  0000 1011b
#define WRITE 	0x02	// Write Memory Data   0000 0010b
#define SLEEP 	0xB9	// Enter Sleep Mode  1011 1001b
#define RDID 	0x9F	// Read Device ID  1001 1111b
#define SNR 	0xC3	// Read S/N  1100 0011b


// Send a byte out to the F-RAM
void byte_out ( fram_interface_t &p, unsigned char c )
{
	unsigned int data = (unsigned int) c;

	// Loop through all 8 bits
	#pragma loop unroll
	for ( int i = 0; i < 8; i++ )
	{
		// Send the data oout MSB first bit order - SPI standard
		p.p_mosi <: ( data >> (7 - i));

		// Send the clock high
		p.p_sclk <: 1;

		// Send the clock low
		p.p_sclk <: 0;
	}
}


// Receive a byte from the F-RAM
unsigned char byte_in ( fram_interface_t &p )
{
	unsigned int temp;
	unsigned char data = 0;

	// Loop through all 8 bits
	#pragma loop unroll
	for ( int i = 0; i < 8; i++)
	{
		// Send the clock high
		p.p_sclk <: 1;

		// Get the data MSB first bit order - SPI standard
		p.p_miso :> temp;
		data = (data << 1) + temp;

		// Send the clock low
		p.p_sclk <: 0;
	}

	return data;
}


// Send a word out to the F-RAM
void word_out ( fram_interface_t &p, unsigned int data )
{
	// Loop through all 32 bits
	#pragma loop unroll
	for ( int i = 0; i < 32; i++ )
	{
		// Send the data oout MSB first bit order - SPI standard
		p.p_mosi <: ( data >> (31 - i));

		// Send the clock high
		p.p_sclk <: 1;

		// Send the clock low
		p.p_sclk <: 0;
	}
}


// Receive a word from the F-RAM
unsigned int word_in ( fram_interface_t &p )
{
	unsigned int temp, data = 0;

	// Loop through all 32 bits
	#pragma loop unroll
	for ( int i = 0; i < 32; i++)
	{
		// Send the clock high
		p.p_sclk <: 1;

		// Get the data MSB first order - SPI standard
		p.p_miso :> temp;
		data = (data << 1) + temp;

		// Send the clock low
		p.p_sclk <: 0;
	}

	return data;
}


// Initialise the F-RAM ports
void fram_initialise ( fram_interface_t &p )
{
	// Configure the clock output to run from a clk blk
	set_clock_div( p.clk, CLK_DIV );
	configure_out_port( p.p_sclk, p.clk, 0 );
	start_clock( p.clk );

	// Put an edge onto the SS line and set it to not select
	p.p_ss <: 1;
	p.p_ss <: 0;
	p.p_ss <: 1;
}


// Send the write enable command
void fram_write_enable ( fram_interface_t &p )
{
	p.p_ss <: 0;
	byte_out(p, WREN);
	p.p_ss <: 1;
}


// Send the write disable command
void fram_write_disable ( fram_interface_t &p )
{
	p.p_ss <: 0;
	byte_out(p, WRDI);
	p.p_ss <: 1;
}


// Read the status register
unsigned char fram_read_status ( fram_interface_t &p )
{
	unsigned char temp;

	p.p_ss <: 0;
	byte_out(p, RDSR);
	temp = byte_in(p);
	p.p_ss <: 1;
	return temp;
}


// Write the status register
void fram_write_status ( fram_interface_t &p, unsigned char value )
{
	p.p_ss <: 0;
	byte_out(p, WRSR);
	byte_out(p, value);
	p.p_ss <: 1;
}


// Get data of <length> from <address> in the F-RAM and place it in <data>
void fram_read ( fram_interface_t &p, unsigned int address, unsigned int length, unsigned char data[] )
{
	// Set the slave select low
	p.p_ss <: 0;

	// Send out the READ command and the address
	word_out(p, (READ << 24) + address);

	// For the length specified
	for (unsigned int i = 0; i < length; i++)
	{
		// Get the data from the F-RAM
		data[i] = byte_in(p);
	}

	// Set the slave select high
	p.p_ss <: 1;
}


// Write <data> of <length> from <address> to the F-RAM
void fram_write ( fram_interface_t &p, unsigned int address, unsigned int length, unsigned char data[] )
{
	// Enable writing to the F-RAM (remember a write clears this flag)
	fram_write_enable ( p );

	// Set the slave select low
	p.p_ss <: 0;

	// Send out the WRITE command and the address
	word_out(p, (WRITE << 24) + address);

	// For the length specified
	for (unsigned int i = 0; i < length; i++)
	{
		// Send the data to the F-RAM
		byte_out(p, data[i]);
	}

	// Set the slave select high
	p.p_ss <: 1;

	// Disable writing to the F-RAM
	fram_write_disable ( p );
}


// Send the sleep command
void fram_sleep ( fram_interface_t &p )
{
	p.p_ss <: 0;
	byte_out(p, SLEEP);
	p.p_ss <: 1;
}


// Read the device id and store it in <data>
void fram_read_id ( fram_interface_t &p, unsigned char data[] )
{
	// Set the slave select low
	p.p_ss <: 0;

	// Send out the RDID command
	byte_out(p, RDID);

	// Get the 8 bytes of device id and write it to <data>
	for (int i = 0; i < 9; i++)
	{
	    data[i] = byte_in(p);
	}

	// Enable writing to the F-RAM
	p.p_ss <: 1;
}
