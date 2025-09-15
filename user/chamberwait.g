M116 H2 C0 S5 ; Wait for Chamber Temp
if heat.heaters[3].active != 0 
  G4 S300
