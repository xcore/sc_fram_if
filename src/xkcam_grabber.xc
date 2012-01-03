#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include "xkcam_I2C.h"
#include "xkcam_grabber.h"
#include "xkcam_profiles.h"

extern void pgmout(int data[], int xWd, int yHt, char fname[]);
extern void savefmeans( uint fmeans[], uint fcnt );

#define uint unsigned
timer IIC_timer;

//MClk and reset ports
port KCAM_MCLK = XS1_PORT_1C;
port KCAM_RST = XS1_PORT_1I;
clock MCLK1 = XS1_CLKBLK_1;

//Data ports
buffered in port:32 p_DIN32 = XS1_PORT_8C;
in port p_pclk = XS1_PORT_1D;
in port p_vsync = XS1_PORT_1E;
in port p_href = XS1_PORT_1F;
clock DIN32CLK = XS1_CLKBLK_3;

void KCAM_reset()
{
	uint count1 = 0, count2 = 0;
	KCAM_RST <: 0 @ count1;
	count2 = count1 + 5;
	KCAM_RST @ count2 <: 1;//"...should only be held low for 3-5 Mclk cycles."
}

void kcam_Init()//Init all camera and camera coms
{
	initI2C();
	KCAM_reset();
	SetModeCtl( 0 ); //Switch to PwUp mode which starts the internal clocks
	SetCPClkGen( 0x0 ); //Set the charge pump clock gen, default is 1
	//SetVMode1( 0x80 ); //Set pixel clk to data ready mode as opposed to free running
	//SetVMode1( 0x02 ); //Set polarity of pixel clock
	SetVMode0( 0x02 ); //Map A/D[11:4]->d[7:0]
	SetVClkGen( 0x00 ); //Set to 0 so divider is 1 and Hclk == Mclk (25MHz), default is 1 divider is 2
	SetFGA( 0x0F ); //Set the global analogue gain, 0x3F is max
	//SetScanConfig( 0x10 ); //Set reversed horizontal scan
	SetScanConfig( 0x28 ); //Set V and H subsampling
	//SetBLKLevConfig1(0x06); // Switch off automatic black
	SetFDelay( 0x0009 ); //This increases frame integration/exposure time, 1FFF max value
	//SetRDelay( 0xFFF ); //This increases each row integration/exposure time
	
	SetUpdate(); //Set this to update double buffered registers changed above, self clears
}
void kcam_run(void)
{
	chan pixels;
	//Start mclk
	configure_clock_rate( MCLK1, 100, 4 );
	configure_port_clock_output( KCAM_MCLK, MCLK1 );
	configure_out_port( KCAM_RST, MCLK1, 1 );

	configure_in_port( p_pclk, MCLK1 );
	configure_in_port( p_vsync, MCLK1 );
	configure_in_port( p_href, MCLK1 );
	configure_clock_src( DIN32CLK, p_pclk );
	
	set_port_inv( p_pclk );
	configure_in_port( p_DIN32, DIN32CLK );
	
	start_clock( MCLK1 );
	start_clock( DIN32CLK );

	kcam_Init();

	//A single image grab demo function:
	//GrabFrame128x128HVSub( p_href, p_vsync, p_DIN32 );
	//A multi-subimage/ROI motion detection demo function:
	par
	{
		Grab64x40BlocksSUB( p_href, p_vsync, p_DIN32, pixels);
		ImProc( pixels );
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma unsafe arrays
void GrabFrame128x128HVSub(in port p_href, in port p_vsync, buffered in port:32 p_DIN32)
{
	uint pix, cnt = 0, sum = 0;
	int ps[ 4096 ];
	//uint stFTime, endFTime;
	uint stROITime, endROITime;
	timer t;

	t :> stROITime;
	SetScanWindow( 256, 511, 116, 371 );
    SetDisplayWindow( 116, 371 );
    SetUpdate();
    t :> endROITime;
    
	get_profile();
	xget_profile();
	
	printf( "About to grab...\n" );
    
    p_vsync when pinseq( 0 ) :> void; //Wait for frame to finish
    p_vsync when pinseq( 1 ) :> void; //Wait for next frame to start
    //t :> stFTime; //Doing this causes the first four pixels to be dropped but is useful to measure timing
    clearbuf( p_DIN32 );
#pragma loop unroll(32)
    for( int x = 0; x < 32; x++ ) //Read in first scan line triggered by p_vsync
    {
		p_DIN32 :> pix;
		ps[ cnt++ ] = pix;
    }

    for( int y = 1; y < 128; y++ ) //Read all other scan lines triggered by p_href
    {
		p_href when pinseq( 0 ) :> void;
        p_href when pinseq( 1 ) :> void; //Wait for next row to start
        clearbuf( p_DIN32 );
#pragma loop unroll(32)
		for( int x = 0; x < 32; x++ )
		{
			p_DIN32 :> ps[ cnt++ ];
        }
    }
    //t :> endFTime;
    

	printf( "ROI set time = %d cycles\n", ( endROITime - stROITime ) );
	//printf( "Frame grab time = %d cycles\n", ( endFTime - stFTime ) );
	
	for( int i = 0; i < 4096; i++ )
	{
		sum += ( ps[ i ] & 0xFF );
		sum += ( ( ps[ i ] >> 8 ) & 0xFF );
		sum += ( ( ps[ i ] >> 16 ) & 0xFF );
		sum += ( ( ps[ i ] >> 24 ) & 0xFF );
	}
	
	printf( "Mean pixel value = %d\n", sum / 16384 );

	pgmout( ps, 128, 128, "../output/image_128x128.pgm" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Grab 5x6 grid of 64x40 HV subsampled sub-images over the whole sensor:
#pragma unsafe arrays
void Grab64x40BlocksSUB(in port p_href, in port p_vsync, buffered in port:32 p_DIN32, chanend pixels)
{
	uint cnt, dsz = 16 * 40, bcnt = 0, nblks = 2400;
    int blk[ 64 * 40 / 4 ];
    char fname[ 64 ];
    uint xOff = 64, yOff = 4, xWd = 128, yHt = 80; //Sub-image dimensions + full image offsets

	SetScanWindow( xOff, xOff + ( xWd - 1 ), yOff, yOff + ( yHt - 1 ) );
    SetDisplayWindow( yOff, yOff + ( yHt - 1 ) );
    SetUpdate();
	xget_profile();
    
	printf( "About to enter 64x40 grab loop\n" );

    while( bcnt < nblks )
    {
		cnt = 0;
        p_vsync when pinseq(0) :> void; //Wait for frame to finish
        p_vsync when pinseq(1) :> void; //Wait for next frame to start
        clearbuf( p_DIN32 );
#pragma loop unroll
        for( int x = 0; x < 16; x++ ) //Read in first scan line triggered by p_vsync
        {
		    p_DIN32 :> blk[ cnt++ ];
        }	
        for( int y = 1; y < 40; y++ ) //Read all other scan lines triggered by p_href
        {
            p_href when pinseq(0) :> void;
            p_href when pinseq(1) :> void; //Wait for next row to start
            clearbuf( p_DIN32 );
#pragma loop unroll
            for( int x = 0; x < 16; x++ )
            {
			    p_DIN32 :> blk[ cnt++ ];
            }
        }

		//Update next blk position
        xOff += xWd;
        if( xOff > 640 )
        {
            xOff = 64;
            yOff += yHt;
            if( yOff > 480 )
            {
                yOff = 4;
            }
        }
        if( xOff == 64 ) //A hack to get rid of over exposed first column of blks?
        {
            SetScanWindow( xOff - 64, ( xOff - 64 ) + ( xWd - 1 ), yOff, yOff + ( yHt - 1 ) );
            SetDisplayWindow( yOff, yOff + ( yHt - 1 ) );
            SetUpdate();
            p_vsync when pinseq(0) :> void; //Wait for frame to finish
            p_vsync when pinseq(1) :> void; //Wait for next frame to start
        }
        
        for( int i = 0; i < dsz; i++ )
        {
			pixels <: blk[ i ];
        }

		//Set new blk position
        SetScanWindow( xOff, xOff + ( xWd - 1 ), yOff, yOff + ( yHt - 1 ) );
        SetDisplayWindow( yOff, yOff + ( yHt - 1 ) );
        SetUpdate();
		/*
		if( bcnt < 30 )
		{
			sprintf( fname, "../output/image64x40_%04d.pgm", bcnt );
			pgmout( blk, 64, 40, fname );
			printf( "Grab::blk %d\n", bcnt );
		}
		*/

        bcnt++;
    }

    printf( "Done Grab64x40BlocksSUB\n" );
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma unsafe arrays
void ImProc(chanend pixels)
{
	uint dsz = 16 * 40, bRun = 1, sum, mean, bcnt = 0, fcnt = 0, cnt;
	int blk[ 64 * 40 / 4 ], val;
	unsigned char blkmn1[ 30 ], blkmn2[ 30 ], diffs[ 500 ][ 30 ];
	uint fmeans[ 500 ];
	uint stTime, endTime;
	timer t;
	
	for( int i = 0; i < 500; i++ )
	{
		fmeans[ i ] = 0;
	}

	while( bRun )
	{
        for( int i = 0; i < dsz; i++ )
        {
			pixels :> blk[ i ];
        }
		if( bcnt == 0 && fcnt == 0 )
		{
			t :> stTime;
		}

		sum = 0; 
 		for( int i = 0; i < dsz; i++ )
		{
			sum += ( blk[ i ] & 0xFF );
			sum += ( ( blk[ i ] >> 8 ) & 0xFF );
			sum += ( ( blk[ i ] >> 16 ) & 0xFF );
			sum += ( ( blk[ i ] >> 24 ) & 0xFF );
		}
		mean = sum / 2560;
		if( fcnt & 0x01 )
		{
			blkmn2[ bcnt ] = mean;
			fmeans[ fcnt ] += mean;
			//diffs[ fcnt ][ bcnt ] = blkmn2[ bcnt ]; //To view image ROI means
		}
		else
		{	
			blkmn1[ bcnt ] = mean;
			fmeans[ fcnt ] += mean;
			//diffs[ fcnt ][ bcnt ] = blkmn1[ bcnt ];
		}

		bcnt++;
		if( bcnt == 30 )
		{
			/*
			for( int i = 0; i < 30; i++ )
			{
				val = (int)blkmn1[ i ] - (int)blkmn2[ i ];
				diffs[ fcnt ][ i ] = ((val<0))?-(val):(val);
			}
			*/
			bcnt = 0;
			fcnt++;
			if( fcnt == 80 )
			{
				bRun = 0;
			}
		}
    }
    t :> endTime;

	printf( "Mean sub-image differences:\n" );
	/*
    for( int f = 0; f < fcnt; f++ )
    {
		cnt = 0;
		for( int y = 0; y < 6; y++ )
		{
			for( int x = 0; x < 5; x++ )
			{
				printf( "%3d ", diffs[ f ][ cnt++ ] );
			}
			printf( "\n" );
		}
		printf( "\n" );
    }
    */
    savefmeans( fmeans, fcnt );
    printf( "Grabbed and processed %d frames at %dfps\n", fcnt, 100000000 / ( ( endTime - stTime ) / fcnt ) );
    printf( "Grabbed and processed %d ROIs at %dROIps\n", fcnt * 30, 100000000 / ( ( endTime - stTime ) / ( fcnt * 30 ) ) );
    printf( "Done ImProc, time taken = %d\n", endTime - stTime );
}