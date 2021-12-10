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
'        _clkmode         = xtal1 + pll16x          'Standard clock mode * crystal frequency = 80 MHz
'        _xinfreq         = 5_000_000                'clkfreq = 1 sec, clkfreq/2
'        _ConClkFreq      = ((_clkmode - xtal1) >> 6) * _xinfreq
'        _Ms_001          = _ConClkFreq / 1_000

        commRxPin        = 20         'DIN
        commTxPin        = 21         'DOUT
        commBaud         = 9600

        commStart        = $7A
        commForward      = $01
        commReverse      = $02
        commTurnLeft     = $03
        commTurnRight    = $04
        commStopAll      = $AA

        forward = 1
        reverse = 2
        stopall = 3
        turnl = 4
        turnr = 5

VAR     'Global variable
long cogIDCom, comStack[128]   'allocates memory to the Stack for new cog
long _Ms_001

OBJ
  Comm      : "FullDuplexSerial.spin"     'UART Communication
  'Create a hardware definition file

PUB Start(mainMSVal, signalADD)

  _Ms_001 := mainMSVal         'For Pause

  Stop                         'stops & frees cogIDCom to prevent recalling

  Pause(800)                   'Buffer

  cogIDCom := cognew(ManualControl(signalADD), @comStack)

  Return

PUB Stop
  if cogIDCom
      cogstop (cogIDCom~)       'Cog~ Post-Clear returns Cog to value 0

PUB ManualControl (signalADD)| rxValue'Doesn't matter what name it has, spin runs the first function
  'Declaration & Initialisation
  Comm.Start(commTxPin, commRxPin, 0, commBaud)
  Pause(200)
  'Run & get readings
   repeat
      'rxValue := Comm.Rx       'This causes an infinite loop of waiting till a byte is received
      rxValue := Comm.RxCheck   'Check for byte and continues to next step
      if rxValue == commStart   'If received byte is $A7 or commStart proceed to next step, else continue
        rxValue := Comm.Rx      'Waits for 'directional' input
        case rxValue
          commForward:
              long[signalADD] := forward

          commReverse:
              long[signalADD] := reverse

          commTurnLeft:
              long[signalADD] := turnl

          commTurnRight:
              long[signalADD] := turnr

          commStopAll:
               long[signalADD] := stopall

PRI Pause(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)      '#> limit minimum
    waitcnt (t += _Ms_001)
  return