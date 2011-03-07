#include <xs1.h>
#include <platform.h>
#include <print.h>
#include "file_functions.h"
#include "fram.h"


// Xcore 0 Ports
on stdcore[0] : fram_interface_t fram_ports = { PORT_SPI_MISO, PORT_SPI_SS, PORT_SPI_CLK, PORT_SPI_MOSI, XS1_CLKBLK_1 };


// Defines for flash size (256 x 4096 = 1048576 bytes)
#define PAGE_SIZE 256
#define NUM_PAGES 4096


// Prototypes for functions
void test_fram( void );
void write_all_fram( unsigned char data_value );
void verify_all_fram( unsigned char data_value );
void read_contents_fram( void );
void write_file_fram( char filename[] );


// Write the file to the F-RAM
void test_fram( void )
{
	unsigned char temp[9];

	// Initialise the F-RAM
	fram_initialise( fram_ports );

	// Get the F-RAM ID
	fram_read_id( fram_ports, temp );

	// Print the last 3 bytes
	printstr( "F-RAM ID: 0x" );
	printhex((unsigned int) (temp[6] >> 4));
	printhex((unsigned int) (temp[6] & 0xF));
	printhex((unsigned int) (temp[7] >> 4));
	printhex((unsigned int) (temp[7] & 0xF));
	printhex((unsigned int) (temp[8] >> 4));
	printhex((unsigned int) (temp[8] & 0xF));
	printchar('\n');

	// Write and check 0x00
	write_all_fram( 0x00 );
	verify_all_fram( 0x00 );

	// Write and check 0x55
	write_all_fram( 0x55 );
	verify_all_fram( 0x55 );

	// Write and check 0xFF
	write_all_fram( 0xFF );
	verify_all_fram( 0xFF );

	// Tell the user that it completed successfully
	printstrln( "F-RAM tested successfully!" );
}


// Write the file to the F-RAM
void write_all_fram( unsigned char data_value )
{
	unsigned char temp[PAGE_SIZE];
	unsigned int i;

	// Write <data_value> into the data buffer
	for (i = 0; i < PAGE_SIZE; i++)
	{
		temp[i] =  data_value;
	}

	// Loop through NUM_PAGES x PAGE_SIZE byte chunks
	for (i = 0; i < NUM_PAGES; i++)
	{
		// Write PAGE_SIZE bytes to the F-RAM
		fram_write ( fram_ports, i * PAGE_SIZE, PAGE_SIZE, temp );
	}

	// Print the data has been written
	printstr( "F-RAM Written With : 0x" );
	printhex((unsigned int) (data_value >> 4));
	printhexln((unsigned int) (data_value & 0xF));
}


// Read the contents of everything in the F-RAM and check it is the expected value
void verify_all_fram( unsigned char data_value )
{
	unsigned char temp[1];
	unsigned int i;

	// Loop through NUM_PAGES x PAGE_SIZE byte chunks
	for ( i = 0; i < (NUM_PAGES * PAGE_SIZE); i++ )
	{
		// Read the 4 bytes from the F-RAM
		fram_read ( fram_ports, i, 1, temp );

		// If the data does not match, print an error
		if ( temp[0] != data_value )
		{
			printstr( "Error : 0x" );
			printhex( i );
			printchar( ' ' );
			printhex((unsigned int) (temp[0] >> 4));
			printhexln((unsigned int) (temp[0] & 0xF));
		}
	}

	// Print the data has been verified
	printstr( "F-RAM Verified With : 0x" );
	printhex((unsigned int) (data_value >> 4));
	printhexln((unsigned int) (data_value & 0xF));
}


