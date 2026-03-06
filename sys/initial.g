M98 P"0:/sys/led/start_cold.g"

; Reset tool change globals to null (clears slicer overrides)
if exists(global.tool0RetractDistance)
  set global.tool0RetractDistance = null
if exists(global.tool1RetractDistance)
  set global.tool1RetractDistance = null
if exists(global.tool0ExtrudeDistance)
  set global.tool0ExtrudeDistance = null
if exists(global.tool1ExtrudeDistance)
  set global.tool1ExtrudeDistance = null

; Reload tool change values for next job
M98 P"0:/user/tool0retract.g"
M98 P"0:/user/tool1retract.g"
M98 P"0:/user/tool0extrude.g"
M98 P"0:/user/tool1extrude.g"

; Set global status variable (create or overwrite)
if !exists(global.printerStatus)
  global printerStatus = "prt_starting"
else
  set global.printerStatus = "prt_starting"

var S0 = tools[0].active[0]
var S1 = tools[1].active[0]
var R0 = tools[0].standby[0]
var R1 = tools[1].standby[0]

var div_Homing = 100
var div_Cleaning = 20
var coldHomed = false
var bedMoved = false


; Preheat (Cold) ===========================================================================

; Select Tool and Set Temp - Temp Delta
if var.S0 > 0 && var.S1 > 0
  T3 P0  ; Select mirror mode for both tools
  M568 P0 S{var.S0 - var.div_Homing} R{var.S0 - var.div_Homing} A2
  M568 P1 S{var.S1 - var.div_Homing} R{var.S0 - var.div_Homing} A2
  M568 P2 S{{var.S0 - var.div_Homing}, {var.S1 - var.div_Homing}} R{{var.S0 - var.div_Homing}, {var.S1 - var.div_Homing}} A2
  M568 P3 S{{var.S0 - var.div_Homing}, {var.S1 - var.div_Homing}} R{{var.S0 - var.div_Homing}, {var.S1 - var.div_Homing}} A2
elif var.S0 > 0
  T0 P0  ; Select tool 0 only
  M568 P0 S{var.S0 - var.div_Homing} R{var.S0 - var.div_Homing} A2
  M568 P1 S{0} R{0} A0
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0
elif var.S1 > 0
  T1 P0  ; Select tool 1 only
  M568 P0 S{0} R{0} A0
  M568 P1 S{var.S1 - var.div_Homing} R{var.S1 - var.div_Homing} A2
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0
else
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Selected Temperature"
  abort "Error: Print cancelled due to Selected Temperature"
  T0 P0
  M568 P0 S{0} R{0} A0
  M568 P1 S{0} R{0} A0
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0

G60 S0  ; Save Tool selection to slot 0

; ============= Initial Cold Homing =============
; Home axes so we can safely command Z moves (bed lowering)
; Skip if already homed (e.g., back-to-back prints)
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed
  set var.coldHomed = true
  M98 P"homeall.g" S1 N1               ; Cold home — probe placed back after (no L1)

; ============= Heating Optimization & HEPA Fan Control =============
; Three-tier strategy based on bed target temperature:
;   Tier 1 (<140°C)  — Default heating, gradual HEPA ramp to full speed
;   Tier 2 (140-165°C) — Lower bed to Z350 to reduce HEPA airflow, gradual ramp
;   Tier 3 (>165°C)  — HEPA OFF for bed heating, then 50% for chamber & print

var heatStart = state.upTime
var bedTarget = heat.heaters[2].active
var bedReached = false
if var.bedTarget > 0 && heat.heaters[2].current >= (var.bedTarget - 5)
  set var.bedReached = true

; Capture chamber state before heating begins (for heat soak calculation)
var chamberTarget = heat.heaters[3].active
var chamberStartTemp = sensors.analog[3].lastReading

if var.chamberTarget > 0
  echo "Chamber target: "^var.chamberTarget^"C (starting from "^var.chamberStartTemp^"C)"

; Initialize HEPA high-temp mode flag (signals end.g to restore full speed)
if !exists(global.hepaHighTempMode)
  global hepaHighTempMode = false
else
  set global.hepaHighTempMode = false

var hepaTarget = global.hepafan           ; Default: full user speed
var hepaRamp = 0

; --- Tier 3: Above 165°C — HEPA OFF for bed, then 50% for chamber ---
if var.bedTarget > 165
  set var.hepaTarget = global.hepafan / 2
  M106 P7 H-1                            ; Switch HEPA to manual control
  M106 P7 S0                             ; HEPA OFF during bed heating
  ; Always lower bed — reduces HEPA airflow when fan kicks in for chamber
  if !var.bedReached
    G1 Z350 F3000
    set var.bedMoved = true
    M400
  set global.hepaHighTempMode = true

elif var.bedTarget >= 140                 ; Tier 2: 140-165°C — Lower bed to reduce HEPA airflow
  if !var.bedReached
    G1 Z350 F3000
    set var.bedMoved = true
    M400

; --- Tier 1: Below 140°C — No special action needed ---


