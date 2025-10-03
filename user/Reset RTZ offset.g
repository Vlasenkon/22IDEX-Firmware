if exists(global.rtzoffset)
  set global.rtzoffset = 0
else
  global rtzoffset = 0


; Generate rtzoffset.g
echo >"0:/user/rtzoffset.g" "if exists(global.rtzoffset)"
echo >>"0:/user/rtzoffset.g" "  set global.rtzoffset = "^{0}
echo >>"0:/user/rtzoffset.g" "else"
echo >>"0:/user/rtzoffset.g" "  global rtzoffset = "^{0}

; Generate tooloffset.g
echo >"0:/user/tooloffset.g" "; Set tool offsets"
echo >>"0:/user/tooloffset.g" "G10 P1 U"^{global.uoffset}^" Y"^{global.yoffset}^" Z"^{0}

M98 P"0:/user/tooloffset.g"