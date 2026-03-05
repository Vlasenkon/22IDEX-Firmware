# Macro Parameters (`param.*`) Reference

Parameters are passed via `M98 P"file.g" X1 Y2` and accessed inside the macro as `param.X`, `param.Y`, etc.

---

## Table of Contents

- [sys/initial.g](#sysinitialg)
- [sys/homey.g](#syshomeyg)
- [sys/homeall.g](#syshomeallg)
- [sys/homez.g](#syshomezg)
- [sys/bed.g](#sysbedg)
- [sys/mesh.g](#sysmeshg)
- [sys/nozzleprobe.g](#sysnozzleprobeg)
- [sys/nozzlewipe.g](#sysnozzlewipeg)
- [sys/baseload.g](#sysbaseloadg)
- [sys/baseunload.g](#sysbaseunloadg)
- [sys/filament_change.g](#sysfilament_changeg)
- [sys/filament-error.g](#sysfilament-errorg)
- [sys/attachedcheck.g](#sysattachedcheckg)
- [sys/end.g](#sysendg)
- [macros/Save Current Z - Offset](#macrossave-current-z---offset)
- [macros/System/Filament/Cold Pull](#macrossystemfilamentcold-pull)
- [macros/System/Calibration/Steps per mm Mode](#macrossystemcalibrationsteps-per-mm-mode)
- [macros/System/Calibration/XY Squaring/Toggle Mode](#macrossystemcalibrationxy-squaringtoggle-mode)
- [Network Macros](#network-macros)
- [AutoCal Macros](#autocal-macros)
- [Parameter Letter Summary](#parameter-letter-summary)

---

## sys/initial.g

Called from slicer start G-code. This is the main print startup sequence.

| Param | Type | Purpose |
|-------|------|---------|
| `W` | Flag | **Skip bed/chamber heating wait.** If present, skips bed temperature wait (`M116 H2`), HEPA ramp-up, chamber wait, and heat soak. |
| `A` | Float | **Adaptive mesh: X minimum** of the first layer print area. Passed through to `mesh.g`. Corresponds to PrusaSlicer `first_layer_print_min[0]`. |
| `B` | Float | **Adaptive mesh: X maximum** of the first layer print area. Passed through to `mesh.g`. Corresponds to PrusaSlicer `first_layer_print_max[0]`. |
| `D` | Float | **Adaptive mesh: Y minimum** of the first layer print area. Passed through to `mesh.g`. Corresponds to PrusaSlicer `first_layer_print_min[1]`. |
| `J` | Float | **Adaptive mesh: Y maximum** of the first layer print area. Passed through to `mesh.g`. Corresponds to PrusaSlicer `first_layer_print_max[1]`. |
| `E` | Integer (0–3) | **Tool to select at end of start sequence.** Executes `T{param.E}`. Values: `0` = T0, `1` = T1, `2` = T2 (copy mode), `3` = T3 (mirror mode). |

### Callers

| Caller | Call |
|--------|------|
| PrusaSlicer start G-code (IDEX) | `M98 P"0:/sys/initial.g" E{current_extruder} A{first_layer_print_min[0]} B{first_layer_print_max[0]} D{first_layer_print_min[1]} J{first_layer_print_max[1]}` |
| PrusaSlicer start G-code (copy mode) | `M98 P"0:/sys/initial.g" E2` |
| PrusaSlicer start G-code (mirror mode) | `M98 P"0:/sys/initial.g" E3` |
| Test print G-code files | `M98 P"0:/sys/initial.g" E0 A... B... D... J...` (with adaptive mesh bounds) |

---

## sys/homey.g

Y-axis homing with dual endstop squaring.

| Param | Type | Purpose |
|-------|------|---------|
| `N` | Flag | **Skip LED reset.** If present, skips `M98 P"0:/sys/led/resetstatus.g"`. Used during cold homing in `initial.g` to avoid unnecessary LED state changes. |
| `L` | Flag | **Skip Z lower after homing.** If present, skips the `G1 H2 Z-10 F18000` move that lowers Z back down after Y homing. |
| `T` | Flag | **Store homing test results to globals.** If present, saves `global.HomeYSide` (which side triggered first) and `global.HomeYDis` (measured offset distance) for QC testing. |

### Callers

| Caller | Call |
|--------|------|
| sys/homeall.g (with `param.N`) | `M98 P"0:/sys/homey.g" L1 N1` |
| sys/homeall.g (normal) | `M98 P"0:/sys/homey.g" L1` |
| QC/Tests/HomeY (no params) | `M98 P"0:/sys/homey.g"` |
| QC/Tests/HomeY (test capture) | `M98 P"0:/sys/homey.g" T1` |

---

## sys/homeall.g

Home all axes (Y → X/U → Z).

| Param | Type | Purpose |
|-------|------|---------|
| `N` | Flag | **Skip LED reset.** Passed through to `homey.g` as `N1`. |
| `L` | Flag | **Skip final XY park & Z lower.** Passes `L1` to `bed.g` and `homey.g`. Skips final parking move (`G1 X-999 U999 Y150 Z100`). |
| `S` | Flag | **Skip final park move.** Passes `S1` to `bed.g`. Skips final parking move. |

### Callers

| Caller | Call |
|--------|------|
| sys/initial.g (cold home) | `M98 P"homeall.g" S1 L1 N1` |
| sys/initial.g (hot re-home) | `M98 P"homeall.g" Z1 S1 L1` |
| sys/mesh.g | `M98 P"homeall.g" L1 S1 Z1` |
| sys/homez.g | `M98 P"homeall.g" S1 L1 Z1` |
| sys/nozzleprobe.g | `M98 P"0:/sys/homeall.g" S1` |
| macros/Auto Calibration | `M98 P"0:/sys/homeall.g" S1` and `M98 P"0:/sys/homeall.g" S1 L1` |
| macros/Auto Cooldown & Sleep | `M98 P"homeall.g"` (no params) |
| macros/System/Filament/Cold Pull | `M98 P"0:/sys/homeall.g" S1` |

---

## sys/homez.g

Z-axis homing with BLTouch/Z probe.

| Param | Type | Purpose |
|-------|------|---------|
| `Z` | Flag | **Skip initial Z lift.** If present, skips the `G1 H2 Z25 F18000` relative Z lift before probing. |
| `T` | Flag | **Skip probe test.** If present, skips `M98 P"0:/sys/probetest.g"` (probe wire short-circuit check). |
| `F` | Flag | **Skip fast probe.** If present, skips the initial fast Z probe pass at F18000. |
| `C` | Flag | **Skip slow (careful) probe.** If present, skips the slow averaging probe pass at F300. |
| `S` | Flag | **Skip final Z lift.** If present, skips the `G1 H2 Z100 F18000` lift after probing. |
| `L` | Flag | **Skip probe placement (place back).** If present, skips `M98 P"place.g"` after homing. |
| `K` | Flag | **Keep current XY for probing.** If present, saves current X/Y position before homing and probes at that position instead of bed center (0,10). Used for adaptive mesh center re-homing. |

### Callers

| Caller | Call |
|--------|------|
| sys/bed.g (before leveling) | `M98 P"homez.g" L1 S1 C1` |
| sys/bed.g (with `param.Z`) | `M98 P"homez.g" L1 S1 Z1 C1` |
| sys/bed.g (after leveling) | Various: `L1 S1 Z1 F1 T1`, `L1 S1 F1 T1`, `S1 Z1 F1 T1`, etc. |
| sys/mesh.g (adaptive center) | `M98 P"homez.g" Z1 S1 F1 T1 K1` |
| sys/mesh.g (bed center) | `M98 P"homez.g" Z1 S1 F1 T1` |

---

## sys/bed.g

Bed leveling (G32 equivalent).

| Param | Type | Purpose |
|-------|------|---------|
| `Z` | Flag | **Skip initial Z lift in `homez.g`.** Passed through to `homez.g` as `Z1`. |
| `L` | Flag | **Skip probe placement in `homez.g`.** Passed through to `homez.g` as `L1`. Also skips final parking move. |
| `S` | Flag | **Skip final park move.** If absent, executes parking move `G1 X{min} U{max} Y150 Z100 F18000`. Passed through to `homez.g` as `S1`. |

### Callers

| Caller | Call |
|--------|------|
| sys/homeall.g (L+S) | `M98 P"0:/sys/bed.g" L1 S1 Z1` |
| sys/homeall.g (L only) | `M98 P"0:/sys/bed.g" L1 Z1` |
| sys/homeall.g (S only) | `M98 P"0:/sys/bed.g" S1 Z1` |
| sys/homeall.g (neither) | `M98 P"0:/sys/bed.g" Z1` |

> All callers always pass `Z1`. The `L` and `S` flags are conditionally forwarded from `homeall.g`'s own received parameters.

---

## sys/mesh.g

Mesh bed compensation (G29 equivalent).

| Param | Type | Purpose |
|-------|------|---------|
| `A` | Float | **Adaptive mesh: X minimum.** Clamped to ≥ −165. Left boundary of mesh probe grid. |
| `B` | Float | **Adaptive mesh: X maximum.** Clamped to ≤ 155. Right boundary of mesh probe grid. |
| `D` | Float | **Adaptive mesh: Y minimum.** Clamped to ≥ −146. Front boundary of mesh probe grid. |
| `J` | Float | **Adaptive mesh: Y maximum.** Clamped to ≤ 165. Rear boundary of mesh probe grid. |

When all four are present, the mesh grid is computed from print area bounds with automatic point spacing (~30 mm, min 3 points). When absent, defaults to full bed: `M557 X-165:155 Y-146:165 P8`. If adaptive mesh was used, the final Z re-home uses `K1` to probe at the center of the print area.

### Callers

| Caller | Call |
|--------|------|
| sys/initial.g (adaptive) | `M98 P"mesh.g" A{param.A} B{param.B} D{param.D} J{param.J}` |
| sys/initial.g (full bed) | `M98 P"mesh.g"` (no params) |

---

## sys/nozzleprobe.g

Nozzle-contact probing for calibration (touch-off against a reference surface).

| Param | Type | Purpose |
|-------|------|---------|
| `Z` | Float | **Probe Z axis with nozzle contact.** The value encodes both tool and direction: `abs(Z) < 5` → T0 (X-axis sweeps), `abs(Z) > 5` → T1 (U-axis sweeps). Common values: `Z1` = T0 Z probe, `Z10` = T1 Z probe. |
| `Y` | Float | **Probe Y axis with nozzle contact.** Sign determines approach direction. `abs(Y) < 5` → T0, `abs(Y) > 5` → T1. |
| `X` | Float | **Probe X/U axis with nozzle contact.** Sign determines approach direction. `abs(X) < 5` → T0 (X movement), `abs(X) > 5` → T1 (U movement). |

> **Note:** Currently only `Z` is used by callers. `X` and `Y` probing exists in the code but has no active callers.

### Callers

| Caller | Call |
|--------|------|
| Z - Offset Calibration | `M98 P"0:/sys/nozzleprobe.g" Z1` (T0 Z reference) |
| XY - Offset Calibration | `M98 P"0:/sys/nozzleprobe.g" Z1` (T0) and `Z10` (T1) |
| Tool Height Auto Calibration | `M98 P"0:/sys/nozzleprobe.g" Z1` (T0) and `Z10` (T1) |
| XY Auto Squaring | `M98 P"0:/sys/nozzleprobe.g" Z10` (T1 Z datum) |
| Mesh Bed calibration | `M98 P"0:/sys/nozzleprobe.g" Z1` (T0 Z reference) |

---

## sys/nozzlewipe.g

Nozzle cleaning on the brush station.

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Restore position after wipe.** Saves current position with `G60 S0` before wiping, returns to it afterward with Z+2 mm clearance. |
| `T` | Integer (0/1) | **Override target tool.** Temporarily activates the specified tool for wiping. Restores original tool afterward. Without this, uses `state.currentTool`. |
| `W` | Flag | **Wait for temperature.** If present and current tool temp is below active target, waits for temperature with `M116 S10`. |
| `E` | Float (mm) | **Extrude filament before wiping.** Extrudes the specified amount at F180 before the brush cleaning cycle. Prompts user for temp if nozzle is cold (<160°C). |
| `L` | Flag | **Skip straight wipe passes.** If present, skips the 1st cleaning loop (straight left-to-right brush passes). |
| `C` | Integer | **Enable ramp cleaning.** If present, performs the 2nd cleaning loop (ramp/zigzag pattern across brush with fine stepping). |

### Callers

| Caller | Call |
|--------|------|
| sys/initial.g (startup clean) | `M98 P"0:/sys/nozzlewipe.g" C1 W1` |
| sys/initial.g (startup purge) | `M98 P"0:/sys/nozzlewipe.g" E50 W1` |
| sys/tpost0.g (tool change) | `M98 P"0:/sys/nozzlewipe.g" T0 W1` |
| sys/tpost1.g (tool change) | `M98 P"0:/sys/nozzlewipe.g" T1 W1` |
| sys/resume.g | `M98 P"0:/sys/nozzlewipe.g" E50 W1 C5` |
| sys/periodic_wipe_check.g | `M98 P"0:/sys/nozzlewipe.g" C5 W1 E20` |
| sys/baseload.g | `M98 P"0:/sys/nozzlewipe.g"` (no params) |
| sys/baseunload.g | `M98 P"0:/sys/nozzlewipe.g"` (no params) |
| macros/Auto Calibration | `M98 P"0:/sys/nozzlewipe.g" C1` and `L1 C1` |
| AutoCal macros | `M98 P"0:/sys/nozzlewipe.g" T0` or `T1` |
| QC/Tests/Nozzle & Purge | `M98 P"0:/sys/nozzlewipe.g" T0 C1` and `T1 C1` |

---

## sys/baseload.g

Filament loading sequence.

| Param | Type | Purpose |
|-------|------|---------|
| `C` | Non-zero integer | **Change mode.** Shows "Preparing to load filament" message and does NOT turn off heaters at the end. Used during filament change sequences. |
| `R` | Non-zero integer | **Ramp mode.** When set along with `param.T`, extrudes filament slowly while heater temperature ramps down to `param.T`, instead of one large extrusion. Used for transitioning between filaments with large temperature differences. |
| `T` | Float (°C) | **Set nozzle temperature.** Sets current tool's active and standby temp via `M568 P{tool} S{param.T} R{param.T}`. |
| `S` | Flag | **Slow load speed.** Sets extrusion speed to 100 mm/min instead of default 300 mm/min. Used for flexible filaments (TPU). |

### Callers

| Caller | Call |
|--------|------|
| sys/filament_change.g | `M98 P"0:/sys/baseload.g" C1` |
| macros/System/Filament/Change Filament | `M98 P"0:/sys/baseload.g" T{temp} C1` |
| macros/System/Filament/Change Filament (ramp) | `M98 P"0:/sys/baseload.g" T{temp} C1 R1` |
| filaments/TPU (FLEX)/load.g | `M98 P"0:/sys/baseload.g" S1` |
| filaments/*/load.g (all others) | `M98 P"0:/sys/baseload.g"` (no params) |

---

## sys/baseunload.g

Filament unloading sequence.

| Param | Type | Purpose |
|-------|------|---------|
| `C` | Non-zero integer | **Change mode.** Shows "Preparing to unload" message. Does NOT turn off heaters at the end. |
| `T` | Float (°C) | **Set nozzle temperature.** Sets current tool's active and standby temp. |
| `S` | Flag | **Slow unload speed.** Sets retraction speed to 200 mm/min instead of default 1200 mm/min. Used for flexible filaments (TPU). |

### Callers

| Caller | Call |
|--------|------|
| sys/filament_change.g | `M98 P"0:/sys/baseunload.g" C1` |
| macros/System/Filament/Change Filament | `M98 P"0:/sys/baseunload.g" T{temp} C1` |
| filaments/TPU (FLEX)/unload.g | `M98 P"0:/sys/baseunload.g" S1` |
| filaments/*/unload.g (all others) | `M98 P"0:/sys/baseunload.g"` (no params) |

---

## sys/filament_change.g

Mid-print filament change handler (triggered by M600 or filament runout).

| Param | Type | Purpose |
|-------|------|---------|
| `A` | Flag | **Auto-change mode.** If present, skips the "Change filament now?" confirmation dialog and proceeds directly to unload/load cycle. |

### Callers

Called automatically by RepRapFirmware's event system (M600 or filament sensor runout). No `M98` callers in the codebase.

---

## sys/filament-error.g

Filament sensor error handler (RRF event).

| Param | Type | Purpose |
|-------|------|---------|
| `D` | Integer (0/1) | **Extruder number that triggered the error.** Passed automatically by RepRapFirmware 3.4+. `0` = extruder 0 (T0/Left), `1` = extruder 1 (T1/Right). Only pauses if the triggered extruder matches the active tool. |

### Callers

Called automatically by RepRapFirmware when a filament monitoring error occurs. The `param.D` is provided by the firmware itself.

---

## sys/attachedcheck.g

Checks if the Z probe is physically attached (safety relay).

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Leave safety relay active.** If absent, turns off the safety relay (`M42 P4 S0`) at the end. If present, keeps the relay on so probing can continue immediately. |

> **Note:** In RRF, `M98 R1 P"file"` passes `R1` as both the M98 return-value parameter AND as `param.R` to the called macro. This is intentional dual-purpose usage in this firmware.

### Callers

| Caller | Call |
|--------|------|
| sys/homez.g | `M98 R1 P"0:/sys/attachedcheck.g"` (3 call sites) |
| sys/bed.g | `M98 R1 P"0:/sys/attachedcheck.g"` |
| sys/mesh.g | `M98 R1 P"0:/sys/attachedcheck.g"` |
| AutoCal macros | `M98 R1 P"0:/sys/attachedcheck.g"` (Mesh Bed, Z-Offset, Tool Height) |

---

## sys/end.g

Print end handler.

| Param | Type | Purpose |
|-------|------|---------|
| `A` | *(commented out)* | **HEPA fan RPM check (disabled).** Was intended to check `param.A > 10` and warn about HEPA filter fan RPM difference. Currently commented out. |

### Callers

Called automatically by RepRapFirmware at print end. No params currently passed.

---

## macros/Save Current Z - Offset

User-facing macro to save the current Z babystep offset.

| Param | Type | Purpose |
|-------|------|---------|
| `S` | Flag | **Silent/scripted mode.** If present AND currently printing, saves Z-offset immediately rather than deferring to print end via `resetzbabystep.g`. |

### Callers

No `M98` callers — run manually from the DWC interface.

---

## macros/System/Filament/Cold Pull

Cold pull cleaning procedure.

| Param | Type | Purpose |
|-------|------|---------|
| `A` | Float (°C) | **Filament temperature (auto mode).** If present, skips user prompts for tool selection and temperature — uses `state.currentTool` and `param.A` as the printing temperature. |
| `C` | Flag | **Skip initial Z lowering.** If absent, moves bed down by 100 mm (`G1 Z100 F6000`). If present, skips this move. |

### Callers

| Caller | Call |
|--------|------|
| macros/System/Filament/Change Filament | `M98 P"0:/macros/System/Cold Pull" A{var.previous_tooltemp}` |
| macros/System/Filament/Change Filament | `M98 P"0:/macros/System/Cold Pull" A{var.intermediate_temp}` |

---

## macros/System/Calibration/Steps per mm Mode

Toggle steps-per-mm calibration mode.

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Force enable.** Forces `global.stepscal = false` before toggling (result is always `true`/enabled). Suppresses user notification dialog. Used for programmatic initialization. |

### Callers

No `M98` callers passing `R` — user-facing macro.

---

## macros/System/Calibration/XY Squaring/Toggle Mode

Toggle XY squaring compensation mode between auto and manual.

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Force enable auto mode.** Forces `global.xy_square_mode = "manual"` before toggling (result is always "auto"). Suppresses the "Run Auto Calibration Now?" prompt. |

### Callers

No `M98` callers passing `R` — user-facing macro.

---

## Network Macros

Three network configuration macros share the same `param.R` pattern:

### Enable Ethernet Mode

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Quick-save mode.** Writes `M552 I0 S1` to `0:/user/networkmode.g` and immediately returns. Skips all UI, testing, and configuration prompts. |

### Enable WiFi - Access Point Mode

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Quick-save mode.** Writes `M552 I1 S2` to `0:/user/networkmode.g` and immediately returns. |

### Enable WiFi - Client Mode

| Param | Type | Purpose |
|-------|------|---------|
| `R` | Flag | **Quick-save mode.** Writes `M552 I1 S1` to `0:/user/networkmode.g` and immediately returns. |

### Callers (all three)

| Caller | Call |
|--------|------|
| Self (recursive for "Save Mode") | `M98 P"0:/macros/System/Settings/Network/Enable ..." R1` |
| sys/networktest.g | `M98 P"0:/macros/System/Settings/Network/Enable Ethernet Mode" R1` |
| sys/networktest.g | `M98 P"0:/macros/System/Settings/Network/Enable WiFi - Client Mode" R1` |
| macros/Reset Network Settings | `M98 P"0:/macros/System/Settings/Network/Enable WiFi - Access Point Mode" R1` |

---

## AutoCal Macros

Five auto-calibration macros share the same `param.A` authorization gate pattern:

- `macros/System/Calibration/QC/AutoCal/Z - Offset Calibration`
- `macros/System/Calibration/QC/AutoCal/XY - Offset Calibration`
- `macros/System/Calibration/QC/AutoCal/Tool Height Auto Calibration`
- `macros/System/Calibration/QC/AutoCal/Mesh Bed calibration`
- `macros/System/Calibration/QC/AutoCal/XY Auto Squaring`

| Param | Type | Purpose |
|-------|------|---------|
| `A` | Flag | **Authorization gate.** Must exist or the macro aborts with "Use Auto Calibration macro". Prevents users from running calibration sub-steps independently — they must be invoked from the parent `Auto Calibration` macro. |

### Callers

| Caller | Call |
|--------|------|
| macros/Auto Calibration | `M98 P"...Tool Height Auto Calibration" A1` |
| macros/Auto Calibration | `M98 P"...Z - Offset Calibration" A1` |
| macros/Auto Calibration | `M98 P"...Mesh Bed Calibration" A1` |
| macros/Auto Calibration | `M98 P"...XY Auto Squaring" A1` |
| macros/Auto Calibration | `M98 P"...XY - Offset Calibration" A1` |
| Tool Height Auto Calibration (self) | `M98 P"...Tool Height Auto Calibration" A1` (recursive after adjustment) |

---

## Parameter Letter Summary

| Letter | Files Using It | Common Meaning |
|--------|---------------|----------------|
| **A** | initial.g, mesh.g, filament_change.g, Cold Pull, 5× AutoCal macros, end.g (commented) | Adaptive mesh X-min / auto-authorization flag / filament temp |
| **B** | initial.g, mesh.g | Adaptive mesh X-max |
| **C** | homez.g, nozzlewipe.g, baseload.g, baseunload.g, Cold Pull | Skip slow probe / ramp clean / change mode / skip Z lower |
| **D** | initial.g, mesh.g, filament-error.g | Adaptive mesh Y-min / extruder number (RRF event) |
| **E** | initial.g, nozzlewipe.g | Tool selection / extrude amount (mm) |
| **F** | homez.g | Skip fast probe |
| **J** | initial.g, mesh.g | Adaptive mesh Y-max |
| **K** | homez.g | Keep current XY for probing |
| **L** | homey.g, homeall.g, homez.g, bed.g, nozzlewipe.g | Skip Z lower / skip placement / skip straight wipe |
| **N** | homey.g, homeall.g | Skip LED reset |
| **R** | attachedcheck.g, nozzlewipe.g, baseload.g, network macros (×3), Steps per mm, Toggle Mode | Leave relay on / restore position / ramp mode / quick-save / force-enable |
| **S** | homeall.g, homez.g, bed.g, baseload.g, baseunload.g, Save Z-Offset | Skip park/lift / slow speed / silent mode |
| **T** | homey.g, homez.g, nozzlewipe.g, baseload.g, baseunload.g | Store test data / skip probe test / tool override / set temperature |
| **W** | initial.g, nozzlewipe.g | Skip bed wait / wait for nozzle temp |
| **X** | nozzleprobe.g | X-axis nozzle contact probe |
| **Y** | nozzleprobe.g | Y-axis nozzle contact probe |
| **Z** | homez.g, bed.g, nozzleprobe.g | Skip Z lift / Z-axis nozzle contact probe |
