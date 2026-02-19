M400 ; finish all current moves and clear the movement buffer

; Check the machine state status and pause it if it's printing
;   - List of available statuses is in .github/instructions/Duet3D.instructions.md:7557 (Current state of the machine)
;   - TODO: move the statuses list to some place with documentation for developers
if state.status == "processing"
  M25 ; Pause SD printing


; Load user settings to define the Shutdown logic if Heater Fault occurred
M98 P"0:/user/heaterfault_timer.g"


; Flash red LEDs
M98 P"0:/sys/led/fault.g"
var error_title = "Heater Fault"


; If shutdown logic is not configured by user then we just show a warning message
if !exists(global.heaterfault_timer)
  M291 S1 R{error_title} P"Warning: Heater fault detected"
else
  ; Shutdown logic: user's timeout settings will be used to shut printer down completely
  if global.heaterfault_timer >= 0
    var timeout = global.heaterfault_timer
    
    if var.timeout == 0
      M291 R{error_title} P"Printer was shut down because of a heater fault." S2
      M81 ; turn power off immediately
    else
      M291 P{"Heater error detected — the printer will shut down in "^var.timeout^" seconds."} R{error_title} S4 K{"Shut down now","Keep power on"} J2 T{var.timeout}
      if result == -1 || input == 0
        M81 ; turn power off immediately after M291 times out
      else
        echo "Shutdown canceled"
    
  else
    echo "Error: The 'heaterfault_timer' value is negative: " ^ heaterfault_timer;
