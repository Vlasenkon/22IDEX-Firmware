var changeMode = exists(param.C) && param.C != 0

if !var.changeMode
  M291 R"Filament will be loaded" P"Please wait while the nozzle heats up. This may take a few minutes." S1 T15
else
  M291 S2 R"Preparing to load filament" P"Heating the active nozzle for filament loading. Please wait..."

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

if {state.status != "processing" || state.status != "printing" || state.status != "pausing" || state.status != "paused" || state.status != "resuming"} && {!move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed}
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



M291 R"Feed the filament, material will be extruded" P"Insert filament into extruder and press ""Start Extrusion"" to begin, or ""Cancel"" to abort." S4 K{"Start Extrusion","Cancel"}
if input = 0
  if heat.heaters[0].state == "fault" || heat.heaters[1].state == "fault" || heat.heaters[2].state == "fault" || heat.heaters[3].state == "fault"
    M568 P0 A0
    M568 P1 A0
    M140 S0
    M141 S0
    G1 X-999 U999 F18000 Y150 Z100 F18000
    M291 S1 R"Error" P"Heater fault detected. Operation aborted."
    abort "Error: Heater fault detected"
  G1 E200 F{var.ss} ; Extrude
else
  if !var.changeMode
    if state.status != "processing" || state.status != "printing" || state.status != "pausing" || state.status != "paused" || state.status != "resuming"
      M568 S0 R0 ; Turn off the heater
  M84 E0:1
  M99


M400

M291 R"Filament Loading Check" P"Is new filament visible coming out of the nozzle?" S4 K{"Yes - Filament Visible","No - Extrude More"}
  while input == 1
    if heat.heaters[0].state == "fault" || heat.heaters[1].state == "fault" || heat.heaters[2].state == "fault" || heat.heaters[3].state == "fault"
      M568 P0 A0
      M568 P1 A0
      M140 S0
      M141 S0
      G1 X-999 U999 F18000 Y150 Z100 F18000
      M291 S1 R"Error" P"Heater fault detected. Operation aborted."
      abort "Error: Heater fault detected"
    G1 E50 F{var.ss} ; Extrude
    M400
    M291 R"Filament Loading Check" P"Is new filament visible coming out of the nozzle?" S4 K{"Yes - Filament Visible","No - Extrude More"}

M98 P"0:/sys/nozzlewipe.g" ; wipe curently active nozzle
M84 E0:1

if !var.changeMode
  if state.status != "processing" || state.status != "printing" || state.status != "pausing" || state.status != "paused" || state.status != "resuming"
    M568 S0 R0 ; Turn off the heater
