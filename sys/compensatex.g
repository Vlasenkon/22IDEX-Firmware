; Ensure global variables exist
if !exists(global.xcomp_mode)
  global xcomp_mode = "manual"

if !exists(global.xcomp_auto)
  M98 P"0:/user/xcomp_auto.g"   ; load auto compensation value

if !exists(global.xcomp_manual)
  global xcomp_manual = 0.0

var mm = 0.0 ; Set default compensation value

; Set compensation value based on mode
if global.xcomp_mode == "auto"
  set var.mm = global.xcomp_auto
else
  set var.mm = global.xcomp_manual

M569 P1.2 S1
M584 Z1.0:1.2     ; define driver mapping

G91               ; set to relative positioning
G1 F240 Z{var.mm} ; move to compensate
G90               ; set to relative positioning

M569 P1.2 S0
M584 Z1.0:1.1:1.2

echo "Mesh bed adjusted for "^{var.mm}^" mm in "^{global.xcomp_mode}^" mode"