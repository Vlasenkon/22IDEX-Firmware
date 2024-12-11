; Home Y
M98 P"homey.g" L1

if exists(param.L) && exists(param.S)
  M98 P"bed.g" L1 S1 Z1
elif exists(param.L)
  M98 P"bed.g" L1 Z1
elif exists(param.S)
  M98 P"bed.g" S1 Z1
else
  M98 P"bed.g" Z1
if result !=0
  M98 P"0:/sys/led/fault.g"
  echo >>"Cancelled due to True Bed Leveling Error"
  abort "Cancelled due to True Bed Leveling Error"

if !exists(param.S)
  G1 X-999 U999 F18000 Y150 Z100 F18000

M204 T5000