// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <stdlib.h>
#include <stdio.h>

FILE* fp;

void my_open( char filename[] )
{
	fp = fopen(filename, "rb");
}

unsigned char my_getc( void )
{
	return getc(fp);
}

void my_close( void )
{
	fclose(fp);
}

int my_feof( void )
{
	return feof(fp);
}