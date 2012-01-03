#include <xs1.h>
#include <print.h>
#include <stdio.h>
#include "xkcam_I2C.h"

//#define USEPRINTF //Define this to get lots of info but may ruin timings

//I2C ports: use sccb interface
port RTCDATA = XS1_PORT_1G;
port SCK = XS1_PORT_1H;
clock b_sccb = XS1_CLKBLK_2;

void sccb_init(port sioc, port siod, clock siob);
int sccb_wr(int reg, int val, port sioc, port siod);
int sccb_rd(int reg, port sioc, port siod);

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Initialisation of I2C bus
void initI2C(void)
{
	sccb_init(SCK, RTCDATA, b_sccb);
#ifdef USEPRINTF
	printf( "Initialised I2C bus\n");
#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Low level register access functions/interface
uint GetDevID(void)
{
	uint devid = 0;
	devid = sccb_rd( REGDEVID, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "devid = 0x%x, (%d)\n", devid, devid );
#endif
	return devid;
}

uint GetRev(void)
{
	uint rev = 0;
	rev = sccb_rd( REGREV, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "rev = 0x%x, (%d)\n", rev, rev );
#endif
	return rev;
}

uint GetVClkGen(void)
{
	uint vclkgen = 0;
	vclkgen = sccb_rd( REGVCLKGEN, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "vclkgen(could be hclkgen?) = 0x%x, (%d)\n", vclkgen & 0x1F, vclkgen & 0x1F );
#endif
	return vclkgen;
}

uint SetVClkGen(uint val)
{//Default reset value is 0x01
	uint ret;
	ret = sccb_wr( REGVCLKGEN, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGVCLKGEN, ret = %d\n", val, val & 0x1F, ret );
#endif
	return ret;
}

uint GetModeCtl(void)
{
	uint modectl = 0;
	modectl = sccb_rd( REGMODECTL, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "modectl = 0x%x, (Update(7) = %d, Slave mode(5) = %d,PwDn(0) = %d)\n", modectl, (modectl & 0x80)>>7, (modectl & 0x20)>>5, modectl & 0x01 );
#endif
	return modectl;
}

uint SetModeCtl(uint val)
{//Default reset value is 0x0D (1101)?
	uint ret;
	ret = sccb_wr( REGMODECTL, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGMODECTL, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetScanConfig(void)
{
	uint scanconfig = 0;
	scanconfig = sccb_rd( REGSCANCONFIG, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "scanconfig = 0x%x:\n\tColour(7) = %d\n\tVScanDir(6) = %d\n\tVSub(5) = %d\n\tHScanDir(4) = %d\n\tHSub(3) = %d\n\tHBin(2) = %d\n\tDisableUpdate(0) = %d\n", scanconfig, (scanconfig & 0x80)>>7, (scanconfig & 0x40)>>6, (scanconfig & 0x20)>>5, (scanconfig & 0x10)>>4, (scanconfig & 0x08)>>3, (scanconfig & 0x04)>>2, scanconfig & 0x01 );
#endif
	return scanconfig;	
}

uint SetScanConfig(uint val)
{
	uint ret;
	ret = sccb_wr( REGSCANCONFIG, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGSCANCONFIG, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetI2CMode(void)
{
	uint i2cmode = 0;
	i2cmode= sccb_rd( REGI2CMODE, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "i2cmode = 0x%x (DevAddrEn(7) = %d, I2CDevAddr = 0x%x)\n", i2cmode, (i2cmode & 0x80)>>7, i2cmode & 0x7F );
#endif
	return i2cmode;
}

uint SetI2CMode(uint val)
{
	uint ret;
	ret = sccb_wr( REGI2CMODE, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGI2CMODE, ret = %d\n", val, val, ret );
#endif
	return ret;	
}

uint GetVMode0(void)
{
	uint vmode0 = 0;
	vmode0 = sccb_rd( REGVMODE0, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "vmode0 = 0x%x:\n\tPixDataSel(7:6) = %d\n\tPixDataMSB(5:4) = %d\n\tSaturation(3) = %d\n\tPixDataMSB7(2) = %d\n\tDataRouting(1:0) = %d\n", vmode0, (vmode0 & 0xC0)>>6, (vmode0 & 0x30)>>4, (vmode0 & 0x08)>>3, (vmode0 & 0x04)>>2, vmode0 & 0x03 );
#endif
	return vmode0;
}

uint SetVMode0(uint val)
{
	uint ret;
	ret = sccb_wr( REGVMODE0, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGVMODE0, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetVMode1(void)
{
	uint vmode1 = 0;
	vmode1 = sccb_rd( REGVMODE1, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "vmode1 = 0x%x:\n\tPixClkMode(7) = %d\n\tVsyncMode(6) = %d\n\tHsyncMode(5) = %d\n\tPixClkPol(4) = %d\n\tVsyncPol(3) = %d\n\tHsyncPol(2) = %d\n\tPixData(1) = %d\n\tTriExtsync(0) = %d\n", vmode1, (vmode1 & 0x80)>>7, (vmode1 & 0x40)>>6, (vmode1 & 0x20)>>5, (vmode1 & 0x10)>>4, (vmode1 & 0x08)>>3, (vmode1 & 0x04)>>2, (vmode1 & 0x02)>>1, vmode1 & 0x01 );
#endif
	return vmode1;
}

uint SetVMode1(uint val)
{
	uint ret;
	ret = sccb_wr( REGVMODE1, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGVMODE1, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetWRowS(void)
{
	uint wrows = 0;
	wrows = sccb_rd( REGWROWS, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrows = 0x%x (%d)\n", wrows, wrows );
#endif
	return wrows;
}

uint SetWRowS(uint val)
{
	uint ret;
	ret = sccb_wr( REGWROWS, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWROWS, ret = %d\n", val, val, ret );
#endif
	return ret;
}
uint GetWRowE(void)
{
	uint wrowe = 0;
	wrowe = sccb_rd( REGWROWE, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrowe = 0x%x (%d)\n", wrowe, wrowe );
#endif
	return wrowe;
}

uint SetWRowE(uint val)
{
	uint ret;
	ret = sccb_wr( REGWROWE, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWROWE, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetWRowMSB(void)
{
	uint wrowmsb = 0;
	wrowmsb = sccb_rd( REGWROWMSB, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrowmsb = 0x%x, (7:4) = 0x%x, (3:0) = 0x%x\n", wrowmsb, ( wrowmsb & 0xF0 )>>4, wrowmsb & 0x0F );
#endif
	return wrowmsb;
}

uint SetWRowMSB(uint val)
{
	uint ret;
	ret = sccb_wr( REGWROWMSB, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWROWMSB, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetWColS(void)
{
	uint wcols = 0;
	wcols = sccb_rd( REGWCOLS, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wcols = 0x%x (%d)\n", wcols, wcols );
#endif
	return wcols;
}

uint SetWColS(uint val)
{
	uint ret;
	ret = sccb_wr( REGWCOLS, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWCOLS, ret = %d\n", val, val, ret );
#endif
	return ret;	
}

uint GetWColE(void)
{
	uint wcole = 0;
	wcole = sccb_rd( REGWCOLE, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wcole = 0x%x (%d)\n", wcole, wcole );
#endif
	return wcole;
}

uint SetWColE(uint val)
{
	uint ret;
	ret = sccb_wr( REGWCOLE, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWCOLE, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetWColMSB(void)
{
	uint wcolmsb = 0;
	wcolmsb = sccb_rd( REGWCOLMSB, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wcolmsb = 0x%x, (7:4) = 0x%x, (3:0) = 0x%x\n", wcolmsb, ( wcolmsb & 0xF0 )>>4, wcolmsb & 0x0F );
#endif
	return wcolmsb;
}

uint SetWColMSB(uint val)
{
	uint ret;
	ret = sccb_wr( REGWCOLMSB, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGWCOLMSB, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetFDelay(void)
{
	uint fdelayl = 0, fdelayh = 0, fdelay;
	fdelayl = sccb_rd( REGFDELAYL, SCK, RTCDATA );
	fdelayh = sccb_rd( REGFDELAYH, SCK, RTCDATA );
	fdelay = (( fdelayh & 0x3F ) << 8) + fdelayl;
#ifdef USEPRINTF
	printf( "fdelay = 0x%x (%d), (fdelayh = 0x%x (%d), fdelayl = 0x%x (%d)\n", fdelay, fdelay, fdelayh, fdelayh, fdelayl, fdelayl );
#endif
	return fdelay;
}

uint SetFDelay(uint val)
{
	uint fdelayh, fdelayl, ret1, ret2;
	fdelayl = ( val & 0xFF );
	fdelayh = ( val >> 8 );
	ret1 = sccb_wr( REGFDELAYL, fdelayl, SCK, RTCDATA );
	ret2 = sccb_wr( REGFDELAYH, fdelayh, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetFDelay: wrote fdelay = 0x%x (%d), (fdelayh = 0x%x (%d), fdelayl = 0x%x (%d)\n", val, val, fdelayh, fdelayh, fdelayl, fdelayl );
#endif
	return ( ret1 + ret2 );
}

uint GetRDelay(void)
{
	uint rdelayl = 0, rdelayh = 0, rdelay;
	rdelayl = sccb_rd( REGRDELAYL, SCK, RTCDATA );
	rdelayh = sccb_rd( REGRDELAYH, SCK, RTCDATA );
	rdelay = (( rdelayh & 0x3F ) << 8) + rdelayl;
#ifdef USEPRINTF
	printf( "rdelay = 0x%x (%d), (rdelayh = 0x%x (%d), rdelayl = 0x%x (%d)\n", rdelay, rdelay, rdelayh, rdelayh, rdelayl, rdelayl );
#endif
	return rdelay;

}

uint SetRDelay(uint val)
{
	uint rdelayh, rdelayl, ret1, ret2;
	rdelayl = ( val & 0xFF );
	rdelayh = ( val >> 8 );
	ret1 = sccb_wr( REGRDELAYL, rdelayl, SCK, RTCDATA );
	ret2 = sccb_wr( REGRDELAYH, rdelayh, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetRDelay: wrote rdelay = 0x%x (%d), (rdelayh = 0x%x (%d), rdelayl = 0x%x (%d)\n", val, val, rdelayh, rdelayh, rdelayl, rdelayl );
#endif
	return ( ret1 + ret2 );
}

uint GetCPClkGen(void)
{
	uint cpclkgen = 0;
	cpclkgen = sccb_rd( REGCPCLKGEN, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "Charge pump clock generation = 0x%x\n", cpclkgen );
#endif
	return cpclkgen;
}

uint SetCPClkGen(uint val)
{
	uint ret = 0;
	ret = sccb_wr( REGCPCLKGEN, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "Wrote charge pump clock generation = 0x%x\n", val );
#endif
	return ret;
}

uint GetDWRowS(void)
{
	uint drows = 0;
	drows = sccb_rd( REGDROWS, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "drows = 0x%x (%d)\n", drows, drows );
#endif
	return drows;
}

uint SetDWRowS(uint val)
{
	uint ret;
	ret = sccb_wr( REGDROWS, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGDROWS, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetDWRowE(void)
{
	uint drowe = 0;
	drowe = sccb_rd( REGDROWE, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "drowe = 0x%x (%d)\n", drowe, drowe );
#endif
	return drowe;
}

uint SetDWRowE(uint val)
{
	uint ret;
	ret = sccb_wr( REGDROWE, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGDROWE, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetDWRowMSB(void)
{
	uint drowmsb = 0;
	drowmsb = sccb_rd( REGDROWMSB, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "drowmsb = 0x%x, (7:4) = 0x%x, (3:0) = 0x%x\n", drowmsb, ( drowmsb & 0xF0 )>>4, drowmsb & 0x0F );
#endif
	return drowmsb;
}

uint SetDWRowMSB(uint val)
{
	uint ret;
	ret = sccb_wr( REGDROWMSB, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGDROWMSB, ret = %d\n", val, val, ret );
#endif
	return ret;
}

uint GetBLKLevConfig5(void)
{
	uint blcf = 0;
	blcf = sccb_rd( REGBLKLEVCONFIG5, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "Black level config = 0x%x\n", blcf );
#endif
	return blcf;
}

uint SetBLKLevConfig5(uint val)
{
	return 0;
}

uint GetPGA0(void)
{
	uint pga0 = 0;
	pga0 = sccb_rd( REGPGA0, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "PGA0 level = 0x%x\n", pga0 );
#endif
	return pga0;
}

uint SetPGA0(uint val)
{
	return 0;
}

uint GetPGA1(void)
{
	uint pga1 = 0;
	pga1 = sccb_rd( REGPGA1, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "PGA1 level = 0x%x\n", pga1 );
#endif
	return pga1;
}

uint SetPGA1(uint val)
{
	return 0;
}

uint GetPGA2(void)
{
	uint pga2 = 0;
	pga2 = sccb_rd( REGPGA2, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "PGA2 level = 0x%x\n", pga2 );
#endif
	return pga2;
}

uint SetPGA2(uint val)
{
	return 0;
}

uint GetPGA3(void)
{
	uint pga3 = 0;
	pga3 = sccb_rd( REGPGA3, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "PGA3 level = 0x%x\n", pga3 );
#endif
	return pga3;
}

uint SetPGA3(uint val)
{
	return 0;
}

uint GetFGA(void)
{
	uint fga = 0;
	fga = sccb_rd( REGFGA, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "FGA level = 0x%x\n", fga );
#endif
	return fga;
}

uint SetFGA(uint val)
{
	uint ret;
	ret = sccb_wr( REGFGA, val, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGFGA, ret = %d\n", val, val, ret );
#endif
	return ret;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Higher level functions/interface

uint GetRowStart(void)
{
	uint rows = 0, wrows, wrowmsb;
	wrows = sccb_rd( REGWROWS, SCK, RTCDATA );
	wrowmsb = sccb_rd( REGWROWMSB, SCK, RTCDATA );
	rows = (( wrowmsb & 0x0F )<<8) + wrows;
#ifdef USEPRINTF
	printf( "GetRowStart = 0x%x (%d)\n", rows, rows );
#endif	
	return rows;
}

uint SetRowStart(uint val)
{
	uint wrows, wrowmsbnew, wrowmsbold, ret1, ret2;
	wrows = val & 0xFF;
	wrowmsbnew = ( val >> 8 ) & 0x0F;
	wrowmsbold = sccb_rd( REGWROWMSB, SCK, RTCDATA );
	//printf( "wrows = 0x%x (%d), wrowmsbnew = 0x%x (%d), wrowmsbold = 0x%x (%d)\n", wrows, wrows, wrowmsbnew, wrowmsbnew, wrowmsbold, wrowmsbold );
	wrowmsbnew += ( wrowmsbold & 0xF0 );
	//printf( "wrows = 0x%x (%d), wrowmsbnew = 0x%x (%d), wrowmsbold = 0x%x (%d)\n", wrows, wrows, wrowmsbnew, wrowmsbnew, wrowmsbold, wrowmsbold );
	ret1 = sccb_wr( REGWROWS, wrows, SCK, RTCDATA );
	ret2 = sccb_wr( REGWROWMSB, wrowmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetRowStart: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, wrowmsbnew, wrows );
#endif
	return ( ret1 + ret2 );
}

uint GetRowEnd(void)
{
	uint rowe = 0, wrowe, wrowmsb;
	wrowe = sccb_rd( REGWROWE, SCK, RTCDATA );
	wrowmsb = sccb_rd( REGWROWMSB, SCK, RTCDATA );
	rowe = (( wrowmsb & 0xF0 )<<4) + wrowe;
#ifdef USEPRINTF
	printf( "GetRowEnd = 0x%x (%d)\n", rowe, rowe );
#endif	
	return rowe;
}

uint SetRowEnd(uint val)
{
	uint wrowe, wrowmsbnew, wrowmsbold, ret1, ret2;
	wrowe = val & 0xFF;
	wrowmsbnew = ( val >> 4 ) & 0xF0;
	wrowmsbold = sccb_rd( REGWROWMSB, SCK, RTCDATA );
	//printf( "wrowe = 0x%x (%d), wrowmsbnew = 0x%x (%d), wrowmsbold = 0x%x (%d)\n", wrowe, wrowe, wrowmsbnew, wrowmsbnew, wrowmsbold, wrowmsbold );
	wrowmsbnew += ( wrowmsbold & 0x0F );
	//printf( "wrowe = 0x%x (%d), wrowmsbnew = 0x%x (%d), wrowmsbold = 0x%x (%d)\n", wrowe, wrowe, wrowmsbnew, wrowmsbnew, wrowmsbold, wrowmsbold );
	ret1 = sccb_wr( REGWROWE, wrowe, SCK, RTCDATA );
	ret2 = sccb_wr( REGWROWMSB, wrowmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetRowEnd: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, wrowmsbnew, wrowe );
#endif
	return ( ret1 + ret2 );
}

uint GetColStart(void)
{
	uint cols = 0, wcols, wcolmsb;
	wcols = sccb_rd( REGWCOLS, SCK, RTCDATA );
	wcolmsb = sccb_rd( REGWCOLMSB, SCK, RTCDATA );
	cols = (( wcolmsb & 0x0F )<<8) + wcols;
#ifdef USEPRINTF
	printf( "GetColStart = 0x%x (%d)\n", cols, cols );
#endif	
	return cols;
}

uint SetColStart(uint val)
{
	uint wcols, wcolmsbnew, wcolmsbold, ret1, ret2;
	wcols = val & 0xFF;
	wcolmsbnew = ( val >> 8 ) & 0x0F;
	wcolmsbold = sccb_rd( REGWCOLMSB, SCK, RTCDATA );
	//printf( "wcols = 0x%x (%d), wcolmsbnew = 0x%x (%d), wcolmsbold = 0x%x (%d)\n", wcols, wcols, wcolmsbnew, wcolmsbnew, wcolmsbold, wcolmsbold );
	wcolmsbnew += ( wcolmsbold & 0xF0 );
	//printf( "wcols = 0x%x (%d), wcolmsbnew = 0x%x (%d), wcolmsbold = 0x%x (%d)\n", wcols, wcols, wcolmsbnew, wcolmsbnew, wcolmsbold, wcolmsbold );
	ret1 = sccb_wr( REGWCOLS, wcols, SCK, RTCDATA );
	ret2 = sccb_wr( REGWCOLMSB, wcolmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetColStart: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, wcolmsbnew, wcols );
#endif
	return ( ret1 + ret2 );
}

uint GetColEnd(void)
{
	uint cole = 0, wcole, wcolmsb;
	wcole = sccb_rd( REGWCOLE, SCK, RTCDATA );
	wcolmsb = sccb_rd( REGWCOLMSB, SCK, RTCDATA );
	cole = (( wcolmsb & 0xF0 )<<4) + wcole;
#ifdef USEPRINTF
	printf( "GetColEnd = 0x%x (%d)\n", cole, cole );
#endif	
	return cole;
}

uint SetColEnd(uint val)
{
	uint wcole, wcolmsbnew, wcolmsbold, ret1, ret2;
	wcole = val & 0xFF;
	wcolmsbnew = ( val >> 4 ) & 0xF0;
	wcolmsbold = sccb_rd( REGWCOLMSB, SCK, RTCDATA );
	//printf( "wcole = 0x%x (%d), wcolmsbnew = 0x%x (%d), wcolmsbold = 0x%x (%d)\n", wcole, wcole, wcolmsbnew, wcolmsbnew, wcolmsbold, wcolmsbold );
	wcolmsbnew += ( wcolmsbold & 0x0F );
	//printf( "wcole = 0x%x (%d), wcolmsbnew = 0x%x (%d), wcolmsbold = 0x%x (%d)\n", wcole, wcole, wcolmsbnew, wcolmsbnew, wcolmsbold, wcolmsbold );
	ret1 = sccb_wr( REGWCOLE, wcole, SCK, RTCDATA );
	ret2 = sccb_wr( REGWCOLMSB, wcolmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetColEnd: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, wcolmsbnew, wcole );
#endif
	return ( ret1 + ret2 );
}

uint GetNRows()
{
	uint wrows = 0, wrowe = 0, nrows;
	wrows = GetRowStart();
	wrowe = GetRowEnd();
	nrows = wrowe - wrows + 1;
#ifdef USEPRINTF
	printf( "Number of rows = 0x%x (%d)\n", nrows, nrows );
#endif
	return nrows;
}

uint GetNCols()
{
	uint wcols = 0, wcole = 0, ncols;
	wcols = GetColStart();
	wcole = GetColEnd();
	ncols = wcole - wcols + 1;
#ifdef USEPRINTF
	printf( "Number of cols = 0x%x (%d)\n", ncols, ncols );
#endif
	return ncols;
}

uint GetFrameRate()
{
	uint Npix, RNHclk, Ropcycle = 206, MHfactor, Rdelay, Nrows, MVfactor, Fdelay, FNHclk, FrameRate;
	Npix = GetNCols();
	MHfactor = 1; //Should extract this from HSub in REGSCANCONFIG (0.5 if HSub is enabled)
	Rdelay = GetRDelay();
	RNHclk = Ropcycle + ( Npix * MHfactor ) + Rdelay;
	MVfactor = 1; // As above
	Nrows = GetNRows() * MVfactor;
	Fdelay = GetFDelay();
	FNHclk = ( Nrows + Fdelay + 8 ) * RNHclk;
	FrameRate = 12500000 / FNHclk;
#ifdef USEPRINTF
	//printf( "FrameRate = %d\n", FrameRate );
#endif
	return FrameRate;
}

uint GetUpdate(void)
{
	uint update;
	update = sccb_rd( REGUPDATE, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "update = 0x%x (%d)\n", update, update );
#endif	
	return update;
}

uint SetUpdate(void)
{//should/does reset it's self to 0
	uint update = 1, ret;
	ret = sccb_wr( REGUPDATE, update, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "wrote 0x%x (%d) to REGUPDATE\n", update, update );
#endif	
	return ret;
}

uint GetNPixels(void)
{
	uint nc = GetNCols(), nr = GetNRows();
#ifdef USEPRINTF
	//printf( "Number of pixels = %d\n", nc * nr );
#endif
	return ( nc * nr );
}

uint GetDRowStart(void)
{
	uint rows = 0, drows, drowmsb;
	drows = sccb_rd( REGDROWS, SCK, RTCDATA );
	drowmsb = sccb_rd( REGDROWMSB, SCK, RTCDATA );
	rows = (( drowmsb & 0x0F )<<8) + drows;
#ifdef USEPRINTF
	printf( "GetDRowStart = 0x%x (%d)\n", rows, rows );
#endif	
	return rows;
}

uint SetDRowStart(uint val)
{
	uint drows, drowmsbnew, drowmsbold, ret1, ret2;
	drows = val & 0xFF;
	drowmsbnew = ( val >> 8 ) & 0x0F;
	drowmsbold = sccb_rd( REGDROWMSB, SCK, RTCDATA );
	//printf( "drows = 0x%x (%d), drowmsbnew = 0x%x (%d), drowmsbold = 0x%x (%d)\n", drows, drows, drowmsbnew, drowmsbnew, drowmsbold, drowmsbold );
	drowmsbnew += ( drowmsbold & 0xF0 );
	//printf( "drows = 0x%x (%d), drowmsbnew = 0x%x (%d), drowmsbold = 0x%x (%d)\n", drows, drows, drowmsbnew, drowmsbnew, drowmsbold, drowmsbold );
	ret1 = sccb_wr( REGDROWS, drows, SCK, RTCDATA );
	ret2 = sccb_wr( REGDROWMSB, drowmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetDRowStart: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, drowmsbnew, drows );
#endif
	return ( ret1 + ret2 );
}

uint GetDRowEnd(void)
{
	uint rowe = 0, drowe, drowmsb;
	drowe = sccb_rd( REGDROWE, SCK, RTCDATA );
	drowmsb = sccb_rd( REGDROWMSB, SCK, RTCDATA );
	rowe = (( drowmsb & 0xF0 )<<4) + drowe;
#ifdef USEPRINTF
	printf( "GetDRowEnd = 0x%x (%d)\n", rowe, rowe );
#endif	
	return rowe;
}

uint SetDRowEnd(uint val)
{
	uint drowe, drowmsbnew, drowmsbold, ret1, ret2;
	drowe = val & 0xFF;
	drowmsbnew = ( val >> 4 ) & 0xF0;
	drowmsbold = sccb_rd( REGDROWMSB, SCK, RTCDATA );
	//printf( "drowe = 0x%x (%d), drowmsbnew = 0x%x (%d), drowmsbold = 0x%x (%d)\n", drowe, drowe, drowmsbnew, drowmsbnew, drowmsbold, drowmsbold );
	drowmsbnew += ( drowmsbold & 0x0F );
	//printf( "drowe = 0x%x (%d), drowmsbnew = 0x%x (%d), drowmsbold = 0x%x (%d)\n", drowe, drowe, drowmsbnew, drowmsbnew, drowmsbold, drowmsbold );
	ret1 = sccb_wr( REGDROWE, drowe, SCK, RTCDATA );
	ret2 = sccb_wr( REGDROWMSB, drowmsbnew, SCK, RTCDATA );
#ifdef USEPRINTF
	printf( "SetDRowEnd: wrote 0x%x (%d) (0x%x (msb), 0x%x (lsb))\n", val, val, drowmsbnew, drowe );
#endif
	return ( ret1 + ret2 );
}

uint SetScanWindow(uint xStart, uint xEnd, uint yStart, uint yEnd)
{
	uint rows, rowe, rmsbnew, cols, cole, cmsbnew, ret;

	rows = yStart & 0xFF;
	rmsbnew = ( yStart >> 8 ) & 0x0F;

	rowe = yEnd & 0xFF;
	rmsbnew += ( ( yEnd >> 4 ) & 0xF0 );

	ret = sccb_wr( REGWROWS, rows, SCK, RTCDATA );
	ret = sccb_wr( REGWROWE, rowe, SCK, RTCDATA );
	ret = sccb_wr( REGWROWMSB, rmsbnew, SCK, RTCDATA );

	cols = xStart & 0xFF;
	cmsbnew = ( xStart >> 8 ) & 0x0F;

	cole = xEnd & 0xFF;
	cmsbnew += ( ( xEnd >> 4 ) & 0xF0 );

	ret = sccb_wr( REGWCOLS, cols, SCK, RTCDATA );
	ret = sccb_wr( REGWCOLE, cole, SCK, RTCDATA );
	ret = sccb_wr( REGWCOLMSB, cmsbnew, SCK, RTCDATA );

#ifdef USEPRINTF
	printf( "SetScanWindow to %d by %d, %d, %d\n", yStart, yEnd, xStart, xEnd );
#endif
	return ret;
}

uint SetDisplayWindow(uint yStart, uint yEnd)
{
	uint drows, drowe, msbnew, ret;
	drows = yStart & 0xFF;
	msbnew = ( yStart >> 8 ) & 0x0F;

	drowe = yEnd & 0xFF;
	msbnew += ( ( yEnd >> 4 ) & 0xF0 );

	ret = sccb_wr( REGDROWS, drows, SCK, RTCDATA );
	ret = sccb_wr( REGDROWE, drowe, SCK, RTCDATA );
	ret = sccb_wr( REGDROWMSB, msbnew, SCK, RTCDATA );

#ifdef USEPRINTF
	printf( "SetDisplayWindow to %d by %d\n", yStart, yEnd );
#endif
	return ret;
}
