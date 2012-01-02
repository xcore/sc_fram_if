#ifndef KCAM_I2C_H_
#define KCAM_I2C_H_

//See "MTD-PS-1170 KAC-00401_Revision 1.0 MTDPS-1070.pdf" (local copy) for full documentation, found at:
//http://www.micronkk.com/1_imaging/kodak/DataSheet/KAC-00401%20Rev.1.0.pdf
#define uint unsigned

#define REGDEVID 0x00 //Device ID, read only, reset value 0x18
#define REGREV 0x01 //Silicon revision, read only, reset value 0xC0
#define REGVCLKGEN 0x02 //Clock generation, read/write, reset value 0x01
#define REGMODECTL 0x03 //Mode and Control, read/write, reset value 0x0D
#define REGSCANCONFIG 0x08 //Scan Configuration, read/write, reset value 0x00
#define REGI2CMODE 0x09 //I2C Mode, read/write, reset value 0x55
#define REGVMODE0 0x0A //Digital Video Mode 0, read/write, reset value 0x00
#define REGVMODE1 0x0B //Digital Video Mode 1, read/write, reset value 0x00
#define REGWROWS 0x0C //Scan Window Start Row, read/write, reset value 0x00
#define REGWROWE 0x0D //Scan Window End Row, read/write, reset value 0xE7
#define REGWROWMSB 0x0E //Scan Window Row MSB, read/write, reset value 0x10
#define REGWCOLS 0x0F //Scan Window Start Column, read/write, reset value 0x09
#define REGWCOLE 0x10 //Scan Window End Column, read/write, reset value 0xF6
#define REGWCOLMSB 0x11 //Scan Window Column MSB, read/write, reset value 0x20
#define REGFDELAYL 0x12 //Frame Delay Low, read/write, reset value 0x00
#define REGFDELAYH 0x13 //Frame Delay High, read/write, reset value 0x00
#define REGRDELAYL 0x14 //Row Delay Low, read/write, reset value 0x00
#define REGRDELAYH 0x15 //Row Delay High, read/write, reset value 0x00
#define REGBLKLEVCONFIG5 0x29 //Black Level Configuration 5, reset value 0x00
#define REGPGA0 0x40 //Analogue gain 0, reset 0x00
#define REGPGA1 0x41 //Analogue gain 1, reset 0x00
#define REGPGA2 0x42 //Analogue gain 2, reset 0x00
#define REGPGA3 0x43 //Analogue gain 3, reset 0x00
#define REGFGA 0x44 //Global analogue gain, reset 0x00
#define REGCPCLKGEN 0x50 //Charge Pump Clock Generation, reset value 0x01
#define REGDROWS 0x70 //Display Window Start Row, read/write, reset value ??
#define REGDROWE 0x71 //Display Window End Row, read/write, reset value ??
#define REGDROWMSB 0x72 //Display Window Row MSB, read/write, reset value ??
#define REGUPDATE 0xD0 //Update registers that have been double buffered, read/write, reset value 0x00


//'Higher' level interface:
void initI2C(void);

uint GetRowStart(void);
uint SetRowStart(uint val);
uint GetRowEnd(void);
uint SetRowEnd(uint val);
uint GetColStart(void);
uint SetColStart(uint val);
uint GetColEnd(void);
uint SetColEnd(uint val);
uint GetDRowStart(void);
uint SetDRowStart(uint val);
uint GetDRowEnd(void);
uint SetDRowEnd(uint val);

uint SetScanWindow(uint xstart, uint xend, uint ystart, uint yend);
uint SetDisplayWindow(uint ystart, uint yend);

uint GetNRows(void);
uint GetNCols(void);

uint GetFrameRate(void);

uint GetUpdate(void);
uint SetUpdate(void);

uint GetNPixels(void);

//'Low' level register interface:
uint GetDevID(void);
uint GetRev(void);
uint GetVClkGen(void);
uint SetVClkGen(uint val);
uint GetModeCtl(void);
uint SetModeCtl(uint val);
uint GetScanConfig(void);
uint SetScanConfig(uint val);
uint GetI2CMode(void);
uint SetI2CMode(uint val);
uint GetVMode0(void);
uint SetVMode0(uint val);
uint GetVMode1(void);
uint SetVMode1(uint val);
uint GetWRowS(void);
uint SetWRowS(uint val);
uint GetWRowE(void);
uint SetWRowE(uint val);
uint GetWRowMSB(void);
uint SetWRowMSB(uint val);
uint GetWColS(void);
uint SetWColS(uint val);
uint GetWColE(void);
uint SetWColE(uint val);
uint GetWColMSB(void);
uint SetWColMSB(uint val);
uint GetFDelay(void);
uint SetFDelay(uint val);
uint GetRDelay(void);
uint SetRDelay(uint val);
uint GetCPClkGen(void);
uint SetCPClkGen(uint val);
uint GetDWRowS(void);
uint SetDWRowS(uint val);
uint GetDWRowE(void);
uint SetDWRowE(uint val);
uint GetDWRowMSB(void);
uint SetDWRowMSB(uint val);
uint GetBLKLevConfig5(void);
uint SetBLKLevConfig5(uint val);
uint GetPGA0(void);
uint SetPGA0(uint val);
uint GetPGA1(void);
uint SetPGA1(uint val);
uint GetPGA2(void);
uint SetPGA2(uint val);
uint GetPGA3(void);
uint SetPGA3(uint val);
uint GetFGA(void);
uint SetFGA(uint val);


#endif /*KCAM_I2C_H_*/
