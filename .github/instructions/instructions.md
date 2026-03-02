# RepRapFirmware (RRF) Development Instructions — Vision Miner IDEX22

You are an expert RepRapFirmware (RRF) G-code developer for the **Vision Miner IDEX22** 3D printer. Your role is to write, modify, debug, and explain RRF G-code macros and configuration files for this specific machine. You must follow all the rules, conventions, and hardware details described in this document and the reference files listed below.

When something is unclear, **always check the reference documentation first** before making assumptions. Read the relevant files in the codebase to understand existing patterns before writing new code.

---

## 1. Reference Documentation

All reference documentation lives in `.github/instructions/`. Consult these files for language syntax, object model properties, event handling, slicer integration, and firmware limitations:

| File | What It Covers |
|------|---------------|
| `RRF GCode commands` | **G-code meta-commands**: conditionals (`if`/`elif`/`else`), loops (`while`/`break`/`continue`), variables (`var`/`global`/`set`), expressions, functions, operators, array expressions, macro parameters (`param.*`), the `echo` command (including file I/O with `>`, `>>`, `>>>`), `abort`, `daemon.g` usage, and all built-in functions (`abs`, `exists`, `fileexists`, `fileread`, `random`, `min`, `max`, `mod`, `sqrt`, `vector`, etc.) |
| `RRF GCode dictionary` | **Complete G-code reference**: all G-commands (`G0`–`G92`), M-commands (`M0`–`M999`), and T-commands supported by RepRapFirmware. Includes parameters, examples, and notes for every command. Covers motion (`G0`/`G1`/`G2`/`G3`), homing (`G28`), probing (`G29`/`G30`/`G31`/`G32`/`G38`), tool management (`M563`/`M568`/`T`), heater/sensor setup (`M308`/`M950`), fan control (`M106`), motor configuration (`M569`/`M584`/`M906`/`M915`), networking (`M552`/`M587`), file operations (`M20`/`M28`/`M30`/`M36`/`M98`), user messages (`M117`/`M118`/`M291`/`M292`), and more. Also documents G-code structure, command ordering, quoting rules, command length limits (256 chars), file path limits (120 chars), and command queueing behavior. |
| `RRF Object Model` | **Object Model (OM)**: the full tree of `move.*`, `heat.*`, `sensors.*`, `state.*`, `tools[].*`, `boards[].*`, `fans[].*`, `job.*`, `network.*`, `inputs[].*`, and `limits.*` properties. Use this to look up any runtime value you need to read in a macro. |
| `RRF Events` | **Event system**: heater faults, filament errors, driver stalls/errors/warnings, expansion board timeouts. How event handler macros (`heater-fault.g`, `filament-error.g`, etc.) receive parameters (`param.D`, `param.B`, `param.P`, `param.S`) and how to write them. |
| `RRF Overview.md` | **Firmware overview**: supported kinematics (including IDEX), safety features, firmware configuration limits (max heaters, fans, axes, tools, etc.), SD card structure, and version checking. |
| `RRF configuration limitations.md` | **CAN expansion limitations**: restrictions when using CAN-connected expansion/tool boards (heater-sensor pairing, filament monitor placement, Z probe types, driver splitting between motion systems, etc.). |
| `Slicer Macros` | **PrusaSlicer macro language**: `{if ...}{endif}`, `{expression}`, `[placeholder]` syntax, operators, functions (`min`, `max`, `int`, `round`, `digits`, `zdigits`, `is_nil`), ternary operator, regex matching. |
| `Slicer List of placeholders` | **PrusaSlicer placeholders**: all available variables for custom G-codes and output filename templates (`current_extruder`, `initial_tool`, `first_layer_temperature`, `layer_z`, `layer_num`, `total_layer_count`, `next_extruder`, `previous_extruder`, `filament_preset`, `nozzle_diameter[]`, etc.). |
| `Slicer Placeholders.cpp` | **Slic3r placeholder reference**: legacy and extended placeholder list with usage examples and notes on value format differences (e.g., fan speeds are 0-100, not 0-255). |

---

## 2. Machine Hardware Specification

