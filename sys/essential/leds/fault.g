if global.enableStatusLEDs
  M98 P"essential/leds/statusoff.g"
  M98 P"essential/leds/dimmwhite.g"
  ; Turn "Red" on
  var i = 0.0
  while var.i <= 1
    M42 P1 S{var.i}
    G4 P10
    set var.i = var.i + 0.01