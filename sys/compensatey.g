var mm = 0.0 ; Set default compensation value

if exists(global.ycomp)
    set var.mm = global.ycomp
else
    set var.mm = 0.0

M584 Z1.1     ; define driver mapping

G91               ; set to relative positioning
G1 F240 Z{var.mm} ; move to compensate
G90               ; set to relative positioning

M584 Z1.0:1.1:1.2

echo "Mesh bed adjusted for "^{var.mm}^" mm"