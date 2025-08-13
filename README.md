# VISION MINER

# 3D Printer IDEX22

## General Information

This repository contains the firmware for the 3D printer IDEX22 with the following configuration:

- **Power supply voltage**: 110V  
- **Mainboard**: Duet 3 6HC 1.02a  
- **Expansion board**: Duet EB3HC V1.02a  
- **Z-axis motor**: LDO-42STH34-1004CL500E (TR8x8)  
- **XY motors**: LDO-42STH60-2004AC (PVP)  
- **Number of printheads**: 2

---

## Latest Firmware Changes

### **CHANGES AS OF 07.2024**

#### **File Updates**

- Added variables `global.xcomp_manual` and `global.xcomp_auto` for Mesh Bed calibration in:  
  - `manual` mode  
  - `auto` mode  
- Added variable `global.xcomp_mode` to select the Mesh Bed calibration mode.  
- Y-homing files now include endstop parallelism check and compensation for misalignment.

#### **Added Macros**

- **Path**: `0:/macros/System/Calibration/Mesh Calibration/`  
  - **↑\_↓ RHS Down**, **↓\_↑ RHS Up** – Manual Mesh Bed calibration.  
  - **Toggle Compensation Mode** – Switch between Mesh Bed calibration modes.

---

### **CHANGES AS OF 10.2024**

#### **Added Macros**

- **Path**: `0:/macros/System/Calibration/Testing/Tests/`  
  - **Voltage** – Check 24V power supply voltage. Acceptable range: `24.0V - 24.3V`.  
  - **Probe** – Servo operation test; automated probe board check.  
  - **HomeY** – Y endstop parallelism check. Acceptable deviation: `0.4`.  
  - **Probe Calibration** – Automated probe servo calibration.  
  - **Nozzle & Purge** – Automates nozzle tightening and bucket level check.  
  - **Lube** – Automates Z motor pulley lubrication process.  
  - **Z screws fixing** – Automates Z motor screw tightening.

#### **Updated Macros**

- **Path**: `0:/macros/System/Calibration/Testing/Tests/`  
  - **Endstop** – Switched from endstop press check to state change detection for filament sensors.  
  - **Head Left, Head Right** – Added checks for correct heater and temperature sensor connections. If no temperature change is detected during heating, the macro stops the test.

#### **Removed Macros**

- **Path**: `0:/macros/System/Calibration/Testing/Tests/`  
  - **Z \- Binding** – Removed due to no issues found during testing.  
    - **Reason**: After Y-homing, the head would move past the rear wall and damage the insulation.

---

### **CHANGES AS OF 07.08.2025**

#### **Added Macros**

- **Path:** `0:/macros/System/Settings/Nozzle Wiping/`  
  - **Wiping during the print** – Enables or disables nozzle cleaning during printing for specific materials. Enabled by default.  
- **Path:** `0:/macros/System/Settings/Network/`  
  - **Enable Ethernet to PC Mode** – Enables Ethernet to PC mode.  
- **Path** `0:/macros/System/Calibration/Testing/Tests/`  
  - **Endstops Test x10** – Endstop check using ten repeated trigger presses.  
  - **Hepo Fan Test** – Filter test.  
  - **Chamber Heating Test**  – Chamber heating test.  
- **Path** `0:/macros/System/Settings/Chamber/`  
  - **Hepa Fan Adjustment**  – Filter speed setting.  
- **Path** `0:/macros/System/Settings/Faults/`  
  - **Heater Fault**  – Automatic shutdown after heater fault setting.  
  - **Bed Fault Detection**  – Enables and disables heater fault for the bed.  
- **Path** `0:/macros/Troubleshooting/`  
  - **Chamber Heating Test**  – Calls the chamber heating test.  
- **Path** `0:/user/`  
  - **periodic\_wiping** – Global variable for toggling nozzle cleaning during printing mode.  
  - **ethernetToPCmode** – Global variable for toggling Ethernet to PC mode.  
  - **ip\_ethernettopc** – Saves the IP address for Ethernet to PC mode.  
  - **hepafan** – Global variable for setting the filter speed.  
  - **heaterfault\_timer** – Global variable for toggling and setting the automatic shutdown after heater fault.  
  - **bedfaultdetection** – Configure bed heater fault detection.  
