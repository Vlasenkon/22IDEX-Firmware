if state.status == "off"
  M80                      ; Turn on power
  G4 S3
  
M98 P"0:/sys/led/homeall.g"
M98 P"tfree3.g"

T0 P0
M280 P0 S0                 ; Take probe holder out of the way


M204 T2000

;=== Move  X & U ===
G91
G1 H2 Z20 F18000
G1 H2 X10 U-10 F18000


;=== Home with Y End Stops ===
G90
G1 H1 Y-500 F3000
G91
G1 Y5 F1200
G1 H1 Y-10 F240
G92 Y0
G4 P260
var ll = move.axes[1].machinePosition




;=== Home with Right end stop ===
M584 Y0.1
M574 Y1 S1 P"io1.in"
G1 H4 Y-5 F240

;=== Home with Left end stop ===
M584 Y0.4
M574 Y1 S1 P"io2.in"
G1 H4 Y-5 F240
G4 P260
var rr = move.axes[1].machinePosition



var dd = var.rr - var.ll

;if abs(var.dd) > 0.5

;echo "RR is "^{var.rr}^" mm"
;echo "LL is "^{var.ll}^" mm"
;echo "DD is "^{var.dd}^" mm"


G92 Y-999
M584 Y0.1:0.4
M574 Y1 S1 P"io1.in+io2.in"                          ; configure endstop

G90
G1 Y150 F18000

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