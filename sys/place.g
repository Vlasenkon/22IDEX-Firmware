if !exists(global.probePickY)
  global probePickY = {move.axes[1].max}


; Test if the probe is present
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] > 500
  echo "Error: Probe not detected at start of placing"
  echo >>"0:/sys/eventlog.txt" "Error: Probe not detected at start of placing"
M42 P4 S0


;Move to Placing position
M204 T5000                 ; set the accelerations
T0                      ; Select first tool
G90
G1 F18000 Y135 X{global.probePickX} U{move.axes[3].max-10} ; Go to position
M400
M280 P0 S{global.probePickAngle}         ; Move probe holder to the 'pick/place' position
G4 S1

M564 S0
G90
G1 F18000 Y{global.probePickY}   ; Pick the probe
M564 S1



; Test if the probe is still present at the dock
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] > 500
  echo "Error: Probe was not detected at the dock after placing"
  echo >>"0:/sys/eventlog.txt" "Error: Probe was not detected at the dock after placing"
M42 P4 S0



; Movement to remove the Probe
M204 T2000                 ; set the accelerations
G91
G1 F18000 X-50             ; Shear probe off the tool head
M204 T5000                 ; set the accelerations
G1 F18000 Y-50
G1 F18000 U{move.axes[3].max}
G90
M400
M280 P0 S0       ; Take probe holder out of the way


; Test if the probe was removed
M42 P4 S1
G4 P500
if sensors.probes[0].value[0] < 500
  M42 P4 S0
  echo "probe stuck after shear — trying recovery"
  echo >>"0:/sys/eventlog.txt" "place.g: probe stuck after shear — trying recovery"

  var stateFile = "0:/sys/PrintStartState.csv"
  if !fileexists(var.stateFile)
    echo >>"0:/sys/eventlog.txt" "Error: Probe stuck — PrintStartState.csv not found"
    M98 P"0:/sys/led/fault.g"
    abort "Error: Probe stuck"

  var printState = fileread(var.stateFile, 0, 2, ',')
  var t0Temp = var.printState[0]
  var t1Temp = var.printState[1]

  if var.t0Temp == 0 && var.t1Temp == 0
    echo >>"0:/sys/eventlog.txt" "Error: Probe stuck — no print temps available"
    M98 P"0:/sys/led/fault.g"
    abort "Error: Probe stuck"

  var success = false
  var coldAttempt = 0

  ; === Hot retract on active tools ===
  if var.t0Temp > 0
    T0 P0
    M568 P0 S{var.t0Temp} R{var.t0Temp} A2
    M116 P0 S5
    M83
    G91
    G1 E-30 F2400
    G90
    M400

  if var.t1Temp > 0
    T1 P0
    M568 P1 S{var.t1Temp} R{var.t1Temp} A2
    M116 P1 S5
    M83
    G91
    G1 E-30 F2400
    G90
    M400

  T0 P0

  M42 P4 S1
  G4 P500
  if sensors.probes[0].value[0] > 500
    set var.success = true
  M42 P4 S0

  ; === Cold retract cycle: cool -40°C, retract 15mm, retry dock — up to 3 attempts ===
  while var.success == false && var.coldAttempt < 3
    set var.coldAttempt = var.coldAttempt + 1

    if var.t0Temp > 0
      T0 P0
      M568 P0 S{var.t0Temp - 40} R{var.t0Temp - 40} A2
      M116 P0 S5
      M83
      G91
      G1 E-15 F600
      G90
      M400

    if var.t1Temp > 0
      T1 P0
      M568 P1 S{var.t1Temp - 40} R{var.t1Temp - 40} A2
      M116 P1 S5
      M83
      G91
      G1 E-15 F600
      G90
      M400

    G4 S3
    T0 P0
    M204 T5000
    G90
    G1 F18000 Y135 X{global.probePickX} U{move.axes[3].max-10}
    M400
    M280 P0 S{global.probePickAngle}
    G4 S1
    M564 S0
    G90
    G1 F18000 Y{global.probePickY}
    M564 S1
    M204 T2000
    G91
    G1 F18000 X-50
    M204 T5000
    G1 F18000 Y-50
    G1 F18000 U{move.axes[3].max}
    G90
    M400
    M280 P0 S0
    M42 P4 S1
    G4 P500
    if sensors.probes[0].value[0] > 500
      set var.success = true
    M42 P4 S0

  M568 P0 S0 R0 A0
  M568 P1 S0 R0 A0
  T0 P0

  if var.success == false
    M98 P"0:/sys/led/fault.g"
    echo >>"0:/sys/eventlog.txt" "Error: Probe recovery failed"
    if fileexists(var.stateFile)
      M30 {var.stateFile}
    M291 R"Probe Stuck" P"Probe could not be removed automatically after hot and cold retract attempts. Please remove it manually and restart the print." S1
    abort "Error: Probe recovery failed"

M42 P4 S0
