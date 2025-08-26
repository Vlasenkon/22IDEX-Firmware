var activetool = {state.currentTool}

var ttt = 0
if exists(param.T)
  set var.ttt = (param.T)
elif state.currentTool == 0 || state.currentTool == 2 || state.currentTool == 3
  set var.ttt = 0
elif state.currentTool == 1
  set var.ttt = 1

if var.activetool == 2
  T3

var brush_min = -87
var brush_max = -59
var y_center = (var.brush_max + var.brush_min) / 2
var x_center = -193
var u_center = 193
var xu_offset = 3
var xu_step = 1
var num_wipes = 2

M98 P"0:/sys/detachedcheck.g" ; Check if the probe is detached
M42 P4 S0

G1 F18000
G90
if move.axes[0].machinePosition > {move.axes[3].min + 5} || move.axes[3].machinePosition < {move.axes[3].max - 5}
  if state.currentTool == 3 || state.currentTool == 2
    G1 Y{var.brush_max + 50} X-999
  else
    G1 Y{var.brush_max + 50} X-999 U999

G90
G1 Y{var.y_center}                            ; Go to the center of purging bucket
M400

; Wait for Temp
if exists(param.W) && sensors.analog[{state.currentTool}].lastReading < tools[{state.currentTool}].active[0]
  M116 S10 P{state.currentTool}

; Purge fillament
M98 P"0:/user/toolchangeretraction.g" E1

if exists(param.E)
  M83                                                             ; Relative extruder moves
  G1 E{(param.E)} F{60}*{3}                                       ; extrude filament
  M400
  G4 S1

G90
G1 F12000
G1 Y{random(var.brush_max - var.brush_min + 1) + var.brush_min}     ; Go to random poit of the brush

if var.ttt = 0

  ; 1st cleaning loop (Staright Left to Right moves)
  if !exists(param.L)
    while iterations < var.num_wipes
      G91
      G1 X25
      M400
      G90
      G1 Y{var.brush_max + 5}
      G1 X-999
      G1 Y{random(var.brush_max - var.brush_min + 1) + var.brush_min} ; Go to random poit of the brush
      M400

  ; 2nd cleaning loop (Ramp Cleaning)
  if exists(param.C)
    G90
    G1 X{var.x_center - var.xu_offset * 2} Y{var.brush_min}
    M400

    while move.axes[0].machinePosition < {var.x_center + var.xu_offset} && iterations < 50
      G91
      G1 X{var.xu_step}
      G90
      G1 Y{var.brush_max}
      G1 Y{var.brush_min}
      M400

    while move.axes[0].machinePosition > {var.x_center - var.xu_offset} && iterations < 50
      G91
      G1 X{-var.xu_step}
      G90
      G1 Y{var.brush_max}
      G1 Y{var.brush_min}
      M400
  G90
  G1 X-999
  G1 Y{var.y_center}                           ; Go to the center of purging bucket

if var.ttt = 1

  ; 1st cleaning loop (Staright Left to Right moves)
  if !exists(param.L)
    while iterations < var.num_wipes
      G91
      G1 U-25
      M400
      G90
      G1 Y{var.brush_max + 5}
      G1 U999
      G1 Y{random(var.brush_max - var.brush_min + 1) + var.brush_min} ; Go to random poit of the brush
      M400
  
  ; 2nd cleaning loop (Ramp Cleaning)
  if exists(param.C)
    G90
    G1 U{var.u_center + var.xu_offset * 2} Y{var.brush_min}
    M400
  
    while move.axes[3].machinePosition > {var.u_center - var.xu_offset} && iterations < 50
      G91
      G1 U{-var.xu_step}
      G90
      G1 Y{var.brush_max}
      G1 Y{var.brush_min}
      M400
  
    while move.axes[3].machinePosition < {var.u_center + var.xu_offset} && iterations < 50
      G91
      G1 U{var.xu_step}
      G90
      G1 Y{var.brush_max}
      G1 Y{var.brush_min}
      M400
  G90
  G1 U999
  G1 Y{var.y_center}                           ; Go to the center of purging bucket

G1 Y{var.y_center}                           ; Go to the center of purging bucket

if var.activetool != state.currentTool
  T2
echo >"0:/sys/resetzbabystep.g" "; do nothing"