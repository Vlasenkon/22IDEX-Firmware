var mm = 0.0


M569 P1.2 S1
M584 Z1.0:1.2     ; define driver mapping

G91               ; set to relative positioning
G1 F240 Z{var.mm} ; move to compensate
G90               ; set to relative positioning

M569 P1.2 S0
M584 Z1.0:1.1:1.2

echo "Mesh bed adjusted for "^{var.mm}^" mm"