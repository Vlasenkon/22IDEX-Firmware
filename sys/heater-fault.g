M400
if state.status == "printing" || state.status != "processing"
  M25

M98 P"0:/sys/led/fault.g"

M98 P"0:/user/heaterfault_timer.g"

if exists(global.heaterfault_timer) && global.heaterfault_timer >= 0
  var timeout = global.heaterfault_timer
  if var.timeout == 0
    M291 R"Heater Fault" P"Printer was shut down because of a heater fault." S2
    M81
  else
    M291 P{"Heater error detected — the printer will shut down in "^var.timeout^" seconds."} R"Heater faults" S4 K{"Shut down now","Keep power on"} J2 T{var.timeout} F0
    if result == -1 || input == 0
      M81
    else
      echo "Shutdown canceled"