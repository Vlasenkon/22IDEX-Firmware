T0 P0

M204 T2000

var uMaxTravel = abs(move.axes[3].max) + abs(move.axes[3].min) + 10

G91
G1 H2 Z10 F18000        ; lift Z relative to current position
G1 H2 U-5 F18000
G90

; Check if global.homeXUPosition exists and is within valid range (160-180)
if !exists(global.homeXUPosition)
  G1 Y172 F18000        ; use default value if variable doesn't exist
elif global.homeXUPosition < 160 || global.homeXUPosition > 180
  M98 P"0:/sys/led/fault.g"  ; activate red LEDs for error
  echo >>"0:/sys/eventlog.txt" "Error: homeXUPosition value "^global.homeXUPosition^" is out of range (160-180)"
  abort "Error: homeXUPosition value "^global.homeXUPosition^" is out of range (160-180)"
else
  G1 Y{global.homeXUPosition} F18000  ; use the stored position value


G91                     ; relative positioning
G1 H1 U{var.uMaxTravel} F1800        ; move quickly to U axis endstop and stop there (first pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home U failed"
  abort "Error: Home U failed"

G1 H2 U-5 F18000        ; go back a few mm

G1 H1 U10 F240         ; move slowly to U axis endstop once more (second pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home U failed"
  abort "Error: Home U failed"

G1 H2 U-1 F18000         ; go back a few mm
G92 U999

G1 H2 Z-10 F18000       ; lower Z again
G90                     ; absolute positioning

M204 T5000