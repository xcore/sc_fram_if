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