// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#ifndef _FILE_FUNCTIONS_H_
#define _FILE_FUNCTIONS_H_

	void my_open( char filename[] );
	unsigned char my_getc( void );
	void my_close( void );
	int my_feof( void );

#endif