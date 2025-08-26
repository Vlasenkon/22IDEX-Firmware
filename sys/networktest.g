echo "_"
echo "_"
echo "Started WiFi Test"
echo "_"
echo "_"

; Wait for any network to apear
while network.interfaces[0].actualIP = "0.0.0.0" && network.interfaces[1].actualIP = "0.0.0.0" && iterations < 15
  G4 S1                                     ; Wait
  echo "L0: "^{iterations}

; Check if network connection was established before the test started
if network.interfaces[0].actualIP != "0.0.0.0" || network.interfaces[1].actualIP != "0.0.0.0"
  echo >"0:/IP_address.txt" "Network Connection was established before the test started. IP: "^{network.interfaces[0].actualIP != "0.0.0.0" ? network.interfaces[0].actualIP : network.interfaces[1].actualIP}
  abort "Network Connection was established before the test started"

; Initialize variable to store the network module state
var module = 0

; Detect what Network mode is selected
if network.interfaces[0].state = "active"; || network.interfaces[0].state = "enabled" || network.interfaces[0].actualIP != "connected"
  set var.module = 0
  echo "Detected Module 0"
  M552 I1 S-1
  G1 S1
  M552 I0 P0.0.0.0 S1
elif network.interfaces[1].state = "active"; || network.interfaces[1].state = "enabled" || network.interfaces[1].actualIP != "connected"
  set var.module = 1
  echo "Detected Module 1"
  M552 I0 S0
  G1 S1
  M552 I1 S1
else                                        ; If none are active, default to Ethernet first and disable WiFi
  set var.module = 0
  echo "Module was not detected and switched to 0"
  M98 P"0:/sys/led/pause.g"                 ; Turn on yellow LEDs to indicate mode switch
  M552 I1 S-1                               ; Disable WiFi
  G4 S1                                     ; Wait
  M552 I0 S0                                ; Disable Ethernet
  G4 S1                                     ; Wait
  M552 I0 P0.0.0.0 S1                       ; Set WiFi to Idle



; Test 1 the selected network mode initially
echo "Test 1 with Module = "^{var.module}
while network.interfaces[{var.module}].actualIP = "0.0.0.0" && iterations < 20
  G4 S1                                     ; Wait
  echo "T1: "^{iterations}

echo "IF 1 with Mode = "^{var.module}
if network.interfaces[{var.module}].actualIP != "0.0.0.0"
  echo >"0:/IP_address.txt" "Last Connected IP is: "^{network.interfaces[{var.module}].actualIP}
  M99                                       ; Exit the script
  abort "IF 1 Passed with Module: "^{var.module}                                     ; Abort if the network connection is successful

; Reverse var.module to test the other network mode
if var.module = 1
  set var.module = 0
  M552 I1 S-1
  G1 S1
  M552 I0 P0.0.0.0 S1
if var.module = 0
  set var.module = 1
  M552 I0 S0
  G1 S1
  M552 I1 S1

echo "Module was reversed to "^{var.module}


; Test 2 the other network mode
echo "Test 2 with var.module = "^{var.module}
while network.interfaces[{var.module}].actualIP = "0.0.0.0" && iterations < 20
  G4 S1                                     ; Wait
  echo "T2: "^{iterations}

echo "IF 2 with var.module = "^{var.module}
if network.interfaces[{var.module}].actualIP != "0.0.0.0"
  M98 P"0:/sys/led/pause.g"                 ; Turn on yellow LEDs to indicate mode switch
  echo >"0:/IP_address.txt" "Last Connected IP is: "^{network.interfaces[{var.module}].actualIP}
  M291 S1 T600 R"Network Mode was automaticaly switched" P" "
  M99                                       ; Exit the script
  abort "IF 2 Passed with Module: "^{var.module}                                     ; Abort if the network connection is successful

; If no connection was successful, set LED status and configure AP mode
M98 P"0:/sys/led/statusoff.g"               ; Turn off status LEDs
M98 P"0:/sys/led/dimmwhite.g"               ; Set LEDs to dim white
M98 P"0:/sys/led/red.g"                     ; Turn on red LEDs

M552 I0 S0                                  ; Disable Ethernet
if result != 0
  echo "M552: Ethernet disable failed"
else
  echo "M552: Ethernet Disabled"
G4 S1                                       ; Wait

M552 I1 S-1                                 ; Turn off WiFi
if result != 0
  echo "M552: WiFi disable failed"
else
  echo "M552: WiFi Disabled"
G4 S1                                       ; Wait

M552 I1 S0                                  ; Set WiFi to Idle
if result != 0
  echo "M552: WiFi Idle failed"
else
  echo "M552: WiFi Idle"
G4 S5                                       ; Wait


M98 P"0:/user/APname.g"
M589 S{global.APname} P"1234567890" I192.168.0.1  ; Configure WiFi Access Point
if result == 0
  echo "M589: AP Mode was configured, first try"
else
  while iterations < 5
    M589 S{global.APname} P"1234567890" I192.168.0.1  ; Configure WiFi Access Point
    if result = 0
      echo "M589: AP Mode was configured, try: "^{iterations}
      break
    G4 S3                                       ; Wait
G4 S5                                       ; Wait


M552 I1 S-1                                 ; Turn off WiFi
if result != 0
  echo "M552: WiFi disable failed"
else
  echo "M552: WiFi Disabled"
G4 S1                                       ; Wait


M552 I1 S2                                  ; Turn on WiFi in Access Point mode
if result != 0
  echo "M552: WiFi AP Mode failed to start"
else
  echo "M552: WiFi AP Mode started"
G4 S5                                       ; Wait
if network.interfaces[1].actualIP != "0.0.0.0"
  echo >"0:/IP_address.txt" "WiFi was switched to AP Mode. IP: "^{network.interfaces[1].actualIP}

M291 S2 R"Connection was not established" P"WiFi module was automatically switched to Access Point Mode"
; Display message indicating that WiFi has been switched to Access Point mode due to failed connection attempts