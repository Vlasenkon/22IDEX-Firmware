M42 P4 S1
M400
G4 P500              ; Wait for Probe value to stabilize

; If probe is available, try to place it
if sensors.probes[0].value[0] < 500
  M98 P"place.g"
  
M400
G4 P500              ; Wait for Probe value to stabilize

; If probe is still available, open safety relay and return
if sensors.probes[0].value[0] < 500
  M42 P4 S0
  M98 P"0:/sys/led/fault.g"
  M291 S0 R"Probe is still connected" P"Check if Probe is detached from the Printhead"
  abort "Error: Probe is still connected"


  M42 P4 S0