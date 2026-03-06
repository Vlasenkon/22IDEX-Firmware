M106 S0
M106 P1 S0
M106 P3 S0


M98 P"0:/user/hepafan.g"
M106 P7 H3 T35:90 L0.2 X{global.hepafan}
; Save current temperatures before resetting
var bedTemp = heat.heaters[2].active
var chamberTemp = heat.heaters[3].active
M568 P0 S0 R0
M568 P1 S0 R0
M568 P2 S0 R0
M568 P3 S0 R0
M140 S0 R0    ; Bed heater off
M141 S0       ; Chamber heater off

; Reset tool change globals to null (clears slicer overrides)
if exists(global.tool0RetractDistance)
  set global.tool0RetractDistance = null
if exists(global.tool1RetractDistance)
  set global.tool1RetractDistance = null
if exists(global.tool0ExtrudeDistance)
  set global.tool0ExtrudeDistance = null
if exists(global.tool1ExtrudeDistance)
  set global.tool1ExtrudeDistance = null

; Reload tool change values for next job
M98 P"0:/user/tool0retract.g"
M98 P"0:/user/tool1retract.g"
M98 P"0:/user/tool0extrude.g"
M98 P"0:/user/tool1extrude.g"

M98 P"0:/sys/led/stop.g"

;reset Z baby steping if it was savedduring the ptint
M98 P"0:/sys/resetzbabystep.g"
M400
echo >"0:/sys/resetzbabystep.g" "; do nothing"

M204 T5000                 ; set the accelerations

; Ask user if they want to keep temperatures (auto-closes after 30s, defaults to Keep Temperature)
M291 R"Keep Temperature?" P"Do you want to keep the bed and chamber temperature?" S4 K{"Keep Temperature", "Set to Zero"} F0 T30

; Restore temperatures if user chose to keep them (or timeout occurred)
if input == 0
  M140 S{var.bedTemp} R{var.bedTemp}
  M141 S{var.chamberTemp}
else
  M84 XYU