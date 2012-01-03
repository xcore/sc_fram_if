#include <stdio.h>
#include "xkcam_I2C.h"

void get_profile(void)
{
	GetDevID();
	GetRev();
	GetVClkGen();
	GetModeCtl();
	GetScanConfig();
	GetI2CMode();
	GetVMode0();
	GetVMode1();
	GetWRowS();
	GetWRowE();
	GetWRowMSB();
	GetWColS();
	GetWColE();
	GetWColMSB();
	GetFDelay();
	GetRDelay();
	GetUpdate();
	GetDWRowS();
	GetDWRowE();
	GetDWRowMSB();
	GetBLKLevConfig5();
	GetPGA0();
	GetPGA1();
	GetPGA2();
	GetPGA3();
	GetFGA();
}

void xget_profile(void)
{
	uint nPixels, FrameRate, drs, dre, rs, re, cs, ce, sc, vs, hs, HVSub;
	printf( "\nFrame info:\n" );
	sc = GetScanConfig();
	vs = (sc & 0x20) >> 5;
	hs = (sc & 0x08) >> 3;
	if( vs && hs )
	{
		HVSub = 4;
		printf( "Horizontal and vertical subsampling is on\n" );
	}
	else if( vs )
	{
		HVSub = 2;
		printf( "Vertical subsampling is on\n" );
	}
	else if( hs )
	{
		HVSub = 2;
		printf( "Horizontal subsampling is on\n" );
	}
	else
	{
		HVSub = 1;
	}
	rs = GetRowStart();
	re = GetRowEnd();
	cs = GetColStart();
	ce = GetColEnd();
	printf( "Grab window is (x1, y1 -> x2, y2) %d, %d to %d, %d\n", cs, rs, ce, re );
	drs = GetDRowStart();
	dre = GetDRowEnd();
	printf( "Display window is rows %d to %d\n", drs, dre );
	nPixels = GetNPixels() / HVSub;
	FrameRate = GetFrameRate() * HVSub;
	printf( "Number of pixels = %d\nFrame/ROI rate = %dfps\n\n", nPixels, FrameRate );
}
