G60 S0

var changeRequested = exists(param.A)

if !var.changeRequested
  M291 R"Filament runout was detected" P"Select the option." S4 K{"Change Filament", "Don't Change"} F0
  if result = -1 || input == 1
    abort "Operation cancelled"
  set var.changeRequested = true

if var.changeRequested
  if state.currentTool == 2 || state.currentTool == 3
    M291 R"Select Tool" P"Which Tool do you want to change filament on?" S4 K{"Left Tool (T0)", "Right Tool (T1)", "Cancel"} F0
    if result = -1 || input == 2
      abort "Operation cancelled"
    if input == 0
      T0
    else
      T1

  var filamentName = move.extruders[state.currentTool].filament
  if var.filamentName = null || var.filamentName = ""
    M291 S1 R"No Filament Assigned" P"Assign a filament to the active tool before running the filament change routine."
    abort

  var base = "0:/filaments/" ^ var.filamentName
  if !fileexists(var.base ^ "/unload.g") || !fileexists(var.base ^ "/load.g")
    M291 S1 R"Missing Filament Macros" P{"Expected unload/load macros in " ^ var.base ^ " but they were not found."}
    abort

  M98 P{var.base ^ "/unload.g"}

  M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
  if input == 0
    M98 P{var.base ^ "/load.g"}

T R0