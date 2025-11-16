if exists(global.stepscal)
  set global.stepscal = false
else
  global stepscal = false

; Steps/mm configuration
; Default values - will be overwritten by Auto Calibration if enabled
M92 X80 Y80 U80 Z400 E400:400  ; default steps/mm (calibration disabled)
