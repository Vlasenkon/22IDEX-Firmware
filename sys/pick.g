if !exists(global.probePickY)
  global probePickY = {move.axes[1].max}


M204 T5000                 ; set the accelerations
T0               ; Select first tool
G90              ; Absolute positioning

; Go to probe pickup position
G1 F18000 Y140 X{global.probePickX} U{move.axes[3].max-10}
M400

M204 T1000 ; Lower the accelerations a little
M280 P0 S{global.probePickAngle}     ; Move probe holder to the 'pick/place' position
G4 S1


M564 S0
G90
G1 F18000 Y{global.probePickY}   ; Pick the probe
M564 S1

M400
G4 P500

G91
G1 F1000  Y-5    ; Return with probe
G1 F18000 Y-30   ; Return with probe
G90

G1 U{move.axes[3].max} F18000
M400

M42 P4 S1    ; Turn on relay, engage probing (ESD Warning)
G4 P1000
if sensors.probes[0].value[0] > 500
  G91
  G1 Y-50 X-100
  G90
  M42 P4 S0       ; Turn on relay, engage probing (ESD Warning)
  M280 P0 S0       ; Take probe holder out of the way
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Z probe was not picked"
  abort "Error: Z probe was not picked"

M280 P0 S0       ; Take probe holder out of the way

M204 T5000 ; Return the accelerations
G90