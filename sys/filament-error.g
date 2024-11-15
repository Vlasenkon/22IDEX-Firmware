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

; Reset the filamenterror flag
if exists(global.filamenterror)
  set global.filamenterror = false
else
  global filamenterror = false