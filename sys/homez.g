; Homing XYU axis if they are not homed
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[3].homed
  var homingPerformed = true
  M98 P"homeall.g" S1 L1 Z1

T0 P0                 ; Select first tool
M204 T2000

; Save current position if K parameter is provided (keep current XY position for probing)
; Only save if homing was NOT performed (position is already accurate)
if exists(param.K) && !exists(var.homingPerformed)
  var savedX = move.axes[0].machinePosition
  var savedY = move.axes[1].machinePosition

if !exists(param.Z)
  G91                ; relative positioning
  G1 H2 Z25 F18000   ; lift Z relative to current position
  G90                 ; absolute positioning

if !exists(param.T)
  M98 P"0:/sys/probetest.g" ; Test the Z - Probe to ensure it is not shorted

M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active

; Fast home Z
if !exists(param.F)
  G90                 ; absolute positioning
  G1 U999 F18000      ; Move second tool out of the way
  M558 K0 P8 C"1.io4.in" H5 F18000 T18000
  M98 P"0:/user/ProbeOffset.g"
  M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active
  
  G1 X{0-sensors.probes[0].offsets[0]} Y{0-sensors.probes[0].offsets[1]} F18000
  G30
  if result !=0
    M98 P"0:/sys/led/fault.g"
    echo >>"0:/sys/eventlog.txt" "Error: Home Z failed"
    abort "Error: Home Z failed"



; Slow home Z
if !exists(param.C)
  G90                 ; absolute positioning
  G1 U999 F18000      ; Move second tool out of the way
  M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active
  M558 K0 P8 C"1.io4.in" H5 F300 T18000 A3 S-1 ; three averaged slow probes regardless of consistency
  M98 P"0:/user/ProbeOffset.g"

  ; Use saved position if K parameter was provided, otherwise default to 0,0
  if exists(param.K) && exists(var.savedX) && exists(var.savedY)
    G1 X{var.savedX - sensors.probes[0].offsets[0]} Y{var.savedY - sensors.probes[0].offsets[1]} F18000
  else
    G1 X{0-sensors.probes[0].offsets[0]} Y{10-sensors.probes[0].offsets[1]} F18000
  
  G30
  if result !=0
    M98 P"0:/sys/led/fault.g"
    echo >>"0:/sys/eventlog.txt" "Error: Home Z failed"
    abort "Error: Home Z failed"

if !exists(param.S)
  G1 H2 Z100 F18000   ; Lift Z

if !exists(param.L)
  M98 P"place.g"

M204 T5000

; Parameters:
; Z1 - Skip initial Z lift (do not raise Z before probing)
; S1 - Skip final Z lift (do not raise Z after probing)
; F1 - Skip fast probe (do not perform initial fast probe at F18000)
; C1 - Skip slow probe (do not perform careful probe at F300)
; L1 - Skip probe placement (do not place probe back after homing)
; T1 - Skip probe test (do not test if probe wire is shorted before probing)
; K1 - Keep current XY position for probing (instead of moving to bed center 0,0)