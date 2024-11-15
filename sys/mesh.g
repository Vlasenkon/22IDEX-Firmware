; home all if any of axis was not homed
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed || !move.axes[3].homed
  M98 P"homeall.g" L1 S1 Z1

G29 S2                                      ; disable MBC
M98 R1 P"0:/sys/attachedcheck.g"            ; make sure probe is conected, pick if negative and leave relay active
M204 T10000                                 ; set accelerations
G1 U999 F18000                              ; move U out of the way

M558 K0 P8 C"1.io4.in" H4 F300 T18000  ; define probe parameters
M98 P"0:/user/ProbeOffset.g"                ; det probe offsets
M557 X-165:155 Y-146:165 P8                 ; define mesh grid

G29 S0                                      ; run MBC
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"0:/sys/eventlog.txt" "Print cancelled due to Mesh Compensation Error"
  abort "Print cancelled due to Mesh Compensation Error"

M376 H40                                    ; enable compensation taper
M98 P"0:/sys/compensatex.g"                 ; run X - rail twist compensation
G29 S1                                      ; enable MBC
M98 P"homez.g" Z1 S1 F1                     ; fine home z to get final reference