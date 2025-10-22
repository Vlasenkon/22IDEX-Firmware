; ToolChange Retraction Enabled"

M83

if exists(param.R)
  if state.currentTool != 1
    M98 P"0:/user/tool0retract"
  if state.currentTool == 1
    M98 P"0:/user/tool1retract"

elif exists(param.E)
  M116 P{state.currentTool} S5
  M106 S1
  if state.currentTool != 1
    M98 P"0:/user/tool0extrude"
  if state.currentTool == 1
    M98 P"0:/user/tool1extrude"
  G4 S1
  M106 S0