; pause.g
; called when a print from SD card is paused

M400
G60 S5
M204 T5000

; Disable ToolChange Retraction
echo >"0:/user/toolchangeretraction.g" "                                                    ; ToolChange Retraction Disabled"

M83                                                                                         ; relative extruder moves
G1 E-20 F{60}*{50}                                                                          ; retract filament
G91                                                                                         ; relative positioning
G1 Z50 F18000                                                                               ; lift Z
G90                                                                                         ; absolute positioning
G1 Y150 F6000


M106 S0

if global.hepafan > 60
  M106 P7 S60

M568 P0 A0
M568 P1 A0
M568 P2 A0
M568 P3 A0

M208 Z-1 S1                                                                                 ; set axis minima to default

if exists(global.filamenterror) && global.filamenterror == true ; If a filament error was detected

  if exists(global.filamentbackup) && global.filamentbackup != true ; If the filament backup is not enabled
    if move.axes[2].machinePosition < 420
      G1 Z420 F18000                                                                        ; Move Z to 420mm position
  
  else ; If the filament backup is enabled
    ; Handle filament runout and switch tools
    var oldTemp = {tools[state.currentTool].active[0], tools[state.currentTool].standby[0]} ; Store the current tool's active temperature
    var oldTool = state.currentTool                                                         ; Store the current tool number
    var nextTool = (var.oldTool == 0) ? 1 : 0                                               ; Calculate the next tool number

    if !exists(global.nextTool)
      global nextTool = var.nextTool
    else
      set global.nextTool = var.nextTool

    T{global.nextTool}                                                                      ; Switch to the next tool
    M568 P{global.nextTool} S{var.oldTemp[0]} R{var.oldTemp[1]}                             ; Set the new tool's temperatures
    M568 P{var.oldTool} S0 R0 

; If one of the heaters failed light alarm LEDs or normal pause LEDs otherwise
if heat.heaters[0].state == "fault" || heat.heaters[1].state == "fault" || heat.heaters[2].state == "fault" || heat.heaters[3].state == "fault"
  M98 P"0:/sys/led/fault.g"  
else
  M98 P"0:/sys/led/pause.g"