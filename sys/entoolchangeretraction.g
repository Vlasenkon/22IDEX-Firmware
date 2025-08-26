echo >"0:/user/toolchangeretraction.g" "; ToolChange Retraction Enabled"
echo >>"0:/user/toolchangeretraction.g" "M83"

echo >>"0:/user/toolchangeretraction.g" "if exists(param.R)"
echo >>"0:/user/toolchangeretraction.g" "  M116 P{state.currentTool} S20"
echo >>"0:/user/toolchangeretraction.g" "  G1 E-2 F3000"

echo >>"0:/user/toolchangeretraction.g" "elif exists(param.E)"
echo >>"0:/user/toolchangeretraction.g" "  M116 P{state.currentTool} S5"
echo >>"0:/user/toolchangeretraction.g" "  M106 S1"
echo >>"0:/user/toolchangeretraction.g" "  G1 E20 F{30}*{3}"
echo >>"0:/user/toolchangeretraction.g" "  G4 S1"
echo >>"0:/user/toolchangeretraction.g" "  M106 S0"