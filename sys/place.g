if !exists(global.probePickY)
  global probePickY = {move.axes[1].max}


; Test if the probe is present
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] > 500
  echo "Error: Probe not detected at start of placing"
  echo >>"0:/sys/eventlog.txt" "Error: Probe not detected at start of placing"
;else
;  echo "IF 1 - Present"
M42 P4 S0


;Move to Placing position
M204 T5000                 ; set the accelerations
T0                      ; Select first tool
G90
G1 F18000 Y135 X{global.probePickX} U{move.axes[3].max-10} ; Go to position
M400
M280 P0 S{global.probePickAngle}         ; Move probe holder to the 'pick/place' position
G4 S1

M564 S0
G90
G1 F18000 Y{global.probePickY}   ; Pick the probe
M564 S1



; Test if the probe is still present at the dock
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] > 500
  echo "Error: Probe was not detected at the dock after placing"
  echo >>"0:/sys/eventlog.txt" "Error: Probe was not detected at the dock after placing"
;else
;  echo "IF 2 - Present"  
M42 P4 S0



; Movement to remove the Probe
M204 T2000                 ; set the accelerations
G91
G1 F18000 X-50             ; Shear probe off the tool head
M204 T5000                 ; set the accelerations
G1 F18000 Y-50
G1 F18000 U{move.axes[3].max} 
G90
M400
M280 P0 S0       ; Take probe holder out of the way


; Test if the probe was removed
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] < 500
  M42 P4 S0   		 ; Turn off relay
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Probe removal failed"
  abort "Error: Probe removal failed"
;else
;  echo "IF 3 - Placed"
M42 P4 S0