; filament-error.g
; Called when a filament error is detected

M400
if global.filamentRunoutTakeover == true
  if exists(global.filamenterror)
    set global.filamenterror = true
  else
    global filamenterror = true

; Pause the print with filament-error parameter
M25 ; This will call pause.g with the parameter

M400
M400

M24 ; Resume the print