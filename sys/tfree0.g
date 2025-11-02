G90
; Skip retraction if printer is starting up
if !exists(global.printerStatus) || global.printerStatus != "prt_starting"
  if state.status == "processing" || state.status == "printing" || state.status == "resuming"
    M83
    if exists(global.tool0RetractDistance) && global.tool0RetractDistance != null
      G1 E{global.tool0RetractDistance} F3000
    else
      G1 E-5 F3000

M106 S0

; Move Z to 10mm if lower than that for safety
if move.axes[2].machinePosition < 10 && (state.status != "processing" || state.status != "printing" || state.status != "pausing" || state.status != "resuming")
  G90
  G1 F18000 Z10

G90
G1 X-999 U999 F18000