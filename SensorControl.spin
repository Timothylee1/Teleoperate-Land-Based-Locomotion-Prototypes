{Comment Documentation}       'or line comments  F8 to run code   F7 to detect/reset board   F10 to load Ram  F11 to load EEPROM
{                              'F12 for Parallex Serial Terminal
 Project: SensorControl.spin
 Platform: Parallax Project USB Board
 Revision: 1.3
 Author: Timothy Lee
 Date: 20 November 2021
 Log:
Date: Desc
      13/11/2021: Created Initialization of ToFs and Ultras
      14/11/2021: Created Read functions for Tofs and Ultras..
      20/11/2021: Casting for variables to act as pointers
      20/11/2021: Created a "black box", where the internal workings are hidden; Code does its thing, Main program can retreive values from their addresses
}

CON  'Cannot be changed during run time
'        _clkmode = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
'        _xinfreq = 5_000_000                'clkfreq = 1 sec, clkfreq/2
'        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
'        _Ms_001 = _ConClkFreq / 1_000

        ''[Declare Pins for Sensors]
        'Ultrasonic 1 Front    - I2C Bus 1
        frontscl1 = 6
        frontsda1 = 7

        'Ultrasonic 3 Back     - I2C Bus 2
        backscl2 = 8          'Trig
        backsda2 = 9          'Echo

        'Time of Flight 1
        tof1SCL = 0
        tof1SDA = 1
        tof1RST = 14            'reset

        'Time of Flight 2
        tof2SCL = 2
        tof2SDA = 3
        tof2RST = 15            'reset

        tofAdd = $29           'address
VAR     'Global variable
  long cogIDNum, cogStack[128]         'allocates memory to the Stack for new cog
  long _Ms_001

OBJ
  Ultra     : "EE-7_Ultra_v2.spin"        'Embedded a 2-element obj within file
  ToF[2]    : "EE-7_TOF.spin"

  'Create a hardware definition file

PUB Start(mainMSVal, mainToF1Add, mainToF2Add, mainUltra1Add, mainUltra2Add)

  _Ms_001 := mainMSVal         'For Pause

  Stop                         'stops & frees cogIDNum to prevent recalling

  Pause(800)                   'Buffer

  cogIDNum := cognew(sensorCore(mainToF1Add, mainToF2Add, mainUltra1Add, mainUltra2Add), @cogStack)

  Return

PUB Stop
  if cogIDNum
      cogstop (cogIDNum~)       'Cog~ Post-Clear returns Cog to value 0

PUB sensorCore(mainToF1Add, mainToF2Add, mainUltra1Add, mainUltra2Add)

  'Declaration & Initialisation
   Ultra.Init(frontscl1, frontsda1, 0)                  'Assigning & init the first element obj in EE-7_Ultra_v2
   Ultra.Init(backscl2, backsda2, 1)                    'Assigning & init the second element obj in EE-7_Ultra_v2

   ToFInit                                              'Perform init for both ToF sensors
   Pause(100)
   'Run & get readings
   repeat
      long[mainUltra1Add] := Ultra.readSensor(0)         'Reading from first element obj
      long[mainUltra2Add] := Ultra.readSensor(1)         'Reading from second element obj
      long[mainToF1Add] := ToF[0].GetSingleRange(tofadd) 'long[name] to cast the variable as long
      long[mainToF2Add] := ToF[1].GetSingleRange(tofadd)
      Pause(100)

PRI ToFInit

    ToF[0].Init(tof1SCL, tof1SDA, tof1RST)
    ToF[0].ChipReset(1)              'Last state is ON position
    Pause(1000)
    ToF[0].FreshReset(tofadd)        'New reset
    ToF[0].MandatoryLoad(tofadd)     'Load code
    ToF[0].RecommendedLoad(tofadd)
    ToF[0].FreshReset(tofadd)        'New reset

    ToF[1].Init(tof2SCL, tof2SDA, tof2RST)
    ToF[1].ChipReset(1)              'Last state is ON position
    Pause(1000)
    ToF[1].FreshReset(tofadd)        'New reset
    ToF[1].MandatoryLoad(tofadd)     'Load code
    ToF[1].RecommendedLoad(tofadd)
    ToF[1].FreshReset(tofadd)        'New reset

    Return

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)                   '#> limit minimum
    waitcnt (t += _Ms_001)
  return