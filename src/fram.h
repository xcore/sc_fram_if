#ifndef _FRAM_H_
#define _FRAM_H_

	// Structure for the ports to access the F-RAM
	typedef struct fram_interface_t
	{
		in port p_miso;
		out port p_ss;
		out port p_sclk;
		out port p_mosi;
		clock clk;
	} fram_interface_t;


	// Internal functions to communicate with the F-RAM using bytes
	void byte_out ( fram_interface_t &p, unsigned char c );
	unsigned char byte_in ( fram_interface_t &p );


	// Internal functions to communicate with the F-RAM using words
	void word_out ( fram_interface_t &p, unsigned int data );
	unsigned int word_in ( fram_interface_t &p );


	// External function calls
	void fram_initialise ( fram_interface_t &p ); // Initialise the F-RAM ports
	void fram_write_enable ( fram_interface_t &p ); // Send the write enable command
	void fram_write_disable ( fram_interface_t &p ); // Send the write disable command
	unsigned char fram_read_status ( fram_interface_t &p ); // Read the status register
	void fram_write_status ( fram_interface_t &p, unsigned char value ); // Write the status register
	void fram_read ( fram_interface_t &p, unsigned int address, unsigned int length, unsigned char data[] ); // Get data of <length> from <address> and place it in <data>
	void fram_write ( fram_interface_t &p, unsigned int address, unsigned int length, unsigned char data[] ); // Write <data> of <length> from <address>
	void fram_sleep ( fram_interface_t &p ); // Send the write enable command
	void fram_read_id ( fram_interface_t &p, unsigned char data[] ); // Read the device id

#endif