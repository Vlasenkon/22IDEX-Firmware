while network.interfaces[0].actualIP = "0.0.0.0" && iterations < 30
  G4 S1

if network.interfaces[0].actualIP = "0.0.0.0"
  M98 P"0:/sys/led/statusoff.g"
  M98 P"0:/sys/led/dimmwhite.g"
  M98 P"0:/sys/led/red.g"


M552 S0                                  ; Disable Ethernet
if result != 0
  echo "Failed 1"
else
  echo "OK 1"
G4 S1                                       ; Wait

M552 S-1                                 ; Turn off WiFi
if result != 0
  echo "Failed 2"
else
  echo "OK 2"
G4 S1                                       ; Wait

M552 S0                                  ; Set WiFi to Idle
if result != 0
  echo "Failed 3"
else
  echo "OK 3"
G4 S5                                       ; Wait


M589 S"22 IDEX" P"1234567890"92.168.0.1  ; Configure WiFi Access Point
if result != 0
  echo "Failed 4"
else
  echo "OK 4"
G4 S5                                       ; Wait


M552 S-1                                 ; Turn off WiFi
if result != 0
  echo "Failed 5"
else
  echo "OK 5"
G4 S1                                       ; Wait


M552 S2                                  ; Turn on WiFi in Access Point mode
if result != 0
  echo "Failed 6"
else
  echo "OK 6"
G4 S5                                       ; Wait

  
  M291 S0 R"Connection was not established" P"WiFi module was automatically switched to Access Point Mode"