{Comment Documentation}       'or line comments  F8 to run code   F7 to detect/reset board   F10 to load Ram  F11 to load EEPROM
{                              'F12 for Parallex Serial Terminal
 Project: CommControl.spin
 Platform: Parallax Project USB Board
 Revision: 1.1
 Author: Timothy Lee
 Date: 21 November 2021
 Log: Brief overview --> This is for Manual control of the Lite Kit
Date: Desc
      21/11/2021: Created spin code to allow for manual control of Lite Kit movement via wireless connection through Xbee
      21/11/2021: Included call to movement in motor
}

CON  'Cannot be changed during run time
        _clkmode         = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq         = 5_000_000                'clkfreq = 1 sec, clkfreq/2
        _ConClkFreq      = ((_clkmode - xtal1) >> 6) * _xinfreq
        _Ms_001          = _ConClkFreq / 1_000

        commRxPin        = 20
        commTxPin        = 21
        commBaud         = 9600

        commStart        = $7A
        commForward      = $01
        commReverse      = $02
        commTurnLeft     = $03
        commTurnRight    = $04
        commStopAll      = $AA

OBJ
  Comm      : "FullDuplexSerial.spin"     'UART Communication
  Motor     : "MotorControl.spin"         'Motor Movement

PUB ManualControl | rxValue'Doesn't matter what name it has, spin runs the first function

  'Declaration & Initialisation
  Comm.Start(commTxPin, commRxPin, 0, commBaud)
  Pause(1000)                   'Wait 1sec

  'Run & get readings
   repeat
      Pause(50)
      'rxValue := Comm.Rx       'This causes an infinite loop of waiting till a byte is received
      rxValue := Comm.RxCheck   'Check for byte and continues to next step
      if rxValue == commStart   'If received byte is $A7 or commStart proceed to next step, else continue
        rxValue:= Comm.RxCheck  'Checks as for 'directional' input
        case rxValue
          commForward:
              Motor.Movement(1)

          commReverse:
              Motor.Movement(2)

          commTurnLeft:
              Motor.Movement(4)

          commTurnRight:
              Motor.Movement(5)

          commStopAll:
              Motor.Movement(3)
      else
        Comm.Stop                 'Frees cog for MyLiteKit to use
        Quit                      'Exit

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)      '#> limit minimum
    waitcnt (t += _Ms_001)
  return