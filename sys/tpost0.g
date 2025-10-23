; Lower Z to 10mm if lower than that for safety
if move.axes[2].machinePosition < 10 && (state.status != "processing" || state.status != "printing"  || state.status != "pausing" || state.status != "resuming")
	G90
	G1 F18000 Z10

; Skip purge if printer is starting up
if !exists(global.printerStatus) || global.printerStatus != "prt_starting"
  M98 P"0:/sys/nozzlewipe.g" T0 W1

M106 R3