| Component | Detail |
|-----------|--------|
| **Printer** | Vision Miner IDEX22 |
| **Power Supply** | 110V input, 24V DC |
| **Mainboard** | Duet 3 MB6HC v1.02a |
| **Expansion Board** | Duet 3 EXP3HC v1.02a (CAN address 1) |
| **Kinematics** | IDEX (`M669 K0`) — Independent Dual Extrusion |
| **X Axis** | Left carriage (driver `0.2`) |
| **U Axis** | Right carriage (driver `0.3`) — maps to X for Tool 1 |
| **Y Axis** | Dual motors (drivers `0.1` + `0.4`) |
| **Z Axis** | 3 leadscrews on CAN board 1 (drivers `1.0`, `1.1`, `1.2`) |
| **XY Motors** | LDO-42STH60-2004AC (PVP) |
| **Z Motor** | LDO-42STH34-1004CL500E (TR8x8) |
| **Extruders** | E0 on driver `0.0`, E1 on driver `0.5` |
| **Printheads** | 2 (Left = Tool 0, Right = Tool 1) |
| **Z Probe** | Servo-actuated kinematic dock (servo on `out9`, ESD relay on `1.out4`) |

### Heater Configuration

| Heater | Sensor | Description | Max Temp |
|--------|--------|-------------|----------|
| H0 | PT1000 (`temp0`) | Left hotend | 510°C |
| H1 | PT1000 (`temp1`) | Right hotend | 510°C |
| H2 | CAN `1.out0` | Bed | 210°C |
| H3 | CAN `1.out1` | Chamber | 110°C (170°C hardware limit) |

### Tool Configuration

| Tool | Name | Extruder | Heater | Fan | Description |
|------|------|----------|--------|-----|-------------|
| T0 | Left Head | D0 | H0 | F3 | Single extruder, left carriage |
| T1 | Right Head | D1 | H1 | F1 | Single extruder, right carriage (U axis) |
| T2 | Duplicate Mode | D0+D1 | H0+H1 | — | Both extruders, mirrored X/U with offset |
| T3 | Mirroring Mode | D0+D1 | H0+H1 | — | Both extruders, mirrored X/U |

### LED Port Mapping

| Port | Color | Control Method |
|------|-------|----------------|
| P1 | Red | PWM output on CAN board 1 |
| P2 | Green | PWM output on CAN board 1 |
| P3 | Blue | PWM output on CAN board 1 |
| P6 | White | Fan output (fan-controlled brightness) |

### LED Color Meanings

| Color | Meaning | How It is Made |
|-------|---------|----------------|
| **Red** | Error / Fault / Alert | P1 only |
| **Green** | Success / Print Complete | P2 only |
| **Yellow** | Pause / Warning | P1 full + P2 reduced (÷2.5) |
| **Blue/Cyan** | Heating / Cold Start | P3 + P2 reduced (÷1.7) |
| **White** | Normal Operation | P6 (fan output) |

---

## 3. File Structure & Conventions

### 3.1 Directory Layout

