; Take Z referrence point (home Z)
if !exists(param.Z)
  M98 P"homez.g" L1 S1 C1
else
  M98 P"homez.g" L1 S1 Z1 C1


M561 ; clear any bed transform
G29 S2 ; Clear height map

M98 R1 P"0:/sys/attachedcheck.g" ; make sure probe is conected, pick if negative and leave relay active

M204 T5000                                 ; set accelerations

; Fast Bed Leveling
M558 K0 P8 C"1.io4.in" H50 F18000 T18000
M98 P"0:/user/ProbeOffset.g"
G1 U999 F18000 ; Move U - carriage off the way
G30 P0 X0     Y50    Z-99999    ; probe near an adjusting screw
G30 P1 X36.3  Y-34.3 Z-99999    ; probe near an adjusting screw
G30 P2 X-36.3 Y-34.3 Z-99999 S3 ; probe near an adjusting screw and report adjustments needed

M204 T10000                                 ; set accelerations

M558 K0 P8 C"1.io4.in" H5 F300 T18000
M98 P"0:/user/ProbeOffset.g"
G30 P0 X-150 Y-140 Z-99999 ; probe near an adjusting screw
G30 P1 X150  Y-140 Z-99999 ; probe near an adjusting screw
G30 P2 X150  Y150  Z-99999 ; probe near an adjusting screw
G30 P3 X-150 Y150  Z-99999 S3 ; probe near an adjusting screw and make adjustments needed


if exists(param.L) && exists(param.S) && exists(param.Z)
  M98 P"homez.g" L1 S1 Z1 F1
elif exists(param.L) && exists(param.S)
  M98 P"homez.g" L1 S1 F1
elif exists(param.S) && exists(param.Z)
  M98 P"homez.g" S1 Z1 F1
elif exists(param.L) && exists(param.Z)
  M98 P"homez.g" L1 Z1 F1
elif exists(param.L)
  M98 P"homez.g" L1 F1
elif exists(param.S)
  M98 P"homez.g" S1 F1
elif exists(param.Z)
  M98 P"homez.g" Z1 F1
else
  M98 P"homez.g" F1

if !exists(param.S)
  G1 X{move.axes[0].min} U{move.axes[3].max} Y150 Z100 F18000

M204 T5000                                 ; set accelerations