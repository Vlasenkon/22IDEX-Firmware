; Homing XYU axis if they are not homed
if !move.axes[1].homed || !move.axes[0].homed || !move.axes[3].homed
  M98 P"homeall.g" S1 L1 Z1

T0                 ; Select first tool
M204 T2000

if !exists(param.Z)
  G91                ; relative positioning
  G1 H2 Z25 F18000   ; lift Z relative to current position
  G90                 ; absolute positioning


M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active


; Fast home Z
if !exists(param.F)
  G90                 ; absolute positioning
  G1 U999 F18000      ; Move second tool out of the way
  G1 X{0 - sensors.probes[0].offsets[0]} Y{10 - sensors.probes[0].offsets[1]} F18000 
  M558 K0 P8 C"1.io4.in" H5 F18000 T18000
  M98 P"0:/user/ProbeOffset.g"
  M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active
  G30           ; Home bed using probe


; Slow home Z
if !exists(param.C)
  G90                 ; absolute positioning
  G1 U999 F18000      ; Move second tool out of the way
  G1 X{0 - sensors.probes[0].offsets[0]} Y{10 - sensors.probes[0].offsets[1]} F18000
  M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active
  M558 K0 P8 C"1.io4.in" H5 F300 T18000
  M98 P"0:/user/ProbeOffset.g"
  G30           ; Home bed using probe

if !exists(param.S)
  G1 H2 Z100 F18000   ; Lift Z

if !exists(param.L)
  M98 P"place.g"

M204 T5000





;Z1 - Do not Lower Z before probing
;S1 - Do not lower Z after probing
;F1 - Do a fast 1st Probe
;C1 - Do a slow 2nd Probe
;L1 - Do not Place the Probe