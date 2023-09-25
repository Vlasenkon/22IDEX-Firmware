if state.status == "off"
  M80                      ; Turn on power
  G4 S3


M98 P"0:/sys/led/homeall.g"
M98 P"tfree3.g"

T0 P0
M280 P0 S0                 ; Take probe holder out of the way

M204 T2000

G91                        ; use relative positioning

G1 H2 Z20 F6000       ; lift Z relative to current position
G1 H2 X10 U-10 F18000

M84 Y
G4 S1

M913 Y60                   ; drop motor current
M204 P500 T500 
M915 Y S3 R0 F0            ; set X and Y to sensitivity 3, do nothing when stall, unfiltered


G1 H1 Y500 F6000           ; move quickly to X axis endstop and stop there


M913 Y100
G1 Y-20 F6000              ; move quickly to X axis endstop and stop there

M84 Y
G4 s1

M913 Y60
G1 H1 Y500 F18000          ; move quickly to X axis endstop and stop there

G1 H2 Y-5
if !exists(param.L)
  G1 H2 Z-20

M400                       ; make sure everything has stopped before we make changes
G90                   ; absolute positioning
M913 Y100                  ; return current to 100%
M204 T5000                 ; return the accelerations