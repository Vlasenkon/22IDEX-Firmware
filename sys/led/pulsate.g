M98 P"0:/sys/led/statusoff.g"
M98 P"0:/sys/led/restorewhite.g"

;M98 P"0:/sys/led/resetstatus.g"

G4 P250

var iter = 0
var pulse = 0.01
var duration = 8
var power = 1.0

while var.iter < 5

    while var.power >= 0
        M106 P6 S{var.power} B0
        set var.power = var.power - var.pulse
        G4 P{var.duration}

    G4 P50

    set var.power = 0
    while var.power <= 1
        M106 P6 S{var.power} B0
        set var.power = var.power + var.pulse
        G4 P{var.duration}

    set var.iter = var.iter + 1

G4 P250
M98 P"0:/sys/led/end.g"