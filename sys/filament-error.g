; filament-error.g
; Called when a filament error is detected

; Check if automatic tool swapping is enabled
if global.filamentRunoutTakeover == true  
  ; Ensure all previous commands are completed
  M400
  
  ; Pause the print with filament-error parameter
  M25 D"filament-error"   ; This will call pause.g with the parameter

else
  ; Automatic tool swapping is disabled
  echo "Filament runout detected. Pausing print."
  M25   ; Pause print