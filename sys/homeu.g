T0

M204 T2000

G91
G1 H2 Z10 F18000        ; lift Z relative to current position
G1 H2 U-5 F18000
G90
G1 Y172 F18000


G91                     ; relative positioning
G1 H1 U375 F6000        ; move quickly to X axis endstop and stop there (first pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home U failed"
  abort "Error: Home U failed"

G1 H2 U-5 F18000        ; go back a few mm

G1 H1 U10 F240         ; move slowly to X axis endstop once more (second pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home U failed"
  abort "Error: Home U failed"

G1 H2 U-1 F18000         ; go back a few mm
G92 U999

G1 H2 Z-10 F18000       ; lower Z again
G90                     ; absolute positioning

M204 T5000