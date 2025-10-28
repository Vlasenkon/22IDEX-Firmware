M572 D0:1 S0.035 ; set pressure advance

M80 ; Turn ON 24V PSU

M221 D0 S100 ; reset flow rate to 100%
M221 D1 S100 ; reset flow rate to 100%

M568 P0 S0 R0
M568 P1 S0 R0
M568 P2 S0 R0
M568 P3 S0 R0

M204 T5000                 ; set the accelerations

echo >"0:/sys/resetzbabystep.g" "; do nothing"