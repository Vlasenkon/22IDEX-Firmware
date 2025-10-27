M98 P"0:/sys/led/start_cold.g"

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

M106 P7 H-1
M106 P7 S{global.hepafan}

; Wait for Bed and (Chamber - Optionally)
if !exists(param.W)
  M116 H2 S10
  M98 P"0:/user/chamberwait.g"



; Home all and MBC ===========================================================================
M98 P"0:/sys/led/start_hot.g"


M84 Y
G4 S2

M98 P"homeall.g" Z1 S1 L1              ; Home the machine  

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