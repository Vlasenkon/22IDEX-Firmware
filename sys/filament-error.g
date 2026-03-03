; filament-error.g
; Called when a filament error is detected
; param.D contains the extruder number that triggered the error

; First, check if parameter D was passed (which extruder triggered)
var triggeredExtruder = -1
if exists(param.D)
  set var.triggeredExtruder = param.D

; Get the current active tool
var currentTool = state.currentTool

; By default, always pause (for safety and backward compatibility)
var shouldPause = true

; Variable for tool name in notification
var toolName = "Unknown"

; Only change shouldPause to false if parameter D exists and tools don't match
if var.triggeredExtruder >= 0
  ; If tool 0 is active but extruder 1 triggered, don't pause
  if var.currentTool == 0 && var.triggeredExtruder == 1
    set var.shouldPause = false
  ; If tool 1 is active but extruder 0 triggered, don't pause
  elif var.currentTool == 1 && var.triggeredExtruder == 0
    set var.shouldPause = false


; Only proceed with pause if shouldPause is true
if var.shouldPause
  ; Notify user about filament runout
  if var.triggeredExtruder == 0
    set var.toolName = "Left Tool (T0)"
  elif var.triggeredExtruder == 1
    set var.toolName = "Right Tool (T1)"
  
  M291 R"Filament Runout Detected" P{"Filament runout detected on " ^ var.toolName ^ "<br><br>Extruder: " ^ var.triggeredExtruder ^ "<br>Active Tool: T" ^ var.currentTool} S1 T0
  
  if exists(global.filamenterror)
    set global.filamenterror = true
  else
    global filamenterror = true

  ; Pause the print with filament-error parameter
  M25 ; This will call pause.g with the parameter

  M400

  if exists(global.filamentbackup) && global.filamentbackup == true
    M400

    ; Purge old/residual filament from the backup tool hotend (1.5 m at 3 mm/s)
    M291 R"Purging Filament" P"Purging residual filament from backup tool before resuming.<br>Please wait..." S1 T0
    M83                                                                                     ; relative extruder mode
    G1 E1500 F180                                                                            ; extrude 1500 mm (1.5 m) at 3 mm/s
    M400                                                                                     ; wait for purge to complete
    M98 P"0:/sys/nozzlewipe.g"                                                               ; wipe nozzle after purge

    M292
    M24 ; Resume the print

  ; Reset the filamenterror flag
  if exists(global.filamenterror)
    set global.filamenterror = false
  else
    global filamenterror = false