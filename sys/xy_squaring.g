M98 P"0:/user/xy_square_manual.g"
M98 P"0:/user/xy_square_auto.g"
M98 P"0:/user/xy_square_mode.g"

if !exists(global.xy_square_manual)
  global xy_square_manual = 0.0

if !exists(global.xy_square_auto)
  global xy_square_auto = 0.0

if !exists(global.xy_square_mode)
  global xy_square_mode = "manual"

var active = global.xy_square_manual
if global.xy_square_mode != "manual"
  set var.active = global.xy_square_auto

G90
G1 Y0 F6000
M400
G4 S2
M584 Y0.4
G91
G1 Y{-var.active} F150   ; Crossbar Alignment
M400
M584 Y0.1
G1 Y{var.active} F150   ; Crossbar Alignment
M400
M584 Y0.1:0.4
M906 X1800 U1800 Y1800:1800 Z850 E600:600 I35 T10
M913 Y100         ; Restore Y motor current to 100%
G90
