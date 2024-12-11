if state.status == "off"
  M80                      ; Turn on power
  G4 S3
  
M98 P"0:/sys/led/homeall.g"
M98 P"tfree3.g"

T0 P0
M280 P0 S0                 ; Take probe holder out of the way


M204 T2000


; Senseless Home Y
M574 Y1 S3
G91                        ; use relative positioning
G1 H2 Z20 F6000            ; lift Z relative to current position
G1 H2 X10 U-10 F6000

M84 Y
G4 S1

M915 Y S3 R0 F0            ; set X and Y to sensitivity 3, do nothing when stall, unfiltered
M204 P500 T500 

;Home Y 1st time
M913 Y70                   ; drop motor current
G1 H1 Y-400 F6000          ; move quickly to X axis endstop and stop there
M913 Y100

G1 Y50 F6000 ;Back off

M84 Y
G4 S1

;Home Y 2nd time
M913 Y70
G1 H1 Y-60 F3000           ; move quickly to X axis endstop and stop there
M913 Y100

G90
M204 T5000                 ; return the accelerations



; Home X and U
G90
G1 Y165 F6000


G91                        ; relative positioning
;G1 H1 X-375 U375 F6000     ; move quickly to both axis endstops and stop there (first pass)


G91                     ; relative positioning
G1 H1 X-375 F6000       ; move quickly to X axis endstop and stop there (first pass)


G91                     ; relative positioning
G1 H1 U375 F6000        ; move quickly to X axis endstop and stop there (first pass)

G90                        ; absolute positioning

; Home with Y End Stops
G91

G1 X10 U-10 F6000


;=== Home with both end stops ===
G90


M574 Y2 S1 P"Zstop+Ystop"
G1 H1 Y190 F600
G91
G1 Y-5 F1200
G1 H1 Y10 F240

G92 Y150
G4 P260
var ll = move.axes[1].machinePosition


;=== Home with Right end stop ===
M584 Y9
M574 Y2 S1 P"Ystop"
G1 H4 Y5 F240

;=== Home with Left end stop ===
M584 Y0
M574 Y2 S1 P"Zstop"
G1 H4 Y5 F240


G4 P260
var rr = move.axes[1].machinePosition - {5}

var dd = var.rr - var.ll

if var.dd > 1.5
  echo "Div "^{var.dd}

G92 Y999




M584 Y0:9
G90
G1 Y165 F6000
G91
G1 H1 X-20 F240            ; move slowly to X axis endstop once more (second pass)
G1 H1 U20 F240             ; move slowly to U axis endstop once more (second pass)
G90                        ; absolute positioning



; Lower Z
if !exists(param.L)
  G91
  G1 H2 Z-20 F18000
  G90

; Reset parameters
M400                       ; make sure everything has stopped before we make changes
G90                        ; absolute positioning
M913 Y100                  ; return current to 100%
M204 T5000                 ; return the accelerations