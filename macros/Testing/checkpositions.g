M98 P"tfree3.g"                       ; Run the "tfree3.g" macro to free the tool
T0

M204 T2000                            ; Set acceleration for non-printing moves


;=== Y-AXIS POSITION CHECK ===
echo "Checking Y-axis positions..."

G90
G1 Y-150 F18000                        ; Move to safe Y position

;=== Check Y-axis endstop positions ===
G91                                   ; Switch to relative positioning
G1 H4 Y-400 F1800                     ; Move towards Y endstop and record position when triggered
G1 Y5 F1200                           ; Move away from endstop by 5 mm

; Initialize variables to store the positions
var leftEndstopPosition = 0
var rightEndstopPosition = 0
var currentYPos = 0
var side = ""

; Check which endstop was triggered and record position
M574 Y1 S1 P"io1.in"                  ; Configure the Y endstop on io1.in
M400
G4 P300
if sensors.endstops[1].triggered      ; Check if the Y1 endstop on io1.in is triggered
    set var.side = "right"            ; If endstop on io1.in is triggered, this is right side
    
M574 Y1 S1 P"io2.in"                  ; Switch the Y endstop to io2.in
M400
G4 P300
if sensors.endstops[1].triggered      ; Check if the Y1 endstop on io2.in is triggered
    set var.side = "left"             ; Set "left" as the side if the endstop is triggered
    M574 Y1 S1 P"io1.in"              ; Configure the Y endstop on io1.in
    G4 P300
    if sensors.endstops[1].triggered  ; Check if both endstops are triggered
        set var.side = "both"         ; Both endstops triggered

; Record the first endstop position
M400
G4 P300
set var.currentYPos = move.axes[1].machinePosition
if var.side == "right"
    set var.rightEndstopPosition = var.currentYPos
    echo "Right Y endstop position: " ^ {var.rightEndstopPosition} ^ " mm"
elif var.side == "left" 
    set var.leftEndstopPosition = var.currentYPos
    echo "Left Y endstop position: " ^ {var.leftEndstopPosition} ^ " mm"

; Now check the other endstop by switching motor drivers
if var.side == "right"
  M584 Y0.4                           ; Switch to the other driver for the Y axis
  M574 Y1 S1 P"io2.in"                ; Configure the Y endstop on io2.in
  G1 H4 Y-10 F140                     ; Move towards left endstop and record position
  M400
  G4 P300
  set var.leftEndstopPosition = move.axes[1].machinePosition
  echo "Left Y endstop position: " ^ {var.leftEndstopPosition} ^ " mm"

if var.side == "left"
  M584 Y0.1                           ; Switch to the other driver for the Y axis  
  M574 Y1 S1 P"io1.in"                ; Configure the Y endstop on io1.in
  G1 H4 Y-10 F140                     ; Move towards right endstop and record position
  M400
  G4 P300
  set var.rightEndstopPosition = move.axes[1].machinePosition
  echo "Right Y endstop position: " ^ {var.rightEndstopPosition} ^ " mm"

; Calculate and report Y-axis offset
var yOffset = abs(var.leftEndstopPosition - var.rightEndstopPosition)
echo "Y-axis endstop offset: " ^ {var.yOffset} ^ " mm"

; Restore Y-axis configuration
M584 Y0.1:0.4                         ; Use both drivers for the Y axis
M574 Y1 S1 P"io1.in+io2.in"           ; Configure endstops for both sides of the Y axis



















;=== X-AXIS POSITION CHECK ===
echo "Checking X-axis position..."


G91                                   ; Switch to relative positioning
G1 H2 X5 U-5 F18000                   ; Move away from any potential endstop
G90                                   ; Switch to absolute positioning
G1 Y172 F18000                        ; Move to safe Y position

G91                                   ; Switch to relative positioning
G1 H4 X-375 F1800                     ; Move towards X endstop and record position when triggered

var xEndstopPosition = move.axes[0].machinePosition
echo "X-axis endstop position: " ^ {var.xEndstopPosition} ^ " mm"

G1 H2 X5 F18000                       ; Move away from endstop by 5 mm

;=== U-AXIS POSITION CHECK ===
echo "Checking U-axis position..."

G91                                   ; Switch to relative positioning
G1 H2 U-5 F18000                      ; Move away from any potential endstop
G90                                   ; Switch to absolute positioning  


G91                                   ; Switch to relative positioning
G1 H4 U375 F1800                      ; Move towards U endstop and record position when triggered

var uEndstopPosition = move.axes[3].machinePosition
echo "U-axis endstop position: " ^ {var.uEndstopPosition} ^ " mm"

G1 H2 U-5 F18000                      ; Move away from endstop by 5 mm

;=== SUMMARY REPORT ===
echo "=== POSITION CHECK SUMMARY ==="
echo "Left Y endstop: " ^ {var.leftEndstopPosition} ^ " mm"
echo "Right Y endstop: " ^ {var.rightEndstopPosition} ^ " mm"  
echo "Y-axis offset: " ^ {var.yOffset} ^ " mm"
echo "X-axis endstop: " ^ {var.xEndstopPosition} ^ " mm"
echo "U-axis endstop: " ^ {var.uEndstopPosition} ^ " mm"


M400                                  ; Ensure all moves are completed