// Read the contents of everything in the F-RAM and print it out
void read_contents_fram( void )
{
	unsigned char temp[9];
	unsigned int i;

	// Initialise the fram
	fram_initialise( fram_ports );

	// Get the id
	fram_read_id( fram_ports, temp );

	// Print the last 3 bytes
	printstr( "fram ID: " );
	printhex((unsigned int) (temp[6] >> 4));
	printhex((unsigned int) (temp[6] & 0xF));
	printchar(' ');
	printhex((unsigned int) (temp[7] >> 4));
	printhex((unsigned int) (temp[7] & 0xF));
	printchar(' ');
	printhex((unsigned int) (temp[8] >> 4));
	printhex((unsigned int) (temp[8] & 0xF));
	printchar('\n');

	// Loop through NUM_PAGES x PAGE_SIZE byte chunks
	for ( i = 0; i < ( ( NUM_PAGES * PAGE_SIZE ) / 4 ); i= i + 4 )
	{
		// Read 4 bytes from the F-RAM
		fram_read ( fram_ports, i, 4, temp );

		// Print out the address
	 	printchar( '0' );
	 	printchar( 'x' );
	 	printhex( (i >> 16) & 0xF );
	 	printhex( (i >> 12) & 0xF );
	 	printhex( (i >> 8) & 0xF );
	 	printhex( (i >> 4) & 0xF );
	 	printhex( i & 0xF );
	 	printchar( ' ' );

		// Print out the data
	    printhex((unsigned int) (temp[0] >> 4));
	    printhex((unsigned int) (temp[0] & 0xF));
		printchar(' ');
	    printhex((unsigned int) (temp[1] >> 4));
	    printhex((unsigned int) (temp[1] & 0xF));
	    printchar(' ');
	    printhex((unsigned int) (temp[2] >> 4));
	    printhex((unsigned int) (temp[2] & 0xF));
		printchar(' ');
	    printhex((unsigned int) (temp[3] >> 4));
	    printhex((unsigned int) (temp[3] & 0xF));
		printchar('\n');
	}
}


// Write and verify a file to the F-RAM - file size is currently 32KB
void write_file_fram( char filename[] )
{
	unsigned char temp[PAGE_SIZE];
	unsigned int i, j, pass = 1;

	// Initialise the F-RAM
	fram_initialise( fram_ports );

	// Get the F-RAM ID
	fram_read_id( fram_ports, temp );

	// Print the last 3 bytes
	printstr( "F-RAM ID: " );
	printhex((unsigned int) (temp[6] >> 4));
	printhex((unsigned int) (temp[6] & 0xF));
	printchar(' ');
	printhex((unsigned int) (temp[7] >> 4));
	printhex((unsigned int) (temp[7] & 0xF));
	printchar(' ');
	printhex((unsigned int) (temp[8] >> 4));
	printhex((unsigned int) (temp[8] & 0xF));
	printchar('\n');

	// Write the file to the F-RAM
		// Open the file
		my_open( filename );

		// Enable writing
		fram_write_enable( fram_ports );

		// Loop through 128 x PAGE_SIZE byte chunks = 32768 bytes
		for ( i = 0; i < 128; i++ )
		{
			// Read PAGE_SIZE bytes from the file
			for ( j = 0; j < PAGE_SIZE; j++ )
			{
				temp[j] = my_getc();
			}

			// Write the PAGE_SIZE bytes to the F-RAM
			fram_write ( fram_ports, i * PAGE_SIZE, PAGE_SIZE, temp );

			fram_write_disable ( fram_ports );
			fram_write_enable ( fram_ports );
		}

		// Disable writing
		fram_write_disable ( fram_ports );

		// Close the file
		my_close();

		// Print the amount of data write
		printstrln( "Data written succesfully!" );

	// Verify the file
		// Open the file
		my_open( filename );

		// Loop through 128 x PAGE_SIZE byte chunks = 32768 bytes
		for ( i = 0; i < 128; i++ )
		{
			// Read the PAGE_SIZE bytes from the F-RAM
			fram_read ( fram_ports, i * PAGE_SIZE, PAGE_SIZE, temp );

			// Read PAGE_SIZE bytes from the file
			for ( j = 0; j < PAGE_SIZE; j++ )
			{
				 if ( temp[j] != my_getc() )
				 {
					printstr( "Verify fail: 0x" );
					printhexln ( (i*PAGE_SIZE) + j );
					pass = 0;
				 }
			}
		}

		// Close the file
		my_close();

		// If the data was OK, return this to the user
		if ( pass == 1 )
		{
			printstrln( "Data verified succesfully!" );
		}
}


// Program Entry Point
int main(void)
{
	par
	{
		// XCore 0
		on stdcore[0] : test_fram( );
		//on stdcore[0] : read_contents_fram( );
		//on stdcore[0] : write_file_fram( "example/xk-1.bin" );
	}

	return 0;
}
