M291 R"Fault Detection" P"Select an option:" S3 K{"Enable","Disable"}

if input = 1
  M291 R"Warning!" P"Disabling Fault Detection is NOT RECOMMENDED and may cause fire, please do it ON YOUR OWN RISK and do not leave the printer unattended" S3
  echo >"0:/user/faultdetection.g" "M570 H3 P999999 T999999 ; Disable Chamber Heater fault detection"
  M570 H3 P999999 T999999
  echo "Fault Detection Disabled"
else
  echo >"0:/user/faultdetection.g" "M570 H3 P999 T70 S0 ; Enable Chamber Heater fault detection"
  M570 H3 P999 T70 S0
  echo "Fault Detection Enabled"