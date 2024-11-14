; resume.g
; called before a print from SD card is resumed

M204 T5000                 ; set the accelerations

M568 P0 A1
M568 P1 A1
M568 P2 A1
M568 P3 A1

T-1
; Check if resuming after filament runout
if global.filamentRunoutTakeover == true && exists(param.D) && param.D == "filament-error"
  ; Prepare new tool after filament runout  
  T{global.nextTool}                         ; Select the tool active before pause
else
  T R4


M116 H0 S5
M116 H1 S5
M116 H2 S5                                 ; Wait for heaters to reach temperature
  
M98 P"0:/sys/nozzlewipe.g" E50 W1 C5  
M208 Z-1 S1                                ; Set axis minima for Z-offset
    
; Move to resume position
G1 R4 Z2 F18000                            ; Move above last print position
G1 R4 X0 Y0 F18000                         ; Move to last print position
G1 R4 Z0                                   ; Lower to last print position

; Reset filament runout flag
set global.filamentRunoutTakeover = false

M204 T5000                 ; set the accelerations
M106 R4                    ; Restore part cooling