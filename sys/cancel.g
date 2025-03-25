M106 P1 S0
M106 P3 S0

G10 P0 S0 R0
G10 P1 S0 R0
G10 P2 S0 R0
G10 P3 S0 R0

M140 S0 R0    ; Bed heater off
M141 S0       ; turn off chamber heater

M98 P"0:/sys/led/stop.g"

;reset Z baby steping if it was savedduring the ptint
M98 P"0:/sys/resetzbabystep.g"
M400
echo >"0:/sys/resetzbabystep.g" "; do nothing"

M204 T5000                 ; set the accelerations