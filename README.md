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
  - **↑_↓ RHS Down**, **↓_↑ RHS Up** – Manual Mesh Bed calibration.
  - **Toggle Compensation Mode** – Switch between Mesh Bed calibration modes.

---

### **CHANGES AS OF 10.2025**
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
  - **Z - Binding** – Removed due to no issues found during testing.
    - **Reason**: After Y-homing, the head would move past the rear wall and damage the insulation.

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