G60 S0
if sensors.filamentMonitors[0].status == "noFilament"
  T1
elif sensors.filamentMonitors[1].status == "noFilament"
  T0
M291 R"Filament runout was detected" P"Select the option." S4 K{"Change Filament", "Cancel"}
    if input == 0
      if move.extruders[state.currentTool].filament == "TPU (FLEX)"            ;TPU (FLEX)
        M98 P"0:/filaments/TPU (FLEX)/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/TPU (FLEX)/load.g"
      elif move.extruders[state.currentTool].filament == "ABS or ASA"          ;ABS os ASA
        M98 P"0:/filaments/ABS or ASA/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/ABS or ASA/load.g"
      elif move.extruders[state.currentTool].filament == "HIPS"                ;HIPS
        M98 P"0:/filaments/HIPS/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/HIPS/load.g"
      elif move.extruders[state.currentTool].filament == "IGUS A350"           ;IGUS A350
        M98 P"0:/filaments/IGUS A350/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/IGUS A350/load.g"
      elif move.extruders[state.currentTool].filament == "IGUS i151"           ;IGUS i151
        M98 P"0:/filaments/IGUS i151/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/IGUS i151/load.g"
      elif move.extruders[state.currentTool].filament == "Nylon"               ;Nylon
        M98 P"0:/filaments/Nylon/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/Nylon/load.g"
      elif move.extruders[state.currentTool].filament == "PC"                  ;PC
        M98 P"0:/filaments/PC/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PC/load.g"
      elif move.extruders[state.currentTool].filament == "PEEK"                ;PEEK
        M98 P"0:/filaments/PEEK/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PEEK/load.g"
      elif move.extruders[state.currentTool].filament == "PEI (9085 or 1010)"  ;PEI (9085 or 1010)
        M98 P"0:/filaments/PEI (9085 or 1010)/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PEI (9085 or 1010)/load.g"
      elif move.extruders[state.currentTool].filament == "PEKK"                ;PEKK
        M98 P"0:/filaments/PEKK/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PEKK/load.g"
      elif move.extruders[state.currentTool].filament == "PETG"                ;PETG
        M98 P"0:/filaments/PETG/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PETG/load.g"
      elif move.extruders[state.currentTool].filament == "PLA"                 ;PLA
        M98 P"0:/filaments/PLA/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PLA/load.g"
      elif move.extruders[state.currentTool].filament == "PP"                  ;PP
        M98 P"0:/filaments/PP/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PP/load.g"
      elif move.extruders[state.currentTool].filament == "PSU or PPSU"         ;PSU or PPSU
        M98 P"0:/filaments/PSU or PPSU/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/PSU or PPSU/load.g"
      elif move.extruders[state.currentTool].filament == "Support - PVA"        ;Support - PVA
        M98 P"0:/filaments/Support - PVA/unload.g"
        M291 R"Loading new filament" P"Prepare the new filament for loading." S4 K{"Load", "Cancel"}
          if input == 0
            M98 P"0:/filaments/Support - PVA/load.g"
T R0