- **Path** `0:/gcodes/Slicer/Tests/`  
  - **Temp Tower Test\_1h5m** – New test.  
  - **Pressure Advanced Tuning Test\_13m** – New test.  
  - **Retraction Test\_6m** – New test.  
  - **Flow Rate Tuning Test\_3h3m** – New test.  
- **Path** `0:/sys/`  
  - **filament\_change** – Filament change.

#### **Updated Macros**

- **Path** `0:/macros/System/Calibration/Auto Calibration Macros/`  
  - **Mesh Bed calibration** – Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning.  
  - **XY \- Offset Calibration** – Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning.  
  - **Z \- Offset Calibration** – Added nozzle height check and adjustment. Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Added yellow indication when settings are required.  
  - **Tool Height Auto Calibration** – Updated macro logic: the toolheads are now aligned at the center of their respective halves of the bed, and the height difference measured at the center is saved to a global variable. Added nozzle height check and adjustment. Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Added yellow indication when settings are required.  
- **Path** `0:/macros/System/Calibration/Testing/Tests/`  
  - **Chamber Heater \+ Fan** – Removed the chamber fan test.  
- **Path** `0:/macros/`  
  - **Auto Calibration** – Added an extra parameter A1 when calling the macros to prevent them from being run separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning.  
- **Path** `0:/macros/System/Settings/Chamber/`  
  - **Wait for Chamber Temp** – Added a 5-minute wait after heating.  
  - **Fault Detection** – Renamed to Chamber Fault Detection and moved to 0:/macros/System/Settings/Faults/.  
- **Path:** `0:/macros/System/Settings/Network/`  
  - **Connect to new WiFi network** – Disables Ethernet to PC mode.  
  - **Enable Ethernet Mode** – Disables Ethernet to PC mode.  
  - **Enable WiFi \- Access Point Mode** – Disables Ethernet to PC mode.  
  - **Enable WiFi \- Client Mode** – Disables Ethernet to PC mode.  
- **Path** `0:/user/`  
  - **chamberwait** – Now enabled by default.  
  - **faultdetection** – Renamed to chamberfaultdetection.  
- **Path** `0:/sys/`  
  - **config** – Switching to Ethernet to PC mode is now automatic. Added filter configuration. New global variables are declared: periodic\_wiping, ethernetToPCmode, hepafan. Bed heater fault detection is now configured via the bedfaultdetection.g macro.  
  - **initial** – Added filter activation.  
  - **end** – Added filter deactivation. Added filter fault message.  
  - **pause** – Added filter speed reduction.  
  - **resume** – Added filter activation. Added a check for whether the temperature is set; if not, the user is prompted to enter it.  
  - **cancel** – Added filter deactivation.  
  - **baseload** – Fixed the bug.  
  - **filament-error** – Added filament change.  
- **Path** `0:/gcodes/Slicer/Tests/`  
  - **Mesh Bed Test** – Added manual configuration for temperatures, nozzle selection, etc.  
  - **Mirror Mode Test** – Added manual configuration for temperatures, nozzle selection, etc.  
  - **XY \- Alignment Test** – Added manual configuration for temperatures, nozzle selection, etc.

#### **Removed Macros**

- **Path** `0:/macros/System/Calibration/Testing/Tests/`  
  - **Endstop**  – Removed, as a new one has been written: Endstops Test x10.

---

## Installation and Update

### Manual Firmware Update

#### Preparation:

1. Power off the printer and carefully eject the SD card.  
2. Back up the SD card contents as a precaution.  
3. Download the latest firmware version:  
   - **V3** – Received **after November 2024**  
   - **V3** – Received **before November 2024**  
4. Unzip the archive.

#### Transfer Machine-Specific Files:

- Drag and drop all folders from the extracted archive onto the SD card, **replacing all existing folders except the `user` folder**.  
- The `user` folder contains your machine's settings and calibrations – **do not overwrite** it.

#### Insert SD Card and Power On:

1. Reinsert the SD card into the control board.  
2. Power on the printer.

#### Update Mainboard Firmware:

1. Open the **Web Interface** (DWC) and go to the console.  
2. Run the command: `M997 S0:1` and press Enter.  
3. Reconnect to your printer via the Web Interface – update complete.

---

## Support and Contact

A wide range of helpful resources is available at:  
🔗 [https://wiki.visionminer.com/](https://wiki.visionminer.com/)

There you’ll find detailed guides on printer usage, configuration, materials, calibration, troubleshooting, and much more.

---

**Last updated:** 10.2025

