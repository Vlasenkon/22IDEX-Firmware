if state.status == "off"
  M80                                 ; Turn on power if it's off
  G4 S3                               ; Delay for 3 seconds to allow power to stabilize
  
M98 P"0:/sys/led/resetstatus.g"       ; Reset the status of the LEDs
M98 P"tfree3.g"                       ; Run the "tfree3.g" macro to free the tool

T0 P0                                 ; Select tool T0 with priority 0
M280 P0 S0                            ; Move the probe out of the way (to its default position)

M204 T2000                            ; Set acceleration for non-printing moves

;=== Move the X & U axes ===
G91                                   ; Switch to relative positioning
G1 H2 Z20 F18000                      ; Lift the Z axis by 20 mm at 18000 mm/min
G1 H2 X10 U-10 F18000                 ; Move the X and U axes 10 mm in opposite directions at 18000 mm/min

;=== Home with Y End Stops ===
G91                                   ; Switch to absolute positioning
G1 H1 Y-400 F3000                     ; Move the Y axis back quickly to hit the endstop
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Y axis homing failed"
  abort "Error: Y axis homing failed"
G1 Y5 F1200                           ; Move the Y axis forward by 5 mm

; Initialize variables to store the zero positions of the left and right sides
var leftZeroPosition = 0
var rightZeroPosition = 0
var dis = 0
var side = ""

G1 H1 Y-10 F200                       ; Move the Y axis back quickly to hit the endstop
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Y axis homing failed"
  abort "Error: Y axis homing failed"

M574 Y1 S1 P"io1.in"                  ; Configure the Y endstop on io1.in
if sensors.endstops[1].triggered      ; Check if the Y1 endstop on io1.in is triggered
    set var.side =  "right"           ; If only the endstop on io1.in is triggered, set "right" as the side    
M574 Y1 S1 P"io2.in"                  ; Switch the Y endstop to io2.in
if sensors.endstops[1].triggered      ; Check if the Y1 endstop on io2.in is triggered
    set var.side =  "left"            ; Set "left" as the side if the endstop is triggered
    M574 Y1 S1 P"io1.in"              ; Configure the Y endstop on io1.in
    if sensors.endstops[1].triggered  ; Check if the Y1 endstop on io1.in is triggered
        set var.side =  "" 

G92 Y0                                ; Set the current Y axis position to 0
; Handle the case when the left side is determined
if var.side == "right"
  M584 Y0.4                           ; Switch to the other driver for the Y axis
  M574 Y1 S1 P"io2.in"                ; Configure the Y endstop on io2.in
  G1 H4 Y-10 F140                     ; Precisely move the Y axis back by 10 mm at 140 mm/min
  set var.rightZeroPosition = move.axes[1].machinePosition  ; Store the right side zero position

; Handle the case when the right side is determined
if var.side == "left"
  M584 Y0.1                           ; Switch to the other driver for the Y axis
  M574 Y1 S1 P"io1.in"                ; Configure the Y endstop on io1.in
  G1 H4 Y-10 F140                     ; Precisely move the Y axis back by 10 mm at 140 mm/min
  set var.leftZeroPosition = move.axes[1].machinePosition  ; Store the left side zero position

; Calculate the offset between the left and right positions
set var.dis = abs(var.leftZeroPosition - var.rightZeroPosition)

; If the offset is greater than 0.5 mm, print a correction message
if var.dis >= 0.5
  echo "Error: The "^{var.side}^" side has been adjusted by "^{var.dis}^" mm"

; Reset the Y axis position and restore the original endstop configuration
G92 Y-999                             ; Set the current Y axis position to -999
M584 Y0.1:0.4                         ; Use both drivers for the Y axis
M574 Y1 S1 P"io1.in+io2.in"           ; Configure endstops for both sides of the Y axis

G90                                   ; Switch to absolute positioning
G1 Y150 F18000                        ; Move the Y axis forward by 150 mm at 18000 mm/min

; Lower the Z axis if parameter L does not exist
if !exists(param.L)
  G91                                 ; Switch to relative positioning
  G1 H2 Z-20 F18000                   ; Lower the Z axis by 20 mm at 18000 mm/min
  G90                                 ; Switch to absolute positioning

; Reset parameters and finish
M400                                  ; Ensure all moves are completed before making changes
G90                                   ; Switch to absolute positioning
M913 Y100                             ; Restore the Y axis motor current to 100%
M204 T5000                            ; Restore the original accelerations


if exists(param.T)
  if !exists(global.HomeYSide) && exists(var.side)
    global HomeYSide = var.side
  else
    set global.HomeYSide = var.side
  
  if !exists(global.HomeYDis) && exists(var.dis)
    global HomeYDis = var.dis
  else
    set global.HomeYDis = var.dis