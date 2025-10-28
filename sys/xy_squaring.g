if exists(global.xy_square_offset)
  G90
  G1 Y0 F6000
  M400
  G4 S2
  M584 Y0.4
  G91
  G1 Y{-global.xy_square_offset} F150   ; Crossbar Alignment
  M400
  M584 Y0.1
  G1 Y{global.xy_square_offset} F150   ; Crossbar Alignment
  M400
  M584 Y0.1:0.4
  G90
