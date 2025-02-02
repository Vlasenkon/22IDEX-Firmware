; filament-error.g
; Called when a filament error is detected

if exists(global.filamenterror)
  set global.filamenterror = true
else
  global filamenterror = true

; Pause the print with filament-error parameter
M25 ; This will call pause.g with the parameter

M400

if exists(global.filamentbackup) && global.filamentbackup == true
  M400
  M24 ; Resume the print
else
  M291 R"Filament runout was detected" P"Change the filament, verify temperatures, close the door and resume the print." S2 T999


; Reset the filamenterror flag
if exists(global.filamenterror)
  set global.filamenterror = false
else
  global filamenterror = false