G60 S0

if !exists(param.A)
  M291 R"Filament runout was detected" P"Select the option." S4 K{"Change Filament", "Cancel"}

if input == 0 || exists(param.A)
  var names = {"TPU (FLEX)", "ABS or ASA", "HIPS", "IGUS A350", "IGUS i151", "Nylon", "PC", "PEEK", "PEI (9085 or 1010)", "PEKK", "PETG", "PLA", "PP", "PSU or PPSU", "Support - PVA"}
  var folders = {"TPU (FLEX)", "ABS or ASA", "HIPS", "IGUS A350", "IGUS i151", "Nylon", "PC", "PEEK", "PEI (9085 or 1010)", "PEKK", "PETG", "PLA", "PP", "PSU or PPSU", "Support - PVA"}

  var idx = -1
  var i = 0
  while var.i < #var.names
    if move.extruders[state.currentTool].filament == var.names[var.i]
      set var.idx = var.i
      break
    set var.i = var.i + 1

  if var.idx < 0
    M291 S1 R"Unsupported Filament" P{"No unload/load macros registered for filament: " ^ move.extruders[state.currentTool].filament}
    abort

  var base = "0:/filaments/" ^ var.folders[var.idx]
  M98 P{var.base ^ "/unload.g"}

  M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
  if input == 0
    M98 P{var.base ^ "/load.g"}

T R0