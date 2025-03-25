M204 T5000                 ; set the accelerations

T0                      ; Select first tool

G90
G1 F18000 Y135 X{global.probePickX} U{move.axes[3].max-10} ; Go to position
M400

M280 P0 S{global.probePickAngle}         ; Move probe holder to the 'pick/place' position
G4 S1

M42 P4 S1		 ; Turn on relay, engage probing (ESD Warning)
G1 F3000 Y{move.axes[1].max}           ; Place the probe

G4 P250
if sensors.probes[0].value[0] > 500
  G91
  G1 Y-50 F18000
  G1 X-100
  G90
  M42 P4 S0   		 ; Turn off relay
  M280 P0 S0       ; Take probe holder out of the way
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Cancelled - Z probe was not placed "
  abort "Cancelled - Z probe was not placed"

M42 P4 S0   		 ; Turn off relay

M204 T2000                 ; set the accelerations

G91
G1 F18000 X-50             ; Shear probe off the tool head
M204 T5000                 ; set the accelerations
G1 F18000 Y-50
G1 F18000 U{move.axes[3].max} 
G90

M280 P0 S0                ; Take probe holder out of the way
G4 P250