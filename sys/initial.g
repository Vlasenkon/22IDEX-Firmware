M98 P"0:/sys/led/start_cold.g"

var S0 = tools[0].active[0]
var S1 = tools[1].active[0]
var R0 = tools[0].standby[0]
var R1 = tools[1].standby[0]

var div = 100                          ; Diviation for Nozzle Temp During Wait for a Bed

; Preheat (Cold) ===========================================================================

; Set Tool Temp - Temp Delta
if var.S0 > 0 && var.S1 > 0
  T3 P0
  M568 P0 S{var.S0 - var.div} R{var.S0 - var.div}
  M568 P1 S{var.S1 - var.div} R{var.S0 - var.div}
  M568 P2 S{{var.S0 - var.div}, {var.S1 - var.div}} R{{var.S0 - var.div}, {var.S1 - var.div}}
  M568 P3 S{{var.S0 - var.div}, {var.S1 - var.div}} R{{var.S0 - var.div}, {var.S1 - var.div}}
elif var.S0 > 0
  T0 P0
  M568 P0 S{var.S0 - var.div} R{var.S0 - var.div}
  M568 P1 S{0} R{0}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}
elif var.S1 > 0
  T1 P0
  M568 P0 S{0} R{0}
  M568 P1 S{var.S1 - var.div} R{var.S1 - var.div}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}
else
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Selected Temperature"
  abort "Error: Print cancelled due to Selected Temperature"
  T0 P0
  M568 P0 S{0} R{0}
  M568 P1 S{0} R{0}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}


; Wait for Bed and (Chamber - Optionally)
if !exists(param.W)
  M116 H2 S10
  M98 P"0:/user/chamberwait.g"



; Home all and MBC ===========================================================================
M98 P"0:/sys/led/start_hot.g"

G60 S0                                 ; Save selectrd tool to slot 0

M98 P"homeall.g" Z1 S1 L1              ; Home the machine
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Homing"
  abort "Error: Print cancelled due to Homing"


if exists(param.A) && exists(param.B) && exists(param.D) && exists(param.E)
  M98 P"mesh.g" A{param.A} B{param.B} D{param.D} E{param.E}
else
  M98 P"mesh.g"
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Mesh Compensation"
  abort "Error: Print cancelled due to Mesh Compensation"

;Clean the nozzles ===========================================================================
T R0                                   ; Load previously selected tool
M98 P"0:/sys/nozzlewipe.g" C1 W1

; Get Nozzles up to Temp ===========================================================================
if var.S0 > 0 && var.S1 > 0
  M568 P0 S{var.S0} R{var.R0}
  M568 P1 S{var.S1} R{var.R1}
  M568 P2 S{var.S0, var.S1} R{var.R0, var.R1}
  M568 P3 S{var.S0, var.S1} R{var.R0, var.R1}
elif var.S0 > 0
  M568 P0 S{var.S0} R{var.R0}
  M568 P1 S{0} R{0}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}
elif var.S1 > 0
  M568 P0 S{0} R{0}
  M568 P1 S{var.S1} R{var.R1}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}
else
  M98 P"0:/sys/led/fault.g"
  T0 P0
  M568 P0 S{0} R{0}
  M568 P1 S{0} R{0}
  M568 P2 S{0} R{0}
  M568 P3 S{0} R{0}
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Selected Temperature"
  abort "Error: Print cancelled due to Selected Temperature"


;Purge and Clean the nozzles ===========================================================================
M98 P"0:/sys/nozzlewipe.g" E50 W1


; Select the tool before ToolChange Retraction Enabled
if exists(param.E)
  T{param.E}


M98 P"0:/sys/entoolchangeretraction.g" ; Enable ToolChange Retraction

M208 Z-1 S1                            ; set axis minima to allow for wider range of Z - Offset
M204 P5000 T5000                       ; set the accelerations