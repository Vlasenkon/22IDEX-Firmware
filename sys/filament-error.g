; filament-error.g
; Called when a filament error is detected

; Load the filament runout tool swap variable
M98 P"0:/user/filamentRunoutToolSwap.g"

; Check if automatic tool swapping is enabled
if global.filamentRunoutTakeover
  ; Set flag to indicate filament runout
  set global.isFilamentRunout = true
  
  ; Ensure all previous commands are completed
  M400
  
  ; Pause the print
  M25   ; This will call pause.g

else
  ; Automatic tool swapping is disabled
  echo "Filament runout detected. Pausing print."
  M25   ; Pause print