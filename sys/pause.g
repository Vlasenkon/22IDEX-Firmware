; pause.g
; called when a print from SD card is paused

M400
G60 S4
M204 T5000

; Disable ToolChange Retraction
echo >"0:/user/toolchangeretraction.g" "; ToolChange Retraction Disabled"

M83            ; relative extruder moves
G1 E-20 F{60}*{50}  ; retract filament
G91            ; relative positioning
G1 Z50 F18000 ; lift Z
G90            ; absolute positioning
G1 Y150 F6000

M106 S0

M568 P0 A0
M568 P1 A0
M568 P2 A0
M568 P3 A0

M208 Z-1 S1         ; set axis minima to default

if global.filamentRunoutTakeover == true && exists(param.D) && param.D == "filament-error"
  ; Handle filament runout and switch tools
  var oldTool = state.currentTool            ; Store the current tool number
  var oldTemp = tools[state.currentTool].active[0]   ; Store the current tool's active temperature

  if exists(global.nextTool)
    set global.nextTool = (var.oldTool == 0) ? 1 : 0
  else
    global nextTool = (var.oldTool == 0) ? 1 : 0

  if var.oldTool == 0
    T{global.nextTool}                           ; Switch to the next tool
    M568 P{global.nextTool} S{var.oldTemp}
  else
    T{global.nextTool}                           ; Switch to the next tool
    M568 P{global.nextTool} S{var.oldTemp}
elif ((global.filamentRunoutTakeover != true || !exists(param.D)) && param.D == "filament-error"
  ; Handle filament runout and switch tools
  

; If one of the heaters failed light alarm LEDs or normal pause LEDs otherwise
if heat.heaters[0].state == "fault" || heat.heaters[1].state == "fault" || heat.heaters[2].state == "fault" || heat.heaters[3].state == "fault"
  M98 P"0:/sys/led/fault.g"  
else
  M98 P"0:/sys/led/pause.g"