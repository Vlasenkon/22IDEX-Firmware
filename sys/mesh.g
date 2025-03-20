; home all if any of axis was not homed
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed
  M98 P"homeall.g" L1 S1 Z1

G29 S2                                      ; disable MBC
M98 R1 P"0:/sys/attachedcheck.g"            ; make sure probe is conected, pick if negative and leave relay active
M204 T10000                                 ; set accelerations
G1 U999 F18000                              ; move U out of the way

M558 K0 P8 C"1.io4.in" H4 F300 T18000  ; define probe parameters
M98 P"0:/user/ProbeOffset.g"                ; det probe offsets





; Check if parameters are provided and set the mesh grid accordingly
if exists(param.A) && exists(param.B) && exists(param.D) && exists(param.J)

  ; make sure the mesh grid is within the printable area
  var Xmin = param.A
  if var.Xmin < -165
    set var.Xmin = -165
  var Xmax = param.B
  if var.Xmax > 155
    set var.Xmax = 155
  var Ymin = param.D
  if var.Ymin < -146
    set var.Ymin = -146
  var Ymax = param.J
  if var.Ymax > 165
    set var.Ymax = 165
  
  ; calculate the number of points in the mesh grid
  var probx = floor((var.Xmax - var.Xmin) / 30)
  if var.probx < 3
    set var.probx = 3
  
  var proby = floor((var.Ymax - var.Ymin) / 30)
  if var.proby < 3
    set var.proby = 3
  
  M557 X{var.Xmin, var.Xmax} Y{var.Ymin, var.Ymax} P{var.probx, var.proby} ; define mesh grid
else
  ; Default mesh grid if parameters are not provided
  M557 X-165:155 Y-146:165 P8                 ; define mesh grid

; Perform mesh bed leveling
G29 S0
if move.compensation.meshDeviation.deviation > 0.25
  echo "Warning: Mesh Compensation is too high"
  echo >>"0:/sys/eventlog.txt" "Mesh Compensation is too high"
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Error: Print cancelled due to Mesh Compensation Error"
  abort "Print cancelled due to Mesh Compensation Error"

M376 H40                                    ; enable compensation taper
M98 P"0:/sys/compensatex.g"                 ; run X - rail twist compensation
M98 P"0:/sys/compensatey.g"                 ; run X - rail twist compensation
G29 S1                                      ; enable MBC
M98 P"homez.g" Z1 S1 F1 T1                    ; fine home z to get final reference