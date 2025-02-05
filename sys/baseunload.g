M291 R"Please wait while the nozzle is being heated up" P" " S1 T10 ; Display message

M98 P"0:/sys/led/start_cold.g"


;Unload Speed
var ss = 0
if !exists(param.S)
  set var.ss = 1200
else
  set var.ss = 200


M400
G60 S0 ; Remember last tool selected

;if move.axes[0].homed && move.axes[1].homed && move.axes[3].homed ;if XYU Homed

T R0 ; Select tool from memory slot

M116 P{state.restorePoints[2].toolNumber} S15; Wait for the temperatures to be reached
M98 P"0:/sys/led/start_hot.g"
  
M291 R"Retracting Filament" P" " T15 ; Display  message
G1 E10 F600 ; Extrude
G1 E-20 F{var.ss} ; Retract
G1 E-100 F{var.ss} ; Retract
M400 ; Wait for the moves to finish
M84 E0:1
G10 S0 R0 ; Turn off the heater