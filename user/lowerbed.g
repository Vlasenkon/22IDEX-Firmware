if move.axes[2].machinePosition > 420
  M99
G90  ; absolute positioning
G1 Z420 F5000 ; Move bed to the bottom of print volume
