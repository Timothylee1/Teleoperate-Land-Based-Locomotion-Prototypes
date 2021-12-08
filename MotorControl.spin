{
  Project : EE-6 MotorControl.spin
  Platform: Parallax Project USB Board
            Lite Kit
  Revision: 1.2
  Author  : Timothy Lee
  Date    : 08/11/21
  Log     :
            Date      : Desc
            01/11/2021: Added 4 Motor Zeroing
            08/11/2021: Added Movement code and everything else included inside
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
  long stack[128]                     'allocates memory to the Stack for new cog
  long Cog                            'long is 4 bytes long or 32-bits long
OBJ ' Objects
  Motors  : "Servo8Fast_vZ2.spin"     'Servo motor Spin file
  'Term    : "FullDuplexSerial.spin"  'Universal Asynchronous Receiver Transmitter (UART) communication

PUB Start
'  StopCog                             'Stops cog activation and frees it
  Init                                'Init motors
  StopAllMotors                       'Set servo motors to zero-ed position
  Pause(5000)                         'Set-up time
'  Cog := cognew(Assignment, @stack)   'COGNEW(ParameterList, StackPointer);Starts the next available cog
{
PUB Assignment                        'Pulse Width Modulation (PWM) technique
                                      'Forward Movement
  Forward(300)
  TurnRight(200)                      'There is a pause to increase duration of movement and a
  Forward(300)                        'StopAllMotors function inside those functions (Forward,
  TurnLeft(200)                       'Reverse, TurnLeft, TurnRight).
  Forward(300)

  Reverse(50)                         'Reverse Movement
  TurnRight(200)
  Reverse(50)
  TurnLeft(200)
  Reverse(50)
}
PUB Init
  Motors.Init                         'Calls Motors object Spin file's Init function
  Motors.AddSlowPin(motor1)           'Sets the pin to be an output
  Motors.AddSlowPin(motor2)
  Motors.AddSlowPin(motor3)
  Motors.AddSlowPin(motor4)
  Motors.Start
  Pause(100)

PUB StopCog
  if Cog
      Cogstop(Cog~)                   'Cog~ Post-Clear returns Cog to value 0

PUB Set (motor, speed)

  case motor
    motor1:
      speed += motor1Zero
      Motors.Set(motor1, speed)
    motor2:
      speed += motor2Zero
      Motors.Set(motor2, speed)
    motor3:
      speed += motor3Zero
      Motors.Set(motor3, speed)
    motor4:
      speed += motor4Zero
      Motors.Set(motor4, speed)

PUB StopAllMotors

  Set(motor1, motor1Zero)
  Set(motor2, motor2Zero)
  Set(motor3, motor3Zero)
  Set(motor4, motor4Zero)

PUB Forward (speed)

  Set(motor1, +speed)
  Set(motor2, +speed)
  Set(motor3, +speed)
  Set(motor4, +speed)
  Pause(3000)
  StopAllMotors
  Pause(300)

PUB Reverse (speed)

  Set(motor1, -speed)
  Set(motor2, -speed)
  Set(motor3, -speed)
  Set(motor4, -speed)
  Pause(3000)
  StopAllMotors
  Pause(300)

PUB TurnLeft (speed)

  Set(motor1, +speed)
  Set(motor2, -50)
  Set(motor3, +speed)
  Set(motor4, -50)
  Pause(2700)
  StopAllMotors
  Pause(300)

PUB TurnRight (speed)

  Set(motor1, -50)
  Set(motor2, +speed)
  Set(motor3, -50)
  Set(motor4, +speed)
  Pause(2700)
  StopAllMotors
  Pause(300)

PRI Pause(ms) | t

  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)
  return