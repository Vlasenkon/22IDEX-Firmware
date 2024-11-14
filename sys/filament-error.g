; filament-error.g
; Called when a filament error is detected


M400  
; Pause the print with filament-error parameter
M25 D"filament-error"   ; This will call pause.g with the parameter