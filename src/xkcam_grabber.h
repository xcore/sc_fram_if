#ifndef KCAM_GRABBER_H_
#define KCAM_GRABBER_H_

#include <platform.h>

#define uint unsigned

void KCAM_reset();
void kcam_run(void);
void GrabFrame128x128HVSub(in port p_href, in port p_vsync, buffered in port:32 p_DIN32);
void Grab64x40BlocksSUB(in port p_href, in port p_vsync, buffered in port:32 p_DIN32, chanend pixels);
void ImProc(chanend pixels);

#endif /*KCAM_GRABBER_H_*/
