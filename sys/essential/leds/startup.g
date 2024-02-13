if global.enableStatusLEDs
  G4 S1
  M106 P6 S0 B0
  var i = 0.0
  while var.i <= 1
    M42 P1 S{var.i}
    G4 P10
    set var.i = var.i + 0.01
  
  set var.i = 1.0
  while var.i >= 0
    M42 P1 S{var.i}
    G4 P10
    set var.i = var.i - 0.01
  
  set var.i = 0.0
  while var.i <= 1
    M106 P6 S{var.i} B0
    G4 P10
    set var.i = var.i + 0.01