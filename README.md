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

- **Path:** `0:/macros/System/Settings/Printing/`  
  - **Wiping during the print** – Enables or disables nozzle cleaning during printing for specific materials. Enabled by default.  
  - **XY Squaring** – Enables or disables XY Squaring. Enabled by default.  
- **Path:** `0:/macros/System/Settings/Network/`  
  - **Adjustment Ethernet to PC Mode** – Adjusts Ethernet to PC mode. Bug fixed.  
  - **AP Mode Network Name Settings** – Changes the network name in Access Point Mode.  
- **Path** `0:/macros/System/Calibration/Temperature Tuning`  
  - **Bed Temp Sensor Tuning** – Bed temperature sensor calibration.  
  - **Chamber Temp Tuning** – Chamber temperature sensor calibration.  
- **Path** `0:/macros/System/Calibration/QC/Tests/`  
  - **Endstops Test x10** – Endstop check using ten repeated trigger presses.  
  - **Hepo Fan Test** – Filter test.  
  - **Chamber Heating Test**  – Chamber heating test.  
  - **Bed & Chamber Heaters Test**  – Chamber / Bed heaters and fans test.  
  - **Z-Homing Test** – Z-Homing test.  
- **Path** `0:/macros/System/Calibration/Z Probe/`  
  - **Disable Probe** – Disabled Probe.  
  - **Enable Probe** – Enabled Probe.  
- **Path** `0:/macros/System/Settings/Chamber/`  
  - **Hepa Fan Adjustment**  – Filter speed setting.  
- **Path** `0:/macros/System/Settings/Faults/`  
  - **Action After Heater Fault**  – Automatic shutdown after heater fault setting.  
  - **Bed Fault Detection**  – Enables and disables heater fault for the bed.  
- **Path** `0:/macros/System/Troubleshooting/Tests/`  
  - **Endstops Test**  – Calls the Endstops Test x10 macro.  
  - **Chamber Heating Test**  – Calls the Chamber Heating Test macro.  
  - **Z-Homing Test**  – Calls the Z-Homing Test macro.  
  - **24V Power Supply Test**  – Calls the Voltage macro.  
  - **Lubrication of Z-Rails**  – Calls the TBL & Lube macro.  
  - **Probe Test**  – Calls the Probe macro.  
  - **Nozzle Tightening & Purge Test**  – Calls the Nozzle & Purge macro.  
  - **Motor Direction Test**  – Calls the Motor Direction macro.  
  - **LED Test**  – Calls the LED macro.  
  - **Y-Endstops Deviation Test**  – Calls the HomeY macro.  
  - **Tool Fans & Heaters Test**  – Calls the Fans & Heaters macro.  
  - **Bad & Chamber Heaters Test**  – Calls the Bed & Chamber Heaters Test macro..  
- **Path** `0:/macros/System/Troubleshooting/Z-Probe/`  
  - **Z-Probe Test**  – Calls the Probe macro.  
  - **Z-Probe Calibration**  – Calls the Probe Calibration macro.  
  - **Z-Homing Test** – Calls the Z-Homing Test macro.  
  - **Rotate holder to a set degree**  – Calls the Rotate holder to a set degree macro.  
  - **Rotate holder to 0 degree**  – Calls the Rotate holder to 0 degree macro.  
  - **Place the Probe**  – Calls the Place the Probe macro.  
  - **Pick the Probe**  – Calls the Pick the Probe macro.  
  - **Adjust pickup angle CW**  – Calls the Adjust pickup angle CW macro.  
  - **Adjust pickup angle CCW**  – Calls the Adjust pickup angle CCW macro.  
- **Path** `0:/macros/System/Troubleshooting/Mesh Bed Calibration/`  
  - **Toggle Compensation Mode**  – Calls the Toggle Compensation Mode macro.  
  - **Reset**  – Calls the Reset macro.  
  - **↓\_↑ RHS Up**  – Calls the ↓\_↑ RHS Up macro.  
  - **↑\_↓ RHS Down**  – Calls the ↑\_↓ RHS Down macro.  
- **Path** `0:/macros/System/Troubleshooting/Temperature Tuning/`  
  - **Right Head PID Tuning**  – Calls the Right Head PID Tuning macro.  
  - **Left Head PID Tuning**  – Calls the Left Head PID Tuning macro.  
  - **Chamber Temp Tuning**  – Calls the Chamber Temp Tuning macro.  
  - **Bed Temp Sensor Tuning**  – Calls the Bed Temp Sensor Tuning macro.  
  - **Bed Heater PID Tuning**  – Calls the Bed Heater PID Tuning macro.  