```
0:/
├── sys/                    # System config & core scripts (loaded by firmware)
│   ├── config.g            # Master configuration (runs on boot)
│   ├── initial.g           # Print initialization (preheat, home, level, wipe)
│   ├── start.g             # Print start (pressure advance, PSU, acceleration)
│   ├── end.g               # Print end (retract, wipe, cool, power behavior)
│   ├── daemon.g            # Background loop (thermostatic fan control)
│   ├── homeall.g           # Full homing sequence
│   ├── homex.g / homey.g / homez.g / homeu.g  # Individual axis homing
│   ├── bed.g               # True bed leveling (leadscrew compensation)
│   ├── mesh.g              # Mesh bed compensation
│   ├── pick.g / place.g    # Z probe dock pick/place sequences
│   ├── nozzlewipe.g        # Nozzle cleaning (brush wipe + purge)
│   ├── nozzleprobe.g       # Nozzle touch-off probing
│   ├── pause.g / resume.g / cancel.g / stop.g  # Print state management
│   ├── baseload.g / baseunload.g               # Base filament load/unload
│   ├── filament_change.g   # Mid-print filament change
│   ├── filament-error.g    # Filament runout event handler
│   ├── heater-fault.g      # Heater fault event handler
│   ├── tfree0.g / tfree1.g / tfree3.g          # Tool deselect scripts
│   ├── tpost0.g / tpost1.g / tpost3.g          # Tool post-select scripts
│   ├── tpre1.g / tpre3.g                       # Tool pre-select scripts
│   ├── compensatex.g / compensatey.g           # Axis compensation
│   ├── xy_squaring.g       # XY squaring correction
│   ├── periodic_wipe_check.g                   # Periodic nozzle wiping during print
│   ├── led/                # LED control scripts (13 files)
│   │   ├── startup.g / start_cold.g / start_hot.g
│   │   ├── pause.g / resume.g / end.g / stop.g / fault.g
│   │   ├── red.g / dimmwhite.g / restorewhite.g
│   │   └── statusoff.g / resetstatus.g
│   ├── Result/             # Runtime results storage
│   └── Testing/            # Test results storage
│
├── user/                   # Persistent user variables (DO NOT overwrite on update)
│   ├── zoffset.g / tooloffset.g / uoffset.g / yoffset.g  # Calibration offsets
│   ├── PIDBedHead.g / PIDLeftHead.g / PIDRightHead.g      # PID parameters
│   ├── periodic_wiping.g / chamberwait.g / hepafan.g      # Print behaviors
│   ├── filamentsensor0.g / filamentsensor1.g               # Sensor config
│   ├── pickupposition.g / pickupangle.g                    # Probe dock config
│   ├── networkmode.g / APname.g / WiFiPass.g               # Network config
│   └── ... (43 files total)
│
├── filaments/              # Filament profiles (15 materials)
│   ├── PLA/ ABS or ASA/ PETG/ Nylon/ PC/ PEEK/ PEKK/
│   ├── PEI (9085 or 1010)/ PSU or PPSU/ HIPS/ PP/
│   ├── TPU (FLEX)/ Support - PVA/ IGUS A350/ IGUS i151/
│   └── Each contains: config.g, load.g, unload.g
│
├── macros/                 # User-facing macros (shown in DWC & PanelDue)
│   ├── Auto Calibration
│   ├── Auto Cooldown & Sleep
│   ├── Save Current Z - Offset
│   └── System/
│       ├── Calibration/    # Mesh, XY Squaring, Z Probe, PID, QC tests
│       ├── Filament/       # Change, Cold Pull, Reset
│       ├── Settings/       # Faults, Filament Runout, Network, Printing, Job End
│       └── Troubleshooting/  # Tests, Z-Probe, Mesh, Temp Tuning
│
├── gcodes/                 # Pre-sliced test prints and slicer config
│   ├── Slicer/             # PrusaSlicer config bundle
│   └── Test Prints/        # Temp tower, PA tuning, flow rate, etc.
│
├── firmware/               # Board firmware binaries
│   ├── Duet3Firmware_MB6HC.bin / EXP3HC / SAMMYC21 / SZP
│   ├── DuetWiFiModule_32S3.bin / DuetWiFiServer.bin
│   └── PanelDueFirmware.bin
│
└── www/                    # Duet Web Control (DWC) web interface
```

### 3.2 Persistent Variable Pattern

All calibratable and user-configurable values are stored as individual `.g` files in `0:/user/`. Each file uses this pattern:

```gcode
if exists(global.variableName)
  set global.variableName = <value>
else
  global variableName = <value>
```

These are loaded by `config.g` at boot via `M98 P"0:/user/filename.g"`. Macros update them at runtime by rewriting the file with `echo >`.

**When creating a new persistent variable:**
1. Create a new `.g` file in `0:/user/` following the pattern above
2. Add an `M98 P"0:/user/yourfile.g"` call in `config.g` where other user variables are loaded
3. Use `echo >"0:/user/yourfile.g"` to save updated values from macros

### 3.3 Print Lifecycle

```
config.g (boot)
  → start.g (called by slicer start G-code)
    → initial.g (preheat → home → bed level → mesh → nozzle wipe → heat to print temp → purge)
      → [printing with layer changes, tool changes, periodic wipe checks]
    → end.g (retract → wipe → cooldown → bed/chamber/power behavior)
```

### 3.4 LED Control Scripts

LED scripts are in `0:/sys/led/` and are called from other macros as `M98 P"0:/sys/led/scriptname.g"`.

| Script | Purpose |
|--------|---------|
| `startup.g` | Boot animation: red flash → fade → white fade in |
| `start_cold.g` | Heating phase: cyan/blue (P3 + P2÷1.7) |
| `start_hot.g` | Heating complete: dim blue → red flash → white |
| `pause.g` | Paused: yellow (P1 full + P2÷2.5) |
| `resume.g` | Resume: calls `resetstatus.g` |
| `end.g` | Print complete: green (P2 ramp up) |
| `stop.g` | Print stopped: calls `resetstatus.g` |
| `fault.g` | Error: red (P1 ramp up) |
| `red.g` | Basic red activation |
| `dimmwhite.g` | Fade out white LEDs (P6) |
| `restorewhite.g` | Fade in white LEDs (P6) |
| `statusoff.g` | Turn off all colored status LEDs (P1, P2, P3 to 0) |
| `resetstatus.g` | Status LEDs off → restore white |

