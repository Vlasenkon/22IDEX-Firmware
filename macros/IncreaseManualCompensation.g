if exists(global.xcomp_manual)
  set global.xcomp_manual = {global.xcomp_manual + 0.05}
else
  global xcomp_manual = 0.05

; Update xcomp_manual.g to save the new value
echo >"0:/user/xcomp_manual.g" "if exists(global.xcomp_manual)"
echo >>"0:/user/xcomp_manual.g" "  set global.xcomp_manual = "{global.xcomp_manual}
echo >>"0:/user/xcomp_manual.g" "else"
echo >>"0:/user/xcomp_manual.g" "  global xcomp_manual = "{global.xcomp_manual}