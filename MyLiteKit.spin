{Comment Documentation}       'or line comments  F8 to run code   F7 to detect/reset board   F10 to load Ram  F11 to load EEPROM
{                              'F12 for Parallex Serial Terminal
 Project: MyLiteKit.spin
 Platform: Parallax Project USB Board
 Revision: 1.4
 Author: Timothy Lee
 Date: 21 November 2021
 Log:
Date: Desc
      14/11/2021: Implemented movement
      15/11/2021: Implemented repeats
      20/11/2021: Edited from SensorControl.spin to create a main to access the sensor values
      21/11/2021: Increased # of Pause functions to create buffer time between calling of functions that require longer processing time (motor movement & sensor reading)
      21/11/2021: Created rxValue in Main and call to Comm.
}

CON  'Cannot be changed during run time
        _clkmode = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000                'clkfreq = 1 sec, clkfreq/2

        'To create a Pause
        _ConClkFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001 = _ConClkFreq / 1_000

VAR     'Global variable
  long ToFFront, ToFBack, UltraFront, UltraBack '<-- Sensor Variables
  long Signal                                   '<-- Comm Control Variables

OBJ
  Sensor    : "SensorControl.spin"        'Object / Blackbox
  Motor     : "MotorControl.spin"         'Motor Movement
  Comm      : "CommControl.spin"          'For Manual Control
PUB Main
  Motor.Init
  Sensor.Start(_Ms_001, @ToFFront, @ToFBack, @UltraFront, @UltraBack)
  Comm.Start(_Ms_001, @Signal)
  Pause(1000)                                'For setup
  'Run & get readings
  repeat                                     '1 Forward, 2 Reverse, 3 StopAllMotors
    Pause(50)                                '4 Turn Left, 5 Turn Right
    case Signal
      1:                     'Stops if no ground or an obstacle is present infront
         if (ToFFront > 180) | (UltraFront < 345)
           Motor.Movement(3)
         else
           Motor.Movement(1)                 'Forwards

      2:                     'Stops if no ground or an obstacle is present behind
         if (ToFBack > 180) | (UltraBack < 345)
           Motor.Movement(3)
         else
           Motor.Movement(2)                 'Reverses

      3:
        Motor.Movement(3)

      4:                     'Sensor control for caution
        if (ToFFront > 180) | (UltraFront < 345) | (ToFBack > 180) | (UltraBack < 345)
          Motor.Movement(3)
        else
          Motor.Movement(4)                  'Turn Left

      5:                     'Sensor control for caution
        if (ToFFront > 180) | (UltraFront < 345) | (ToFBack > 180) | (UltraBack < 345)
          Motor.Movement(3)
        else
          Motor.Movement(5)                  'Turn Right

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)      '#> limit minimum
    waitcnt (t += _Ms_001)
  return

DAT
{
  'Run & get readings
   repeat
      Term.Str(String(13, "Ultrasonic Front Reading: "))
      Term.Dec(UltraFront)
      Term.Str(String(13, "Ultrasonic Rear Reading: "))
      Term.Dec(UltraBack)
      Term.Str(String(13, "ToF Front Reading: "))
      Term.Dec(ToFFront)
      Term.Str(String(13, "ToF Rear Reading: "))
      Term.Dec(ToFBack)
      Pause(300) 'Wait .3sec
      Term.Tx(0)                                        'ASCII code table 0 is to clear screen

}

 {     Motor.Movement(1)         'Motor speed setup / Movement control setup
      Pause(2000)
      Motor.Movement(3)
      Pause(1000)
      Motor.Movement(2)
      Pause(2000)
      Motor.Movement(3)
      Pause(1000)
      Motor.Movement(4)
      Pause(2000)
      Motor.Movement(3)
      Pause(1000)
      Motor.Movement(5)
      Pause(2000)
      Motor.Movement(3)
      Pause(1000)             }