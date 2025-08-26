; Disable ToolChange Retraction
echo >"0:/user/toolchangeretraction.g" "; ToolChange Retraction Disabled"

M106 P3 S0
M106 P1 S0

M104 T0 S0 R0 ; Extruder heater off
M104 T1 S0 R0 ; Extruder heater off
M104 T2 S0 R0 ; Extruder heater off
M104 T3 S0 R0 ; Extruder heater off

M208 Z-1 S1         ; set axis minima to default

M98 P"0:/user/bedfinishbehavior.g"	    ; decide what to do with bed after printing is finished
M98 P"0:/user/chamberfinishbehavior.g"	; decide what to do with chamber after printing is finished

;reset Z baby steping if it was savedduring the ptint
M98 P"0:/sys/resetzbabystep.g"
M400
echo >"0:/sys/resetzbabystep.g" "; do nothing"