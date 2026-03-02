On this page you can find a list of Slic3r placeholders or variables that can be used in the custom gcode settings

You can use multiple placeholders at a time:

M109 T[next_extruder] S[first_layer_temperature_[next_extruder]] would generate something like M109 T1 S190

note that the values from the Slic3r GUI are used and not values your firmware will expect.

Useful place holders

bed_temperature

M140 S[bed_temperature]

note: It will always take the value of the filament loaded in extruder_0

current_extruder

 M104 S[first_layer_temperature_[current_extruder]]

note: this will not work in start gcode as the [current_extruder] placeholder is filled with the number of the last used extruder, which is nothing at startup and random at any other slicing job

first_layer_temperature

M104 S[first_layer_temperature_0]  M104 S[first_layer_temperature_[next_extruder]]

first_layer_bed_temperature

 M140 S[first_layer_bed_temperature]

note: It will always take the value of the filament loaded in extruder_0

layer_num

M117 printing layer [layer_num]

layer_z

M117 printing layer [layer_num] at [layer_z]mm

total_layer_count

M117 printing layer {layer_num+1}/[total_layer_count]

next_extruder

 M104 S[first_layer_temperature_[next_extruder]]

note: this only works in tool change gcode

previous_extruder

 M104 S[first_layer_temperature_[previous_extruder]]

note: this only works in tool change gcode

temperature

M109 S[temperature_0] M109 S[temperature_[previous_extruder]]

Additional placeholders in the output file template

print_time

normal_print_time

silent_print_time

used_filament

extruded_volume

total_cost

total_weight

total_wipe_tower_cost

total_wipe_tower_filament

Less usefull place holders

avoid_crossing_perimeters

bed_shape

bottom_solid_layers

bridge_acceleration

bridge_fan_speed

 M106 S[bridge_fan_speed] -> This will put in the actual value (0-100) that was filled in, and not 0-255 .

bridge_flow_ratio

bridge_speed

brim_width

complete_objects

cooling

default_acceleration

disable_fan_first_layers

dont_support_bridges

duplicate_distance

external_fill_pattern

external_perimeter_extrusion_width

external_perimeter_speed

external_perimeters_first

extra_perimeters

extruder_clearance_height

extruder_clearance_radius

extruder_offset

extrusion_axis

extrusion_multiplier

extrusion_width

fan_always_on

fan_below_layer_time

filament_colour

filament_diameter

filament_settings_id

fill_angle

fill_density

fill_pattern

first_layer_acceleration

first_layer_extrusion_width

first_layer_height

first_layer_speed

gap_fill_speed

gcode_arcs

gcode_comments

gcode_flavor

infill_acceleration

infill_every_layers

infill_extruder

infill_extrusion_width

infill_first

infill_only_where_needed

infill_overlap

infill_speed

interface_shells

layer_height

max_fan_speed

 M106 S[max_fan_speed] -> This will put in the actual value (0-100) that was filled in, and not 0-255

max_print_speed

max_volumetric_speed

min_fan_speed

M106 S[min_fan_speed] -> This will put in the actual value (0-100) that was filled in, and not 0-255

min_print_speed

min_skirt_length

notes

nozzle_diameter

octoprint_apikey

octoprint_host

only_retract_when_crossing_perimeters

ooze_prevention

output_filename_format

overhangs

perimeter_acceleration

perimeter_extruder

perimeter_extrusion_width

perimeters

perimeter_speed

 G1 F[perimeter_speed] -> This will put in the actual value (mm/sec) that was filled in, and not mm/min

post_process

pressure_advance

print_settings_id

printer_settings_id

raft_layers

resolution

retract_before_travel

retract_layer_change

retract_length

retract_length_toolchange

retract_lift

retract_lift_above

retract_lift_below

retract_restart_extra

retract_restart_extra_toolchange

retract_speed

seam_position

serial_port

serial_speed

skirt_distance

skirt_height

skirts

slowdown_below_layer_time

small_perimeter_speed

solid_infill_below_area

solid_infill_every_layers

solid_infill_extruder

solid_infill_extrusion_width

solid_infill_speed

spiral_vase

standby_temperature_delta

support_material

support_material_angle

support_material_contact_distance

support_material_enforce_layers

support_material_extruder

support_material_extrusion_width

support_material_interface_extruder

support_material_interface_layers

support_material_interface_spacing

support_material_interface_speed

support_material_pattern

support_material_spacing

support_material_speed

support_material_threshold

thin_walls

threads

top_infill_extrusion_width

top_solid_infill_speed

top_solid_layers

travel_speed

use_firmware_retraction

use_relative_e_distances

use_volumetric_e

vibration_limit

wipe

xy_size_compensation

z_offset