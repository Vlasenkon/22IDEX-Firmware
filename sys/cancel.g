M291 R"Keep the temperature?" P"Do you want to keep the current temperature?" S3 J2 T20

var doReset = false

if result == -1
  set var.doReset = true

elif input == 0
  set var.doReset = true


if var.doReset
  M106 P1 S0
  M106 P3 S0
  M98 P"0:/user/hepafan.g"
  M106 P7 H3 T50 X{global.hepafan}

  G10 P0 S0 R0
  G10 P1 S0 R0
  G10 P2 S0 R0
  G10 P3 S0 R0

  M140 S0 R0    ; Bed heater off
  M141 S0       ; turn off chamber heater
echo >"0:/user/tool0retract" "G1 E-5 F3000"
echo >"0:/user/tool1retract" "G1 E-5 F3000"
echo >"0:/user/tool0extrude" "G1 E10 F{30}*{3}"
echo >"0:/user/tool1extrude" "G1 E10 F{30}*{3}"

M84 XYU

M98 P"0:/sys/led/stop.g"

;reset Z baby steping if it was savedduring the ptint
M98 P"0:/sys/resetzbabystep.g"
M400
echo >"0:/sys/resetzbabystep.g" "; do nothing"

M204 T5000                 ; set the accelerations