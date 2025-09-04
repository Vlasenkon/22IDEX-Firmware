var i = 1.0

; Dimm blue
while var.i >= 0
  M42 P3 S{var.i}
  M42 P2 S{var.i / 1.7}
  G4 P8
  set var.i = var.i - 0.01
  
; Flash red
set var.i = 0.0
while var.i <= 1
  M42 P1 S{var.i}
  G4 P10
  set var.i = var.i + 0.01

set var.i = 1.0
while var.i >= 0
  M42 P1 S{var.i}
  G4 P10
  set var.i = var.i - 0.01


M98 P"0:/sys/led/restorewhite.g"