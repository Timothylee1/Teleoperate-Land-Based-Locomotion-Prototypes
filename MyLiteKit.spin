{
  Project : EE-7 MyLiteKit.spin
  Platform: Parallax Project USB Board
            Lite Kit
  Revision: 1.1
  Author  : Timothy Lee
  Date    : 15/11/21
  Log     :
  Date    : Desc
            14/11/2021: Implemented SensorControl & MotorControl call function
            15/11/2021: Implemented movement control
}

CON
  _clkmode = xtal1 + pll16x                      'Standard clock mode * crystal frequency = 80 MHz
  _xinfreq = 5_000_000
  _ConClickFreq = ((_clkmode - xtal1) >> 6) * _xinfreq
  _MS_001 = _ConClickFreq / 1_000
OBJ
  Sensor      : "SensorControl.spin"
  Motor       : "MotorControl.spin"
PUB Main
    Motor.Start
    Sensor.Init
    Wait(2000) 'Wait for setup
    repeat
      Motor.Forward(100)         'Forward mobile platform   Does not detect floor or detects wall/obstacle
                                 'Front ToF and Ultrasonic Sensor
      if (Sensor.ReadToF(1)) > 200 OR  (Sensor.ReadUltrasonic(1)) < 250
        Motor.StopAllMotors
        Wait(500)
        repeat
          Motor.Reverse(100)       'Reverse mobile platform   Does not detect floor or detects wall/obstacle
                                 'Back ToF and Ultrasonic Sensor
          if (Sensor.ReadToF(2)) > 200 OR  (Sensor.ReadUltrasonic(2)) < 250
          Motor.StopAllMotors
      Wait(500)
PRI Wait(ms) | t
  t := cnt - 1088
  repeat (ms #> 0)
    waitcnt(t += _MS_001)
  return