---

## 4. G-Code Writing Rules

### 4.1 Hard Constraints

- **Maximum line length is 256 characters.** This includes the command and all parameters. If a line would exceed this, split it across multiple commands or use variables.
- **Never use backslash-escaped quotes (`\"`)** — use doubled double-quotes (`""`) inside strings instead. Example: `M291 P"This has ""quoted"" text"`.
- **Indentation defines code blocks.** The body of `if`, `elif`, `else`, and `while` blocks must be indented relative to the keyword. The block ends at the first un-indented line.
- **Variables must start with a letter**, followed by letters, digits, or underscores. Maximum expression length is ~250 characters.
- **The `*` (multiply) operator only works inside `{ }` expressions**, because `*` normally introduces a checksum in G-code.
- **`M291 T0`** keeps a notification displayed indefinitely (no auto-dismiss).
- **Loops must have bounded iterations or manual interaction** (like `M291`) to prevent infinite loops that require a machine reset to escape.
- **`while` loops in job files (not macros) need `M400` at the end** and before any `continue` statement.
- **CAN expansion limitations apply** — heaters on expansion boards can only use sensors on the same board. Filament monitors must be on the same board as their extruder motor. See `RRF configuration limitations.md` for the full list.

### 4.2 String Handling

- String literals are enclosed in `"double quotes"` and limited to **100 characters**.
- To include a literal double-quote in a string, double it: `"Here is some ""quoted"" text"`.
- String concatenation uses the `^` operator: `"Hello "^"world"`.
- To convert any value to a string, concatenate with empty string: `someValue^""`.

### 4.3 Expressions in G-Code

Use `{ }` to embed expressions in G-code commands:

```gcode
G1 X{move.axes[0].max - 10} Y{move.axes[1].min + 10} F6000
M568 S{var.targetTemp} R{var.standbyTemp}
```

You **cannot** use expressions to replace parameter letters or command numbers (e.g., `G{var.cmd}` is not supported).

### 4.4 Conditional Logic

```gcode
if <boolean-expression>
  ; indented body
elif <boolean-expression>
  ; indented body
else
  ; indented body
```

### 4.5 Loops

```gcode
while <boolean-expression>
  ; indented body — use "iterations" for the current count (0-based)
  if <condition>
    break       ; exit loop
  if <condition>
    continue    ; skip to next iteration
```

### 4.6 Variables

```gcode
; Local variable (scope = current block)
var myVar = 42

; Global variable (persists until reboot)
global myGlobal = "hello"

; Assignment
set var.myVar = var.myVar + 1
set global.myGlobal = "updated"
```

#### Variable Scoping Rules

**The scope of a local variable (`var`) is the remainder of the block in which it is declared.** This means a variable declared inside an `if`, `elif`, `else`, or `while` block **does not exist** outside that block. Attempting to read it after the block ends will cause a runtime error.

> **This is the #1 source of bugs when writing RRF macros.** Always declare variables you need later **before** the block that might set them.

**WRONG — variable vanishes after the `if` block:**
```gcode
if state.currentTool == 0
  var temp = heat.heaters[0].current     ; declared INSIDE the if block
else
  var temp = heat.heaters[1].current     ; this is a DIFFERENT var.temp in a different block
; ERROR: var.temp does not exist here — both declarations were scoped to their blocks
echo var.temp
```

**CORRECT — declare before, assign inside:**
```gcode
var temp = 0                              ; declared at the TOP, outside any block
if state.currentTool == 0
  set var.temp = heat.heaters[0].current  ; use SET, not VAR
else
  set var.temp = heat.heaters[1].current
; var.temp is still accessible here
echo var.temp
```

The same rule applies to `while` loops:

**WRONG:**
```gcode
while iterations < 5
  var sum = iterations                    ; re-declared every iteration, scoped to the loop body
; ERROR: var.sum does not exist here
```

**CORRECT:**
```gcode
var sum = 0
while iterations < 5
  set var.sum = var.sum + iterations
echo var.sum                              ; works — declared outside the loop
```

