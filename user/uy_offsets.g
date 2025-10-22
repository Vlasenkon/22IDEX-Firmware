if param.Q == 0
  echo >"0:/user/uoffset.g" "if exists(global.uoffset)"
  echo >>"0:/user/uoffset.g" "  set global.uoffset = 0"
  echo >>"0:/user/uoffset.g" "else"
  echo >>"0:/user/uoffset.g" "  global uoffset = 0"
  echo >"0:/user/yoffset.g" "if exists(global.yoffset)"
  echo >>"0:/user/yoffset.g" "  set global.yoffset = 0"
  echo >>"0:/user/yoffset.g" "else"
  echo >>"0:/user/yoffset.g" "  global yoffset = 0"
  echo >"0:/user/tooloffset.g" "                         ; Set tool offsets"
  echo >>"0:/user/tooloffset.g" "G10 P1 U0 Y0 Z0"
  set global.uoffset = 0
  set global.yoffset = 0
  G10 P1 U{global.uoffset} Y{global.yoffset} Z{global.rtzoffset}
elif param.Q == 1
  echo >"0:/user/uoffset.g" "if exists(global.uoffset)"
  echo >>"0:/user/uoffset.g" "  set global.uoffset = 0"
  echo >>"0:/user/uoffset.g" "else"
  echo >>"0:/user/uoffset.g" "  global uoffset = 0"
  echo >"0:/user/yoffset.g" "if exists(global.yoffset)"
  echo >>"0:/user/yoffset.g" "  set global.yoffset = 0"
  echo >>"0:/user/yoffset.g" "else"
  echo >>"0:/user/yoffset.g" "  global yoffset = 0"
  echo >"0:/user/tooloffset.g" "                         ; Set tool offsets"
  echo >>"0:/user/tooloffset.g" "G10 P1 U0 Y0 Z0"
  set global.uoffset = 0
  set global.yoffset = 0
  G10 P1 U{global.uoffset} Y{global.yoffset} Z{global.rtzoffset}
