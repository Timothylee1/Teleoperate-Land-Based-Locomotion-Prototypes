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
  long  ToFFront, ToFBack, UltraFront, UltraBack

OBJ
  Term      : "FullDuplexSerial.spin"     'UART Communication
  Sensor    : "SensorControl.spin"        'Object / Blackbox
  Motor     : "MotorControl.spin"         'Motor Movement
  Comm      : "CommControl.spin"          'For Manual Control
  'Create a hardware definition file
  'Not using, comment it out else it'll use a cog
PUB Main    | rxValue                    'Doesn't matter what name it has, spin runs the first function

  'Declaration & Initialization
  Term.Start(31, 30, 0, 115200)
  Motor.Init
  Sensor.Start(_Ms_001, @ToFFront, @ToFBack, @UltraFront, @UltraBack)
  Pause(2000)          'For setup

  'Run & get readings
  repeat
    Pause(50) 'buffer
    rxValue := Term.RxCheck   'Check for byte and continues to next step
    if rxValue == $7A         'If received byte is commStart proceed to next step, else continue
      Comm.ManualControl
    else
      if (ToFFront > 160) | (UltraFront < 300)            'Stops if no ground or an obstacle is present infront
        Motor.Movement(3)                                 'Movement 1 = forward, 2 = reverse, 3 is stopallmotors
        Pause(1000)
        repeat
          Pause(1000)
          if (ToFBack > 160) | (UltraBack < 250)          'Stops if no ground or an obstacle is present behind
            Motor.Movement(3)
            Pause(1000)
            QUIT
          elseif (ToFBack <= 160) & (UltraBack => 250)    'Reverse if on ground and no obstacle behind
            Motor.Movement(2)
            Pause(250)
      elseif (ToFFront <= 160) & (UltraFront => 300)      'Forwards if on ground and no obstacles in front
        Motor.Movement(1)

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