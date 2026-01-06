M204 P5000 T5000  ; reset accelerations
M208 Z-1 S1       ; set axis minima to default

M83               ; relative extruder moves
G1 E-20 F3600     ; retract 20mm of filament

G91
G1 Z10
G90

; Always wipe nozzle(s)
M98 P"0:/sys/nozzlewipe.g"

M98 P"0:/sys/led/end.g"
M98 P"0:/user/lowerbed.g"                 ; lower the bed (if needed)
M98 P"0:/user/bedfinishbehavior.g"	    ; decide what to do with bed after printing is finished
M98 P"0:/user/chamberfinishbehavior.g"	; decide what to do with chamber after printing is finished
M98 P"0:/user/powerendbehavior.g"	        ; decide what to do with power after printing is finished

G90

; Extended retraction based on user settings
M98 P"0:/user/retractfinishbehavior.g"

T0 P0

; Disable Fans
M106 P3 S0
M106 P1 S0

;Cool Down Tools
M568 P0 S0 R0
M568 P1 S0 R0
M568 P2 S0 R0
M568 P3 S0 R0

M84 XYU

M106 P7 H3 T50 X{global.hepafan}

M98 P"0:/sys/resetzbabystep.g"
G4 S1
echo >"0:/sys/resetzbabystep.g" "; do nothing"

; Reset tool change globals to null (clears slicer overrides)
if exists(global.tool0RetractDistance)
  set global.tool0RetractDistance = null
if exists(global.tool1RetractDistance)
  set global.tool1RetractDistance = null
if exists(global.tool0ExtrudeDistance)
  set global.tool0ExtrudeDistance = null
if exists(global.tool1ExtrudeDistance)
  set global.tool1ExtrudeDistance = null

; Reload tool change values for next job (restores machine overrides if any)
M98 P"0:/user/tool0retract.g"
M98 P"0:/user/tool1retract.g"
M98 P"0:/user/tool0extrude.g"
M98 P"0:/user/tool1extrude.g"

if move.axes[2].babystep != 0
	echo "Warning: Adjustment of "^move.axes[2].babystep^" mm was detected, please save Z - Offset"
	M291 S1 R"Save Z-Offset" P{"Adjustment of "^move.axes[2].babystep^" mm was detected.<br>It is recommended to save this Z-Offset adjustment."} T0

M98 P"0:/user/filamentbackup.g"                          ; load filament runout tool swap variable

if exists(param.A)
	if param.A > 10
		echo "Warning: HEPA filter fan RPM difference detected - fan may be worn out"
		echo >>"0:/sys/eventlog.txt" "Warning: HEPA filter fan RPM difference detected - fan may be worn out"
		M98 P"0:/sys/led/fault.g"
		M291 R"HEPA Filter Fan Warning" P"RPM difference detected on HEPA filter fan. The fan may be worn out and may require replacement." S1 T0