{
  Project : EE-6 MotorControl.spin
  Platform: Parallax Project USB Board
            Lite Kit
  Revision: 1.4
  Author  : Timothy Lee
  Date    : 08/11/21
  Log     :
  Date    : Desc
            01/11/2021: Added 4 Motor Zeroing
            08/11/2021: Added Movement code and everything else included inside
            14/11/2021: Commented functions within Forward, Reverse, TurnRight, and TurnLeft
            21/11/2021: Implemented cog movement
}

CON

  _clkmode = xtal1 + pll16x                      'Standard clock mode * crystal frequency = 80 MHz
  _xinfreq = 5_000_000

  'Creating a Pause()
  _ConClickFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _MS_001 = _ConClickFreq / 1_000

  'Declare Pins for Motors
  motor1 = 10
  motor2 = 11
  motor3 = 12
  motor4 = 13

  'Declare Zero Speed for Motors
  motor1Zero = 1520
  motor2Zero = 1520
  motor3Zero = 1520
  motor4Zero = 1520

VAR

  long MovementCoreStack[64]
  long cogIDM

OBJ ' Objects

  Motors  : "Servo8Fast_vZ2.spin"
{
PUB m
  init
  pause(250)
  movement(1)
  pause(1000)
  movement(2)
  pause(1000)
  movement(3)
  pause(1000)
}

PUB Movement (Move)
  Pause(250)
  Stop
  Pause(250)
  case Move
    1:
      cogIDM := cognew(Forward(90), @MovementCoreStack)
      Pause(250)
    2:
      cogIDM := cognew(Reverse(70), @MovementCoreStack)
      Pause(250)
    3:
     cogIDM := cognew(StopAllMotors, @MovementCoreStack)
     Pause(250)
    4:
     cogIDM := cognew(TurnLeft(100), @MovementCoreStack)           'To adjust during actual testing
     Pause(250)
    5:
     cogIDM := cognew(TurnRight(100), @MovementCoreStack)          'To adjust during actual testing
     Pause(250)

PUB Init

  Motors.Init
  Motors.AddSlowPin(motor1)
  Motors.AddSlowPin(motor2)
  Motors.AddSlowPin(motor3)
  Motors.AddSlowPin(motor4)
  Motors.Start
  Pause(500)
'  StopAllMotors

PUB StopAllMotors

  Set(motor1, motor1Zero)
  Set(motor2, motor2Zero)
  Set(motor3, motor3Zero)
  Set(motor4, motor4Zero)

PUB Stop

  if cogIDM
    cogstop(cogIDM~)

PUB Set (motor, speed)

  case motor
    10:
      speed += motor1Zero
      Motors.Set(motor1, speed)
    11:
      speed += motor2Zero
      Motors.Set(motor2, speed)
    12:
      speed += motor3Zero
      Motors.Set(motor3, speed)
    13:
      speed += motor4Zero
      Motors.Set(motor4, speed)

PUB Forward (speed)

  Set(motor1, +speed)
  Set(motor2, +speed)
  Set(motor3, +speed)
  Set(motor4, +speed)

PUB Reverse (speed)

  Set(motor1, -speed)
  Set(motor2, -speed)
  Set(motor3, -speed)
  Set(motor4, -speed)

PUB TurnLeft (speed)

  Set(motor1, +speed)
  Set(motor2, -50)
  Set(motor3, +speed)
  Set(motor4, -50)

PUB TurnRight (speed)

  Set(motor1, -50)
  Set(motor2, +speed)
  Set(motor3, -50)
  Set(motor4, +speed)

PRI Pause(ms) | t

  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)
  return

DAT
{

  Pause(3000)
  StopAllMotors
  Pause(1500)

  Pause(2700)
  StopAllMotors
  Pause(1500)
}