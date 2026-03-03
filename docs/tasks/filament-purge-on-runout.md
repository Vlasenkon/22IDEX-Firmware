# Task: Add Filament Purge Step to Filament Runout Recovery Flow

**Status:** Implemented (pending testing)  
**Priority:** High  
**Type:** Enhancement  
**Created:** 2026-03-02  
**Branch:** V4-Stable  

---

## Problem

When a filament runout is detected during a print, the current recovery flow pauses the print and (if filament backup is enabled) switches to the backup tool. However, **there is no automated purge step** to flush the old/residual filament out of the hotend before or after loading new filament.

Currently, the user must manually extrude filament repeatedly (clicking extrude ~10 times, extruding ~1 meter total) just to clear the old material before the new filament feeds through cleanly. This is tedious, error-prone, and wastes time.

### Current Flow (filament runout during print)

1. `filament-error.g` detects the runout, sets `global.filamenterror = true`, calls `M25` (pause)
2. `pause.g` runs:
   - Retracts 20mm, lifts Z by 50mm, moves Y to 150
   - Turns off heaters & part cooling
   - If `filamentbackup` is enabled: switches to backup tool and transfers temperatures
   - If `filamentbackup` is disabled: lowers bed to Z420
3. `filament-error.g` resumes after pause returns:
   - If `filamentbackup` is enabled: immediately calls `M24` (resume) — no purge happens
4. If user manually triggers `filament_change.g`, it calls `baseunload.g` and `baseload.g`, but there is still no dedicated purge step for flushing residual filament

### Key files involved

- `sys/filament-error.g` — entry point for runout detection
- `sys/pause.g` — pause handler with filament-error logic
- `sys/filament_change.g` — manual filament change routine
- `sys/baseunload.g` — filament unload helper
- `sys/baseload.g` — filament load helper

---

## Proposed Solution

Add an automated **filament purge step** to the filament runout recovery flow. The sequence should be:

### New Recovery Flow

1. **Detect runout** → pause print (existing behavior)
2. **Prompt user**: "Filament runout detected. Would you like to change the filament?" (existing behavior in `filament_change.g`)
3. **Purge old filament** *(NEW STEP)*:
   - Before loading new filament, extrude **1500mm (1.5 meters)** at **3 mm/s** (F180) to flush all residual/old filament out of the hotend
   - This ensures the nozzle path is fully clear of old material
   - Display a message to the user: "Purging old filament... Please wait." during this operation
   - The purge should happen with the hotend at working temperature
4. **Prompt user to insert new filament**: "Insert new filament and press OK when ready"
5. **Load new filament** (existing `baseload.g` behavior)
6. **Resume print**

### Implementation Details

- **Purge parameters**: `G1 E1500 F180` (1500mm at 3mm/s in relative extruder mode)
  - 1500mm = 1.5 meters of filament extruded
  - F180 = 3mm/s × 60 = 180 mm/min
- The purge should occur **after** the old filament unload and **before** the new filament load prompt
- Consider adding the purge as a dedicated macro (e.g., `sys/filament_purge.g`) for reusability
- The purge should only run during filament-error recovery, not during normal manual filament changes (unless desired)
- Nozzle wipe (`nozzlewipe.g`) should run after the purge to clean extruded material
- User should see clear UI messages throughout the process so they know what is happening

### GCode Reference

```gcode
; Filament purge — flush old material
M291 R"Purging Filament" P"Purging old filament from the hotend. Please wait..." S1 T0
M83                          ; relative extruder mode
G1 E1500 F180                ; extrude 1500mm (1.5m) at 3mm/s
M400                         ; wait for move to complete
M98 P"0:/sys/nozzlewipe.g"   ; wipe nozzle after purge
```

### Where to integrate

The best place to add the purge step is in `sys/filament_change.g`, between the `baseunload.g` call and the "Load New Filament" prompt:

```
Current:
  M98 P"0:/sys/baseunload.g" C1
  M291 R"Load New Filament" P"Insert the new filament..." ...

Proposed:
  M98 P"0:/sys/baseunload.g" C1
  ; --- NEW: Purge old filament ---
  M291 R"Purging Filament" P"Purging old filament from the hotend. Please wait..." S1 T0
  M83
  G1 E1500 F180
  M400
  M98 P"0:/sys/nozzlewipe.g"
  ; --- END purge ---
  M291 R"Load New Filament" P"Insert the new filament..." ...
```

---

## Acceptance Criteria

- [ ] When a filament runout is detected during printing and the user opts to change filament, the old filament is automatically purged (1500mm at 3mm/s) before loading new filament
- [ ] User sees clear status messages during the purge ("Purging old filament...")
- [ ] Nozzle is wiped after purge completes
- [ ] User is prompted to insert new filament only after purge is complete
- [ ] Normal (non-error) filament changes are not affected unless intentionally integrated
- [ ] The purge step works correctly for both T0 and T1 tools

---

## Testing Notes

- Test with both T0 and T1 as the active tool during runout
- Verify the 1.5m purge fully clears old filament in real-world conditions
- Confirm the purge does not interfere with the filament backup (tool-swap) flow
- Ensure the nozzle wipe runs correctly after purge and does not collide with the print

---

## Changes Made

### `sys/filament_change.g` (manual filament change after runout)

Added a purge step **after** `baseunload.g` and **before** the "Load New Filament" prompt:

```gcode
; Purge old/residual filament from the hotend (1.5 m at 3 mm/s)
M291 R"Purging Filament" P"Purging old filament from the hotend (1.5 m at 3 mm/s).<br>Please wait..." S1 T0
M83                          ; relative extruder mode
G1 E1500 F180                ; extrude 1500 mm (1.5 m) at 3 mm/s
M400                         ; wait for purge to complete
M98 P"0:/sys/nozzlewipe.g"   ; wipe nozzle after purge
```

### `sys/filament-error.g` (automatic tool-swap with filament backup)

Added a purge step **after** the pause/tool-swap and **before** auto-resume (`M24`):

```gcode
; Purge old/residual filament from the backup tool hotend (1.5 m at 3 mm/s)
M291 R"Purging Filament" P"Purging residual filament from backup tool before resuming.<br>Please wait..." S1 T0
M83                          ; relative extruder mode
G1 E1500 F180                ; extrude 1500 mm (1.5 m) at 3 mm/s
M400                         ; wait for purge to complete
M98 P"0:/sys/nozzlewipe.g"   ; wipe nozzle after purge
```
