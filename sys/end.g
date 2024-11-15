; Disable ToolChange Retraction
echo >"0:/user/toolchangeretraction.g" "; ToolChange Retraction Disabled"

M204 P5000 T5000  ; reset accelerations
M208 Z-1 S1       ; set axis minima to default

M83               ; relative extruder moves
G1 E-20 F3600     ; retract 10mm of filament

G91
G1 Z10
G90

T0 P0

M98 P"0:/sys/led/end.g"
M98 P"0:/user/lowerbed.g"                 ; lower the bed (if needed)
M98 P"0:/user/bedfinishbehavior.g"	    ; decide what to do with bed after printing is finished
M98 P"0:/user/chamberfinishbehavior.g"	; decide what to do with chamber after printing is finished
M98 P"0:/user/powerendbehavior.g"	        ; decide what to do with power after printing is finished


G90
G1 Y150 F18000

; Disable Fans
M106 P3 S0
M106 P1 S0

;Cool Down Tools
G10 P0 S0 R0
G10 P1 S0 R0
G10 P2 S0 R0
G10 P3 S0 R0

M84 XYU

M98 P"0:/sys/resetzbabystep.g"
G4 S1
echo >"0:/sys/resetzbabystep.g" "; do nothing"


if move.axes[2].babystep != 0
	M291 R"Reminder: Save Z - Offset?" P{"Adjustment of "^move.axes[2].babystep^" mm was detected, please save Z - Offset"} S1 T120