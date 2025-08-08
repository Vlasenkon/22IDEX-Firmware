M291 R"Please wait while the nozzle is being heated up" P"This may take a few minutes." S1 T15

M98 P"0:/sys/led/resetstatus.g"
M98 P"0:/sys/led/start_cold.g"


;Load Speed
var ss = 0
if !exists(param.S)
  set var.ss = 300
else
  set var.ss = 100


M400
G60 S0 ; Remember last tool selected

if {state.status != "processing" || state.status != "pausing" || state.status != "paused" || state.status != "resuming"} && {!move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed}
  G28
  M98 P"0:/sys/led/statusoff.g"
  M98 P"0:/sys/led/restorewhite.g"
  M98 P"0:/sys/led/start_cold.g"


T R0 ; Select tool from memory slot
if move.axes[0].homed && move.axes[1].homed && move.axes[2].homed && move.axes[3].homed
  G90
  if move.axes[2].machinePosition < 420
    G1 F18000 Z420
  
  if state.currentTool == 0
    G1 Y0 X0 U999 F18000
  elif state.currentTool == 1
    G1 Y0 U0 X-999 F18000


M116 P{state.currentTool} S15; Wait for the temperatures to be reached
M98 P"0:/sys/led/start_hot.g"
M83 ; Extruder to relative mode



M291 R"Feed the filament, material will be extruded" P"Press ""Extrude"" to start or ""Cancel"" to stop." S4 K{"Extrude","Cancel"}
if input = 0
  G1 E200 F{var.ss} ; Extrude
else
  if state.status != "processing" || state.status != "pausing" || state.status != "paused" || state.status != "resuming"
    G10 S0 R0 ; Turn off the heater
    M84 E0:1
  M99


M400

M291 R"Do you see new filament extruding?" P"Press ""Yes"" if filament is extruding or ""No"" to extrude more." S4 K{"Yes","No"}
  while input = 1
    G1 E50 F{var.ss} ; Extrude
    M400
    M291 R"Do you see new filament extruding?" P"Press ""Yes"" if filament is extruding or ""No"" to extrude more." S4 K{"Yes","No"}

M98 P"0:/sys/nozzlewipe.g" ; wipe curently active nozzle
M84 E0:1

if state.status == "processing" || state.status == "pausing" || state.status == "paused" || state.status == "resuming"
  M568 P{state.currentTool} A0
  M291 R"Please set the nozzle temperature" P"Manually return the nozzle temperature that is optimal for printing new filament." S1 T15
else
  G10 S0 R0 ; Turn off the heater