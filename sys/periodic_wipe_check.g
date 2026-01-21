; Periodic Nozzle Wiping Check
; Called automatically from slicer at every layer change
; Checks if wiping is needed based on user-configured frequency

; Exit silently if periodic wiping is disabled or not configured
if !exists(global.periodic_wiping) || global.periodic_wiping == 0
    ; Feature not enabled - exit without doing anything
    M99

; Initialize layer counter on first run
if !exists(global.periodic_wipe_layer_count)
    global periodic_wipe_layer_count = 0

; Increment layer counter
set global.periodic_wipe_layer_count = global.periodic_wipe_layer_count + 1

; Check if it's time to wipe (layer count divisible by frequency)
var should_wipe = false
if mod(global.periodic_wipe_layer_count, global.periodic_wiping) == 0
    set var.should_wipe = true

; Exit silently if not time to wipe yet
if !var.should_wipe
    ; Not time to wipe yet - exit without doing anything
    M99

; Perform wipe for the active tool
M400
G60 S0  ; Save current position

; Retract before moving
M83
G1 E-5  F18000

; Wipe the nozzle
M400
M98 P"0:/sys/nozzlewipe.g" C5 W1 E20
M400

; Restore position
G1 R0 X0 Y0 F18000
G1 R0 Z0 F18000
