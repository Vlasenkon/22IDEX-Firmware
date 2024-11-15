; resume.g
; called before a print from SD card is resumed

M204 T5000                 ; set the accelerations

M568 P0 A1
M568 P1 A1
M568 P2 A1
M568 P3 A1

T-1
T R4                 ; select the tool that was active last time the print was paused
G1 R4 Z2 F18000       ; go above the position of the last print move


M98 P"0:/sys/nozzlewipe.g" E50 W1 C5

M106 R4  ; Recover part cooling

M208 Z-1 S1         ; set axis minima to allow for wider range of Z - Offset


G1 R4 X0 Y0 F18000    ; go back to the last print move
G1 R4 Z0              ; go back to the last print move

M98 P"0:/sys/entoolchangeretraction.g" ; Enable ToolChange Retraction

M98 P"0:/sys/led/resume.g"

M204 T5000                 ; set the accelerations