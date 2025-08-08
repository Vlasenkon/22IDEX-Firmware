; Dimm white LEDs
var i = fans[6].requestedValue
while var.i >= 0
  M106 P6 S{var.i} B0
  set var.i = var.i - 0.01
  G4 P8

; For 100% chance that white LEDs are off
M106 P6 S0 B0