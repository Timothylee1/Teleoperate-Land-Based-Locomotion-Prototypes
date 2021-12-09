{Comment Documentation}       'or line comments  F8 to run code   F7 to detect/reset board   F10 to load Ram  F11 to load EEPROM
{                              'F12 for Parallex Serial Terminal
 Project: MyLiteKit.spin
 Platform: Parallax Project USB Board
 Revision: 1.5
 Author: Timothy Lee
 Date: 01 December 2021
 Log:
Date: Desc
      14/11/2021: Implemented movement
      15/11/2021: Implemented repeats
      20/11/2021: Edited from SensorControl.spin to create a main to access the sensor values
      21/11/2021: Increased # of Pause functions to create buffer time between calling of functions that require longer processing time (motor movement & sensor reading)
      21/11/2021: Created rxValue in Main and call to Comm.
      01/12/2021: Modified movement controls in Main to detect for allowable movement.
}

CON  'Cannot be changed during run time
        _clkmode = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000               'clkfreq = 1 sec, clkfreq/2

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
  'Create a hardware definition file
  'Not using, comment it out else it'll use a cog
PUB Main                       'Doesn't matter what name it has, spin runs the first function
  'Declaration & Initialization
  Motor.Init
  Sensor.Start(_Ms_001, @ToFFront, @ToFBack, @UltraFront, @UltraBack)
  Comm.Start(_Ms_001, @Signal)
  Pause(1000)          'For setup

  'check dat for movement control init before testing

  'Run & get readings
  repeat
    Pause(50)                                                '1 Forwards, 2 Reverses, 3 StopAllMotors
    case Signal                                              '4 Turn Left, 5 Turn Right
      1:
         if (ToFFront < 180) AND (UltraFront > 300)          'Does not detect edge or obstacle
           Motor.Movement(1)                                 'Forwards

         else
            Motor.Movement(3)
      2:
         if (ToFBack < 180) AND  (UltraBack > 300)           'Does not detect edge or obstacle
           Motor.Movement(2)                                 'Reverses

         else
           Motor.Movement(3)
      3:
           Motor.Movement(3)                                 'Stops all motors
      4:                                                     'Does not detect edge or obstacle (caution; not required)
         if (ToFBack < 180) OR (UltraBack > 300) OR (ToFFront < 180) OR (UltraFront > 300)  
           Motor.Movement(4)                                 'Turn Left

         else
           Motor.Movement(3)
      5:                                                     'Does not detect edge or obstacle (caution; not required)
         if (ToFBack < 180) OR (UltraBack > 300) OR (ToFFront < 180) OR (UltraFront > 300)  
           Motor.Movement(4)                                 'Turn Right

         else
           Motor.Movement(3)

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

}             ' elseif (ToFBack > 180) | (UltraBack < 300)

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
