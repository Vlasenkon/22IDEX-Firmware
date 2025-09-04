; ToolChange Retraction Enabled"

M83

if exists(param.R)
  M116 P{state.currentTool} S20
  G1 E{global.retraction_value} F3000

elif exists(param.E)
  M116 P{state.currentTool} S5
  M106 S1
  G1 E{global.extrusion_value} F{30}*{3}
  G4 S1
  M106 S0