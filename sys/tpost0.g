; Lower Z to 10mm if lower than that for safety
if move.axes[2].machinePosition < 10 && state.status != "processing"  && state.status != "pausing" && state.status != "resuming"
	G90
	G1 F18000 Z10

if state.status == "processing"
	M98 P"0:/sys/nozzlewipe.g" W1 C5 T0 E10
else
	M98 P"0:/sys/nozzlewipe.g" T0

M106 R3