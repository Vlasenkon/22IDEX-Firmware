; Configuration file for AddWise IDEX

; General preferences
G90                                                              ; absolute coordinates
M83                                                              ; relative extruder moves
M550 P"22IDEX Mark 4"                                                   ; set printer name

M80 C"pson"                                                      ; define PS_ON pin

; Wait a moment for the CAN expansion boards to start 
G4 S2

M98 P"0:/user/ethernetToPCmode.g"

if global.ethernetToPCmode == 0
  ; Network
  M98 P"0:/user/networkmode.g"

M586 P0 S1                                                       ; configure HTTP 
M586 P1 S0                                                       ; configure FTP 
M586 P2 S0                                                       ; configure Telnet


if global.ethernetToPCmode == 1
  ; Set network configuration
  M98 P"0:/user/ip_ethernettopc.g"

; Drives
M569 P0.0 S1                                                     ; motor direction
M569 P0.1 S1                                         
M569 P0.2 S0                                          
M569 P0.3 S1                                          
M569 P0.4 S0                                          
M569 P0.5 S1                                          
M569 P1.0 S0                                         
M569 P1.1 S0                                          
M569 P1.2 S0                                         


M584 X0.2 Y0.1:0.4 U0.3 Z1.0:1.1:1.2 E0.0:0.5                    ; set motor mapping (Z: Right, Rear, Left)

M669 K0 Y1:1:0:1                                                 ; set kinematics parameters
M671 X222.5:0:-222.5 Y-170.5:193.5:-170.5 S100                   ; leadscrews at Right, Rear, Left

M350 X16 Y16 U16 Z16 E16:16 I1                                   ; configure microstepping
M92 X80 Y80 U80 Z400 E400:400                                    ; set steps per mm
M566 X600 U600 Y600 Z200 E600:600                                ; set maximum jerk (mm/min)
M203 X18000 U18000 Y18000 Z1200 E12000:12000                     ; set maximum speeds (mm/min)
M201 X10000 U10000 Y10000 Z500 E5000:5000                        ; set accelerations (mm/s^2)
M906 X1800 U1800 Y1800:1800 Z850 E600:600 I35                    ; set motor currents (mA) and motor idle factor in per cent
M84 S10                                                          ; set idle timeout
M204 P5000 T5000

; Axis Limits
M208 X-208 U-161 Y-175 Z0   S1                                   ; set axis minima
M208  U208  X161  Y180 Z450 S0                                   ; set axis maxima


; Endstops
M574 X1 S1 P"io4.in"                                             ; configure endstop
M574 U2 S1 P"io5.in"                                             ; configure endstop
M574 Y1 S1 P"io1.in+io2.in"                                      ; configure endstop
M98 P"0:/user/filamentsensor0.g"                                 ; configure endstop
M98 P"0:/user/filamentsensor1.g"                                 ; configure endstop

; Probe 
M950 S0 C"out9" Q50                                              ; define servo pin
M558 K0 P8 C"1.io4.in" H5 F18000 T18000                          ; define Z probe parameters
M98 P"0:/user/ProbeOffset.g"                                     ; define Z probe offsets
M950 P4 C"1.out4" Q500                                           ; define output for ESD protection
M42 P4 S0                                                        ; enable EDS protection

; Heaters
M308 S0 A"Left Heater" P"temp0" Y"pt1000"                        ; configure temperature sensor
M950 H0 C"out1" T0                                               ; configure heater
M98 P"0:/user/PIDLeftHead.g"                                     ; configure PID parameters
M143 H0 S510                                                     ; configure temperature limit for the heater
M570 H0 P30 T50 R10                                              ; configure heater fault detection

M308 S1 A"Right Heater" P"temp1" Y"pt1000"                       ; configure temperature sensor
M950 H1 C"out2" T1                                               ; configure heater
M98 P"0:/user/PIDRightHead.g"                                    ; configure PID parameters
M143 H1 S510                                                     ; configure temperature limit for the heater
M570 H1 P30 T50 R10                                              ; configure heater fault detection

M308 S2 A"Bed Heater" P"1.temp1" Y"thermistor" T100000 B3950     ; configure temperature sensor
M950 H2 C"1.out0" Q10 T2                                         ; configure heater
M98 P"0:/user/PIDBedHead.g"                                      ; configure PID parameters
M140 H2                                                          ; map heated bed to heater
M143 H2 S210                                                     ; configure temperature limit for the heater
M98 P"0:/user/bedfaultdetection.g"                               ; configure heater fault detection

M308 S3 A"Chamber Air" P"1.temp0" Y"thermistor" T200000 B3100    ; configure temperature sensor
M98 P"0:/user/ChamberTempSensor.g"                               ; configure C coef
M950 H3 C"1.out1" Q10 T3                                         ; configure heater
M98 P"0:/user/PIDChamber.g"                                      ; configure PID parameters
M307 H3 R0.1 K0.895 D55 S1.00 B1                                 ; configure PID parameters
M141 H3                                                          ; map chamber to heater
M143 H3 S110                                                     ; configure temperature limit for the heater
M98 P"0:/user/chamberfaultdetection.g"                           ; configure heater fault detection