; ============= Wait for Bed, Chamber & Heat Soak =============
if !exists(param.W)
  if var.bedReached
    echo "Bed already at target temperature"
  else
    echo "Heating bed..."
    M116 H2 S10
    echo "Bed reached target temperature"

  ; --- Tier 3: Ramp HEPA to 50% after bed is hot so chamber can heat ---
  if var.bedTarget > 165
    echo "Bed heated - ramping HEPA to "^floor(var.hepaTarget / 2.55)^"% (50% of user preset "^floor(global.hepafan / 2.55)^"%)"
    M106 P7 H-1
    while var.hepaRamp < var.hepaTarget
      set var.hepaRamp = min(var.hepaRamp + 10, var.hepaTarget)
      M106 P7 S{var.hepaRamp}
      G4 P500
    M106 P7 S{var.hepaTarget}

  ; --- Chamber Wait & Heat Soak ---
  if var.chamberTarget > 0
    echo "Waiting for chamber to reach "^var.chamberTarget^"C..."
    M116 H3 S5                           ; Wait for chamber within 5°C tolerance
    echo "Chamber reached target temperature"

    ; Calculate heat soak based on how cold the chamber started
    var tempDelta = var.chamberTarget - var.chamberStartTemp
    var soakTime = 0

    if var.tempDelta <= 5
      echo "Skipping heat soak - chamber was already at "^var.chamberStartTemp^"C"
    elif var.tempDelta <= 20
      set var.soakTime = 120
      echo "Heat soaking for 2 min - chamber started warm at "^var.chamberStartTemp^"C"
    elif var.tempDelta <= 50
      set var.soakTime = 180
      echo "Heat soaking for 3 min - chamber started at "^var.chamberStartTemp^"C"
    else
      set var.soakTime = 300
      echo "Heat soaking for 5 min - chamber started cold at "^var.chamberStartTemp^"C"

    if var.soakTime > 0
      G4 S{var.soakTime}
      echo "Heat soak complete"


; ============= HEPA Fan Gradual Ramp (Tier 1 & 2 only) =============
; Tier 3 already ramped HEPA above; skip if already running
if var.bedTarget <= 165
  M106 P7 H-1
  while var.hepaRamp < var.hepaTarget
    set var.hepaRamp = min(var.hepaRamp + 10, var.hepaTarget)
    M106 P7 S{var.hepaRamp}
    G4 P500
  M106 P7 S{var.hepaTarget}

var heatDuration = state.upTime - var.heatStart
var heatMin = floor(var.heatDuration / 60)
var heatSec = mod(var.heatDuration, 60)
echo "Preheat completed in "^var.heatMin^"m "^var.heatSec^"s"

; Hot Re-Home & MBC =========================================================================
M98 P"0:/sys/led/start_hot.g"

; Re-home only when cold home ran (thermal expansion) or bed physically moved
if var.coldHomed || var.bedMoved
  M84 Y
  G4 S2
  M98 P"homeall.g" S1 L1               ; Hot re-home (L1 keeps probe for mesh)
  M98 P"0:/user/xy_square_manual.g"
  M98 P"0:/user/xy_square_auto.g"
  M98 P"0:/user/xy_square_mode.g"
  M98 P"0:/sys/xy_squaring.g"

M98 P"0:/user/periodic_wiping.g"

if exists(param.A) && exists(param.B) && exists(param.D) && exists(param.J)
  M98 P"mesh.g" A{param.A} B{param.B} D{param.D} J{param.J}
else
  M98 P"mesh.g"


;Clean the nozzles ===========================================================================
T R0                                        ; Restore previously selected tool from slot 0

; Pre-heat to 20°C below target for initial cleaning
if var.S0 > 0 && var.S1 > 0
  M568 P0 S{var.S0 - var.div_Cleaning} R{var.R0} A2
  M568 P1 S{var.S1 - var.div_Cleaning} R{var.R1} A2
  M568 P2 S{var.S0 - var.div_Cleaning, var.S1 - var.div_Cleaning} R{var.R0, var.R1} A2
  M568 P3 S{var.S0 - var.div_Cleaning, var.S1 - var.div_Cleaning} R{var.R0, var.R1} A2
elif var.S0 > 0
  M568 P0 S{var.S0 - var.div_Cleaning} R{var.R0} A2
elif var.S1 > 0
  M568 P1 S{var.S1 - var.div_Cleaning} R{var.R1} A2

M98 P"0:/sys/nozzlewipe.g" C1 W1
M42 P4 S0
; Get Nozzles up to Full Temp ===========================================================================
if var.S0 > 0 && var.S1 > 0
  M568 P0 S{var.S0} R{var.R0} A2
  M568 P1 S{var.S1} R{var.R1} A2
  M568 P2 S{var.S0, var.S1} R{var.R0, var.R1} A2
  M568 P3 S{var.S0, var.S1} R{var.R0, var.R1} A2
elif var.S0 > 0
  M568 P0 S{var.S0} R{var.R0} A2
  M568 P1 S{0} R{0} A0
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0
elif var.S1 > 0
  M568 P0 S{0} R{0} A0
  M568 P1 S{var.S1} R{var.R1} A2
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0
else
  M98 P"0:/sys/led/fault.g"
  T0 P0
  M568 P0 S{0} R{0} A0
  M568 P1 S{0} R{0} A0
  M568 P2 S{0} R{0} A0
  M568 P3 S{0} R{0} A0
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Selected Temperature"
  abort "Error: Print cancelled due to Selected Temperature"


;Final Purge and Clean the nozzles ===========================================================================
; Final purge with 50mm extrusion for the selected tool(s)
T R0  ; Restore previously selected tool
M98 P"0:/sys/nozzlewipe.g" E50 W1

M42 P4 S0

; Final tool selection (use param.E if provided, otherwise keep current selection)
if exists(param.E)
  T{param.E}
; If no param.E, tool is already correctly selected from above


M208 Z-1 S1                            ; set axis minima to allow for wider range of Z - Offset
M204 P5000 T5000                       ; set the accelerations

M42 P4 S0

; Clear the global status
set global.printerStatus = "None"