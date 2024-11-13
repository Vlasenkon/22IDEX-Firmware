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

; Check if resuming after filament runout
if global.filamentRunoutTakeover == true && exists(param.D) && param.D == "filament-error"
  ; Prepare new tool after filament runout
  M400                                       ; Ensure all previous moves are completed
  
  T-1
  T R4                                       ; Select the tool active before pause
  M400
  
  M116 H0 S5
  M116 H1 S5
  M116 H2 S5                                 ; Wait for heaters to reach temperature
  
  M83                                        ; Relative extruder moves
  G1 E50 F{60}*{3}                           ; Extrude filament to purge
  M400
  
  M98 P"0:/sys/nozzlewipe.g" E50 W1 C5
  
  M106 R4                                    ; Restore part cooling
  
  ; Adjust axis minima if needed
  M208 Z-1 S1                                ; Set axis minima for Z-offset
  
  ; Move to resume position
  G1 R4 Z2 F18000                            ; Move above last print position
  G1 R4 X0 Y0 F18000                         ; Move to last print position
  G1 R4 Z0                                   ; Lower to last print position
  
  ; Reset filament runout flag
  set global.filamentRunoutTakeover = false

else
  ; Normal resume actions
  T-1
  T R4                                                 ; Select the tool active before pause
  M400

  M116 H0 S5
  M116 H1 S5
  M116 H2 S5                                           ; Wait for heaters to reach temperature

  M83                                                  ; Relative extruder moves
  M400
  G1 E50 F{60}*{3}                                     ; Extrude filament to purge
  M400

  T-1
  T R4                                                 ; Re-select the active tool

  M98 P"0:/sys/nozzlewipe.g" E50 W1 C5

  M106 R4  ; Recover part cooling

  M208 Z-1 S1         ; set axis minima to allow for wider range of Z - Offset


  G1 R4 X0 Y0 F18000    ; go back to the last print move
  G1 R4 Z0              ; go back to the last print move

  M98 P"0:/sys/entoolchangeretraction.g" ; Enable ToolChange Retraction

  M98 P"0:/sys/led/resume.g"

M204 T5000                 ; set the accelerations