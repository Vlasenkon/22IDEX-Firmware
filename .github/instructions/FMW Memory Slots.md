# Memory Slots & Restore Points Reference

RepRapFirmware provides **6 memory slots** (0–5) that store axis positions, tool selections, and fan speeds. Some are saved automatically by the firmware, others are saved explicitly with `G60`.

---

## Slot Overview

| Slot | Saved By | What It Stores | Restore Commands |
|------|----------|----------------|------------------|
| **0** | `G60 S0` (manual) | Position + current tool | `G1 R0 X0 Y0 Z0` (position), `T R0` (tool) |
| **1** | **Automatic on pause** | Position + tool + fan speed | `G1 R1 X0 Y0 Z0` (position), `T R1` (tool), `M106 R1` (fan) |
| **2** | **Automatic on tool change** | Position + fan speed | `G1 R2 X0 Y0 Z2` (position), `M106 R2` (fan) |
| 3–5 | `G60 S3`–`G60 S5` (manual) | Position + current tool | `G1 R3`–`G1 R5`, `T R3`–`T R5` |

### Important Notes

- **Do NOT use `G60` in `pause.g`** — slot 1 is saved automatically before `pause.g` runs. Using `G60` there can break position restore on resume (especially in RRF 3.5.1+ with dual motion systems).
- **Tool change auto-save to slot 2** happens whenever the tool number changes (including selecting or deselecting), before `tfree#.g` runs.
- Restore commands use axis parameters as **offsets** from the saved position. `G1 R1 X0 Y0 Z0` = exact saved position. `G1 R1 Z5` = 5 mm above saved Z (X/Y not moved).

---

## Slot 0 — Manual Save (General Purpose)

Used throughout the firmware to save and restore position/tool across operations that need to temporarily move the head.

### Save Sites

| File | Code | Purpose |
|------|------|---------|
| sys/nozzlewipe.g | `G60 S0` | Save position before wipe (only when `param.R` is passed) |
| sys/periodic_wipe_check.g | `G60 S0` | Save position before mid-print periodic wipe |
| sys/baseload.g | `G60 S0` | Remember current tool before filament load sequence |
| sys/baseunload.g | `G60 S0` | Remember current tool before filament unload sequence |
| sys/initial.g | `G60 S0` | Save tool selection before startup homing/heating sequence |
| sys/filament_change.g | `G60 S0` | Save tool before filament change (M600 / runout) |
| macros/System/Filament/Reset Selected Filament | `G60 S0` | Save tool before resetting filament assignment |

### Position Restore (`G1 R0`)

| File | Code | Purpose |
|------|------|---------|
| sys/nozzlewipe.g | `G1 R0 X0 Y0 F18000` then `G1 R0 Z0 F18000` | Return to pre-wipe position (when `param.R`) |
| sys/nozzlewipe.g | `G1 R0 U0 Y0 F18000` then `G1 R0 Z0 F18000` | Same, but for T1 (uses U axis instead of X) |
| sys/periodic_wipe_check.g | `G1 R0 X0 Y0 F18000` then `G1 R0 Z0 F18000` | Return to pre-wipe position during print |

### Tool Restore (`T R0`)

| File | Code | Purpose |
|------|------|---------|
| sys/baseload.g | `T R0` | Re-select original tool after load sequence |
| sys/baseunload.g | `T R0` | Re-select original tool after unload sequence |
| sys/initial.g | `T R0` (×2) | Restore tool after homing/heating phases |
| sys/filament_change.g | `T R0` (×3) | Restore tool after change or if user cancels |
| macros/System/Filament/Reset Selected Filament | `T R0 P0` | Restore tool after resetting filament (P0 = no macros) |

---

## Slot 1 — Automatic on Pause

Saved **automatically by RRF** when a print is paused (before `pause.g` runs). Stores position, active tool, and fan speed.

### What Gets Saved Automatically

- All axis positions (X, Y, Z, U, etc.)
- Current tool number
- Part cooling fan speed

### Restore Sites

| File | Code | Purpose |
|------|------|---------|
| sys/resume.g | `T R1` | Select the tool that was active when paused |
| sys/resume.g | `G1 R1 Z5 F18000` | Move to 5 mm above paused print position |
| sys/resume.g | `G1 R1 X0 Y0 F18000` | Move to paused XY position |
| sys/resume.g | `G1 R1 Z0` | Lower to exact paused Z position |
| sys/resume.g | `M106 R1` | Restore part cooling fan to speed at time of pause |

### Typical Pause/Resume Flow

```
PAUSE (automatic):
  → RRF saves position + tool + fan to slot 1
  → pause.g runs: retracts, lifts Z, moves Y forward, turns off fans/heaters

RESUME:
  → resume.g runs: re-heats, wipes nozzle
  → T R1              — reselect paused tool
  → G1 R1 Z5 F18000   — move above saved position
  → G1 R1 X0 Y0 F18000 — move to saved XY
  → G1 R1 Z0          — lower to saved Z
  → M106 R1           — restore fan speed
```

---

## Slot 2 — Automatic on Tool Change

Saved **automatically by RRF** when a tool change occurs (before `tfree#.g` runs). Stores position and fan speed. This happens whenever the new tool number differs from the old one (including T-1 deselect).

### What Gets Saved Automatically

- All axis positions
- Part cooling fan speed for the current tool (or fan 0 if no tool active)

### Restore Sites

| File | Code | Purpose |
|------|------|---------|
| sys/tpost0.g | `M106 R2` | Restore fan speed from before tool change (so slicer fan commands carry across tools) |
| sys/tpost1.g | `M106 R2` | Same for T1 |

### Why `M106 R2` Matters

On multi-extruder printers, the slicer sets fan speed before issuing a tool change. Without `M106 R2` in `tpost#.g`, the fan speed would be lost after the tool change. This ensures the fan speed set by the slicer carries over to the new tool.

---

## Slots 3–5 — Free

Not currently used in this firmware. Available for custom macros.

---

## Summary of All Save/Restore Commands

### Saving

| Command | Effect |
|---------|--------|
| `G60 S0` | Save current position + tool to slot 0 |
| `G60 S1` | Save to slot 1 (**avoid — slot 1 is auto-saved on pause**) |
| `G60 S2` | Save to slot 2 (**avoid — slot 2 is auto-saved on tool change**) |
| `G60 S3`–`G60 S5` | Save to free slots |

### Restoring Position (`G0`/`G1` with `R` parameter)

| Command | Effect |
|---------|--------|
| `G1 R0 X0 Y0 Z0` | Move to exact position saved in slot 0 |
| `G1 R1 Z5` | Move to 5 mm above Z saved in slot 1 (X/Y unchanged) |
| `G1 R1 X0 Y0` | Move to XY saved in slot 1 (Z unchanged) |
| `G1 R2 X0 Y0 Z2` | Move to 2 mm above position saved in slot 2 |

> Axes not mentioned in the command are **not moved**. The numeric values are **offsets** from the saved position (0 = exact, positive = offset above/beyond).

### Restoring Tool (`T` with `R` parameter)

| Command | Effect |
|---------|--------|
| `T R0` | Select the tool that was active when slot 0 was saved |
| `T R1` | Select the tool that was active when the print was paused |
| `T R0 P0` | Same as `T R0` but skip all tool change macros |

### Restoring Fan Speed (`M106` with `R` parameter)

| Command | Effect |
|---------|--------|
| `M106 R1` | Restore fan speed to value at time of pause |
| `M106 R2` | Restore fan speed to value before last tool change |
