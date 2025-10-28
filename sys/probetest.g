M42 P4 S1
M400
G4 P500              ; Wait for Probe value to stabilize


if sensors.probes[0].value[0] < 500
  M98 P"place.g"
  echo "Probe detected, trying to Place"
else
  M99

M400
G4 P500              ; Wait for Probe value to stabilize

; If probe is still available
if sensors.probes[0].value[0] < 500
  M42 P4 S0
  M98 P"0:/sys/led/fault.g"
  M291 S0 R"GND Wire is Shorted on T0" P"Check Grounding Wire on LHS Tool Heat, it migh be shorted to Aluminum plate"
  abort "Error: GND Wire is Shorted on T0"
else
  M98 P"pick.g"