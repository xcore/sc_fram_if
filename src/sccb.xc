///////////////////////////////////////////////////////////////////////////////////////
//
// Camera Image Processing Demo
// Version 1.0
//
// sccb.xc
// SCCB configuration interface driver (OmniVision's I2C):*** adapted for Kodak KAC-401 sensor
//
// Copyright (C) 2009 XMOS Ltd
//
// Only for writing, pull up not available for reading (internal too weak)
//
// Specification:
//   http://www4.cs.umanitoba.ca/~jacky/Robotics/DataSheets/ov-sccb.pdf
//
// Discussion:
//   http://e2e.ti.com/forums/p/6233/23647.aspx
//   http://www.avrfreaks.net/index.php?name=PNphpBB2&file=viewtopic&t=77832
//   http://www.embeddedrelated.com/usenet/embedded/show/4589-1.php
//

#include <xs1.h>
#include <print.h>

// Device ID
#define DEVICE_ID 0x55 //was 0x21, ID of KAC-401 is 0x21 or could be 0x33

#ifdef SIM
// Units of 10ns (default clock block)
//#define T 100
#else
// Units of 1us (clock block with divider of 50)
#define T 4 //was 1000
#endif

// Data toggles when SIOC is 0 (must be stable when SIOC is 1)

static void phase1(char type, port sioc, port siod)
{
  int data = (DEVICE_ID << 1) | (type == 'r');
  int t;
  sioc <: 1 @ t;

  for (int i = 0; i < 8; i++)
  {
    t += T;
    sioc @ t <: 0;
    siod @ (t + T / 4) <: data >> (7 - i);
    sioc @ (t + T / 2) <: 1;
  }

  // Don't care cycle - let go off SIOD
  t += T;
  sioc @ t <: 0;
  siod @ (t + T / 4) :> int;
  sioc @ (t + T / 2) <: 1;
}

static void phase2w(int data, port sioc, port siod)
{
  int t;
  sioc <: 1 @ t;

  for (int i = 0; i < 8; i++)
  {
    t += T;
    sioc @ t <: 0;
    siod @ (t + T / 4) <: data >> (7 - i);
    sioc @ (t + T / 2) <: 1;
  }

  // Don't care cycle - let go of SIOD
  t += T;
  sioc @ t <: 0;
  siod @ (t + T / 4) :> int;
  sioc @ (t + T / 2) <: 1;
}

static int phase2r(port sioc, port siod)
{
  int data = 0;
  int t;
  sioc <: 1 @ t;
  t += T / 2;

  for (int i = 0; i < 8; i++)
  {
    int bit;
    t += T / 2;
    sioc @ t <: 0;
    t += T / 2;
    sioc @ t <: 1;
    siod @ (t + T / 4) :> bit;
    data |= bit << (7 - i);
  }

  // N/A cycle - drive SIOD 1
  t += T / 2;
  sioc @ t <: 0;
  siod @ (t + T / 4) <: 1;
  t += T / 2;
  sioc @ t <: 1;

  return data;
}

static void phase3(int data, port sioc, port siod)
{
  int t;
  sioc <: 1 @ t;

  for (int i = 0; i < 8; i++)
  {
    t += T;
    sioc @ t <: 0;
    siod @ (t + T / 4) <: data >> (7 - i);
    sioc @ (t + T / 2) <: 1;
  }

  // Don't care cycle - let go off SIOD
  t += T;
  sioc @ t <: 0;
  siod @ (t + T / 4) :> int;
  sioc @ (t + T / 2) <: 1;
}

static void sccb_start(port sioc, port siod)
{
  // Start of transmission is SIOD going 0 while SIOC is 1
  int t;
  sync(sioc);
  sioc <: 1 @ t;
  siod @ (t + T) <: 1;
  siod @ (t + 3 * T) <: 0;
  sync(siod);
}

static void sccb_stop(port sioc, port siod)
{
  // End of transmission is SIOD going 1 while SIOC is 1
  int t;
  sync(sioc);
  sioc <: 1 @ t;
  t += T / 2;
  sioc @ t <: 0;
  siod @ (t + T / 4) <: 0;
  t += T / 2;
  sioc @ t <: 1;
  t += T;
  siod @ t <: 1;
  sync(siod);
}

void sccb_init(port sioc, port siod, clock siob)
{
#ifndef SIM
  // Need 1us period - frequency 1MHz - divider of 50
  set_clock_div(siob, 16); //was 50, 16 is much faster, couldn't get it faster, used with xkcam
  set_port_clock(sioc, siob);
  set_port_clock(siod, siob);
  start_clock(siob);
#endif

  // Internal pull up - not strong enough to enable reading back
  //set_port_pull_up(siod); //Don't know if I need this for kcam
  //This causes:
  //xrun: Program received signal ET_ECALL, Application exception raised.
  //0x00010570 in set_port_pull_up ()

  // SIOC and SIOD are 1 when bus idle
  sioc <: 1;
  siod <: 1;
}

int sccb_rd(int reg, port sioc, port siod)
{
  int val;
  sioc <: 1;
  siod <: 1;
  sccb_start(sioc, siod);
  phase1('w', sioc, siod);
  phase2w(reg, sioc, siod);
  sccb_stop(sioc, siod);
  sccb_start(sioc, siod);
  phase1('r', sioc, siod);
  val = phase2r(sioc, siod);
  sccb_stop(sioc, siod);
  return val;
}

int sccb_wr(int reg, int val, port sioc, port siod)
{
  int ret;
  sioc <: 1;
  siod <: 1;
  sccb_start(sioc, siod);
  phase1('w', sioc, siod);
  phase2w(reg, sioc, siod);
  phase3(val, sioc, siod);
  sccb_stop(sioc, siod);
  //sccb_start(sioc, siod); //Can do without this, 29/12/09, it seems to return 0xFF in kcam context
  ret = 0;//phase2r(sioc, siod);
  //sccb_stop(sioc, siod);
  return ret;
}