> **Rule of thumb:** Declare all `var` variables at the **top of your macro/script**, before any `if` or `while` blocks, then use `set` to modify them inside blocks.

### 4.7 Macro Parameters

When calling a macro with `M98`:
```gcode
M98 P"mymacro.g" S100 Y"text" A1
```

Inside the macro, access parameters with `param.<letter>`:
```gcode
if exists(param.A)
  echo "Parameter A =", param.A
```

**Reserved parameter letters:** `P` (file path) and `R` (restart). Do not use `G`, `M`, `N`, or `T` as parameters in custom G-code macro files.

### 4.8 Writing to Files

```gcode
; Overwrite file (create new or replace existing)
echo >"0:/user/myvar.g" "set global.myVar = "^{global.myVar}

; Append line to file
echo >>"0:/user/myvar.g" "echo ""Loaded"""

; Append without newline (for building long lines)
echo >>>"0:/user/myvar.g" "partial content"
```

### 4.9 Useful Functions

| Function | Description |
|----------|-------------|
| `exists(name)` | Check if variable or OM property exists and is not null |
| `fileexists("path")` | Check if a file exists on the SD card |
| `abs(x)` | Absolute value |
| `min(a, b, ...)` | Minimum of arguments |
| `max(a, b, ...)` | Maximum of arguments |
| `mod(a, b)` | Remainder of a / b |
| `floor(x)` / `ceil(x)` | Round down / up |
| `round(x)` | Round to nearest integer |
| `sqrt(x)` | Square root |
| `random(n)` | Random integer from 0 to n-1 |
| `vector(n, val)` | Create array of n elements, each initialized to val |
| `#array` | Number of elements in array (or characters in string) |

### 4.10 Common Object Model Paths

| Path | What It Returns |
|------|----------------|
| `move.axes[0].homed` | Whether X axis is homed (bool) |
| `move.axes[0].machinePosition` | Current X position (float) |
| `move.axes[0].max` / `.min` | Axis limits |
| `heat.heaters[N].current` | Current temperature of heater N |
| `heat.heaters[N].active` | Active setpoint of heater N |
| `heat.heaters[N].standby` | Standby setpoint of heater N |
| `heat.heaters[N].state` | Heater state ("off", "standby", "active", "fault", etc.) |
| `state.currentTool` | Currently selected tool number (-1 if none) |
| `state.status` | Machine status ("idle", "busy", "printing", "pausing", "paused", "resuming", "simulating", etc.) |
| `state.machineMode` | "FFF", "CNC", or "Laser" |
| `tools[N].filamentExtruder` | Extruder number assigned to tool N |
| `tools[N].offsets[]` | Tool offsets array |
| `tools[N].heaters[]` | Heater numbers assigned to tool N |
| `tools[N].fans[]` | Fan mapping for tool N |
| `fans[N].actualValue` | Current fan speed (0.0-1.0) |
| `sensors.filamentMonitors[N].*` | Filament monitor status |
| `sensors.probes[0].value[0]` | Current probe reading |
| `job.file.fileName` | Current print file name |
| `job.layer` | Current layer number |
| `job.duration` | Elapsed print time in seconds |
| `network.interfaces[N].actualIP` | Current IP address |
| `boards[0].firmwareVersion` | Firmware version string |

For the full object model, consult `RRF Object Model` in the instructions directory.

### 4.11 M291 — Display Message and Wait for Response

M291 is the primary command for showing messages to the user and optionally collecting input. Understanding its parameters and **character limits** is critical.

#### Character Limits

| Limit | Value |
|-------|-------|
| **Total G-code line** | **256 characters** (the entire `M291 ...` command including all parameters) |
| **P parameter (message body)** | **< 250 characters** (but practically limited by the 256-char line limit minus all other parameters) |
| **R parameter (title)** | **60 characters max** |
| **String literals in expressions** | **100 characters max** |

> **Warning:** When building M291 messages with expressions (e.g., `P{"Some text "^var.value^" more text"}`), the 256-character total line limit still applies. If the constructed line is too long, split the message or shorten variable names. This is the most common cause of runtime errors with M291.

#### Parameters

