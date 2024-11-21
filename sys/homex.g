T0

M204 T2000

G91
G1 H2 Z10 F18000        ; lift Z relative to current position
G1 H2 X5 F18000
G90
G1 Y172 F18000


G91                     ; relative positioning
G1 H1 X-375 F6000       ; move quickly to X axis endstop and stop there (first pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home X failed"
  abort "Error: Home X failed"


G1 H2 X5 F18000         ; go back a few mm

G1 H1 X-10 F240        ; move slowly to X axis endstop once more (second pass)
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Home X failed"
  abort "Error: Home X failed"


G1 H2 X1 F18000         ; go back a few mm
G92 X-999

G1 H2 Z-10 F18000       ; lower Z again
G90                     ; absolute positioning

M204 T5000