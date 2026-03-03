G60 S0

var changeRequested = exists(param.A)

if !var.changeRequested
  M291 R"Filament runout was detected" P"Change filament now?" S4 K{"Change Filament", "Don't Change"} F0
  if result = -1 || input == 1
    T R0
    M99
  set var.changeRequested = true

if !var.changeRequested
  T R0
  M99

; Choose a tool if we are in a combined/duplicate mode
if state.currentTool == -1
  M291 S1 R"No Tool Selected" P"Select a tool before running the filament change routine."
  abort

if state.currentTool == 2 || state.currentTool == 3
  M291 R"Select Tool" P"Which tool should be serviced?" S4 K{"Left Tool (T0)", "Right Tool (T1)", "Cancel"} F0
  if result = -1 || input == 2
    abort "Operation cancelled"
  if input == 0
    T0
  else
    T1

var tool = state.currentTool

; Capture the current tool temperature configuration so we can restore it afterwards
var originalActive = tools[var.tool].active
var originalStandby = tools[var.tool].standby
var originalState = tools[var.tool].state
var heaterCount = #var.originalActive

if var.heaterCount = 0
  M291 S1 R"Unsupported Tool" P"Selected tool has no heaters defined. Aborting filament change."
  abort

; Determine a working temperature – fall back to user input if the tool is currently cold
var targetTemp = 0.0
var i = 0
while var.i < var.heaterCount
  if var.originalActive[var.i] != null && var.originalActive[var.i] > var.targetTemp
    set var.targetTemp = var.originalActive[var.i]
  if var.originalStandby[var.i] != null && var.originalStandby[var.i] > var.targetTemp
    set var.targetTemp = var.originalStandby[var.i]
  set var.i = var.i + 1

var heaters = tools[var.tool].heaters
if #var.heaters > 0
  var primaryHeater = var.heaters[0]
  if heat.heaters[var.primaryHeater].current > var.targetTemp
    set var.targetTemp = heat.heaters[var.primaryHeater].current

if var.targetTemp < 120
  M291 S5 R"Filament Change" P{"Enter nozzle temperature for T" ^ var.tool} L0 H450 J1
  if result = -1
    abort "Operation cancelled"
  set var.targetTemp = input

var workingTemps = vector(var.heaterCount, var.targetTemp)
M568 P{var.tool} S{var.workingTemps} R{var.workingTemps} A2

; Execute the standard retract/load helpers with change-mode behaviour
M98 P"0:/sys/baseunload.g" C1

M291 R"Load New Filament" P"Insert the new filament, then choose Load." S4 K{"Load", "Cancel"}
if result != -1 && input = 0
  M98 P"0:/sys/baseload.g" C1
else
  echo "Filament unload completed; loading skipped."

; Restore the original temperature targets and tool state
M568 P{var.tool} S{var.originalActive} R{var.originalStandby} A{var.originalState}

T R0