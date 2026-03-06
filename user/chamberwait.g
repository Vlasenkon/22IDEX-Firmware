; Chamber wait for resume.g (initial.g handles its own chamber wait + heat soak)
M116 H2 S10                               ; Wait for bed
if heat.heaters[3].active > 0
  M116 H3 S5                              ; Wait for chamber within 5°C tolerance