- **Path** `0:/macros/System`  
  - **Change Filament**  – Macro for changing filament with Cold Pull and intermediate filament.  
  - **Reset Selected Filament**  – Macro for resetting selected filament.  
- **Path** `0:/user/`  
  - **periodic\_wiping** – Global variable for toggling nozzle cleaning during printing mode.  
  - **ip\_ethernettopc** – Saves the IP address for Ethernet to PC mode.  
  - **hepafan** – Global variable for setting the filter speed.  
  - **heaterfault\_timer** – Global variable for toggling and setting the automatic shutdown after heater fault.  
  - **bedfaultdetection** – Configure bed heater fault detection.  
  - **APname** – Global variable for setting network name in Access Point Mode.  
  - **BedTempCalibration** – Adjusts bed temperature.  
  - **ChamberTempCalibration** – Adjusts chamber temperature.  
  - **extrusion\_value** – Global variable for setting extrusion in nozzle\_wipe macro.  
  - **retraction\_value** – Global variable for setting retraction in nozzle\_wipe macro.  
  - **xy\_squar\_offset** – Global variable for setting XY Squaring.  
  - **XY Auto Squaring** – New Calibration macro.  
- **Path** `0:/gcodes/Slicer/Tests/`  
  - **Temp Tower Test\_1h5m** – New test.  
  - **Pressure Advanced Tuning Test\_13m** – New test.  
  - **Retraction Test\_6m** – New test.  
  - **Flow Rate Tuning Test\_3h3m** – New test.  
- **Path** `0:/sys/`  
  - **filament\_change.g**  – Filament change.  
  - **heater-fault.g** – Auto shutdown after heater fault.  
  - **xy\_squaring.g** – Y axis adjustment.  
  - **xy\_squar\_dir.g** – Writed direction of XY squaring.  
  - **autocali\_res.g** – Auto Calibration results.

#### **Updated Macros**

- **Path** `0:/macros/System/Calibration/QC`  
  - Folder renamed to QC.  
  - **Test 1** – Changed the test sequence. Added Bed & Chamber Heaters Test macro.  
  - **Test 2** – Moved some tests into the Test 1 macro.  
- **Path** `0:/macros/System/Calibration/QC/Tests/`  
  - **LED** – Added a prompt before the test.  
  - **Voltage** – Increased the number of iterations.  
  - **Z-Binding** – Fixed the bugs. Improved communication with the user.  
  - **TBL & Lube** – Improved macro. Improved communication with the user.  
  - **TBL** – Improved communication with the user.  
  - **Fans & Heaters** – Improved communication with the user. Deleted Bed & Chamber heaters test.  
  - **Motor Direction** – Improved communication with the user.  
- **Path** `0:/macros/`  
  - **Auto Calibration** – Added an extra parameter A1 when calling the macros to prevent them from being run separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Added XY Auto Squaring macro. At the end displayed a pop-up with results. Added heater fault check at start.  
- **Path** `0:/macros/System`  
  - **Cold Pull** – Added LED indication. Added M702 P0 command. Added parameter for calling macro without pop-ups.  
  - **Allow movement without homing** – Renamed to Movement Without Homing. Made this macro toggle.  
- **Path** `0:/macros/System/Settings/Chamber/`  
  - **Wait for Chamber Temp** – Added a 5-minute wait after heating.  
  - **Fault Detection** – Renamed to Chamber Fault Detection and moved to 0:/macros/System/Settings/Faults/.  
- **Path:** `0:/macros/System/Settings/Network/`  
  - **Connect to new WiFi network** – Added custom network name.  
  - **Enable Ethernet Mode** – Changed M552 I0 S1 to M552 I0 P0.0.0.0 S1.  
  - **Enable WiFi \- Access Point Mode** – Added custom network name.  
- **Path:** `0:/macros/System/Settings/Filament Runout/`  
  - **Sensor 0 Mode** – Renamed to Filament Sensor 0 ON, OFF. Added pop-up with result.  
  - **Sensor 1 Mode** – Renamed to Filament Sensor 1 ON, OFF. Added pop-up with result.  
- **Path:** `0:/macros/System/Settings/Job End/`  
  - **Power** – Recovered macro.  
