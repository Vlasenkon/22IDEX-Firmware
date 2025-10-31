; ===================================================================
; NETWORK CONNECTION TEST AND CONFIGURATION
; ===================================================================
; This script tests network connectivity and automatically configures
; the appropriate network mode (Ethernet, WiFi Client, Ethernet to PC,
; or Access Point fallback). It runs during system startup.
; ===================================================================

; Wait for any network to appear
while network.interfaces[0].actualIP == "0.0.0.0" && network.interfaces[1].actualIP == "0.0.0.0" && iterations < 15
  G4 S1                                     ; Wait 1 second per iteration (max 15 seconds)

; ===================================================================
; PRE-EXISTING CONNECTION CHECK
; ===================================================================
; Check if a network connection was already established before this
; test started (e.g., from a previous boot's saved configuration)
; ===================================================================
if network.interfaces[0].actualIP != "0.0.0.0" || network.interfaces[1].actualIP != "0.0.0.0"
  ; Determine which interface is connected and what mode
  if network.interfaces[0].actualIP != "0.0.0.0"
    echo "Ethernet Mode (Pre-existing) - IP: " ^ {network.interfaces[0].actualIP}
    echo >"0:/IP_address.txt" "Network Mode: Ethernet (Pre-existing)"
    echo >>"0:/IP_address.txt" "IP Address: "^{network.interfaces[0].actualIP}
    M99                                      ; Exit the script - network already connected
  elif network.interfaces[1].actualIP == "192.168.0.1"
    echo "WiFi Access Point Mode (Pre-existing) - IP: " ^ {network.interfaces[1].actualIP}
    echo >"0:/IP_address.txt" "Network Mode: WiFi Access Point (Pre-existing)"
    echo >>"0:/IP_address.txt" "IP Address: "^{network.interfaces[1].actualIP}
    M99                                     ; Exit the script - network already connected
  elif network.interfaces[1].actualIP != "0.0.0.0"
    echo "WiFi Client Mode (Pre-existing) - IP: " ^ {network.interfaces[1].actualIP}
    echo >"0:/IP_address.txt" "Network Mode: WiFi Client (Pre-existing)"
    echo >>"0:/IP_address.txt" "IP Address: "^{network.interfaces[1].actualIP}
    M99                                    ; Exit the script - network already connected

; ===================================================================
; INITIALIZATION - DETERMINE WHICH INTERFACE TO TEST FIRST
; ===================================================================
; Initialize variable to store the network module state
; 0 = Ethernet (interface 0), 1 = WiFi (interface 1)
; ===================================================================
var module = 0

; Detect what Network mode is selected based on active interface
if network.interfaces[0].state == "active"; || network.interfaces[0].state = "enabled" || network.interfaces[0].actualIP != "connected"
  set var.module = 0                        ; Ethernet is active - test it first
  echo "Testing Ethernet connection..."
  M552 I1 S-1                               ; Disable WiFi
  G4 S1
  M552 I0 S1                                ; Enable Ethernet
elif network.interfaces[1].state == "active"; || network.interfaces[1].state = "enabled" || network.interfaces[1].actualIP != "connected"
  set var.module = 1                        ; WiFi is active - test it first
  echo "Testing WiFi connection..."
  M552 I0 S0                                ; Disable Ethernet
  G4 S1
  M552 I1 S1                                ; Enable WiFi
else                                        ; If none are active, default to Ethernet first and disable WiFi
  set var.module = 0
  echo "Testing Ethernet connection..."
  M552 I1 S-1                               ; Disable WiFi
  G4 S1                                     ; Wait
  M552 I0 S0                                ; Disable Ethernet
  G4 S1                                     ; Wait
  M552 I0 S1                                ; Enable Ethernet


; ===================================================================
; TEST 1 - PRIMARY NETWORK MODE TEST
; ===================================================================
; Test the selected network mode (either Ethernet or WiFi based on
; what was active). Wait up to 20 seconds for connection.
; ===================================================================
; Test 1 the selected network mode initially
while network.interfaces[{var.module}].actualIP == "0.0.0.0" && iterations < 15
  G4 S1                                     ; Wait 1 second per iteration (max 15 seconds)

if network.interfaces[{var.module}].actualIP != "0.0.0.0"
  ; Determine connection mode and display result
  var connectedIP = network.interfaces[{var.module}].actualIP
  var savePrompt = false
  
  if var.module == 0
    echo "Ethernet Mode - IP: " ^ var.connectedIP
    echo >"0:/IP_address.txt" "Network Mode: Ethernet"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP
    M98 P"0:/sys/led/pause.g"               ; Yellow LED for Ethernet
    set var.savePrompt = true
  elif var.module == 1 && var.connectedIP == "192.168.0.1"
    echo "WiFi Access Point Mode - IP: " ^ var.connectedIP
    echo >"0:/IP_address.txt" "Network Mode: WiFi Access Point"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP
    M98 P"0:/sys/led/fault.g"               ; Red LED for Access Point (includes statusoff and dimmwhite)
  elif var.module == 1
    echo "WiFi Client Mode - IP: " ^ var.connectedIP
    echo >"0:/IP_address.txt" "Network Mode: WiFi Client"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP
    M98 P"0:/sys/led/end.g"                 ; Green LED for WiFi Client
    set var.savePrompt = true
  
  G4 S1
  
  ; Prompt user to save network configuration (only for Ethernet and WiFi Client, not AP)
  if var.savePrompt
    M291 S4 K{"Save network configuration","Don't save"} R{"Network Connected - IP: " ^ var.connectedIP} P"Do you want to remember this network mode after restart?"
    if input = 0
      ; User chose to save - write to networkmode.g
      if var.module == 0
        echo >"0:/user/networkmode.g" "M552 I0 S1 ; Enable Ethernet Mode"
        echo "Saved Ethernet mode to networkmode.g"
      elif var.module == 1
        echo >"0:/user/networkmode.g" "M552 I1 S1 ; Enable WiFi Client Mode"
        echo "Saved WiFi Client mode to networkmode.g"
    else
      echo "User chose not to save network configuration"
  
  M99                                       ; Exit the script successfully

; ===================================================================
; ETHERNET TO PC MODE TEST
; ===================================================================
; If Ethernet failed in Test 1, try direct PC connection mode with
; static IP 192.168.1.50. This is for direct connection to a computer.
; ===================================================================
if var.module == 0 && network.interfaces[{var.module}].actualIP == "0.0.0.0"
  ; Ethernet to PC Test - Configure static IP for direct PC connection
  echo "Testing Ethernet to PC connection..."
  M552 I0 S0                                ; Disable Ethernet
  M552 P192.168.1.50 I0 S1                  ; Set static IP address
  M553 P255.255.255.0                       ; Set subnet mask
  M554 P192.168.1.1                         ; Set gateway

  while network.interfaces[{var.module}].actualIP != "192.168.1.50" && iterations < 20
    G4 S1                                     ; Wait 1 second per iteration (max 20 seconds)

  if network.interfaces[{var.module}].actualIP == "192.168.1.50"
    var etpcIP = network.interfaces[{var.module}].actualIP
    echo "Ethernet to PC Mode - IP: " ^ var.etpcIP
    
    echo >"0:/IP_address.txt" "Network Mode: Ethernet to PC"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.etpcIP
    
    M98 P"0:/sys/led/start_cold.g"          ; Blue LED for Ethernet to PC
    G4 S1
    
    ; Prompt user to save Ethernet to PC configuration
    M291 S4 K{"Save network configuration","Don't save"} R{"Network Connected - IP: " ^ var.etpcIP} P"Do you want to remember this network mode after restart?"
    if input = 0
      ; User chose to save - write to networkmode.g
      echo >"0:/user/networkmode.g" "M552 P192.168.1.50 I0 S1"
      echo >>"0:/user/networkmode.g" "M553 P255.255.255.0"
      echo >>"0:/user/networkmode.g" "M554 P192.168.1.1"
      echo "Saved Ethernet to PC mode to networkmode.g"
    else
      echo "User chose not to save network configuration"
    
    M99                                       ; Exit the script successfully

  else
    ; Ethernet to PC failed - reset network settings to defaults
    M552 P0.0.0.0 I0 S0                     ; Reset IP
    M553 P0.0.0.0                           ; Reset subnet mask
    M554 P0.0.0.0                           ; Reset gateway
    

; ===================================================================
; REVERSE MODULE TEST - PREPARE FOR TEST 2
; ===================================================================
; If Test 1 failed, switch to the other network interface and test it
; ===================================================================
; Reverse var.module to test the other network mode
if var.module = 1
  set var.module = 0                        ; Switch from WiFi to Ethernet
  echo "Testing Ethernet connection..."
  M552 I1 S-1                               ; Disable WiFi
  G1 S1
  M552 I0 S1                                ; Enable Ethernet
if var.module = 0
  set var.module = 1                        ; Switch from Ethernet to WiFi
  echo "Testing WiFi connection..."
  M552 I0 S0                                ; Disable Ethernet
  G1 S1
  M552 I1 S1                                ; Enable WiFi


; ===================================================================
; TEST 2 - SECONDARY NETWORK MODE TEST
; ===================================================================
; Test the other network interface (the one not tested in Test 1).
; This is the fallback if the primary interface failed.
; ===================================================================
; Test 2 the other network mode
while network.interfaces[{var.module}].actualIP == "0.0.0.0" && iterations < 20
  G4 S1                                     ; Wait 1 second per iteration (max 20 seconds)

if network.interfaces[{var.module}].actualIP != "0.0.0.0"
  ; Determine connection mode and display result
  var connectedIP2 = network.interfaces[{var.module}].actualIP
  var savePrompt2 = false
  
  if var.module == 0
    echo "Ethernet Mode - IP: " ^ var.connectedIP2
    echo >"0:/IP_address.txt" "Network Mode: Ethernet"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP2
    M98 P"0:/sys/led/pause.g"               ; Yellow LED for Ethernet
    set var.savePrompt2 = true
  elif var.module == 1 && var.connectedIP2 == "192.168.0.1"
    echo "WiFi Access Point Mode - IP: " ^ var.connectedIP2
    echo >"0:/IP_address.txt" "Network Mode: WiFi Access Point"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP2
    M98 P"0:/sys/led/fault.g"               ; Red LED for Access Point (includes statusoff and dimmwhite)
  elif var.module == 1
    echo "WiFi Client Mode - IP: " ^ var.connectedIP2
    echo >"0:/IP_address.txt" "Network Mode: WiFi Client"
    echo >>"0:/IP_address.txt" "IP Address: " ^ var.connectedIP2
    M98 P"0:/sys/led/end.g"                 ; Green LED for WiFi Client
    set var.savePrompt2 = true
  
  G4 S1
  
  ; Prompt user to save network configuration (only for Ethernet and WiFi Client, not AP)
  if var.savePrompt2
    M291 S4 K{"Save network configuration","Don't save"} R{"Network Connected - IP: " ^ var.connectedIP2} P"Do you want to remember this network mode after restart?"
    if input = 0
      ; User chose to save - write to networkmode.g
      if var.module == 0
        echo >"0:/user/networkmode.g" "M552 I0 S1 ; Enable Ethernet Mode"
        echo "Saved Ethernet mode to networkmode.g"
      elif var.module == 1
        echo >"0:/user/networkmode.g" "M552 I1 S1 ; Enable WiFi Client Mode"
        echo "Saved WiFi Client mode to networkmode.g"
    else
      echo "User chose not to save network configuration"
  
  M99                                       ; Exit the script successfully

; ===================================================================
; FALLBACK - ACCESS POINT MODE
; ===================================================================
; If all connection attempts failed, create a WiFi Access Point so
; the user can connect directly to the printer to configure network.
; SSID: Uses global.APname, Password: "1234567890", IP: 192.168.0.1
; ===================================================================
; If no connection was successful, configure AP mode
echo "Starting WiFi Access Point mode..."
M98 P"0:/sys/led/fault.g"                   ; Red LED for fallback mode (includes statusoff and dimmwhite)

M552 I0 S0                                  ; Disable Ethernet
G4 S1                                       ; Wait

M552 I1 S-1                                 ; Turn off WiFi completely
G4 S1                                       ; Wait

M552 I1 S0                                  ; Set WiFi to Idle state
G4 S5                                       ; Wait for WiFi to stabilize


M589 S{global.APname} P"1234567890" I192.168.0.1  ; Configure WiFi Access Point
if result != 0
  ; Retry AP configuration up to 5 times if it fails
  while iterations < 5
    M589 S{global.APname} P"1234567890" I192.168.0.1
    if result == 0
      break                                 ; Success - exit retry loop
    G4 S3                                   ; Wait 3 seconds before retry
G4 S5                                       ; Wait for configuration to settle


M552 I1 S-1                                 ; Turn off WiFi again
G4 S1                                       ; Wait


M552 I1 S2                                  ; Turn on WiFi in Access Point mode
G4 S5                                       ; Wait for AP to start

; ===================================================================
; VERIFY ACCESS POINT MODE SUCCESS
; ===================================================================
; Check if Access Point mode successfully established an IP address.
; If it fails after 15 attempts, turn off LEDs completely.
; ===================================================================
; Verify Access Point mode is established
while network.interfaces[1].actualIP == "0.0.0.0" && iterations < 15
  G4 S1                                     ; Wait 1 second per iteration (max 15 seconds)

if network.interfaces[1].actualIP != "0.0.0.0"
  ; Access Point successfully established
  echo "WiFi Access Point Mode (Fallback) - IP: " ^ {network.interfaces[1].actualIP} ^ " | SSID: " ^ {global.APname} ^ " | Password: 1234567890"

  echo >"0:/IP_address.txt" "Network Mode: WiFi Access Point (Fallback)"
  echo >>"0:/IP_address.txt" "IP Address: "^{network.interfaces[1].actualIP}

  ; Non-Blocking notification informing user of AP mode
  M291 S1 R"Connection was not established" P"WiFi module was automatically switched to Access Point Mode" T0
else
  ; ===================================================================
  ; CRITICAL FAILURE - ALL NETWORK MODES FAILED
  ; ===================================================================
  ; Access Point mode failed - turn off LEDs completely to indicate critical failure
  M98 P"0:/sys/led/statusoff.g"             ; Turn off all LEDs
  M98 P"0:/sys/led/dimmwhite.g"             ; Set LEDs to dim white
  echo "CRITICAL: Access Point mode failed to establish connection"
  echo >"0:/IP_address.txt" "Network Mode: FAILED - No connection established"
  ; Non-Blocking error notification
  M291 S1 R"Network Connection Failed" P"Access Point mode could not be established. Please check network configuration." T0