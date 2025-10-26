; Adjust tool change retraction and extrusion distances/feedrates

M291 R"Tool Change Settings" P"Select tool to adjust" S3 K{"Tool 0","Tool 1"} F0
if result = -1
  abort "Operation cancelled"

var toolIndex = input
var toolLabel = var.toolIndex == 0 ? "Tool 0" : "Tool 1"

M291 R"Tool Change Settings" P"Select parameter to adjust" S3 K{"Retraction","Extrusion"} F0
if result = -1
  abort "Operation cancelled"

var isRetraction = (input == 0)
var distance = 0.0
var distanceGlobal = ""

if var.isRetraction
  M291 R{var.toolLabel^" Retraction"} P"Enter retraction distance (mm, positive)" S5 L0.1 H50 J1 F0
  if result = -1
    abort "Operation cancelled"
  set var.distance = -abs(input)

  if var.toolIndex == 0
    set var.distanceGlobal = "tool0RetractDistance"
  else
    set var.distanceGlobal = "tool1RetractDistance"
else
  M291 R{var.toolLabel^" Extrusion"} P"Enter extrusion distance (mm, positive)" S5 L0.1 H50 J1 F0
  if result = -1
    abort "Operation cancelled"
  set var.distance = abs(input)

  if var.toolIndex == 0
    set var.distanceGlobal = "tool0ExtrudeDistance"
  else
    set var.distanceGlobal = "tool1ExtrudeDistance"

var suffix = var.isRetraction ? "retract" : "extrude"
var targetFile = "0:/user/tool" ^ (var.toolIndex == 0 ? "0" : "1") ^ suffix
var summary = var.toolLabel ^ " " ^ (var.isRetraction ? "retraction" : "extrusion")

echo >{var.targetFile} "; "^{var.summary}^" custom value"
echo >>{var.targetFile} "if exists(global."^{var.distanceGlobal}^")"
echo >>{var.targetFile} "  set global."^{var.distanceGlobal}^" = "^{var.distance}
echo >>{var.targetFile} "else"
echo >>{var.targetFile} "  global "^{var.distanceGlobal}^" = "^{var.distance}

M98 P{var.targetFile}

var feedDisplay = var.isRetraction ? "F3000" : "F9000"
M291 R"Tool Change Settings" P{var.summary^" set to E"^var.distance^" "^var.feedDisplay} S2