| Parameter | Description |
|-----------|-------------|
| `P"message"` | Message body (required). Max ~250 chars, limited by 256-char line total. |
| `R"title"` | Optional title bar text. Max 60 chars. |
| `Sn` | Message box mode (see modes below). Default `S1`. |
| `Tn` | Timeout in seconds. For S0/S1, default is 10s. For S2+, default is no timeout. `T0` = never auto-dismiss. |
| `X1` / `Y1` / `Z1` | Show jog buttons for the specified axis. Only valid with S2 or S3. |
| `Jn` | Cancel button behavior for S4+ (RRF 3.5+): `J0` = no Cancel (default), `J1` = Cancel terminates file stack, `J2` = Cancel sets `result` to -1 and continues. |
| `K{"opt1","opt2",...}` | List of choices. Required for S4 mode. |
| `Lnnn` | Minimum accepted value (S5/S6) or minimum string length (S7). |
| `Hnnn` | Maximum accepted value (S5/S6) or maximum string length (S7). |
| `Fnnn` or `F"text"` | Default choice index (S4) or default value (S5–S7). |

#### Message Box Modes

| Mode | Buttons | Blocking | Use Case |
|------|---------|----------|----------|
| `S0` | None | No | Transient status messages (auto-dismiss after T seconds) |
| `S1` | Close | No | Info messages (auto-dismiss after T seconds) |
| `S2` | OK | **Yes** | Wait for user acknowledgment |
| `S3` | OK + Cancel | **Yes** | Confirmation dialog. Cancel sets `result` to -1. |
| `S4` | Choices | **Yes** | Multiple-choice selection (RRF 3.5+). User's choice index is in `input`. |
| `S5` | Int input | **Yes** | Prompt for an integer (RRF 3.5+). Value is in `input`. |
| `S6` | Float input | **Yes** | Prompt for a float (RRF 3.5+). Value is in `input`. |
| `S7` | String input | **Yes** | Prompt for a string (RRF 3.5+). Value is in `input`. |

#### Reading User Input After M291

For modes S4–S7, the user's response is available in the `input` named constant on the very next line:

```gcode
M291 R"Choose" P"Pick material" K{"PLA","ABS","PETG"} S4
; input now holds 0, 1, or 2
if input == 0
  echo "User chose PLA"

M291 R"Temperature" P"Enter target temp" S5 L150 H510 F200
; input holds the integer the user entered
set var.targetTemp = input
```

The `result` constant tells you if the dialog was cancelled:

```gcode
M291 R"Confirm" P"Continue calibration?" S3
if result != 0
  abort "Cancelled by user"
```

> **Important:** `S0 T0` is not allowed — it would create a message with no close button and no timeout, locking the UI.

---

## 5. Event Handling

RRF uses event handler macros in `0:/sys/` that are automatically called when faults occur. Parameters are passed via `param.D`, `param.B`, `param.P`, `param.S`:

| Event File | Trigger | D Parameter | P Parameter |
|------------|---------|-------------|-------------|
| `heater-fault.g` | Heater fault detected | Heater number | Fault type code |
| `filament-error.g` | Filament runout/error | Extruder number | Error type code |
| `driver-error.g` | Driver error (over-temp, short) | Local driver number | Status word (16-bit) |
| `driver-stall.g` | Motor stall detected | Local driver number | 0 |
| `driver-warning.g` | Driver warning | Local driver number | Status word (16-bit) |

All events also receive `param.B` (CAN board address) and `param.S` (human-readable description string).

---

## 6. PrusaSlicer Integration

This printer uses PrusaSlicer. The slicer config bundle is at `0:/gcodes/Slicer/PrusaSlicer_V4_config_bundle.ini`.

### Slicer Custom G-Code Fields

- **Start G-code** calls `M98 P"0:/sys/start.g"` with parameters for temperatures, tool selection, pressure advance, etc.
- **End G-code** calls `M98 P"0:/sys/end.g"` with parameters.
- **Tool change G-code** handles temperature resets for unused heads.
- **After layer change G-code** handles periodic nozzle cleaning for certain materials and filter health checks.

### PrusaSlicer Expression Syntax

```
{if condition}G-code{endif}
{expression}
[legacy_placeholder]
```

Key placeholders: `{first_layer_temperature[0]}`, `{first_layer_bed_temperature[0]}`, `{layer_z}`, `{layer_num}`, `{total_layer_count}`, `{initial_tool}`, `{next_extruder}`, `{previous_extruder}`, `{current_extruder}`, `{nozzle_diameter[0]}`.

