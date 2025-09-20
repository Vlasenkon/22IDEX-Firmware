if fileexists("/sys/daemon.g.bak")
    M472 P"/sys/daemon.g.bak"

while !fileexists("/sys/daemon.g.bak")
    var chamberTemp = sensors.analog[3].lastReading
    var targetTemp = var.chamberTemp + 20
    if var.targetTemp < 40
        set var.targetTemp = 40
    if var.chamberTemp >= 100
        set var.targetTemp = 120
    M106 P0 H1 T{var.targetTemp} S1 B0
    M106 P2 H0 T{var.targetTemp} S1 B0
    G4 S15