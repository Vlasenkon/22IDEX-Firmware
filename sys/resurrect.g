; Resume printing file "0:/gcodes/Shape-Box_FLEX,NYLON_21m.gcode" after print paused at 2024-05-02 18:38
M140 P0 S80.0
M141 P0 S0.0
G29 S1
M568 P0  A2 S210 R0
M568 P1  A1 S280 R0
M568 P2  A0 S210:300 R210:300M567 P2 E1.00:1.00
M568 P3  A1 S210:300 R210:300M567 P3 E1.00:1.00
M486 S0 A"Shape-Box"
G21
M98 P"resurrect-prologue.g" X-8.977 Y-2.016 Z8.360 U208.000
M290 R0 X0.000 Y0.000 Z-0.040 U0.000
; Workplace coordinates
G10 L2 P1 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P2 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P3 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P4 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P5 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P6 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P7 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P8 X0.00 Y0.00 Z0.00 U0.00
G10 L2 P9 X0.00 Y0.00 Z0.00 U0.00
M596 P0
M486 S0
T0
G54
M106 S1.00
M116
G92 E0.00000
M83
G94
G17
M23 "0:/gcodes/Shape-Box_FLEX,NYLON_21m.gcode"
M26 S188088
G0 F6000 Z10.400
G0 F6000 X-8.977 Y-2.016
G0 F6000 Z8.400
G1 F3281.7 P0
M204 P2500.0 T10000.0
G21
M596 P1
M486 S-1
G54
M106 S0.00
M116
G92 E0.00000
M83
G94
G17
M26 S188088
G1 F3281.7 P0
M204 P50000.0 T50000.0
G21
M596 P0
M106 P1 S0.00
M106 P3 S1.00
M106 P6 S1.00
M302 P0
M24