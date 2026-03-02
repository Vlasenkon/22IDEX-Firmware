Introduction
RepRapFirmware is a comprehensive motion control firmware intended primarily for controlling 3D printers, but with applications in laser engraving/cutting and CNC too. Unlike most other 3D printer firmwares, it is targeted only at modern 32-bit processors, not outdated 8-bit processors with limited CPU power. So it is designed to make good use of the power of modern inexpensive ARM processors to implement advanced features.
It is configured with human editable files located on an SD-card plugged into the printer electronics. As such, there is no need for ordinary users to compile the software nor install any development tools.
Innovation
RepRapFirmware was the first open-source firmware to implement significant advances in 3D printing, including:
Model-based heater control and tuning (since RRF 1.15)
Heater feedforward for changes in extrusion rate (since RRF v3.4)
Heater feedforward for changes in cooling fan RPM (since RRF v3.2)
CAN bus-based distributed control system (Duet 3, since RRF v3.0)
Object model of the printer configuration and state, allowing a wide variety of values to be retrieved (since RRF 3.0)
Conditional and looping GCode (since RRF 3.0)
Daemon task (since RRF v3.0)
Heater power compensated for changes in supply voltage (November 2017)
Support for SPI-controlled stepper drivers (August 2016)
Least-squares auto calibration of delta printers (April 2015)
Segmentation-free delta motion (January 2015)
Accurate extruder pressure advance, including retraction before the end of a move when needed (December 2014)
Precise timing of step pulses, even during acceleration (December 2014)
Support for mixing extruders (July 2014)
Kinematics supported
RepRapFirmware supports the following machine kinematics:
Cartesian
CoreXY, CoreXZ, CoreXYU, CoreXYUV
Linear delta, rotary delta
Multiple independent axes (IDEX)
Markforged
Serial SCARA, five-bar parallel SCARA
Hangprinter
Polar
Additionally, RepRapFirmware can support any kinematics for which the movement of each axis is a linear combination of the movement of the motors. The relationship between axis movement and motor movement is defined by a matrix; see GCode M669.
Safety features
RepRapFirmware employs two or three (depending on the microcontroller used) internal watchdogs to guard against dangerous situations such as runaway heating in the event of a firmware crash, by resetting the board and reporting the reset cause. It resets in the following cases:
If the tick interrupt fails to occur, after about 1 second the hardware watchdog timer resets the processor. The reset cause will be "watchdog". Where the microcontroler has a secondary hardware watchdog, the first one is set to go off a little earlier than the main one and attempts to save additional information about the firmware state.
If the task that controls heaters doesn't run for 20 seconds, or the main task doesn't run for 20 seconds, then the processor will be reset. The reset cause will be "heat task stuck" or "stuck in spin loop". (This may be reduced to 5 seconds in RRF 3.5.)
RepRapFirmware builds a model of each heater in your system when you run the corresponding heater tuning. RepRapFirmware uses this model to estimate the expected heating rate. If the actual heating rate falls short of the minimum expected (for example, because the temperature sensor and the heater have become decoupled), RepRapFirmware will turn off that heater and report a heater fault.
Checking firmware versions
To check the RepRapFirmware version in Duet Web Control (v2 and v3), to to Settings > Machine-Specific > General tab:
dwc23_23_settings_03.png
This screen shows settings that are specific for the machine including, in the Electronics section, the Duet board type, firmware version and, if available, WiFi firmware version. It is useful to quote these when posting a request for support on the support forum.
To check the Duet Web Control version, go to Settings > General > General tab:
dwc23_23_settings_01.png
This screen shows the DWC Version, which is also useful to quote when posting a request for support on the support forum.
Checking versions when not on the network yet
If you cannot get onto Duet Web Control yet because the network is not set up, then connect using YAT or another terminal program and send M115 to get a print out of the firmware versions. For example:
M115
FIRMWARE_NAME: RepRapFirmware for Duet 2 WiFi/Ethernet FIRMWARE_VERSION: 3.3 ELECTRONICS: Duet WiFi 1.02 or later FIRMWARE_DATE: 2021-06-15 21:45:03
Installing and Updating Firmware
Duet boards are shipped with RepRapFirmware installed, however users are advised to check the version, if required, to upgrade to the latest stable version. To upgrade firmware, WiFi firmware, in-app programmer and Duet Web Control (and for an explanation of these files) see the Installing and Updating Firmware page.
SD card structure
See the wiki page on the SD card.
Firmware configuration limits
RepRapFirmware has some configuration limits. Note that:
The total system limits are set by the mainboard.
Expansion boards can be configured within the full capabilities of their hardware, subject to the overall system limits.
There are also some firmware configuration limitations with CAN expansion on Duet 3, see CAN expansion limitations.
You can check the configuration limits of the firmware version you are running by opening the 'Object Model' plugin in DWC, and checking the 'limits' section.
The limits depend on firmware version, see relevant tab below. Bold figures indicate change from previous firmware version.
Duet 3 MB6HC/6XD	Duet 3 Mini 5+	Duet 2 WiFi/Ethernet	Notes
MaxSensors	56	56	32	The maximum number of sensors
MaxHeaters	32	32	10	The maximum number of heaters
MaxPortsPerHeater	3	2	2	The maximum number of output ports per heater
MaxMonitorsPerHeater	3	3	3	The maximum number of monitors per heater
MaxBedHeaters	12	4	4	The maximum number of bed heaters
MaxChamberHeaters	8	4	4	The maximum number of chamber heaters
MaxZProbes	8	8	4	The maximum number of probes
MaxGridProbePoints	961	441	441	The maximum number of mesh bed compensation points
MaxGpInPorts	56	56	20	The maximum number of general purpose input ports.
MaxGpOutPorts	64	64	20	The maximum number of general purpose output ports
MaxAxes	30	10	10	The maximum number of movement axes
MaxDriversPerAxis	8	4	6	The maximum number of stepper drivers assigned to one axis
MaxExtruders	20	8	7	The maximum number of extruders
MaxAxesPlusExtruders	32	12	12	The maximum number of axes + extruders
MaxHeatersPerTool	20	2	8	The maximum number of heaters per tool
MaxExtrudersPerTool	12	8	8	The maximum number of extruders per tool
MaxFans	32	32	12	The maximum number of fans
MaxTriggers	32	16	16	The maximum number of triggers
MaxSpindles	4	4	4	Maximum number of configurable spindles
MaxZProbeProgramBytes	8	8	8	Maximum number of bytes in a Z probe program
MaxCanDrivers	30	8		The maximum number of CAN connected stepper drivers
MaxCanBoards	20	8		The maximum number of CAN connected boards
MaxLedStrips	5	5	2	The maximum number of LED strips
Note: Duet 2 Maestro no longer supported in RRF 3.6 and later.
Firmware differences from other firmwares
The Duets run RepRapFirmware. This differs from Marlin, Repetier and other firmwars in a number of ways.
You do not need to build the firmware yourself unless you are a firmware developer. The firmware is supplied as a ready-built binary file. All important configuration parameters are defined within the /sys/config.g file on the on-board SD card, which you can edit either in the web interface, or by moving the on-board SD card to a PC and using an ordinary text editor such as Notepad++. You can also change these parameters on the fly by sending the appropriate G-codes.
The homing behaviour is defined in homing files also on the SD card. Bed probing behaviour is defined in the bed.g file on the on-board SD card. For more details, see Configuring RepRapFirmware for a Cartesian Printer
PID auto tune works differently. The firmware models each heater as a first order process with dead time, and measures the corresponding model parameters for your heater. It uses these parameters to compute two sets of PID values. One is designed to minimise overshoot when heating up to operating temperature. The other is used to give faster response to changes in load, for example when a print cooling fan is turned on or the extrusion rate is changed. The model parameters are also used to compute the expected behaviour of your heater, so that the firmware can better detect deviations from this behaviour that could be symptomatic of dangerous heater faults.
For delta printers, fast auto delta calibration is provided using a least-squares algorithm. The process takes around 30 seconds or less, making it practical to run at the start of every print if you wish.
Firmware updates are normally done over the web interface, with USB used only as a backup.
Nozzle heaters are controlled differently. With RepRapFirmware, you associate heaters and extruder drives to tools (you can have more than one of each used by a tool if you like), you assign active and standby temperatures to each tool's heaters, then you activate the tool. You can have several tools that share the same heaters and extruder drives. Other firmwares have a much more primitive concept of tools and typically consider each heater to be a tool.
Marlin and Repetier use mm/s for some speed values (e.g. in M203) and mm/min for others (e.g. F parameter in G1 commands). RepRapFirmware uses mm/min consistently. Be careful when switching between the two. To convert from one to the other you will either need to multiply or divide by 60. Example 100mm/s = 6000mm/min.
See also Adapting an existing printer to Duet
Printing over USB connection (Octoprint, Cura, Simplify3D, Etc.)
The Duet control board supports printing your gcode files over a USB connection streamed by a gcode sender software like those mentioned in the title. However, there are limitations, including, but not limited to:
Print statistics, such as remaining time estimation, current layer etc, not showing in Duet Web Control or on the LCD display.
Pause print will have to be handled by the GCode sender, and will take longer because all queued moves will have to complete before the pause takes place.
Filament sensors will not function.
Resume after power fail will not function.
Print speed might be limited because some GCode senders can't supply data fast enough over USB, so print time may be extended.
It is strongly recommended that you use the Duet Web Control for machine control and the internal SD card for gcode printing, however, if your application requires printing over USB, such as using the Mosaic Palette, it should work as expected with the above limitations.