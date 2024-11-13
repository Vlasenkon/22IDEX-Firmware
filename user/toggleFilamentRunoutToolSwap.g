; toggleFilamentRunoutToolSwap.g
; Toggles the filament runout tool swap feature

if global.filamentRunoutTakeover == true
  set global.filamentRunoutTakeover = false
  echo "Filament runout tool swap feature disabled."
else
  set global.filamentRunoutTakeover = true
  echo "Filament runout tool swap feature enabled."

; Save the updated value to filamentRunoutToolSwap.g for persistence
echo >"0:/user/filamentRunoutToolSwap.g" "if exists(global.filamentRunoutTakeover)"
echo >>"0:/user/filamentRunoutToolSwap.g" "  set global.filamentRunoutTakeover = "^{global.filamentRunoutTakeover}
echo >>"0:/user/filamentRunoutToolSwap.g" "else"
echo >>"0:/user/filamentRunoutToolSwap.g" "  global filamentRunoutTakeover = "^{global.filamentRunoutTakeover}