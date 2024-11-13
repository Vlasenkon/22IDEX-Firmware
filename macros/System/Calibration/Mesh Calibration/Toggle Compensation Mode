if exists(global.xcomp_mode)
  if global.xcomp_mode == "auto"
    set global.xcomp_mode = "manual"
  else
    set global.xcomp_mode = "auto"
else
  global xcomp_mode = "manual"

echo "Compensation mode set to "^{global.xcomp_mode}

; Update xcomp_mode.g to save the new mode permanently
echo >"0:/user/xcomp_mode.g" "if exists(global.xcomp_mode)"
echo >>"0:/user/xcomp_mode.g" "  set global.xcomp_mode = """^{global.xcomp_mode}"""""
echo >>"0:/user/xcomp_mode.g" "else"
echo >>"0:/user/xcomp_mode.g" "  global xcomp_mode = """^{global.xcomp_mode}"""""