- **Path** `0:/user/`  
  - **chamberwait** – Now enabled by default.  
  - **faultdetection** – Renamed to chamberfaultdetection.  
  - **toolchangeretraction** – Moved to 0:/sys/  
  - **Mesh Bed calibration** – Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Moved to user folder.  
  - **XY \- Offset Calibration** – Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Writed results of calibration to autocali\_res file. Moved to user folder.  
  - **Z \- Offset Calibration** – Added nozzle height check and adjustment. Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Added yellow indication when settings are required. Writed results of calibration to autocali\_res file. Moved to user folder.  
  - **Tool Height Auto Calibration** – Updated macro logic: the toolheads are now aligned at the center of their respective halves of the bed, and the height difference measured at the center is saved to a global variable. Added nozzle height check and adjustment. Disabled the ability to run the macro separately from the Auto Calibration Macro. Disabled heating during nozzle cleaning. Added yellow indication when settings are required. Writed results of calibration to autocali\_res file. Moved to user folder.  
  - **Reset RTZ Offset** – Moved to user folder.  
- **Path** `0:/sys/`  
  - **config** – Switching to Ethernet to PC mode is now automatic. Added filter configuration. New global variables are declared: periodic\_wiping, hepafan, retruction\_value. Bed heater fault detection is now configured via the bedfaultdetection.g macro. Made Hepafan thermodependent.  
  - **initial** – Added filter activation. Made Hepafan not thermodependent. Removed the entoolchangeretruction.g macro call. Added XY Squaring macro call. The printer will wait for heating tools before nozzlewipe.  
  - **end** – Added filter deactivation. Added filter fault message. Made Hepafan thermodependent. Removed the toolchangeretruction.g macro call. Bug fixed. Added tools cleaning.  
  - **pause** – Added filter speed reduction. Removed the toolchangeretruction.g macro call.  
  - **stop**  – Removed the toolchangeretruction.g macro call.  
  - **resume** – Added filter activation. Added a check for whether the temperature is set; if not, the user is prompted to enter it. Removed the entoolchangeretruction.g macro call.  
  - **cancel** – Added filter deactivation. Added an option to reset the temperature. Made Hepafan thermodependent. Added M84 XYU command.  
  - **baseload** – Fixed the bug. The temperature is no longer reset when the printer is paused.  
  - **filament-error** – Added filament change.  
  - **networktest** – Changed M552 I0 S1 to M552 I0 P0.0.0.0 S1. Added custom network name. Added test Ethernet to PC.  
  - **nozzlewipe** – Fixed the bug. toolchangeretruction.g is now only called when printing. Added temperature check before extrusion.  
  - **tfree0** – toolchangeretruction.g is now only called when printing.  
  - **tfree1** – toolchangeretruction.g is now only called when printing.  
  - **baseunload** –The temperature is no longer reset when the printer is paused.  
- **Path** `0:/gcodes/Slicer/Tests/`  
  - **Mesh Bed Test** – Added manual configuration for temperatures, nozzle selection, etc.  
  - **Mirror Mode Test** – Added manual configuration for temperatures, nozzle selection, etc.  
  - **XY \- Alignment Test** – Added manual configuration for temperatures, nozzle selection, etc.

#### **Removed Macros**

- **Path** `0:/macros/System/Calibration/QC/Tests/`  
  - **Endstop**  – Removed, as a new one has been written: Endstops Test x10.  
  - **Chamber Heater \+ Fan** – Removed, as a new one has been written: Fans & Heaters.  
- **Path** `0:/sys`  
  - **entoolchangeretraction** – Removed as unnecessary.

#### **Slicer Updates**

- **Path** `Printers/Custom G-code/Stard G-code`  
  - If the nozzles have different filaments, the bed temperature is set for the most refractory.  
  - If the nozzles have different filaments, the chamber temperature is set for the most refractory.  
  - Variables are created to regulate Pressure Advance for different nozzle diameters.  
  - A variable is created to detect errors with a filter.  
  - If there are toolchanges in the print, a variable is created to count them.  
  - If the plastic ULTEM 1010 or ULTEM 9085 is selected, a variable is created with the volume of plastic through which the nozzles will be cleaned.  
- **Path** `Printers/Custom G-code/End G-code`  
  - A parameter with filter errors has been added to the end.g macro call.  
- **Path** `Printers/Custom G-code/After layer change G-code`  
  - Added nozzle cleaning for ULTEM 1010 and ULTEM 9085 plastics.  
  - Added filter health check  
- **Path** `Printers/Custom G-code/Tool change G-code`  
  - Added resetting of the head temperature if it is no longer used in printing.  
- **Path** `Filaments/Custom G-code/Start G-code`  
  - Pressure Advance is set for a specific filament depending on the nozzle diameter.  
  - Sets the extrusion and retract values ​​for a specific filament

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

**Last updated:** 03.10.2025