M98 P"0:/user/heaterfault_timer.g"

if global.heaterfault_timer >= 0
  var Time = state.time

  M291 P{"Heater error detected — the printer will shut down in "^global.heaterfault_timer^" seconds."} R"Heater faults" S4 K{"Shutdown",} J2 T{global.heaterfault_timer}

  if result == -1
    if state.time - var.Time < global.heaterfault_timer
      echo "Shutdown canceled"
    else
      M81      
      M112
  else
    M81
    M112
else
  M291 S2 R"Error notification" P"Heater error detected"
