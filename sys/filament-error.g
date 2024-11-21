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
  M291 R"Do you want to change the filament?" P"Filament Runout was detected" S3 K{"Change Filament","Do not change"}
  if input == 0
    M702 ; Unload the filament
    M400
    M701 ; Load the filament



; Reset the filamenterror flag
if exists(global.filamenterror)
  set global.filamenterror = false
else
  global filamenterror = false