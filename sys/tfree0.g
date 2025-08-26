G90

M98 P"0:/user/toolchangeretraction.g" R1

G60 S3
M106 S0

; Move Z to 10mm if lower than that for safety
if move.axes[2].machinePosition < 10 && state.status != "processing"  && state.status != "pausing" && state.status != "resuming"
	G90
	G1 F18000 Z10

G90
G1 X-999 U999 F18000