{Comment Documentation}       'or line comments  F8 to run code   F7 to detect/reset board   F10 to load Ram  F11 to load EEPROM
{                              'F12 for Parallex Serial Terminal
 Project: EE-7 SensorControl.spin
 Platform: Parallax Project USB Board
 Revision: 1.2
 Author: Timothy Lee
 Date: 14 November 2021
 Log:
Date: Desc
      13/11/2021: Created Initialization of ToFs and Ultras
      14/11/2021: Created Read functions for Tofs and Ultras
}

CON  'Cannot be changed during run time
        _clkmode = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000                'clkfreq = 1 sec, clkfreq/2
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

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

OBJ
'  Term      : "FullDuplexSerial.spin"     'UART Communication
  Ultra     : "EE-7_Ultra_v2.spin"        'Embedded a 2-element obj within file
  ToF[2]    : "EE-7_TOF.spin"

PUB Init
    'ToF Initialization
    ToF[0].Init(tof1SCL, tof1SDA, tof1RST)       'Front
    ToF[0].ChipReset(1)                          'Last state is ON position
    Pause(250)
    ToF[0].FreshReset(tofadd)                    'New reset
    ToF[0].MandatoryLoad(tofadd)                 'Load code
    ToF[0].RecommendedLoad(tofadd)
    ToF[0].FreshReset(tofadd)                    'New reset
    Pause(100)                                   'Delay
    ToF[1].Init(tof2SCL, tof2SDA, tof2RST)       'Back
    ToF[1].ChipReset(1)                          'Last state is ON position
    Pause(250)
    ToF[1].FreshReset(tofadd)                    'New reset
    ToF[1].MandatoryLoad(tofadd)                 'Load code
    ToF[1].RecommendedLoad(tofadd)
    ToF[1].FreshReset(tofadd)                    'New reset
    Pause(100)

    'Ultrasonic Initialization
     Ultra.Init(frontscl1, frontsda1, 0)         'Front
     Ultra.Init(backscl2, backsda2, 1)           'Back

PUB ReadToF(SensorNum)     | Front, Back

 repeat
   if SensorNum == 1                             'Front
    Front := ToF[0].GetSingleRange(tofadd)
'    Term.Str(String(13,"TOF 1 Readings: "))      '13 == '\n'
'    Term.dec(Front)
    Return Front

   elseif SensorNum == 2                         'Back
    Back := ToF[1].GetSingleRange(tofadd)
'    Term.Str(String(13,"TOF 2 Readings: "))      '13 == '\n'
'    Term.dec(Back)
    Return Back

PUB ReadUltrasonic(SensorNum)   | Front, Back

 repeat
   if SensorNum == 1
     Front := Ultra.readSensor(0)
'     Term.Str(String(13, "Ultrasonic 1 Readings: "))           '
'     Term.Dec(Front)
     Return Front

   elseif SensorNum == 2
     Back := Ultra.readSensor(1)
'     Term.Str(String(13, "Ultrasonic 2 Readings: "))
'     Term.Dec(Back)
     Return Back

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)      '#> limit minimum
    waitcnt (t += _Ms_001)
  return