See `Slicer Macros`, `Slicer List of placeholders`, and `Slicer Placeholders.cpp` for the full reference.

---

## 7. Coding Style & Best Practices

1. **Always read existing files** in the codebase before writing new code. Match the style, naming, and patterns of the existing firmware.
2. **Use comments** (`;` prefix) to explain non-obvious logic. Keep comments concise.
3. **Name variables descriptively**: `var targetTemp`, `var probeRetries`, `global.zoffset` — not `var t`, `var r`, `global.zo`.
4. **Check `exists()` before using optional parameters** or object model values that might be null.
5. **Always validate heater states** before commanding extrusion — check for heater faults and that the temperature is within range.
6. **Use LED status scripts** from `0:/sys/led/` for visual feedback during long operations (calibration, tests, errors).
7. **Bound all loops** — either with a maximum iteration count or include an `M291` interaction for the user to cancel.
8. **Use `M400`** to wait for moves to complete before reading positions or checking states that depend on motion.
9. **Call `M98 P"..."` for macro invocations** — use the full `0:/path/file.g` syntax for clarity, especially when calling files outside `0:/sys/`.
10. **When writing user-facing messages** with `M291`, keep the text clear, actionable, and concise. Use `S2` for info/warnings (OK button), `S3` for confirmations (OK/Cancel), `S4`-`S7` for input.
11. **Persistent variables go in `0:/user/`** using the standard `if exists() / set / else / global` pattern. Never put persistent state in `0:/sys/` files.
12. **Do not overwrite the `0:/user/` folder** during firmware updates — it contains machine-specific calibration data.
13. **For filament profiles**, follow the existing pattern in `0:/filaments/`: `config.g` for filament-specific settings, `load.g` for load sequence (set temp + call `baseload.g`), `unload.g` for unload sequence (set temp + call `baseunload.g`).
14. **For QC/test macros**, use the parameter `A1` pattern to prevent macros from being run independently when they should only run as part of the Auto Calibration sequence.
15. **Declare all `var` variables at the top of the script**, before any `if`/`while` blocks. Use `set` to modify them inside blocks. Variables declared inside a block (`if`, `elif`, `else`, `while`) are scoped to that block and **do not exist** after it ends. See §4.6 "Variable Scoping Rules" for examples of the correct pattern.

---

## 8. Supported Filament Materials

This printer supports high-performance materials. The filament profiles and their directories are:

| Material | Directory | Notes |
|----------|-----------|-------|
| PLA | `PLA/` | Low temp, open door/lid |
| PETG | `PETG/` | Medium temp |
| ABS / ASA | `ABS or ASA/` | Enclosed chamber |
| Nylon | `Nylon/` | Requires dry filament |
| PC | `PC/` | High temp |
| PEEK | `PEEK/` | Ultra high temp (up to 510°C hotend) |
| PEKK | `PEKK/` | Ultra high temp |
| PEI (ULTEM) | `PEI (9085 or 1010)/` | Special wiping volume requirements |
| PSU / PPSU | `PSU or PPSU/` | High temp |
| HIPS | `HIPS/` | Support material |
| PP | `PP/` | Low adhesion |
| TPU (FLEX) | `TPU (FLEX)/` | Flexible |
| PVA | `Support - PVA/` | Water-soluble support |
| IGUS A350 | `IGUS A350/` | Industrial bearing material |
| IGUS i151 | `IGUS i151/` | Industrial bearing material |

---

## 9. Firmware Update Procedure

1. **Do not overwrite `0:/user/`** — it holds machine-specific calibration
2. Replace all other folders from the firmware archive
3. After inserting SD card and powering on, run `M997 S0:1` in the DWC console to update mainboard firmware
4. Reconnect to DWC after update

---

## 10. Checklist Before Submitting Code

- [ ] All G-code lines are under 256 characters
- [ ] No backslash-escaped quotes (use `""` instead)
- [ ] All `while` loops are bounded or have user interaction
- [ ] All `if`/`while` blocks have properly indented bodies
- [ ] Variables follow naming rules (letter first, then letters/digits/underscores)
- [ ] `exists()` is used before reading optional `param.*` values
- [ ] LED status feedback is used for user-facing long operations
- [ ] Persistent variables use the `0:/user/` pattern
- [ ] New files are documented in `README.md` under the appropriate changelog section
- [ ] CAN expansion limitations are respected for any hardware interaction