M308 S4 A"Chamber Heater" P"1.temp2" Y"thermistor" T100000 B3950 ; configure temperature sensor
M143 H3 S170 T4 A2                                               ; configure temperature limit for the heater


; Fans
M950 F2 C"out4" Q500                                             ; configure fan
M106 P2 H0 T70 S1 B0                                             ; configure thermostatic contron
M950 F3 C"out5" Q500                                             ; configure fan
M106 P3 C"X - Fan" H-1 S0 B0.5                                   ; configure thermostatic contron

M950 F0 C"out7" Q500                                             ; configure fan
M106 P0 H1 T70 S1 B0                                             ; configure thermostatic contron
M950 F1 C"out8" Q500                                             ; configure fan
M106 P1 C"U - Fan" H-1 S0 B0.5                                   ; configure contron

M950 F4 C"1.out2" Q5000                                          ; configure Chamber Heater fan
M106 P4 H4 T80 S1 B1                                             ; configure thermostatic contron
;M106 P4 H-1 S0.5 B1

M950 F7 C"!1.out5+out5.tach" Q500                                ; configure CrFan
M98 P"0:/user/hepafan.g"
M106 P7 H3 T50 X{global.hepafan}                                 ; configure thermostatic contron

; LEDs
M950 P1 C"1.out6" Q5000                                          ; Red LEDs
M42 P1 S0
M950 P2 C"1.out7" Q5000                                          ; Green LEDs
M42 P2 S0
M950 P3 C"1.out8" Q5000                                          ; Blue LEDs
M42 P3 S0
M950 F6 C"1.out3" Q5000                                          ; White LEDs
M106 P6 C"W LED" H-1 S0 B0


; Tools
M563 P0 S"Left Head" D0 H0 F3                                    ; define tool
G10 P0 X0 Y0 Z0 U0                                               ; set tool offsets
G10 P0 R0 S0                                                     ; set initial tool active and standby temperatures

M563 P1 S"Right Head" D1 H1 F1 X3                                ; define tool
M98 P"0:/user/tooloffset.g"                                      ; Load tool offsets
G10 P1 R0 S0                                                     ; set initial tool active and standby temperatures

M563 P2 S"Duplicate Mode" D0:1 H0:1 X0:3 F1:3                    ; tool 2 uses both extruders and hot end heaters, maps X to both X and U, and uses both print cooling fans
G10 P2 X97.5 Y0 U-97.5 S0 R0                                     ; set tool offsets and temperatures for tool 2
M567 P2 E1:1                                                     ; set mix ratio 100% on both extruders

M563 P3 S"Mirroring Mode" D0:1 H0:1 X0:3 F1:3                    ; tool 3 uses both extruders and hot end heaters, maps X to both X and U, and uses both print cooling fans
G10 P3 X0 Y0 U0 S0 R0                                            ; set tool offsets and temperatures for tool 3
M567 P3 E1:1                                                     ; set mix ratio 100% on both extruders


; Load persistent variables
M98 P"0:/user/uoffset.g"                                         ; load global variables
M98 P"0:/user/yoffset.g"                                         ; load global variables
M98 P"0:/user/zoffset.g"                                         ; load global variables
M98 P"0:/user/probeoffset.g"                                     ; load global variables
M98 P"0:/user/rtzoffset.g"                                       ; load global variables
M98 P"0:/user/pickupposition.g"                                  ; load global variables

if fileexists("0:/user/pickuppositiony.g")
  M98 P"0:/user/pickuppositiony.g"                               ; load global variables

M98 P"0:/user/pickupangle.g"                                     ; load global variables
M98 P"0:/user/eventlogging.g"                                    ; load global variables
M98 P"0:/user/filamentbackup.g"                                  ; load filament runout tool swap variable
M98 P"0:/user/xcomp_auto.g"                                      ; load auto calibration value
M98 P"0:/user/xcomp_manual.g"                                    ; load manual calibration value
M98 P"0:/user/xcomp_mode.g"                                      ; load compensation mode

M98 P"0:/user/periodic_wiping.g" 				 ; load global variables 
M98 P"0:/user/hepafan.g"                                         ; load hepa fan speed

echo >"0:/user/toolchangeretraction.g" "                         ; ToolChange Retraction Disabled"
echo >"0:/sys/resetzbabystep.g" "                                ; do nothing"

; Custom settings
M280 P0 S0                                                       ; rotate servo to 0 deg
T0 P0
M568 P0 A2                                                       ; set tool state
M568 P1 A2                                                       ; set tool state

M575 P1 S1 B57600                                                ; define PanelDUE
;M955 P0 C"spi.cs1+spi.cs0" I06                                   ; configure accelerometer
M593 P"ei3" F59                                                  ; configure input shaping
;M915 P0.0:0.5 R3 F1 H10 S5

; Wait for voltage to stabilize and hold Z motors
while boards[0].vIn.current < 22 && boards[1].vIn.current < 22 && iterations < 20
  G4 P250
M17 Z                                                            ; Hold Z motors with idle current

M98 P"0:/sys/led/startup.g"                                      ; startup LED

; test internet connection
echo >"0:/sys/runonce.g" "G4 S5"
echo >>"0:/sys/runonce.g" "M98 P""0:/sys/networktest.g"""