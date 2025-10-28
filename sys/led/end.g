M98 P"0:/sys/led/statusoff.g"
M98 P"0:/sys/led/dimmwhite.g"
var i = 0.0
while var.i <= 1
  M42 P2 S{var.i}
  G4 P10
  set var.i = var.i + 0.01